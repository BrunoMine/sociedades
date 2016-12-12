--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Nodes
  ]]

-- Caminho do diretório do mod
local modpath = minetest.get_modpath("sunos")

-- Bau dos sunos
--[[
	Esse é o node que tem nas casas dos sunos
]]
minetest.register_node("sunos:bau", {
	description = sunos.S("Bau dos Sunos"),
	tiles = {"default_chest_top.png^sunos_bau_topo.png", "default_chest_top.png", "default_chest_side.png^sunos_bau_lado.png",
		"default_chest_side.png^sunos_bau_lado.png", "default_chest_side.png^sunos_bau_lado.png", "default_chest_lock.png^sunos_bau_frente.png"},
	paramtype2 = "facedir",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory=1},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	drop = "default:chest",
	
	-- Nao pode ser escavado/quebrado por jogadores
	--on_dig = function() end,
})

-- Fundamento dos sunos
--[[
	Esse é o node de fundamento das estruturas dos sunos
]]
minetest.register_node("sunos:fundamento", {
	description = sunos.S("Fundamento dos Sunos"),
	tiles = {"default_tree_top.png^sunos_fundamento.png", "default_tree_top.png", "default_tree.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 1, not_in_creative_inventory=1},
	sounds = default.node_sound_wood_defaults(),
	drop = "default:tree",
	
	-- Nao pode ser escavado/quebrado por jogadores
	on_dig = function() end,
	
	-- Clique direito para restaurar
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)		
		local node = minetest.get_node(pos)
		if node.name == "sunos:fundamento" then
			local meta = minetest.get_meta(pos)
			local vila = meta:get_string("vila")
			local tipo = meta:get_string("tipo")
	
			if tipo == "casa_comunal" then
				if meta:get_string("status") == "destruida" then
					if itemstack:get_name() == "sunos:kit_reparador" then
						local n_estrutura = meta:get_string("estrutura")
						
						-- Obter dados do fundamento
						local nivel = meta:get_string("nivel")
						local n_estrutura = meta:get_string("estrutura")
						
						-- Alterar o status para permitir que seja destruido para ser remontada
						meta:set_string("status", "recon") 
						
						-- Construir casa comunal nova
						local r = sunos.construir_casa_comunal(pos, vila, nivel, n_estrutura, true)
						
						if r == true then
							-- Salvar novo total de estruturas da vila
							sunos.bd:salvar("vila_"..vila, "estruturas", n_estrutura)
			
							-- Retorna mensagem de montagem concluida
							minetest.chat_send_player(player:get_player_name(), sunos.S("Casa Comunal reconstruida"))
							itemstack:take_item()
							return itemstack
						else
							-- Retorna mensagem de falha
							minetest.chat_send_player(player:get_player_name(), r)
							return itemstack
						end
					else
						minetest.chat_send_player(player:get_player_name(), sunos.S("Casa Comunal em decadencia. Use o Kit de Reparo"))
					end
				end
			end
		
		end
	end,
	
	-- Remover do banco de dados caso o bloco seja removido
	on_destruct = function(pos)
		local meta = minetest.get_meta(pos)
		local vila = meta:get_string("vila")
		local tipo = meta:get_string("tipo")
		local dist = meta:get_string("dist")
		
		-- Remover do bando de dados
		if tipo == "casa" then -- Casa
			sunos.montar_ruinas(pos, dist)
			sunos.bd:remover("vila_"..meta:get_string("vila"), "casa_"..meta:get_string("estrutura"))
		elseif tipo == "casa_comunal" then -- Casa Comunal
			local status = meta:get_string("status")
			if status ~= "recon" then
				sunos.montar_ruinas(pos, dist)
				sunos.bd:remover("vila_"..meta:get_string("vila"), "casa_comunal")
			end
		elseif tipo == "decor" then -- Decorativo
			sunos.montar_ruinas(pos, dist)
			sunos.bd:remover("vila_"..meta:get_string("vila"), "decor_"..meta:get_string("estrutura"))
		end
		sunos.atualizar_bd_vila(vila)
	end,
	
	-- Impede explosão
	on_blast = function() end,
})

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
			"label[1.75,0;Craftador]"..
			"list[current_player;main;0,4.25;8,1;]"..
			"list[current_player;main;0,5.5;8,3;8]"..
			"list[current_player;craft;1.75,0.5;3,3;]"..
			"image[4.85,1.45;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
			"list[current_player;craftpreview;5.75,1.5;1,1;]"..
			default.get_hotbar_bg(0,4.25)
		)
	end,
})
