--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Mob comum das vilas
  ]]


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
		if self.temp then
			self.temp = self.temp + dtime
		else
			self.temp = 14
			self.loop = 0 -- Verifica um numero de loops
		end
		if self.temp >= 15 then
			self.temp = 0
			self.loop = self.loop + 1
			
			-- Verifica se ja tem um bau registrado para esse npc
			if self.registro == nil then
				local pos_node = minetest.find_node_near(self.object:getpos(), 2, {"sunos:bau"})
				
				if pos_node == nil then -- Caso não tenha nenhum bau perto
					self.object:remove()
					return
				end
				
				self.registro = minetest.serialize(pos_node)
			end
			
			-- Verificar se esta perto do bau
			local pos_node = minetest.deserialize(self.registro)
			if verif_dist_pos(self.object:getpos(), pos_node) > 12 then
				self.object:remove()
				return
			end
			
			-- Verifica o se o bau de origem ainda existe
			if self.loop >= 10 then
				self.loop = 0
				
				local node = minetest.get_node(pos_node)
				if node.name ~= "sunos:bau" then
					self.object:remove()
					return
				end
			end 
		end
		
	end,
})

-- Verifica se tem um nps suno comum
local verificar_bau_sunos = function(pos)

	-- Pegar e verificar mobs em uma area
	local r = false
	for  _,obj in ipairs(minetest.get_objects_inside_radius(pos, 8)) do
		local ent = obj:get_luaentity() or {}
		if ent and ent.name == "sunos:npc" then
			r = true
			break
		end
	end
	
	if r == false then
		local node = minetest.get_node(pos)
		local p = minetest.facedir_to_dir(node.param2)
		local spos = {x=pos.x-p.x,y=pos.y+1.5,z=pos.z-p.z}
		minetest.add_entity(spos, "sunos:npc")
	end
end

-- Coloca e verifica o barman
minetest.register_abm({
	nodenames = {"sunos:bau"},
	interval = 60,
	chance = 1,
	action = function(pos)	
		-- Espera alguns segundos para que o mapa seja corretamente carregado
		minetest.after(5, verificar_bau_sunos, pos)
	end,
})
