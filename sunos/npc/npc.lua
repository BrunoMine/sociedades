--[[
	Mod Sunos para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Mob comum das vilas
  ]]

-- Tabela global
sunos.npcs.npc = {}

-- Tabela de tipos de NPCs sunos registrados
sunos.npcs.npc.registrados = {}

-- Variaveis sistematicas

-- Verificador do Bau de sunos
-- Tempo (em segundos) que demora para um bau verificar se tem um suno dele por perto
local tempo_verif_npc = 5--20
-- Distancia (om blocos) que um bau verifica em sua volta para encontrar seu proprio npc
local dist_verif_npc = 10

-- Tempo para bau verificar se deve spawner novo npc
timeout_bau = 5--20

-- Verificador do npc suno comum 
-- Tempo (em segundos) que um npc demora para verificar se esta perto da pos de seu bau
sunos.timer_npc_check = 10
-- A cada quantos loops de verificação do npc ele deve verificar se seu bau ainda existe
local qtd_loops_npc = 3

-- Verificar distancia entre duas pos
local verif_dist_pos = function(pos1, pos2)
	local x = math.abs(math.abs(pos1.x)-math.abs(pos2.x))
	local y = math.abs(math.abs(pos1.y)-math.abs(pos2.y))
	local z = math.abs(math.abs(pos1.z)-math.abs(pos2.z))
	if x > z and x > y then return x end
	if y > x and y > z then return y end
	if z > x and z > y then return z end
	return x or y or z
end

-- Tabelas
local sunos_walkable_nodes = {
	"sunos:carpete_palha",
	"sunos:carpete_palha_nodrop"
}

-- Pegar horario atual em minetest para checkins
sunos.npcs.npc.get_time = function()
	local time = minetest.get_timeofday() * 24
	time = (time) - (time % 1)
	return time
end

-- Spawners
tabela_spawners = {}

-- Tabela de npcs ativos no mundo
--[[
	Essa tabela conecta um determinado hash de npc ao seu objeto,
	caso esteja nulo, o objeto não esta mais carregado ou morreu.
  ]]
sunos.npcs.npc.ativos = {}

-- Verificar se o NPC de um node está ativo
sunos.npcs.is_active = function(npcnode_pos)
	local hash = minetest.get_meta(npcnode_pos):get_string("sunos_npchash")
	if hash ~= "" and sunos.npcs.npc.ativos[hash] and sunos.npcs.npc.ativos[hash]:getpos() then
		return true
	end
	return false
end

-- Spawnar um NPC
sunos.npcs.npc.spawn = function(tipo, vila, npcnode_pos, spos)
	if not tipo then
		minetest.log("error", "[Sunos] tipo nulo (em sunos.npcs.npc.spawn)")
		return false
	end
	if not sunos.npcs.npc.registrados[tipo] then
		minetest.log("error", "[Sunos] tipo invalido (em sunos.npcs.npc.spawn)")
		return false
	end
	if not vila then
		minetest.log("error", "[Sunos] vila nula (em sunos.npcs.npc.spawn)")
		return false
	end
	if not npcnode_pos then
		minetest.log("error", "[Sunos] npcnode_pos nula (em sunos.npcs.npc.spawn)")
		return false
	end
	if not spos then
		minetest.log("error", "[Sunos] faltou coordenada para spawnar (em sunos.npcs.npc.spawn)")
		return false
	end
		
	local obj = minetest.add_entity(spos, "sunos:npc_"..tipo) -- Cria o mob
	
	-- Salva alguns dados na entidade inicialmente
	if obj then
		local ent = obj:get_luaentity()
		ent.tipo = tipo -- Tipo de npc
		ent.temp = 0 -- Temporizador
		ent.loop = 0 -- Numero de loop de temporizador
		ent.vila = vila -- numero da vila
		ent.mypos = npcnode_pos -- pos do npcnode de spawn (bau)
		ent.mynode = minetest.get_node(npcnode_pos).name -- nome do node de spawn (bau)
		ent.sunos_fundamento = minetest.deserialize(minetest.get_meta(npcnode_pos):get_string("pos_fundamento"))
		
		-- Gera um hash numerico com a data e coordenada
		local hash = minetest.pos_to_string(npcnode_pos)..os.date("%Y%m%d%H%M%S")
		
		ent.sunos_npchash = hash -- Salva no npc
		sunos.npcs.npc.ativos[hash] = ent.object -- salva na tabela de npcs ativos
		minetest.get_meta(ent.mypos):set_string("sunos_npchash", hash) -- Salva no bau
		
		-- Flags
		ent.flags["sunos_checkin_status"] = "dentro"
		ent.flags["sunos_target_status"] = "nenhum"
		ent.flags["sunos_repouso_status"] = "nenhum"
		
		-- Finaliza registro nos sunos
		ent.sunos_registrado = true
		
		-- Realiza chamadas que foram impedidas
		-- 'on_spawn'
		if sunos.npcs.npc.registrados[tipo].on_spawn then
			sunos.npcs.npc.registrados[tipo].on_spawn(ent)
		end
		
		-- Retorna a entidade
		return ent
	else
	
		return false
	end
	
end


-- Envia o npc para o checkin
--[[
    Retorna true se conseguir enviar ação
    Retorna false se nao conseguir
  ]]
sunos.npcs.npc.send_to_checkin = function(self)
	if not self or not self.object or not self.object:getpos() then return end
	
	local pos1 = sunos.copy_tb(self.object:getpos())
	local pos2 = sunos.copy_tb(self.sunos_checkin[tostring(sunos.npcs.npc.get_time())])
	local cmds = 0
	local dist = sunos.p1_to_p2(pos1, pos2)
	
	while (dist >= 15) do
		local pos_indo = sunos.ir_p1_to_p2(pos1, pos2, 7)
		
		-- Escolher caminho
		-- 1º Rua calcetada
		local alvo = minetest.find_node_near(pos_indo, 4, {"sunos:rua_calcetada"}, true)
		-- 2º Gramado
		if not alvo then
			alvo = minetest.find_node_near(pos_indo, 4, {"default:dirt_with_grass"}, true)
		end
		
		if alvo then
			if alvo then alvo.y = alvo.y+1 end
		end
		
		if alvo then
			-- Atualiza numero do comando
			cmds = cmds + 1 
			-- Salva o local para andar
			npc.locations.add_shared_accessible_place(
				self, 
				{owner="", node_pos=alvo}, 
				"sunos_npc_walk_"..cmds, 
				true,
				{}
			)
			npc.programs.execute(self, "advanced_npc:walk_to_pos", {
				end_pos = "sunos_npc_walk_"..cmds,
				walkable = {}
			})
		end
		
		-- Atualiza para proximo loop
		pos1 = sunos.copy_tb(pos_indo)
		dist = sunos.p1_to_p2(pos1, pos2)
	end
	
	if cmds > 0 then 
		return true
	else
		return false
	end
end

-- Envia o npc durmir
--[[
    Retorna true se conseguir enviar ação
    Retorna false se nao conseguir
  ]]
sunos.npcs.npc.send_to_bed = function(self, pos)
	if not self or not self.object or not self.object:getpos() then return end
	
	local pos1 = sunos.copy_tb(self.object:getpos())
	local pos2 = sunos.copy_tb(pos)
	local cmds = 0
	local dist = sunos.p1_to_p2(pos1, pos2)
	
	while (dist > 6) do
	
		local pos_indo = sunos.ir_p1_to_p2(pos1, pos2, 7)
		
		-- Escolher caminho
		-- 1º Rua calcetada
		local alvo = minetest.find_node_near(pos_indo, 4, {"sunos:rua_calcetada"}, true)
		-- 2º Gramado
		if not alvo then
			alvo = minetest.find_node_near(pos_indo, 4, {"default:dirt_with_grass"}, true)
		end
		-- 3º Carpete da casa
		if not alvo then
			alvo = minetest.find_node_near(pos_indo, 4, {"sunos:carpete_palha", "sunos:carpete_palha_nodrop"}, true)
			if alvo then alvo.y = alvo.y-1 end
		end
		
		if alvo then
			if alvo then alvo.y = alvo.y+1 end
		end
		
		if alvo then
			-- Atualiza numero do comando
			cmds = cmds + 1 
			-- Salva o local para andar
			npc.locations.add_shared_accessible_place(
				self, 
				{owner="", node_pos=alvo}, 
				"sunos_npc_walk_target_"..cmds, 
				true,
				{}
			)
			npc.exec.enqueue_program(self, "advanced_npc:walk_to_pos", {
				end_pos = "sunos_npc_walk_target_"..cmds,
				walkable = sunos_walkable_nodes,
			})
		else
			-- Impossivel avançar em direção ao alvo (sem caminho)
			break
		end
		
		-- Atualiza para proximo loop
		pos1 = sunos.copy_tb(pos_indo)
		dist = sunos.p1_to_p2(pos1, pos2)
	end
	
	-- Certifica que dist foi atualizada (caso o loop tenha interrompido antes)
	dist = sunos.p1_to_p2(pos1, pos2)
	
	-- Se for chegar na cama, durmir
	if dist <= 6 then
		npc.exec.enqueue_program(self, "advanced_npc:walk_to_pos", {
			end_pos = {
				place_type="bed_primary", 
				use_access_node=true
			}
		})
		npc.exec.enqueue_program(self, "advanced_npc:use_bed", {
			pos = "bed_primary",
			action = npc.programs.const.node_ops.beds.LAY
		})
		npc.exec.enqueue_program(self, "advanced_npc:idle", 
			{
				acknowledge_nearby_objs = false,
				wander_chance = 0
			},
			{},
			true
		)
	end
	
	
	if cmds > 0 or dist <= 6 then 
		return true
	else
		return false
	end
end

-- Instrução para manter deitado
npc.programs.instr.register("sunos:definir_deitado", function(self, args)
	local node = minetest.get_node(args.pos)
	local dir = minetest.facedir_to_dir(node.param2)
	local bed_pos = npc.programs.instr.nodes.beds[node.name].get_lay_pos(args.pos, dir)
	-- Sit down on bed, rotate to correct direction
	npc.programs.instr.execute(self, npc.programs.instr.default.SIT, {pos=bed_pos, dir=(node.param2 + 2) % 4})
	npc.programs.instr.execute(self, npc.programs.instr.default.LAY, {})
end)

-- Registrar um NPC
sunos.npcs.npc.registrar = function(tipo, def)
	if not tipo then
		minetest.log("error", "[Sunos] Tipo de npc invalido (em sunos.registrar_npc)")
		return false
	end
	if not def then
		minetest.log("error", "[Sunos] Tabela def nula (em sunos.registrar_npc)")
		return false
	end
	
	-- Cria o registro na tabela global
	sunos.npcs.npc.registrados[tipo] = def
	
	-- Registrar um mob
	mobs:register_mob("sunos:npc_"..tipo, {
		type = "npc",
		passive = false,
		damage = 3,
		attack_type = "dogfight",
		attacks_monsters = true,
		pathfinding = false,
		hp_min = 10,
		hp_max = 20,
		armor = 100,
		collisionbox = {-0.35,0.0,-0.35, 0.35,1.8,0.35},
		visual = "mesh",
		mesh = "character.b3d",
		drawtype = "front",
		textures = {
			{"sunos_npc_male.png"},
			{"sunos_npc_female.png"},
		},
		makes_footstep_sound = true,
		sounds = {},
		walk_velocity = 2,
		run_velocity = 3,
		jump = true,
		drops = def.drops,
		water_damage = 0,
		lava_damage = 2,
		light_damage = 0,
		view_range = 15,
		owner = "",
		order = "follow",
		fear_height = 3,
		animation = {
			speed_normal = 30,
			speed_run = 30,
			stand_start = 0,
			stand_end = 79,
			walk_start = 168,
			walk_end = 187,
			run_start = 168,
			run_end = 187,
			punch_start = 200,
			punch_end = 219,
		},
		
		
		on_spawn = function(self)
		
			if self.initialized == nil then
				npc.initialize(self, self.object:getpos(), true)
				self.tamed = false
			end
			
			-- Verifica se já está registrado
			if self.sunos_registrado == true and sunos.npcs.npc.registrados[tipo].on_spawn then
				sunos.npcs.npc.registrados[tipo].on_spawn(self)
			end
			
			-- Verifica se está durmindo
			if self.npc_state.movement.is_laying == true then
				local target = sunos.copy_tb(npc.locations.get_by_type(self, "bed_primary")[1])
				if not target or not target.pos then
					minetest.chat_send_all("g")
					self.object:remove()
					return
				end
				npc.programs.instr.execute(self, "sunos:definir_deitado", {pos=target.pos})
			end
			
		end,
		
		-- Atualiza dados com tabela de NPCs ativos
		after_activate = function(self, staticdata, def, dtime)

			-- Verifica se está registrado
			if self.sunos_registrado == true then
				
				-- Verifica se é o npc atual de seu node
				local node = sunos.pegar_node(self.mypos) -- Certifica que carregou no node
				if minetest.get_meta(self.mypos):get_string("sunos_npchash") ~= self.sunos_npchash then
					minetest.chat_send_all("s")
					self.object:remove()
					return
				else
					-- Atualiza tabela de npcs ativos
					sunos.npcs.npc.ativos[self.sunos_npchash] = self.object
				end
				
				-- Realiza procedimento personalizado
				if sunos.npcs.npc.registrados[tipo].after_activate then
					sunos.npcs.npc.registrados[tipo].after_activate(self, staticdata, def, dtime)
				end
			end
		end,
	
		do_custom = function(self, dtime)
			
			if not self.tipo then
				minetest.chat_send_all("c")
				self.object:remove()
				return
			end
								
			-- Verifica se esta perto do bau de origem
			self.temp = (self.temp or 0) + dtime
			if self.temp >= sunos.timer_npc_check then
				
				-- Verifica se é o npc atual de seu node
				if not sunos.npcs.npc.ativos[self.sunos_npchash] 
					or not sunos.npcs.npc.ativos[self.sunos_npchash]:getpos() 
				then
					-- Esse NPC ja está ativo em outro objeto
					minetest.chat_send_all("z")
					self.object:remove()
					return					
				end
				
				local def_npc = sunos.npcs.npc.registrados[self.tipo]
				
				self.temp = 0
				self.loop = self.loop + 1
			
				-- Verifica o se o bau de origem possui seu hash
				if self.loop >= qtd_loops_npc then
					self.loop = 0
					
					local node = sunos.pegar_node(self.mypos) -- Certifica que carregou no node
					if minetest.get_meta(self.mypos):get_string("sunos_npchash") ~= self.sunos_npchash then
						minetest.chat_send_all("k")
						self.object:remove()
						return
					end
				end 
				
				-- Verifica se algum dos jogadores proximos é um inimigo
				if self.state ~= "attack" then -- Verifica se ja não está em um ataque
					for _,obj in ipairs(minetest.get_objects_inside_radius(self.object:getpos(), 13)) do
						if obj:is_player() then
						
							-- Verifica se o jogador é inimigo
							if sunos.verif_inimigo(self.vila, obj:get_player_name()) == true then
								self.attack = obj
								self.state = "attack"
								return npc.step(self, dtime)
							end
					
						end
					end
				end
				
				-- Verificiar se deve ir para o checkin atual
				if sunos.p1_to_p2(
					self.object:getpos(), 
					sunos.copy_tb(self.sunos_checkin[tostring(sunos.npcs.npc.get_time())])) > 10 
				then
					minetest.chat_send_all("enviando")
					npc.exec.enqueue_program(self, "sunos:walk_to_checkin", {
						end_pos = sunos.copy_tb(self.sunos_checkin[tostring(sunos.npcs.npc.get_time())]),
						dist_min = 10,
					})
				end
				
				-- Verifica se deve ir durmir
				
				if self.flags["sunos_repouso_status"] == "durmir" then
					local target = sunos.copy_tb(npc.locations.get_by_type(self, "bed_primary")[1])
					if not target or not target.pos then
						minetest.chat_send_all("b")
						self.object:remove()
						return
					end
					
					-- Verifica se ja esta durmindo 
					if self.npc_state.movement.is_laying ~= true
						or sunos.p1_to_p2(self.object:getpos(), target.pos) > 2
					then
						local caminho = sunos.npcs.npc.send_to_bed(self, target.pos)
						
						-- Impossivel andar ate o local destino
						if caminho == false then
							minetest.chat_send_all("f")
							self.object:remove()
							return
						end
					end
					
					self.flags["sunos_repouso_status"] = "nenhum"
					
				end
				
				-- Realiza procedimento personalizado
				if def_npc.on_step_timed then
					def_npc.on_step_timed(self)
				end
			end
			
			-- Realiza procedimento personalizado
			if sunos.npcs.npc.registrados[self.tipo].on_step then
				sunos.npcs.npc.registrados[self.tipo].on_step(self, dtime)
			end
			
			return npc.step(self, dtime)
		
		end,
	
		-- Clique direito (acessar)
		on_rightclick = function(self, player)
			if sunos.npcs.npc.registrados[self.tipo].on_rightclick then 
				sunos.npcs.npc.registrados[self.tipo].on_rightclick(self, player) 
			end
		end, 
		
	})
	
	
end


