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
					if itemstack:get_name() == "default:wood" then
						local n_estrutura = meta:get_string("estrutura")
						
						-- Alterar o status para permitir que seja destruido para ser remontada
						meta:set_string("status", "recon") 
						
						-- Criar casa comunal
						local dist = 6
						-- Caminho do arquivo da estrutura
						local arquivo = modpath.."/estruturas/casa_comunal/casa_comunal_nivel_1.13.mts"

						-- Criar estrutura
						minetest.place_schematic({x=pos.x-dist,y=pos.y,z=pos.z-dist}, arquivo, nil, nil, true)
				
						-- Criar fundamento e configurar
						local pos_novo_fund = pos
						minetest.set_node(pos_novo_fund, {name="sunos:fundamento"})
						local meta_novo_fund = minetest.get_meta(pos_novo_fund)
						meta_novo_fund:set_string("vila", vila) -- Numero da vila
						meta_novo_fund:set_string("tipo", "casa_comunal") -- Numero da vila
						meta_novo_fund:set_string("estrutura", n_estrutura) -- Numero da estrutura
						meta_novo_fund:set_string("dist", dist) -- Distancia centro a borda da estrutra
						meta_novo_fund:set_string("status", "ativa") -- Status da casa comunal
						sunos.contabilizar_blocos_estruturais(pos_novo_fund) -- Armazena quantidade de nodes estruturais

						-- Salvar dados da estrutura no banco de dados da vila
						local dados_casa_comunal = {
							pos = pos_novo_fund, -- Pos do fundamento
							vila = vila, -- Numero da vila
							nivel = 1, -- Nivel da Casa Comunal
						}
						sunos.bd:salvar("vila_"..vila, "casa_comunal", dados_casa_comunal)

						-- Verifica se tem baus na estrutura montada
						local baus = minetest.find_nodes_in_area(
							{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
							{x=pos.x+dist, y=pos.y+15, z=pos.z+dist}, 
							{"sunos:bau_casa_comunal"}
						)

						-- Salva dados da estrutura no bau dela
						for _,pos_bau in ipairs(baus) do
							local meta = minetest.get_meta(pos_bau)
							meta:set_string("vila", vila) -- Numero da vila
							meta:set_string("estrutura", n_estrutura) -- Numero da estrutura
							meta:set_string("pos_fundamento", minetest.serialize(pos_novo_fund)) -- Pos do fundamento
							meta:set_string("infotext", "Bau de Casa Comunal")
						end
				
						itemstack:take_item()
						minetest.chat_send_player(player:get_player_name(), "Casa Comunal restaurada")
					else
						minetest.chat_send_player(player:get_player_name(), "Casa Comunal em decadencia. Coloque um Fundamento de casa comunal para restaurar.")
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
