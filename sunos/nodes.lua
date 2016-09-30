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
	groups = {choppy = 2, oddly_breakable_by_hand = 1},
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
							minetest.chat_send_player(player:get_player_name(), "Casa Comunal reconstruida.")
							itemstack:take_item()
							return itemstack
						else
							-- Retorna mensagem de falha
							minetest.chat_send_player(player:get_player_name(), r)
							return itemstack
						end
						itemstack:take_item()
						minetest.chat_send_player(player:get_player_name(), "Casa Comunal restaurada")
					else
						minetest.chat_send_player(player:get_player_name(), "Casa Comunal em decadencia. Use o kit de reparo.")
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
	
	-- Para desenvolvimento
	on_punch = function(pos, node, player, pointed_thing)
		local meta = minetest.get_meta(pos)
		minetest.chat_send_all("Vila: "..meta:get_string("vila"))
		minetest.chat_send_all("Tipo: "..meta:get_string("tipo"))
		minetest.chat_send_all("Estrutura: "..meta:get_string("estrutura"))
		if meta:get_string("tipo") == "casa_comunal" then
			minetest.chat_send_all("Status: "..meta:get_string("status"))
			if meta:get_string("status") == "destruida" then
				minetest.chat_send_all("Decadencia: "..meta:get_string("tempo").." seg")
			end
		end
	end,
	
	-- Impede explosão
	on_blast = function() end,
})
