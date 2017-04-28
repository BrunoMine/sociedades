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
local tempo_verif_npc = 20
-- Distancia (om blocos) que um bau verifica em sua volta para encontrar seu proprio npc
local dist_verif_npc = 10

-- Verificador do npc suno comum 
-- Tempo (em segundos) que um npc demora para verificar se esta perto da pos de seu bau
local tempo_verif_bau = 20
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
	
	local obj = minetest.add_entity(spos, "sunos:npc") -- Cria o mob
	
	-- Salva alguns dados na entidade inicialmente
	if obj then
		local ent = obj:get_luaentity()
		ent.tipo = tipo -- Tipo de npc comum
		ent.temp = 0 -- Temporizador
		ent.loop = 0 -- Numero de loop de temporizador
		ent.vila = vila -- numero da vila
		ent.mypos = pos
		ent.mynode = node.name
		
		-- Retorna a entidade
		return ent
	else
		local pos_string = pos.x.." "..pos.y.." "..pos.z
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
	sunos.npcs.npc.registrados[tipo].on_step = def.on_step
	sunos.npcs.npc.registrados[tipo].on_rightclick = def.on_rightclick
	
	-- Registrar um mob
	mobs:register_mob("sunos:npc", {
		type = "npc",
		passive = false,
		damage = 3,
		attack_type = "dogfight",
		attacks_monsters = true,
		pathfinding = false,
		hp_min = 10,
		hp_max = 20,
		armor = 100,
		collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
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
	
		do_custom = function(self, dtime)
			
			-- Verifica se esta perto do bau de origem
			self.temp = (self.temp or 0) + dtime
			if self.temp >= tempo_verif_bau then
			
				-- Verifica se ainda tem os dados internos
				if not self.tipo then
					self.object:remove()
					return
				end
				
				self.temp = 0
				self.loop = self.loop + 1
			
				-- Verificar se esta perto do bau
				if verif_dist_pos(self.object:getpos(), self.mypos) > dist_verif_npc then
					self.object:remove()
					return
				end
			
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
				if verif_dist_pos(self.object:getpos(), self.mypos) > sunos.npcs.npc.registrados[tipo].max_dist then
					self.object:remove()
					return
				end
				
				-- Realiza procedimento personalizado
				if sunos.npcs.npc.registrados[self.tipo].on_step then
					sunos.npcs.npc.registrados[self.tipo].on_step(self)
				end
			end
		
		end,
	
		-- Clique direito (acessar)
		on_rightclick = function(self, player)
			if sunos.npcs.npc.registrados[self.tipo].on_rightclick then 
				sunos.npcs.npc.registrados[self.tipo].on_rightclick(self, player) 
			end
		end, 
		
		
	})

end
