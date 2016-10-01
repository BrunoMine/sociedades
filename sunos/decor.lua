--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Estrutura decorativa dos sunos
  ]]

-- Caminho do diretório do mod
local modpath = minetest.get_modpath("sunos")

-- Construir estrutura decorativa
--[[
	Essa função construi uma estrutura decorativa de sunos e configura o fundamento
	Retorno:
		^ true caso ocorra tudo bem
		^ string de erro caso algo de errado
	Argumentos:
		<pos> é a coordenada do fundamento da estrutura
		<dist> distancia centro a borda da nova estrutura
		<vila> OPCIONAL | é o numero da vila a qual a estrutura decorativa pertence
		<force_area> OPCIONAL | true para ignorar verificadores de area
  ]]
sunos.construir_decor = function(pos, dist, vila, force_area)
	-- Validar argumentos de entrada
	if pos == nil then
		minetest.log("error", "[Sunos] Tabela pos nula (sunos.construir_decor)")
		return "Erro interno (pos nula)"
	end
	if dist == nil then
		minetest.log("error", "[Sunos] variavel dist nula (em sunos.construir_decor)")
		return "Erro interno (tamanho de estrutura decorativa inexistente)"
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
	
	-- Criar estrutura decorativa
	sunos.montar_estrutura(pos, dist, "decor")
	
	-- Numero da estrutura da nova estrutura decorativa comunal
	local n_estrutura = sunos.bd:pegar("vila_"..vila, "estruturas")+1 -- Numero da nova estrutura
	
	-- Criar fundamento e configurar
	minetest.set_node(pos, {name="sunos:fundamento"})
	local meta = minetest.get_meta(pos)
	meta:set_string("vila", vila) -- Numero da vila
	meta:set_string("tipo", "decor") -- Tipo da estrutura
	meta:set_string("estrutura", n_estrutura) -- Numero da estrutura
	meta:set_string("dist", dist) -- Distancia centro a borda da estrutura
	sunos.contabilizar_blocos_estruturais(pos) -- Armazena quantidade de nodes estruturais
	
	-- Registros a serem salvos
	local registros = {
		numero = n_estrutura,
		tipo = "decor",
		estrutura = {
			dist = dist,
			largura = largura,
			pos = pos
		}
	}
	
	-- Salva no banco de dados
	sunos.bd:salvar("vila_"..vila, "decor_"..n_estrutura, registros)
	
	-- Salvar novo total de estruturas da vila
	sunos.bd:salvar("vila_"..vila, "estruturas", n_estrutura)
	
	return true
end

