--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Casa comunal
  ]]

-- Caminho do diretório do mod
local modpath = minetest.get_modpath("sunos")

-- Construir casa comunal
--[[
	Essa função construi uma casa comunal e configura o fundamento
	Retorno:
		^ true caso ocorra tudo bem
		^ string de erro caso algo de errado
	Argumentos:
		<pos> é a coordenada do fundamento da estrutura
		<vila> é o numero da vila a qual a casa comunal pertence
		<nivel> é o nível da casa comunal a ser construida
		<n_estrutura> é o numero da estrutura da casa comunal
		<force_area> OPCIONAL | Para ignorar as verificações de area limpa
  ]]
sunos.construir_casa_comunal = function(pos, vila, nivel, n_estrutura, force_area)
	-- Validar argumentos de entrada
	if pos == nil then
		minetest.log("error", "[Sunos] Tabela pos nula (construir_casa_comunal)")
		return "Erro interno (pos nula)"
	end
	if nivel == nil then
		minetest.log("error", "[Sunos] variavel nivel nula (em construir_casa_comunal)")
		return "Erro interno (nivel nulo)"
	end
	if vila == nil then
		minetest.log("error", "[Sunos] variavel vila nula (em construir_casa_comunal)")
		return "Erro interno (vila inexistente)"
	end
	if n_estrutura == nil then
		minetest.log("error", "[Sunos] variavel n_estrutura nula (em construir_casa_comunal)")
		return "Erro interno (Numero de estrutura inexistente)"
	end
	
	-- Distancia centro a borda padrão
	local dist = 6 
	
	-- Variaveis auxiliares
	local largura = 13
	
	-- Verificações de area
	if force_area ~= true then
	-- Verificar se o local esta limpo, gramado e plano (contando o entorno da estrutura)
		local nodes_solo = minetest.find_nodes_in_area(
			{x=pos.x-dist-1, y=pos.y, z=pos.z-dist-1}, 
			{x=pos.x+dist+1, y=pos.y, z=pos.z+dist+1}, 
			{"default:dirt_with_grass", "default:dirt"}
		)
		local nodes_acima_solo = minetest.find_nodes_in_area(
			{x=pos.x-dist-1, y=pos.y+1, z=pos.z-dist-1}, 
			{x=pos.x+dist+1, y=pos.y+1, z=pos.z+dist+1}, 
			{"air"}
		)
		if table.maxn(nodes_solo) < ((2*(dist+1))+1)^2
			or table.maxn(nodes_acima_solo) < (((2*(dist+1))+1)^2)-1
		then
			return sunos.S("O local precisa estar limpo, gramado e plano para uma estrutura com @1x@1 blocos da largura", largura)
		end
	
		-- Verificar se tem outra estrutura de suno interferindo na area da nova estrutura
		if sunos.verif_fundamento(pos, dist) == false then
			return sunos.S("Muito perto de outra estrutura dos Sunos (afaste um pouco)")
		end
	end
	
	-- Criar casa comunal
	-- Caminho do arquivo da estrutura
	local arquivo = modpath.."/estruturas/casa_comunal/nivel_"..nivel..".13.mts"
	
	-- Criar estrutura
	minetest.place_schematic({x=pos.x-dist,y=pos.y,z=pos.z-dist}, arquivo, nil, nil, true)
	
	-- Criar fundamento e configurar
	minetest.set_node(pos, {name="sunos:fundamento"})
	local meta = minetest.get_meta(pos)
	meta:set_string("vila", vila) -- Numero da vila
	meta:set_string("tipo", "casa_comunal") -- Numero da vila
	meta:set_string("estrutura", n_estrutura) -- Numero da estrutura
	meta:set_string("nivel", nivel) -- Nivel da casa comunal
	meta:set_string("dist", dist) -- Distancia centro a borda da estrutra
	meta:set_string("status", "ativa") -- Status da casa comunal
	sunos.contabilizar_blocos_estruturais(pos) -- Armazena quantidade de nodes estruturais
	
	-- Salvar nova dados da estrutura no banco de dados da vila
	local dados_casa_comunal = {
		pos = pos, -- Pos do fundamento
		vila = vila, -- Numero da vila
		nivel = nivel, -- Nivel da Casa Comunal
	}
	sunos.bd:salvar("vila_"..vila, "casa_comunal", dados_casa_comunal)
	
	-- Ajustar nodes da estrutura
	
	-- Ajustar baus
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
		meta:set_string("pos_fundamento", minetest.serialize(pos)) -- Pos do fundamento
		meta:set_string("infotext", sunos.S("Bau da Casa Comunal dos Sunos"))
	end
	
	return true
end

-- Fundamento de casa comunal
--[[
	Esse é o node usado para construir uma casa comunal
]]
minetest.register_node("sunos:fundamento_casa_comunal", {
	description = sunos.S("Fundamento de Casa Comunal dos Sunos"),
	tiles = {"default_tree_top.png^sunos_fundamento.png", "default_tree_top.png", "default_tree.png"},
	inventory_image = "sunos_inv_fundamento.png^sunos_inv_fundamento_casa_comunal.png",
	wield_image = "sunos_inv_fundamento.png^sunos_inv_fundamento_casa_comunal.png",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	stack_max = 1,
	
	-- Colocar uma casa comunal
	on_place = function(itemstack, placer, pointed_thing)
		
		-- Verificar Vila e pegar dados (buscando por um fundamento proximo)
		local pos_fund_prox = minetest.find_node_near(pointed_thing.under, 25, {"sunos:fundamento"})
		if pos_fund_prox == nil then 
			return minetest.chat_send_player(placer:get_player_name(), sunos.S("Nenhuma vila por perto"))
		end
		
		-- Pegar dados da vila encontrada
		local meta_fund_prox = minetest.get_meta(pos_fund_prox)
		local vila = meta_fund_prox:get_string("vila")
		
		-- Numero da estrutura da nova casa comunal
		local n_estrutura = sunos.bd:pegar("vila_"..vila, "estruturas")+1 -- Numero da nova estrutura
		
		-- Verificar se a vila pode criar uma nova casa comunal
		sunos.atualizar_bd_vila(vila) -- Atualizar o banco de dados
		
		-- Verificar se ainda existe um banco de dados da vila
		if sunos.bd:verif("vila_"..vila, "numero") == false then
			return minetest.chat_send_player(placer:get_player_name(), sunos.S("Vila abandonada"))
		end
		
		-- Verificar se ja existe uma casa comunal
		if sunos.bd:verif("vila_"..vila, "casa_comunal") == true then
			return minetest.chat_send_player(placer:get_player_name(), sunos.S("Ja existe uma Casa Comunal nessa vila"))
		end
		
		local r = sunos.construir_casa_comunal(pointed_thing.under, vila, 1, n_estrutura)
		if r == true then
			-- Salvar novo total de estruturas da vila
			sunos.bd:salvar("vila_"..vila, "estruturas", n_estrutura)
			
			-- Retorna mensagem de montagem concluida
			minetest.chat_send_player(placer:get_player_name(), sunos.S("Casa Comunal construida"))
			itemstack:take_item()
			return itemstack
			
		else
			-- Retorna mensagem de falha
			minetest.chat_send_player(placer:get_player_name(), r)
			return itemstack
		end
	end,
})

-- Bau da casa comunal (para spawnar atendentes)
--[[
	Esse é o node usado para construir uma casa comunal
]]
minetest.register_node("sunos:bau_casa_comunal", {
	description = sunos.S("Bau da Casa Comunal dos Sunos"),
	tiles = {"default_chest_top.png^sunos_bau_topo.png", "default_chest_top.png", "default_chest_side.png^sunos_bau_lado.png",
		"default_chest_side.png^sunos_bau_lado.png", "default_chest_side.png^sunos_bau_lado.png", "default_chest_lock.png^sunos_bau_frente.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	stack_max = 1,
	drop = "default:chest",
})

