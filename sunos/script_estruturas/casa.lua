--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Casa dos sunos
  ]]

-- Caminho do diretório do mod
local modpath = minetest.get_modpath("sunos")


local set_bau = function(pos, vila, n_estrutura, dist)

	-- Verifica se tem baus na estrutura montada
	local baus = minetest.find_nodes_in_area(
		{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
		{x=pos.x+dist, y=pos.y+14, z=pos.z+dist}, 
		{"sunos:bau"}
	)
	-- Salva dados da estrutura no bau dela
	for _,pos_bau in ipairs(baus) do
		local meta = minetest.get_meta(pos_bau)
		meta:set_string("vila", vila) -- Numero da vila
		meta:set_string("estrutura", n_estrutura) -- Numero da estrutura
		meta:set_string("pos_fundamento", minetest.serialize(pos)) -- Pos do fundamento
		meta:set_string("infotext", sunos.S("Bau dos Sunos"))
	end


end

-- Itens simples decorativos para casas
local decor_simples = {
	"default:apple",
	"flowers:rose",
	"flowers:tulip",
	"flowers:dandelion_yellow",
	"flowers:geranium",
	"flowers:viola",
	"flowers:dandelion_white",
	"flowers:mushroom_brown",
	"vessels:glass_bottle",
	"vessels:drinking_glass"
}

-- Construir casa de sunos
--[[
	Essa função construi uma casa de sunos e configura o fundamento
	Retorno:
		^ true caso ocorra tudo bem
		^ string de erro caso algo de errado
	Argumentos:
		<pos> é a coordenada do fundamento da estrutura
		<dist> distancia centro a borda da nova estrutura
		<vila> OPCIONAL | é o numero da vila a qual a casa pertence
		<force_area> OPCIONAL | true para ignorar verificadores de area
		<itens_repo> OPCIONAL | Repassado ao comando sunos.decor_repo para substituir itens de reposição
  ]]
sunos.construir_casa_comum = function(pos, dist, vila, force_area, itens_repo)
	-- Validar argumentos de entrada
	if pos == nil then
		minetest.log("error", "[Sunos] Tabela pos nula (sunos.construir_casa_comum)")
		return "Erro interno (pos nula)"
	end
	if dist == nil then
		minetest.log("error", "[Sunos] variavel dist nula (em sunos.construir_casa_comum)")
		return "Erro interno (tamanho de casa inexistente)"
	end
	
	-- Variaveis auxiliares
	local largura = (dist*2)+1
	
	-- Buscar uma vila por perto
	if not vila then
		local pos_fund_prox = minetest.find_node_near(pos, 25, {"sunos:fundamento"})
		if pos_fund_prox == nil then 
			return sunos.S("Nenhuma vila por perto")
		end
	
		-- Pegar dados da vila encontrada
		local meta_fund_prox = minetest.get_meta(pos_fund_prox)
		vila = meta_fund_prox:get_string("vila")
	
		-- Verificar se ainda existe um banco de dados da vila
		if sunos.bd:verif("vila_"..vila, "numero") == false then
			return sunos.S("Vila abandonada")
		end
	end
	
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
	
	-- Criar casa
	sunos.montar_estrutura(pos, dist, "casa")
	
	-- Recoloca itens reais (apartir dos itens de reposição)
	if itens_repo then
		sunos.decor_repo(pos, dist, itens_repo)
	end
	
	-- Numero da estrutura da nova casa
	local n_estrutura = sunos.bd:pegar("vila_"..vila, "estruturas")+1 -- Numero da nova estrutura
	
	-- Criar fundamento e configurar
	minetest.set_node(pos, {name="sunos:fundamento"})
	local meta = minetest.get_meta(pos)
	meta:set_string("vila", vila) -- Numero da vila
	meta:set_string("tipo", "casa") -- Tipo da estrutura
	meta:set_string("estrutura", n_estrutura) -- Numero da estrutura
	meta:set_string("dist", dist) -- Distancia centro a borda da estrutura
	sunos.contabilizar_blocos_estruturais(pos) -- Armazena quantidade de nodes estruturais
	
	-- Configurar bau de casas
	minetest.after(1, set_bau, {x=pos.x,y=pos.y,z=pos.z}, vila, n_estrutura, dist)
	
	-- Registros a serem salvos
	local registros = {
		numero = n_estrutura,
		tipo = "casa",
		pop = sunos.tb_pop_casa[tostring(largura)] or 1,
		estrutura = {
			dist = dist,
			largura = largura,
			pos = pos
		}
	}
	
	-- Salva no banco de dados
	sunos.bd:salvar("vila_"..vila, "casa_"..n_estrutura, registros)
	
	-- Salvar novo total de estruturas da vila
	sunos.bd:salvar("vila_"..vila, "estruturas", n_estrutura)
	
	return true
end

-- Fundamento de casa comum
--[[
	Esse é o node usado para construir uma casa comum
]]
-- Gerar itens de reposição
sunos.gerar_itens_repo_casa_pequena = function()
	return {
		bancadas = {
			{"sunos:bau", 1},
			{"sunos:bancada_de_trabalho", 1, true},
		},
		simples = {
			{decor_simples[math.random(1, table.maxn(decor_simples))], 1},
			{decor_simples[math.random(1, table.maxn(decor_simples))], 1}
		},
	}
end
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
		
		local r = sunos.construir_casa_comum(pointed_thing.under, 2, nil, nil, sunos.gerar_itens_repo_casa_pequena())
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

-- Gerar itens de reposição
sunos.gerar_itens_repo_casa_mediana = function()
	return {
		bancadas = {
			{"sunos:bau", 1},
			{"sunos:bancada_de_trabalho", 1, true},
		},
		simples = {
			{decor_simples[math.random(1, table.maxn(decor_simples))], math.random(1, 2)},
			{decor_simples[math.random(1, table.maxn(decor_simples))], math.random(1, 2)}
		},
	}
end
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
		
		local r = sunos.construir_casa_comum(pointed_thing.under, 3, nil, nil, sunos.gerar_itens_repo_casa_mediana())
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


-- Gerar itens de reposição
sunos.gerar_itens_repo_casa_grande = function()
	return {
		bancadas = {
			{"sunos:bau", 1},
			{"sunos:bancada_de_trabalho", 1, true},
		},
		simples = {
			{decor_simples[math.random(1, table.maxn(decor_simples))], math.random(1, 2)},
			{decor_simples[math.random(1, table.maxn(decor_simples))], math.random(1, 2)},
			{decor_simples[math.random(1, table.maxn(decor_simples))], math.random(1, 2)},
			{decor_simples[math.random(1, table.maxn(decor_simples))], math.random(1, 2)}
		},
	}
end
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
		
		local r = sunos.construir_casa_comum(pointed_thing.under, 4, nil, nil, sunos.gerar_itens_repo_casa_grande())
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

-- Criar tabela que relaciona disttancia centra a borda com funcões de geração de tabela de reposição
sunos.tb_repo_casas = {}
sunos.tb_repo_casas["2"] = sunos.gerar_itens_repo_casa_pequena
sunos.tb_repo_casas["3"] = sunos.gerar_itens_repo_casa_mediana
sunos.tb_repo_casas["4"] = sunos.gerar_itens_repo_casa_grande
