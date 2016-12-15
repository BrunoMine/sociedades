--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Bancada dos sunos
  ]]


-- Bancada dos sunos
minetest.register_node("sunos:bancada", {
	description = sunos.S("Bancada dos Sunos"),
	tiles = {"default_wood.png", "default_wood.png", "default_wood.png^sunos_bancada_lado.png",
		"default_wood.png^sunos_bancada_lado.png", "default_wood.png^sunos_bancada_lado.png", "default_wood.png^sunos_bancada_lado.png"},
	paramtype2 = "facedir",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, sunos=1},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, -0.375, 0.375, -0.375}, -- Perna_1
			{0.375, -0.5, -0.5, 0.5, 0.375, -0.375}, -- Perna_2
			{-0.5, -0.5, 0.375, -0.375, 0.375, 0.5}, -- Perna_3
			{0.375, -0.5, 0.375, 0.5, 0.375, 0.5}, -- Perna_4
			{-0.5, 0.375, -0.5, 0.5, 0.5, 0.5}, -- Tampo
			{-0.4375, -0.4375, -0.4375, 0.4375, 0.375, 0.4375}, -- Interior
		}
	},
})

