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

-- Construir casa de sunos
--[[
	Essa função construi uma casa de sunos e configura o fundamento
	Retorno:
		^ true caso ocorra tudo bem
		^ string de erro caso algo de errado
	Argumentos:
		<pos> é a coordenada do fundamento da estrutura
		<vila> é o numero da vila a qual a casa pertence
		<dist> distancia centro a borda da nova estrutura
  ]]
sunos.construir_casa_comum = function(pos, dist)
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
	
	-- Verificar Vila e pegar dados (buscando por um fundamento proximo)
	local pos_fund_prox = minetest.find_node_near(pos, 25, {"sunos:fundamento"})
	if pos_fund_prox == nil then 
		return "Nenhuma vila por perto"
	end
	
	-- Pegar dados da vila encontrada
	local meta_fund_prox = minetest.get_meta(pos_fund_prox)
	local vila = meta_fund_prox:get_string("vila")
	
	-- Verificar se ainda existe um banco de dados da vila
	if sunos.bd:verif("vila_"..vila, "numero") == false then
		return "Vila abandonada"
	end
	
	-- Verificações de area
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
		return "O local precisa estar limpo, gramado em plano para a casa com "..largura.."x"..largura.." blocos da largura"
	end

	-- Verificar se tem outra estrutura de suno interferindo na area da nova estrutura
	if sunos.verif_fundamento(pos, dist) == false then
		return "Muito perto de uma estrutura de sunos. Afaste um pouco."
	end
	
	-- Criar casa
	sunos.montar_estrutura(pos, dist, "casa")
	
	-- Numero da estrutura da nova casa comunal
	local n_estrutura = sunos.bd:pegar("vila_"..vila, "estruturas")+1 -- Numero da nova estrutura
	
	-- Criar fundamento e configurar
	minetest.set_node(pos, {name="sunos:fundamento"})
	local meta = minetest.get_meta(pos)
	meta:set_string("vila", vila) -- Numero da vila
	meta:set_string("tipo", "casa") -- Tipo da estrutura
	meta:set_string("estrutura", n_estrutura) -- Numero da estrutura
	meta:set_string("dist", dist) -- Distancia centro a borda da estrutura
	sunos.contabilizar_blocos_estruturais(pos) -- Armazena quantidade de nodes estruturais
	
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
		meta:set_string("infotext", "Bau de Suno")
	end
	
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
-- Fundamento de casa pequena
minetest.register_node("sunos:fundamento_casa_pequena", {
	description = "Fundamento Suno de Casa Pequena",
	tiles = {"default_tree_top.png^sunos_fundamento.png", "default_tree_top.png", "default_tree.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	stack_max = 1,
	
	-- Colocar uma casa comunal
	on_place = function(itemstack, placer, pointed_thing)
		
		local r = sunos.construir_casa_comum(pointed_thing.under, 2)
		if r == true then
			
			-- Retorna mensagem de montagem concluida
			minetest.chat_send_player(placer:get_player_name(), "Casa construida.")
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
	description = "Fundamento Suno de Casa Mediana",
	tiles = {"default_tree_top.png^sunos_fundamento.png", "default_tree_top.png", "default_tree.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	stack_max = 1,
	
	-- Colocar uma casa comunal
	on_place = function(itemstack, placer, pointed_thing)
		
		local r = sunos.construir_casa_comum(pointed_thing.under, 3)
		if r == true then
			
			-- Retorna mensagem de montagem concluida
			minetest.chat_send_player(placer:get_player_name(), "Casa construida.")
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
	description = "Fundamento Suno de Casa Grande",
	tiles = {"default_tree_top.png^sunos_fundamento.png", "default_tree_top.png", "default_tree.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	stack_max = 1,
	
	-- Colocar uma casa comunal
	on_place = function(itemstack, placer, pointed_thing)
		
		local r = sunos.construir_casa_comum(pointed_thing.under, 4)
		if r == true then
			
			-- Retorna mensagem de montagem concluida
			minetest.chat_send_player(placer:get_player_name(), "Casa construida.")
			itemstack:take_item()
			return itemstack
			
		else
			-- Retorna mensagem de falha
			minetest.chat_send_player(placer:get_player_name(), r)
			return itemstack
		end
	end,
})


