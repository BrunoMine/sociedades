--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Nodes
  ]]

minetest.register_node("sunos:teste", {
	description = "TESTE SUNOS",
	tiles = {"default_stone.png"},
	is_ground_content = true,
	groups = {cracky=3, stone=1},
	drop = 'default:cobble',
	legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
	on_use = function(itemstack, player, pointed_thing)
		if pointed_thing and pointed_thing.under then
			sunos.criar_vila(pointed_thing.under)
		end
	end,
})
