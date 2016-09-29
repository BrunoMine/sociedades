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
local construir_casa_comunal = function(pos, nivel)
	-- Validar argumentos de entrada
	if pos == nil then
		minetest.log("error", "[Sunos] Tabela pos nula (construir_casa_comunal)")
		return "Erro interno (pos nula)"
	end
	if nivel == nil then
		minetest.log("error", "[Sunos] nivel (em construir_casa_comunal)")
		return "Erro interno (nivel nulo)"
	end
	local dist = 6 -- Distancia centro a borda padrão
	if dist == nil then
		minetest.log("error", "[Sunos] falha em encontrar dist (em construir_casa_comunal)")
		return "Erro interno (dist inexistente)"
	end
	
	-- Verificações
	
	-- Verificar Vila e pegar dados (buscando por um fundamento proximo)
	local pos_node_vila = minetest.find_node_near(pos, 20, {"sunos:fundamento"})
	if pos_node_vila == nil then 
		return "Precisa estar perto de uma vila"
	end
	local meta_fund = minetest.get_meta(pos_node_vila)
	local vila = meta_fund:get_string("vila")
	local n_estrutura = sunos.bd:pegar("vila_"..vila, "estruturas") -- Numero da nova estrutura
	
	-- Verificar se ja existe uma casa comunal ativa
	if sunos.bd:verif("vila_"..vila, "casa_comunal") == true then
		local registros_casa_comunal_antiga = sunos.bd:pegar("vila_"..vila, "casa_comunal")
		local node_casa_comunal_antiga = minetest.get_node(registros_casa_comunal_antiga.pos)
		if node_casa_comunal_antiga.name == "sunos:fundamento" then
			local meta_casa_comunal_antiga = minetest.get_meta(registros_casa_comunal_antiga.pos)
			if meta_casa_comunal_antiga:get_string("tipo") == "casa_comunal" then
				return "Ja existe uma casa comunal nessa vila"
			end
		end
	end
	
	-- Verificar se o local esta limpo, gramado e plano (contando o entorno da estrutura)
	local nodes_solo = minetest.find_nodes_in_area(
		{x=pos.x-dist-1, y=pos.y-1, z=pos.z-dist-1}, 
		{x=pos.x+dist+1, y=pos.y-1, z=pos.z+dist+1}, 
		{"default:dirt_with_grass", "default:dirt"}
	)
	local nodes_acima_solo = minetest.find_nodes_in_area(
		{x=pos.x-dist-1, y=pos.y, z=pos.z-dist-1}, 
		{x=pos.x+dist+1, y=pos.y, z=pos.z+dist+1}, 
		{"air"}
	)
	local n = minetest.get_node({x=pos.x-dist, y=pos.y-1, z=pos.z-dist})
	
	if table.maxn(nodes_solo) < ((2*(dist+1))+1)^2
		or table.maxn(nodes_acima_solo) < (((2*(dist+1))+1)^2)-1
	then
		return "O local precisa estar limpo, gramado em plano para a casa comunal com um 15x15 blocos da largura"
	end
	
	-- Verificar se tem outra estrutura de suno interferindo na area da nova estrutura
	if sunos.verif_fundamento(pos, dist) == false then
		return "Muito perto de uma estrutura de sunos. Afaste um pouco."
	end
	
	-- Verificar se a vila foi abandonada
	sunos.atualizar_bd_vila(vila) -- Atualizar o banco de dados
	if sunos.bd:verif("vila_"..vila, "numero") == false then
		return "Vila abandonada"
	end
	if sunos.bd:verif("vila_"..vila, "pop") == true and sunos.bd:pegar("vila_"..vila, "pop") == 0 then
		return "Vila abandonada (inabitada)"
	end
	
	-- Criar casa comunal
	-- Caminho do arquivo da estrutura
	local arquivo = modpath.."/estruturas/casa_comunal/casa_comunal_nivel_"..nivel..".13.mts"
	
	-- Criar estrutura
	minetest.place_schematic({x=pos.x-dist,y=pos.y-1,z=pos.z-dist}, arquivo, nil, nil, true)
	
	-- Criar fundamento e configurar
	local pos_novo_fund = {x=pos.x,y=pos.y-1,z=pos.z}
	minetest.set_node(pos_novo_fund, {name="sunos:fundamento"})
	local meta_novo_fund = minetest.get_meta(pos_novo_fund)
	meta_novo_fund:set_string("vila", vila) -- Numero da vila
	meta_novo_fund:set_string("tipo", "casa_comunal") -- Numero da vila
	meta_novo_fund:set_string("estrutura", n_estrutura+1) -- Numero da estrutura
	meta_novo_fund:set_string("dist", dist) -- Distancia centro a borda da estrutra
	meta_novo_fund:set_string("status", "ativa") -- Status da casa comunal
	sunos.contabilizar_blocos_estruturais(pos_novo_fund) -- Armazena quantidade de nodes estruturais
	
	-- Salvar novo total de estruturas da vila
	sunos.bd:salvar("vila_"..vila, "estruturas", n_estrutura+1)
	
	-- Salvar nova dados da estrutura no banco de dados da vila
	local dados_casa_comunal = {
		pos = pos_novo_fund, -- Pos do fundamento
		vila = vila, -- Numero da vila
		nivel = nivel, -- Nivel da Casa Comunal
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
		meta:set_string("estrutura", n_estrutura+1) -- Numero da estrutura
		meta:set_string("pos_fundamento", minetest.serialize(pos_novo_fund)) -- Pos do fundamento
		meta:set_string("infotext", "Bau de Casa Comunal")
	end
	
	return true
end

-- Fundamento de casa comunal
--[[
	Esse é o node usado para construir uma casa comunal
]]
minetest.register_node("sunos:fundamento_casa_comunal", {
	description = "Fundamento de Casa Comunal dos Sunos",
	tiles = {"default_tree_top.png^sunos_fundamento.png", "default_tree_top.png", "default_tree.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	stack_max = 1,
	on_place = function(itemstack, placer, pointed_thing)
		local r = construir_casa_comunal(pointed_thing.above, 1)
		if r ~= true then
			minetest.chat_send_player(placer:get_player_name(), r)
			return 
		else
			minetest.chat_send_player(placer:get_player_name(), "Casa Comunal construida.")
			itemstack:take_item()
			return itemstack
		end
	end,
})

-- Piso de atendente da casa comunal
--[[
	Esse é o node usado para construir uma casa comunal
]]
minetest.register_node("sunos:bau_casa_comunal", {
	description = "Bau de Atendente da Casa Comunal",
	tiles = {"default_chest_top.png", "default_chest_top.png", "default_chest_side.png",
		"default_chest_side.png", "default_chest_side.png", "default_chest_lock.png^sunos_fundamento.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	stack_max = 1,
	drop = "default:chest",
})

