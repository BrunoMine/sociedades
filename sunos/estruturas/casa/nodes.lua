--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Nodes para criar fundamentos
  ]]

-- Tradução de strings
local S = sunos.S


-- Fundamento de casa pequena
minetest.register_node("sunos:fundamento_casa_pequena", {
	description = S("Fundamento Suno de Casa Pequena"),
	tiles = {"default_tree_top.png^sunos_fundamento.png", "default_tree_top.png", "default_tree.png"},
	inventory_image = "sunos_fundamento_fundo_inv.png^sunos_fundamento_casa_inv.png",
	wield_image = "sunos_fundamento_estrutura_namao.png^sunos_fundamento_casa_namao.png",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	stack_max = 1,
	
	-- Colocar uma casa
	on_place = function(itemstack, placer, pointed_thing)
		
		local pos = pointed_thing.under
		
		local r, vila = sunos.estruturas.casa.verif(pos, 2, nil, true, true)
		
		if r == true then
			
			-- Coloca rua em torno
			sunos.colocar_rua(pos, 2)
			
			-- Coloca fundamento step para construir estrutura
			minetest.set_node(pointed_thing.under, {name="sunos:fundamento_step"})
			local meta = minetest.get_meta(pos)
			meta:set_string("tipo", "casa")
			meta:set_string("dist", 2)
			meta:set_string("versao", sunos.versao)
			meta:set_string("vila", vila)
			meta:set_string("step", 1)
			meta:set_string("data_inicio", minetest.get_day_count())
			meta:set_string("tempo_inicio", minetest.get_timeofday())
			meta:set_string("duracao", 24000) -- 1 dia no jogo
			meta:set_string("schem", sunos.pegar_arquivo(5, "casa"))
			meta:set_string("rotat", sunos.pegar_rotat())
			meta:set_string("itens_repo", minetest.serialize(sunos.estruturas.casa.gerar_itens_repo["2"]()))
			minetest.get_node_timer(pos):set(0.1, 0) -- Inicia temporizador
			
			-- Retorna mensagem de montagem concluida
			minetest.chat_send_player(placer:get_player_name(), S("Casa sendo construida"))
			itemstack:take_item()
			return itemstack
			
		else
			-- Mostra area a ser usada
			sunos.criar_caixa_de_area(pos, 2+1)
			-- Retorna mensagem de falha
			minetest.chat_send_player(placer:get_player_name(), r)
			return itemstack
		end
	end,
})

-- Fundamento de casa mediana
minetest.register_node("sunos:fundamento_casa_mediana", {
	description = S("Fundamento Suno de Casa Mediana"),
	tiles = {"default_tree_top.png^sunos_fundamento.png", "default_tree_top.png", "default_tree.png"},
	inventory_image = "sunos_fundamento_fundo_inv.png^sunos_fundamento_casa_inv.png",
	wield_image = "sunos_fundamento_estrutura_namao.png^sunos_fundamento_casa_namao.png",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	stack_max = 1,
	
	-- Colocar uma casa
	on_place = function(itemstack, placer, pointed_thing)
		
		local pos = pointed_thing.under
		
		local r, vila = sunos.estruturas.casa.verif(pos, 3, nil, true, true)
		
		if r == true then
			
			-- Coloca rua em torno
			sunos.colocar_rua(pos, 3)
			
			-- Coloca fundamento step para construir estrutura
			minetest.set_node(pointed_thing.under, {name="sunos:fundamento_step"})
			local meta = minetest.get_meta(pos)
			meta:set_string("tipo", "casa")
			meta:set_string("dist", 3)
			meta:set_string("versao", sunos.versao)
			meta:set_string("vila", vila)
			meta:set_string("step", 1)
			meta:set_string("data_inicio", minetest.get_day_count())
			meta:set_string("tempo_inicio", minetest.get_timeofday())
			meta:set_string("duracao", 36000) -- 1,5 dias no jogo
			meta:set_string("schem", sunos.pegar_arquivo(7, "casa"))
			meta:set_string("rotat", sunos.pegar_rotat())
			meta:set_string("itens_repo", minetest.serialize(sunos.estruturas.casa.gerar_itens_repo["3"]()))
			minetest.get_node_timer(pos):set(0.1, 0) -- Inicia temporizador
			
			-- Retorna mensagem de montagem concluida
			minetest.chat_send_player(placer:get_player_name(), S("Casa sendo construida"))
			itemstack:take_item()
			return itemstack
			
		else
			-- Mostra area a ser usada
			sunos.criar_caixa_de_area(pos, 3+1)
			-- Retorna mensagem de falha
			minetest.chat_send_player(placer:get_player_name(), r)
			return itemstack
		end
	end,
})



-- Fundamento de casa grande
minetest.register_node("sunos:fundamento_casa_grande", {
	description = S("Fundamento Suno de Casa Grande"),
	tiles = {"default_tree_top.png^sunos_fundamento.png", "default_tree_top.png", "default_tree.png"},
	inventory_image = "sunos_fundamento_fundo_inv.png^sunos_fundamento_casa_inv.png",
	wield_image = "sunos_fundamento_estrutura_namao.png^sunos_fundamento_casa_namao.png",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	stack_max = 1,
	
	-- Colocar uma casa
	on_place = function(itemstack, placer, pointed_thing)
		
		local pos = pointed_thing.under
		
		local r, vila = sunos.estruturas.casa.verif(pos, 4, nil, true, true)
		
		if r == true then
			
			-- Coloca rua em torno
			sunos.colocar_rua(pos, 4)
			
			-- Coloca fundamento step para construir estrutura
			minetest.set_node(pointed_thing.under, {name="sunos:fundamento_step"})
			local meta = minetest.get_meta(pos)
			meta:set_string("tipo", "casa")
			meta:set_string("dist", 4)
			meta:set_string("versao", sunos.versao)
			meta:set_string("vila", vila)
			meta:set_string("step", 1)
			meta:set_string("data_inicio", minetest.get_day_count())
			meta:set_string("tempo_inicio", minetest.get_timeofday())
			meta:set_string("duracao", 48000) -- 2 dias no jogo
			meta:set_string("schem", sunos.pegar_arquivo(9, "casa"))
			meta:set_string("rotat", sunos.pegar_rotat())
			meta:set_string("itens_repo", minetest.serialize(sunos.estruturas.casa.gerar_itens_repo["4"]()))
			minetest.get_node_timer(pos):set(0.1, 0) -- Inicia temporizador
			
			-- Retorna mensagem de montagem concluida
			minetest.chat_send_player(placer:get_player_name(), S("Casa sendo construida"))
			itemstack:take_item()
			return itemstack
			
		else
			-- Mostra area a ser usada
			sunos.criar_caixa_de_area(pos, 4+1)
			-- Retorna mensagem de falha
			minetest.chat_send_player(placer:get_player_name(), r)
			return itemstack
		end
	end,
})


