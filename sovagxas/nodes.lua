--[[
	Mod Sovagxas para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Nodes
  ]]


-- sorteia 4 itens em uma tabela ordenada
local amplitude_de_valores = 0
for _, col in ipairs(sovagxas.itens_bau) do
	col[5] = amplitude_de_valores + 1
	amplitude_de_valores = amplitude_de_valores + col[4]
	col[6] = amplitude_de_valores
end
local sortear_bau = function()
	local sorteado = math.random(1, amplitude_de_valores)
	local itens = {}
	for _, col in ipairs(sovagxas.itens_bau) do
		if col[5] <= sorteado and sorteado <= col[6] then 
			itens[1] = {col[1], math.random(col[2], col[3])}
			break
		end
	end
	local sorteado = math.random(1, amplitude_de_valores)
	for _, col in ipairs(sovagxas.itens_bau) do
		if col[5] <= sorteado and sorteado <= col[6] then 
			itens[2] = {col[1], math.random(col[2], col[3])}
			break
		end
	end
	local sorteado = math.random(1, amplitude_de_valores)
	for _, col in ipairs(sovagxas.itens_bau) do
		if col[5] <= sorteado and sorteado <= col[6] then 
			itens[3] = {col[1], math.random(col[2], col[3])}
			break
		end
	end
	local sorteado = math.random(1, amplitude_de_valores)
	for _, col in ipairs(sovagxas.itens_bau) do
		if col[5] <= sorteado and sorteado <= col[6] then 
			itens[4] = {col[1], math.random(col[2], col[3])}
			break
		end
	end
	return itens
end

-- Bau dos Sovagxas
minetest.register_node("sovagxas:bau", {
	description = "Bau dos Sovagxas",
	tiles = {
		"default_chest_top.png^sovagxas_bau_cima.png", 
		"default_chest_top.png^sovagxas_bau_cima.png", 
		"default_chest_side.png^sovagxas_bau_lado.png",
		"default_chest_side.png^sovagxas_bau_lado.png", 
		"default_chest_side.png^sovagxas_bau_lado.png", 
		"default_chest_front.png^sovagxas_bau_lado.png"},
	paramtype2 = "facedir",
	groups = {choppy=2,oddly_breakable_by_hand=2},
	legacy_facedir_simple = true,
	is_ground_content = false,
	drop = "default:chest",
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("itens", minetest.serialize(sortear_bau()))
		meta:set_string("data", os.date("%Y %m %d %H"))
		meta:set_string("arvore", minetest.serialize({x=0,y=0,z=0}))
		meta:set_string("infotext", "Bau dos Sovagxas")
		local formspec = "size[8,8.5]".. 
				default.gui_bg..
				default.gui_bg_img..
				default.gui_slots..
				"label[0,0;Bau dos sovaxgas]"..
				"list[current_player;main;0,4.25;8,1;]"..
				"list[current_player;main;0,5.5;8,3;8]"..
				default.get_hotbar_bg(0,4.25)
		local itens = minetest.deserialize(meta:get_string("itens"))
		if itens[1] then
			formspec = formspec.."item_image_button[0,1;2,2;"..itens[1][1]..";item1;"..itens[1][2].."]"
		end
		if itens[2] then
			formspec = formspec.."item_image_button[2,1;2,2;"..itens[2][1]..";item2;"..itens[2][2].."]"
		end
		if itens[3] then
			formspec = formspec.."item_image_button[4,1;2,2;"..itens[3][1]..";item3;"..itens[3][2].."]"
		end
		if itens[4] then
			formspec = formspec.."item_image_button[6,1;2,2;"..itens[4][1]..";item4;"..itens[4][2].."]"
		end
		meta:set_string("formspec", formspec)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		local player_inv = sender:get_inventory()
		local itens = minetest.deserialize(meta:get_string("itens"))
		
		if fields.item1 then
			if player_inv:room_for_item("main", itens[1][1].." "..itens[1][2]) then
				player_inv:add_item("main", itens[1][1].." "..itens[1][2])
				itens[1] = false
			else
				minetest.send_chat_player(sender:get_player_name(), "Inventario lotado. Esvazie um pouco.")
			end
		elseif fields.item2 then
			if player_inv:room_for_item("main", itens[2][1].." "..itens[2][2]) then
				player_inv:add_item("main", itens[2][1].." "..itens[2][2])
				itens[2] = false
			else
				minetest.send_chat_player(sender:get_player_name(), "Inventario lotado. Esvazie um pouco.")
			end
		elseif fields.item3 then
			if player_inv:room_for_item("main", itens[3][1].." "..itens[3][2]) then
				player_inv:add_item("main", itens[3][1].." "..itens[3][2])
				itens[3] = false
			else
				minetest.send_chat_player(sender:get_player_name(), "Inventario lotado. Esvazie um pouco.")
			end
		elseif fields.item4 then
			if player_inv:room_for_item("main", itens[4][1].." "..itens[4][2]) then
				player_inv:add_item("main", itens[4][1].." "..itens[4][2])
				itens[4] = false
			else
				minetest.send_chat_player(sender:get_player_name(), "Inventario lotado. Esvazie um pouco.")
			end
		end
		meta:set_string("itens", minetest.serialize(itens))
		
		local formspec = "size[8,8.5]".. 
				default.gui_bg..
				default.gui_bg_img..
				default.gui_slots..
				"label[0,0;Bau dos sovaxgas]"..
				"list[current_player;main;0,4.25;8,1;]"..
				"list[current_player;main;0,5.5;8,3;8]"..
				default.get_hotbar_bg(0,4.25)
		local itens = minetest.deserialize(meta:get_string("itens"))
		if itens[1] then
			formspec = formspec.."item_image_button[0,1;2,2;"..itens[1][1]..";item1;"..itens[1][2].."]"
		end
		if itens[2] then
			formspec = formspec.."item_image_button[2,1;2,2;"..itens[2][1]..";item2;"..itens[2][2].."]"
		end
		if itens[3] then
			formspec = formspec.."item_image_button[4,1;2,2;"..itens[3][1]..";item3;"..itens[3][2].."]"
		end
		if itens[4] then
			formspec = formspec.."item_image_button[6,1;2,2;"..itens[4][1]..";item4;"..itens[4][2].."]"
		end
		if itens[1] == false and itens[2] == false and itens[3] == false and itens[4] == false then 
			formspec = formspec.."label[1.5,1.5;Bau vazio no momento espere ate \nque um sovagxa coloque algo aqui]"
		end
		meta:set_string("formspec", formspec)
	end,
})

-- atualizar baus periodicamente
minetest.register_abm({
	nodenames = {"sovagxas:bau"},
	interval = 600,
	chance = 1,
	action = function(pos)
		local meta = minetest.get_meta(pos)
		
		-- Verificar se arvore ainda existe
		local p_arv = minetest.deserialize(meta:get_string("arvore"))
		local folhas = minetest.find_nodes_in_area(
			{x=p_arv.x-8, y=p_arv.y-3, z=p_arv.z-8}, 
			{x=p_arv.x+8, y=p_arv.y+3, z=p_arv.z+8}, {"default:jungleleaves"})
		if folhas[1] and table.maxn(folhas) < 700 then
			local node = minetest.get_node(pos)
			minetest.set_node(pos, {name="default:chest", param2 = node.param2})
			return true
		end
		
		-- Renovar itens
		if meta:get_string("data") ~= os.date("%Y %m %d %H") then
			meta:set_string("itens", minetest.serialize(sortear_bau()))
			meta:set_string("data", os.date("%Y %m %d %H"))
		end
		
	end,
})

-- Totem Sovagxa
minetest.register_node("sovagxas:totem", {
	description = "Totem Sovagxa",
	tiles = {
		"default_jungletree_top.png", 
		"default_jungletree_top.png", 
		"default_jungletree.png",
		"default_jungletree.png", 
		"default_jungletree.png", 
		"default_jungletree.png^sovagxas_totem.png" -- frente
	},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Totem Sovagxas")
	end,
	on_place = minetest.rotate_node
})

-- Bancada de Trabalho Selvagem
default.crafttable_formspec = -- Inventario da Bancada de Trabalho
	"size[8,9]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"label[1.75,0;Craftador]"..
	"list[current_player;main;0,4.25;8,1;]"..
	"list[current_player;main;0,5.5;8,3;8]"..
	"list[current_player;craft;1.75,0.5;3,3;]"..
	"image[4.85,1.45;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
	"list[current_player;craftpreview;5.75,1.5;1,1;]"..
	default.get_hotbar_bg(0,4.25)
	
minetest.register_node("sovagxas:bancada", { -- Bancada de Trabalho Sovagxa
	description = "Bancada de Trabalho Sovagxa",
	tiles = {"default_junglewood.png"},
	paramtype2 = "facedir",
	paramtype = "light",
	drawtype = "nodebox",
		node_box = {
		type = "fixed",
		fixed = {
			{0.3125, -0.5, -0.375, 0.375, 0.375, -0.25}, -- Perna_1
			{-0.375, -0.5, -0.375, -0.25, 0.375, -0.25}, -- Perna_2
			{0.3125, -0.5, 0.3125, 0.375, 0.375, 0.375}, -- Perna_3
			{-0.4375, -0.5, 0.3125, -0.25, 0.375, 0.4375}, -- Perna_4
			{-0.5, -0.25, -0.25, 0.4375, -0.1875, 0.3125}, -- Gaveta_1
			{-0.25, 0.0625, -0.4375, 0.3125, 0.125, 0.4375}, -- Gaveta_2
			{-0.4375, 0.375, -0.4375, 0.4375, 0.4375, 0.5}, -- Mesa
			{-0.5, -0.1875, 0.0625, 0.5, -0.0625, 0.1875}, -- Objeto_1
			{-0.125, 0.125, -0.4375, -0.0625, 0.1875, 0.5}, -- Objeto_2
			{0, 0.125, -0.5, 0.0625, 0.1875, 0.4375}, -- Objeto_3
			{0.1875, 0.125, -0.5, 0.25, 0.1875, 0.5}, -- Objeto_4
			{-0.3125, 0.4375, -0.25, -0.25, 0.5, 0.375}, -- Base_1
			{-0.125, 0.4375, -0.25, -0.0625, 0.5, 0.375}, -- Base_2
			{0.0625, 0.4375, -0.25, 0.125, 0.5, 0.375}, -- Base_3
			{0.25, 0.4375, -0.25, 0.3125, 0.5, 0.375}, -- Base_4
			{-0.3125, 0.4375, -0.25, 0.3125, 0.5, -0.1875}, -- Base_5
			{-0.3125, 0.4375, -0.0625, 0.3125, 0.5, 0}, -- Base_6
			{-0.3125, 0.4375, 0.125, 0.3125, 0.5, 0.1875}, -- Base_7
			{-0.3125, 0.4375, 0.3125, 0.3125, 0.5, 0.375}, -- Base_8
		}
	},
	groups = {choppy=2,oddly_breakable_by_hand=2},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec",default.crafttable_formspec)
	end,
})
