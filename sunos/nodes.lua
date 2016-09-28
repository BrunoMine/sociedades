--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Nodes
  ]]

-- Bau dos sunos
--[[
	Esse é o node que tem nas casas dos sunos
]]
minetest.register_node("sunos:bau", {
	description = "Bau dos Sunos",
	tiles = {"default_chest_top.png", "default_chest_top.png", "default_chest_side.png",
		"default_chest_side.png", "default_chest_side.png", "default_chest_lock.png"},
	paramtype2 = "facedir",
	groups = {choppy = 2, oddly_breakable_by_hand = 2},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	drop = "default:chest",
})

-- Fundamento dos sunos
--[[
	Esse é o node de fundamento das estruturas dos sunos
]]
minetest.register_node("sunos:fundamento", {
	description = "Fundamento dos Sunos",
	tiles = {"default_tree_top.png^sunos_fundamento.png", "default_tree_top.png", "default_tree.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	drop = "default:tree",
	-- Remover do banco de dados caso o bloco seja removido
	on_destruct = function(pos)
		local meta = minetest.get_meta(pos)
		local tipo = meta:get_string("tipo")
		
		-- Remover do bando de dados
		if tipo == "casa" then -- Casa
			sunos.bd:remover("vila_"..meta:get_string("vila"), "casa_"..meta:get_string("estrutura"))
		elseif tipo == "casa_comunal" then -- Casa Comunal
			sunos.bd:remover("vila_"..meta:get_string("vila"), "casa_comunal")
		elseif tipo == "decor" then -- Decorativo
			sunos.bd:remover("vila_"..meta:get_string("vila"), "decor_"..meta:get_string("estrutura"))
		end
	end,
	-- Para desenvolvimento
	on_punch = function(pos, node, player, pointed_thing)
		local meta = minetest.get_meta(pos)
		minetest.chat_send_all("Vila: "..meta:get_string("vila"))
		minetest.chat_send_all("Tipo: "..meta:get_string("tipo"))
		minetest.chat_send_all("Estrutura: "..meta:get_string("estrutura"))
	end,
	
})
