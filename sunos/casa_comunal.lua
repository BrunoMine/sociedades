--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Casa comunal
  ]]

-- Tabela de definicoes das casas comunais
local tb_casas_comunais = {
	--	distancia centro a borda
		{dist = 4},
}

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
	if tb_casas_comunais[nivel] == nil then
		minetest.log("error", "[Sunos] nivel (em construir_casa_comunal)")
		return "Erro interno (nivel inexistente)"
	end
	local dist = tb_casas_comunais[nivel].dist
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
	
	-- Verificar se o local esta limpo, gramado e plano
	local nodes_solo = minetest.find_nodes_in_area(
		{x=pos.x-dist, y=pos.y-1, z=pos.z-dist}, 
		{x=pos.x+dist, y=pos.y-1, z=pos.z+dist}, 
		{"default:dirt_with_grass", "default:dirt"}
	)
	local nodes_acima_solo = minetest.find_nodes_in_area(
		{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
		{x=pos.x+dist, y=pos.y, z=pos.z+dist}, 
		{"air"}
	)
	local n = minetest.get_node({x=pos.x-dist, y=pos.y-1, z=pos.z-dist})

	if table.maxn(nodes_solo) < ((2*dist)+1)^2
		or table.maxn(nodes_acima_solo) < (((2*dist)+1)^2)-1
	then
		return "O local precisa estar limpo, gramado em plano para a casa comunal"
	end
	
	-- Verificar se a vila foi abandonada
	
	-- Verificar se ja existe outra casa comunal
	
	-- Criar casa comunal
	sunos.montar_estrutura({x=pos.x,y=pos.y-1,z=pos.z}, dist, "casa_comunal")
	
	-- Criar fundamento e configurar
	local pos_novo_fund = {x=pos.x,y=pos.y-1,z=pos.z}
	minetest.set_node(pos_novo_fund, {name="sunos:fundamento"})
	local meta_novo_fund = minetest.get_meta(pos_novo_fund)
	meta_novo_fund:set_string("vila", vila) -- Numero da vila
	meta_novo_fund:set_string("tipo", "casa_comunal") -- Numero da vila
	meta_novo_fund:set_string("estrutura", n_estrutura+1) -- Numero da estrutura
	
	-- Salvar novo total de estruturas da vila
	sunos.bd:salvar("vila_"..vila, "estruturas", n_estrutura+1)
	
	-- Salvar nova dados da estrutura no banco de dados da vila
	local dados_casa_comunal = {
		pos = pos_novo_fund, -- Pos do fundamento
		vila = vila, -- Numero da vila
	}
	sunos.bd:salvar("vila_"..vila, "casa_comunal", dados_casa_comunal)

	
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
		--return itemstack
		local r = construir_casa_comunal(pointed_thing.above, 1)
		if r ~= true then
			minetest.chat_send_player(placer:get_player_name(), r)
			return 
		else
			minetest.chat_send_player(placer:get_player_name(), "Casa Comunal construida.")
			return itemstack
		end
	end,
})

