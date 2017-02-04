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

-- Tabela global de Decorativos (estruturas)
sunos.estruturas.decor = {}

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
sunos.estruturas.decor.construir = function(pos, dist, vila, force_area)
	-- Validar argumentos de entrada
	if pos == nil then
		minetest.log("error", "[Sunos] Tabela pos nula (sunos.estruturas.decor.construir)")
		return "Erro interno (pos nula)"
	end
	if dist == nil then
		minetest.log("error", "[Sunos] variavel dist nula (em sunos.estruturas.decor.construir)")
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
	
		-- Verifica status do terreno
		local st = sunos.verif_terreno(pos, dist)
		
		-- Problema: em cima da faixa de solo existem obstrucoes (nao esta limpo e plano)
		if st == 1 then
			return sunos.S("O local precisa estar limpo e plano em uma area de @1x@1 blocos da largura", (largura+2))
		
		-- Problema: faixa de solo (superficial) falta blocos de terra
		elseif st == 2 then
			return sunos.S("O solo precisa estar plano e gramado em uma area de @1x@1 blocos da largura", (largura+2))
		
		-- Problema: faixa de subsolo (considerando 2 faixas) falta blocos de terra
		elseif st == 3 then
			return sunos.S("O subsolo precisa estar preenchido (ao menos 2 blocos de profundidade) em uma area de @1x@1 blocos da largura", (largura+2))
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

-- Verificação do fundamento
sunos.estruturas.decor.verif_fund = function(pos)
	local meta = minetest.get_meta(pos)
	local vila = meta:get_string("vila")
	if not vila then return end
	vila = tonumber(vila)
	local tipo = meta:get_string("tipo")
	local dist = tonumber(meta:get_string("dist"))
	
	-- Verificar Estrutura danificada
	if sunos.verificar_blocos_estruturais(pos) == false then 
	
		-- Montar ruinas no local da antiga casa
		sunos.montar_ruinas(pos, dist)
		
		-- Exclui o arquivo da estrutura do banco de dados
		sunos.bd:remover("vila_"..meta:get_string("vila"), tipo.."_"..meta:get_string("estrutura"))
		
		-- Trocar bloco de fundamento por madeira
		minetest.set_node(pos, {name="default:tree"})
		
		-- Atualizar banco de dados da vila
		sunos.atualizar_bd_vila(vila)
	end
end

