--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
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

-- Configurar schekin
sunos.npcs.npc.set_checkin = function(self, lugar, inicio, fim)
	if inicio > fim then return end
	for h=inicio, fim do
		self.sunos_checkin[h] = sunos.copy_tb(lugar)
	end
	
	-- Atualiza dados do bau
	minetest.get_meta(self.mypos):set_string("checkin_npc", minetest.serialize(self.sunos_checkin))
end
local set_checkin = sunos.npcs.npc.set_checkin

-- Spawners
tabela_spawners = {}

-- Tabela de npcs ativos no mundo
--[[
	Essa tabela conecta um determinado hash de npc ao seu objeto,
	caso esteja nulo, o objeto não esta mais carregado ou morreu.
  ]]
sunos.npcs.npc.ativos = {}

-- Spawnar um NPC
sunos.npcs.npc.spawn = function(tipo, vila, pos, spos)
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
	if not pos then
		minetest.log("error", "[Sunos] pos nula (em sunos.npcs.npc.spawn)")
		return false
	end
	if not spos then
		minetest.log("error", "[Sunos] faltou coordenada para spawnar (em sunos.npcs.npc.spawn)")
		return false
	end
	
	-- Verifica o node para spawn
	local node = minetest.get_node(pos)
	if node.name == "air" then
		local pos_string = pos.x.." "..pos.y.." "..pos.z
		minetest.log("error", "[Sunos] nao pode spawnar um NPC baseando-se num node de ar ("..pos_string..") (em sunos.npcs.npc.spawn)")
		return false
	end
	if not node.param2 then
		local pos_string = pos.x.." "..pos.y.." "..pos.z
		minetest.log("error", "[Sunos] faltou param2 no node da coordenada de spawn pretendido ("..pos_string..") (em sunos.npcs.npc.spawn)")
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
		ent.mypos = pos -- pos do node de spawn (bau)
		ent.mynode = node.name -- nome do node de spawn (bau)
		ent.sunos_fundamento = minetest.deserialize(minetest.get_meta(pos):get_string("pos_fundamento"))
		
		-- Gera um hash numerico com a data e coordenada
		local hash = minetest.pos_to_string(pos)
		
		ent.sunos_npchash = hash -- Salva no npc
		sunos.npcs.npc.ativos[hash] = ent.object -- salva na tabela de npcs ativos
		minetest.get_meta(ent.mypos):set_string("npchash", hash) -- Salva no bau
		
		-- Tabela de checkins da agenda
		--[[
			Quando da o horario o NPC se dirige ao local, 
			ao estar la ele volta as atividades que deve fazer la
		  ]]
		ent.sunos_checkin = {}
		set_checkin(ent, ent.sunos_fundamento, 0, 23) -- configura checkin no npc e bau
		
		-- Flags
		ent.flags["sunos_checkin_status"] = "dentro"
		ent.flags["sunos_target_status"] = "nenhum"
		ent.flags["sunos_repouso_status"] = "nenhum"
		
		-- Retorna a entidade
		return ent
	else
		local pos_string = pos.x.." "..pos.y.." "..pos.z
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
	
	-- Remove todas atividades atuais do NPC
	self.actions.queue = {}
	
	local pos1 = sunos.copy_tb(self.object:getpos())
	local pos2 = sunos.copy_tb(self.sunos_checkin[sunos.npcs.npc.get_time()])
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
			npc.places.add_shared_accessible_place(
				self, 
				{owner="", node_pos=alvo}, 
				"sunos_npc_walk_"..cmds, 
				true,
				{}
			)
			npc.add_task(self, npc.actions.cmd.WALK_TO_POS,
				{
					end_pos = "sunos_npc_walk_"..cmds,
					walkable = sunos_walkable_nodes,
				}
			)
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

-- Envia o npc para uma coordenada alvo
--[[
    Retorna true se conseguir enviar ação
    Retorna false se nao conseguir
  ]]
sunos.npcs.npc.send_to_target = function(self, pos)
	if not self or not self.object or not self.object:getpos() then return end
	
	-- Remove todas atividades atuais do NPC
	self.actions.queue = {}
	
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
			npc.places.add_shared_accessible_place(
				self, 
				{owner="", node_pos=alvo}, 
				"sunos_npc_walk_target_"..cmds, 
				true,
				{}
			)
			npc.add_task(self, npc.actions.cmd.WALK_TO_POS,
				{
					end_pos = "sunos_npc_walk_target_"..cmds,
					walkable = sunos_walkable_nodes,
				}
			)
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
	
	-- Remove todas atividades atuais do NPC
	self.actions.queue = {}
	
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
			npc.places.add_shared_accessible_place(
				self, 
				{owner="", node_pos=alvo}, 
				"sunos_npc_walk_target_"..cmds, 
				true,
				{}
			)
			npc.add_task(self, npc.actions.cmd.WALK_TO_POS,
				{
					end_pos = "sunos_npc_walk_target_"..cmds,
					walkable = sunos_walkable_nodes,
				}
			)
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
		npc.add_task(self, npc.actions.cmd.WALK_TO_POS, 
			{
				end_pos = {
					place_type="bed_primary", 
					use_access_node=true
				}
			}
		)
		npc.add_task(self, npc.actions.cmd.USE_BED, 
			{
				pos = "bed_primary",
				action = npc.actions.const.beds.LAY
			}
		)
		npc.add_action(self, npc.actions.cmd.FREEZE, {freeze = true})
	end
	
	
	if cmds > 0 or dist <= 6 then 
		return true
	else
		return false
	end
end


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
	sunos.npcs.npc.registrados[tipo].max_dist = def.max_dist or 10
	
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
			{"sunos_npc.png"},
			{"sunos_npc2.png"},
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
				
				-- Realiza procedimento personalizado
				if def.on_spawn then
					def.on_spawn(self)
				end
			end
			
		end,
		
		-- Atualiza dados com tabela de NPCs ativos
		after_activate = function(self, staticdata, def, dtime)
			
			if not self.sunos_npchash then
				return
			end

			-- Verifica se é o npc atual de seu node
			if not sunos.npcs.npc.ativos[self.sunos_npchash] then
				-- Atualiza tabela de npcs ativos
				sunos.npcs.npc.ativos[self.sunos_npchash] = self.object
			else
				-- Esse NPC ja está ativo em outro objeto
				self.object:remove()
			end
			
			-- Realiza procedimento personalizado
			if sunos.npcs.npc.registrados[tipo].after_activate then
				sunos.npcs.npc.registrados[tipo].after_activate(self, staticdata, def, dtime)
			end
		end,
	
		do_custom = function(self, dtime)
			
			if not self.tipo then
				self.object:remove()
				return
			end
			
			-- Correção do NPC_advanced para tornar NPC em modo de ataque interrompedo qualquer atividade
			if self.state == "attack" then
				-- Interrompe atividades
				if self.actions.current_action_state ~= npc.action_state.interrupted then
					npc.lock_actions(self)
					self.freeze = false
				end
				-- Permite API Mobs Redo controlar ataque
				return true
			end
			if self.actions.current_action_state == npc.action_state.interrupted and self.state ~= "attack" then
				npc.execute_action(self)
			end
			
			-- Verifica se esta perto do bau de origem
			self.temp = (self.temp or 0) + dtime
			if self.temp >= sunos.timer_npc_check then
				
				local def_npc = sunos.npcs.npc.registrados[self.tipo]
				
				self.temp = 0
				self.loop = self.loop + 1
			
				-- Verifica o se o bau de origem ainda existe
				if self.loop >= qtd_loops_npc then
					self.loop = 0
				
					local node = minetest.get_node(self.mypos)
					if node.name ~= self.mynode then
						self.object:remove()
						return
					end
				end 
				
				-- Verificar se está muito longe do bau
				if verif_dist_pos(self.object:getpos(), self.mypos) > def_npc.max_dist then
					self.object:remove()
					return
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
				if self.flags["sunos_checkin_status"] == "fora" then
					if sunos.p1_to_p2(self.object:getpos(), sunos.copy_tb(self.sunos_checkin[sunos.npcs.npc.get_time()])) > 15 then
						self.flags["sunos_checkin_status"] = "dentro"
						local caminho = sunos.npcs.npc.send_to_checkin(self)
						-- Impossivel andar ate o local destino
						if caminho == false then
							self.object:remove()
							return
						end
					else
						-- Ignora pois ja esta perto do edificio
						self.flags["sunos_checkin_status"] = "dentro"
					end
				end
				
				-- Verificar se deve ir para proximo de uma coordenada
				if self.flags["sunos_target_status"] ~= "nenhum" then
					local target = sunos.copy_tb(npc.places.get_by_type(self, self.flags["sunos_target_status"])[1])
					if not target.pos then
					elseif sunos.p1_to_p2(self.object:getpos(), target.pos) > 6 then
						
						local caminho = sunos.npcs.npc.send_to_target(self, target.pos)
						
						self.flags["sunos_target_status"] = "nenhum"
						-- Impossivel andar ate o local destino
						if caminho == false then
							self.object:remove()
							return
						end
					else
						-- Ignora pois ja esta perto do edificio
						self.flags["sunos_target_status"] = "nenhum"
					end
				end
				
				-- Verifica se deve ir durmir
				if self.flags["sunos_repouso_status"] == "durmir" then
					local target = sunos.copy_tb(npc.places.get_by_type(self, "bed_primary")[1])
					
					-- Verifica se ja esta durmindo 
					if self.actions.move_state.is_laying ~= true
						or sunos.p1_to_p2(self.object:getpos(), target.pos) > 2
					then
						local caminho = sunos.npcs.npc.send_to_bed(self, target.pos)
						
						-- Impossivel andar ate o local destino
						if caminho == false then
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
	
	-- Modifica a chamada on_timer do node spawnador
	minetest.override_item(def.node_spawner, {
		on_timer = function(pos, elapsed)
			local meta = minetest.get_meta(pos)
			
			-- Pega a coordenada do fundamento
			local pf = meta:get_string("pos_fundamento")
			if pf == "" then
				minetest.set_node(pos, {name="default:chest", param2=minetest.get_node(pos).param2})
				return
			end
			pf = minetest.deserialize(pf)
			
			-- Verificar se o fundamento ainda existe
			if minetest.get_node(pf).name ~= "sunos:fundamento" then
				minetest.set_node(pos, {name="default:chest", param2=minetest.get_node(pos).param2})
				return
			end
			
			-- Verifica se NPC já está ativo
			local obj = sunos.npcs.npc.ativos[minetest.pos_to_string(pos)]
			if obj and obj:getpos() then
				-- Reinicia o ciclo com um tempo definido
				minetest.get_node_timer(pos):set(timeout_bau, 0)
				return false
			end
			local dist = tonumber(minetest.get_meta(pf):get_string("dist"))
			
			
			-- Spawna NPC na regiao de checkin
			local checkin = meta:get_string("checkin_npc")
			
			-- Ajusta para caso nao tenha checkin
			if checkin ~= "" then
				checkin = minetest.deserialize(checkin)
			else
				checkin = {}
			end
			
			-- Tenta remover resquicio do antigo NPC (evitar existir uma multidão de NPC no local nao carregado)
			if obj then
				obj:remove()
			end
			
			-- Local de checkin
			local pc = checkin[sunos.npcs.npc.get_time()] or pf
			-- Distancia centro a borda para analise
			local pc_dist = tonumber(minetest.get_meta(pc):get_string("dist")) or 6
			
			-- Verifica se a area está carregada
			if minetest.get_node(pc).name == "ignore" then
				minetest.get_voxel_manip():read_from_map(
					{x=pc.x-pc_dist, y=pc.y, z=pc.z-pc_dist},
					{x=pc.x+pc_dist, y=pc.y+14, z=pc.z+pc_dist}
				)
			end
			
			-- Analizar objetos (possiveis npcs) perto
			do
				for i = 0, math.floor(15/pc_dist)-1 do
					for _,obj in ipairs(minetest.get_objects_inside_radius({x=pc.x, y=pc.y+(i*pc_dist), z=pc.z}, dist)) do
					
						-- Evita jogadores por perto para nao spawnar de repente
						if obj:is_player() then
							-- Encerra o procedimento para tentar novamente apos um tempo mais curto
							minetest.get_node_timer(pos):set(5, 0)
							return false
						end
					end
				end
			end
			
			-- Escolher uma coordenada para spawnar
			local spos = {}
			do
				local nok = {} -- tabela de nodes ok 
				-- Pegar nodes de madeira
				local nodes = minetest.find_nodes_in_area(
					{x=pc.x-pc_dist, y=pc.y, z=pc.z-pc_dist}, 
					{x=pc.x+pc_dist, y=pc.y+14, z=pc.z+pc_dist}, 
					def.nodes_spawn or {"sunos:wood_nodrop", "default:stonebrick", "sunos:cobble_nodrop"})
				for _,p in ipairs(nodes) do
					if minetest.get_node({x=p.x, y=p.y+1, z=p.z}).name == "sunos:carpete_palha_nodrop"
						and minetest.get_node({x=p.x, y=p.y+2, z=p.z}).name == "air"
					then
						table.insert(nok, {x=p.x, y=p.y+1.5, z=p.z})
					end
				end
				-- Verifica se achou algum
				if not nok[1] then 
					-- Reinicia o ciclo com um tempo definido
					minetest.get_node_timer(pos):set(timeout_bau, 0)
					return false
				end
				
				-- Sorteia uma coordenada
				spos = nok[math.random(1, table.maxn(nok))]
			end
			
			-- Spawnar um novo npc na casa
			local ent = sunos.npcs.npc.spawn(tipo, minetest.get_meta(pos):get_string("vila"), pos, spos)
			
			-- Reinicia o ciclo com um tempo definido
			minetest.get_node_timer(pos):set(timeout_bau, 0)
			return false -- Evita que repita com um tempo diferente do definido
		end
	})
	
	-- Insere spawner na lista
	table.insert(tabela_spawners, def.node_spawner)
	
	-- LBM para iniciar nodetimer caso ainda nao tenha
	minetest.register_lbm({
		name = "sunos:casa_start_nodetimer",
		nodenames = tabela_spawners,
		run_at_every_load = true,
		action = function(pos, node)
			if minetest.get_node_timer(pos):is_started() == false then
				minetest.get_node_timer(pos):set(2, 0)
			end
		end,
	})
	
end


