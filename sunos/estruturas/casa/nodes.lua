--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Nodes para criar fundamentos
  ]]


-- Fundamento de casa pequena
minetest.register_node("sunos:fundamento_casa_pequena", {
	description = sunos.S("Fundamento Suno de Casa Pequena"),
	tiles = {"default_tree_top.png^sunos_fundamento.png", "default_tree_top.png", "default_tree.png"},
	inventory_image = "sunos_inv_fundamento.png^sunos_inv_fundamento_casa.png",
	wield_image = "sunos_inv_fundamento.png^sunos_inv_fundamento_casa.png",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	stack_max = 1,
	
	-- Colocar uma casa
	on_place = function(itemstack, placer, pointed_thing)
		
		local r = sunos.estruturas.casa.construir(pointed_thing.under, 2, nil, nil, sunos.estruturas.casa.gerar_itens_repo["2"]())
		if r == true then
			
			-- Retorna mensagem de montagem concluida
			minetest.chat_send_player(placer:get_player_name(), sunos.S("Casa construida"))
			itemstack:take_item()
			return itemstack
			
		else
			-- Retorna mensagem de falha
			minetest.chat_send_player(placer:get_player_name(), r)
			return itemstack
		end
	end,
})

-- Fundamento de casa mediana
minetest.register_node("sunos:fundamento_casa_mediana", {
	description = sunos.S("Fundamento Suno de Casa Mediana"),
	tiles = {"default_tree_top.png^sunos_fundamento.png", "default_tree_top.png", "default_tree.png"},
	inventory_image = "sunos_inv_fundamento.png^sunos_inv_fundamento_casa.png",
	wield_image = "sunos_inv_fundamento.png^sunos_inv_fundamento_casa.png",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	stack_max = 1,
	
	-- Colocar uma casa
	on_place = function(itemstack, placer, pointed_thing)
		
		local r = sunos.estruturas.casa.construir(pointed_thing.under, 3, nil, nil, sunos.estruturas.casa.gerar_itens_repo["3"]())
		if r == true then
			
			-- Retorna mensagem de montagem concluida
			minetest.chat_send_player(placer:get_player_name(), sunos.S("Casa construida"))
			itemstack:take_item()
			return itemstack
			
		else
			-- Retorna mensagem de falha
			minetest.chat_send_player(placer:get_player_name(), r)
			return itemstack
		end
	end,
})



-- Fundamento de casa grande
minetest.register_node("sunos:fundamento_casa_grande", {
	description = sunos.S("Fundamento Suno de Casa Grande"),
	tiles = {"default_tree_top.png^sunos_fundamento.png", "default_tree_top.png", "default_tree.png"},
	inventory_image = "sunos_inv_fundamento.png^sunos_inv_fundamento_casa.png",
	wield_image = "sunos_inv_fundamento.png^sunos_inv_fundamento_casa.png",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	stack_max = 1,
	
	-- Colocar uma casa
	on_place = function(itemstack, placer, pointed_thing)
		
		local r = sunos.estruturas.casa.construir(pointed_thing.under, 4, nil, nil, sunos.estruturas.casa.gerar_itens_repo["4"]())
		if r == true then
			
			-- Retorna mensagem de montagem concluida
			minetest.chat_send_player(placer:get_player_name(), sunos.S("Casa construida"))
			itemstack:take_item()
			return itemstack
			
		else
			-- Retorna mensagem de falha
			minetest.chat_send_player(placer:get_player_name(), r)
			return itemstack
		end
	end,
})


