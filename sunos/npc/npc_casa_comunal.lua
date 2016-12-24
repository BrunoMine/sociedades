--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Mob da Casa Comunal
  ]]

-- Variaveis sistematicas

-- Verificador do Bau de sunos
-- Tempo (em segundos) que demora para um bau verificar se tem um suno dele por perto
local tempo_verif_npc = 30
-- Distancia (om blocos) que um bau verifica em sua volta para encontrar seu proprio npc
local dist_verif_npc = 5

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

-- Registrar um NPC
mobs:register_mob("sunos:npc_casa_comunal", {
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
	drops = {
		{name = "default:wood", chance = 1, min = 1, max = 3},
		{name = "default:apple", chance = 2, min = 1, max = 2},
		{name = "default:axe_stone", chance = 5, min = 1, max = 1},
	},
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
		self.temp = self.temp + dtime
		if self.temp >= tempo_verif_bau then
		
			self.temp = 0
			self.loop = self.loop + 1
			
			-- Verificar se esta perto do bau
			if verif_dist_pos(self.object:getpos(), self.registro) > dist_verif_npc then
				self.object:remove()
				return
			end
			
			-- Verifica o se o bau de origem ainda existe
			if self.loop >= qtd_loops_npc then
				self.loop = 0
				
				local node = minetest.get_node(self.registro)
				if node.name ~= "sunos:bau_casa_comunal" then
					self.object:remove()
					return
				end
			end 
		end
		
	end,
	
	-- Clique direito (acessar)
	on_rightclick = function(self, player)
		sunos.acessar_npc(self, player)
	end, 
})

-- Verifica se tem um npc da casa comunal perto do bau
local verificar_bau_casa_comunal = function(pos)
	local meta = minetest.get_meta(pos) -- Pegar os metadados
	local pos_fund = minetest.deserialize(meta:get_string("pos_fundamento")) -- Pegar pos do fundamento
	
	-- Cercifica se esta ativo
	if not pos_fund then return end
	
	-- Verificar se o fundamento ainda existe
	local node_fund = minetest.get_node(pos_fund)
	if node_fund.name ~= "sunos:fundamento" then
		minetest.remove_node(pos)
		return 
	end
	
	-- Pegar e verificar mobs em uma area
	local r = false
	
	for _,obj in ipairs(minetest.get_objects_inside_radius(pos, dist_verif_npc)) do
		local ent = obj:get_luaentity() or {}
		-- Verifica se for mob certo
		if ent.name == "sunos:npc_casa_comunal" then 
			r = true
			break
		end
	end
	
	-- Caso nao encontre o mob cria um novo
	if r == false then
		local node = minetest.get_node(pos)
		local p = minetest.facedir_to_dir(node.param2)
		local spos = {x=pos.x-p.x,y=pos.y+1.5,z=pos.z-p.z}
		local obj = minetest.add_entity(spos, "sunos:npc_casa_comunal") -- Cria o mob
		
		-- Salva alguns dados na entidade inicialmente
		if obj then
			local ent = obj:get_luaentity()
			ent.temp = 0 -- Temporizador
			ent.loop = 0 -- Numero de loop de temporizador
			ent.vila = meta:get_string("vila") -- numero da vila
			ent.registro = pos -- Pos do bau
		end
	end
end

-- Verificar o Bau da Casa Comunal
minetest.register_abm({
	nodenames = {"sunos:bau_casa_comunal"},
	interval = tempo_verif_npc,
	chance = 1,
	action = function(pos)
		verificar_bau_casa_comunal(pos)
	end,
})
