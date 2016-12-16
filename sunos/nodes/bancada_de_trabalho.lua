--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Bancada de trabalho dos Sunos
  ]]


-- Bancada de trabalho dos Sunos
minetest.register_node("sunos:bancada_de_trabalho", {
	description = sunos.S("Bancada de Trabalho dos Sunos"),
	tiles = {"default_wood.png^sunos_bancada_trabalho_topo.png", "default_wood.png", "default_wood.png",
		"default_wood.png", "default_wood.png", "default_wood.png"},
	paramtype2 = "facedir",
	paramtype = "light",
	drawtype = "nodebox",
		node_box = {
		type = "fixed",
		fixed = {
			{0.375, -0.4375, -0.4375, 0.4375, 0.375, 0.4375}, -- Tampo_direito
			{-0.4375, -0.4375, -0.4375, -0.375, 0.375, 0.4375}, -- Tampo_esquerdo
			{-0.4375, -0.4375, 0.375, 0.4375, 0.375, 0.4375}, -- tampo_trazeiro
			{0.3125, -0.5, 0.3125, 0.4375, 0.375, 0.4375}, -- Perna_1
			{-0.4375, -0.5, 0.3125, -0.3125, 0.375, 0.4375}, -- Perna_2
			{0.3125, -0.5, -0.4375, 0.4375, 0.375, -0.3125}, -- Perna_3
			{-0.4375, -0.5, -0.4375, -0.3125, 0.375, -0.3125}, -- Perna_4
			{-0.375, -0.4375, -0.375, 0.375, -0.375, 0.375}, -- Tampo_inferior
			{-0.5, 0.375, -0.5, 0.5, 0.5, 0.5}, -- Tampo_superior
		}
	},
	groups = {choppy=2,oddly_breakable_by_hand=2,sunos=1},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", "size[8,8.2]"..
			default.gui_bg..
			default.gui_bg_img..
			default.gui_slots..
			"label[1.75,0;"..sunos.S("Craftador").."]"..
			"list[current_player;main;0,4.25;8,1;]"..
			"list[current_player;main;0,5.5;8,3;8]"..
			"list[current_player;craft;1.75,0.5;3,3;]"..
			"image[4.85,1.45;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
			"list[current_player;craftpreview;5.75,1.5;1,1;]"..
			default.get_hotbar_bg(0,4.25)
		)
	end,
})
