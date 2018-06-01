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

-- Verificar terreno antes de construir casa
local verificar_terreno = function(pos, dist)

	-- Validar argumentos de entrada
	if pos == nil then
		minetest.log("error", "[Sunos] Tabela pos nula (sunos.estruturas.casa.construir)")
		return "Erro interno (pos nula)"
	end
	if dist == nil then
		minetest.log("error", "[Sunos] variavel dist nula (em sunos.estruturas.casa.construir)")
		return "Erro interno (tamanho de casa inexistente)"
	end
	
	-- Verificar se vila existe (caso especificado)
	if vila and sunos.verificar_vila_existente(vila) == false then
		return S("Vila abandonada")
		
	-- Encontrar vila ativa
	else
		vila = sunos.encontrar_vila(pos, 25)
		if not vila then
			return S("Nenhuma vila habitavel encontrada")
		end
	end
	
	-- Verifica se está muito perto de outras estruturas atravez de areas protegidas
	for x=-1, 1 do
		for y=-1, 1 do
			for z=-1, 1 do
				if minetest.is_protected({x=pos.x+((dist+2)*x), y=pos.y+((dist+2)*x), z=pos.z+((dist+2)*x)}, name) == true then
					minetest.chat_send_player(name, S("Muito perto de estruturas protegidas"))
					return itemstack 
				end
			end
		end
	end
	
	-- Verificar limite populacional
	if sunos.verif_pop_vila(vila) ~= true then
		return S("Limite de @1 habitantes foi atingido", sunos.var.max_pop)
	end
	
	-- Verificações de area
	do
		local r = sunos.verificar_area_para_fundamento(pos, dist)
		if r ~= true then
			return r
		end
	end
	
	return true, vila
end

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
		
		local r, vila = verificar_terreno(pos, 2)
		
		if r == true then
			
			-- Coloca rua em torno
			sunos.colocar_rua(pos, 2)
			
			-- Construir estrutura
			sunos.estruturas.casa.construir(pos, 2, vila)
			
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
		
		local r, vila = verificar_terreno(pos, 3)
		
		if r == true then
			
			-- Coloca rua em torno
			sunos.colocar_rua(pos, 3)
			
			-- Construir estrutura
			sunos.estruturas.casa.construir(pos, 3, vila)
			
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
		
		local r, vila = verificar_terreno(pos, 4)
		
		if r == true then
			
			-- Coloca rua em torno
			sunos.colocar_rua(pos, 4)
			
			-- Construir estrutura
			sunos.estruturas.casa.construir(pos, 4, vila)
			
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


