--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Casa dos sunos
  ]]
  

-- Tabela global de Casa
sunos.estruturas.casa = {}

-- Esse tipo de estrutura tem população
sunos.estruturas.casa.pop = true

-- Métodos para gerar tabelas de itens para reposição de nodes (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/casa/repo_nodes.lua") 

-- Registros do NPC da casa (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/casa/npc.lua") 

-- Registros do NPC da casa (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/casa/interface.lua") 

-- Bau de casa dos sunos (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/casa/bau.lua") 

local set_bau = function(pos, vila, n_estrutura, dist)

	-- Verifica se tem baus na estrutura montada
	local baus = minetest.find_nodes_in_area(
		{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
		{x=pos.x+dist, y=pos.y+14, z=pos.z+dist}, 
		{"sunos:bau_casa"}
	)
	-- Salva dados da estrutura no bau dela
	for _,pos_bau in ipairs(baus) do
		local meta = minetest.get_meta(pos_bau)
		meta:set_string("obs", "n") -- Verifica se esta obstruido
		meta:set_string("vila", vila) -- Numero da vila
		meta:set_string("estrutura", n_estrutura) -- Numero da estrutura
		meta:set_string("pos_fundamento", minetest.serialize(pos)) -- Pos do fundamento
		meta:set_string("infotext", sunos.S("Bau dos Sunos"))
	end

end

-- Tabela para valores de rotação
local tb_rotat = {"0", "90", "180", "270"}

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
		<verif_area> OPCIONAL | para verificar a area a ser usada
		<itens_repo> OPCIONAL | Repassado ao comando sunos.decor_repo para substituir itens de reposição
  ]]
sunos.estruturas.casa.construir = function(pos, dist, vila, verif_area, itens_repo)
	-- Validar argumentos de entrada
	if pos == nil then
		minetest.log("error", "[Sunos] Tabela pos nula (sunos.estruturas.casa.construir)")
		return "Erro interno (pos nula)"
	end
	if dist == nil then
		minetest.log("error", "[Sunos] variavel dist nula (em sunos.estruturas.casa.construir)")
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
	if verif_area == true then
		
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
	
	-- Escolhe uma rotação aleatória
	local rotat = tb_rotat[math.random(1, 4)]
	
	-- Criar casa e pega o nome do arquivo da estrutura
	local rm, schem = sunos.montar_estrutura(pos, dist, "casa", rotat)
	
	-- Recoloca itens reais (apartir dos itens de reposição)
	if itens_repo then
		sunos.decor_repo(pos, dist, sunos.estruturas.casa.gerar_itens_repo[tostring(dist)]())
	end
	
	-- Numero da estrutura da nova casa
	local n_estrutura = sunos.nova_estrutura(vila) -- Numero da nova estrutura
	
	-- Criar fundamento e configurar
	minetest.set_node(pos, {name="sunos:fundamento"})
	local meta = minetest.get_meta(pos)
	meta:set_string("versao", sunos.versao) -- Salva a versão atual do projeto
	meta:set_string("schem", schem) -- Nome do arquivo da esquematico da estrutura
	meta:set_string("rotat", rotat) -- Rotação da estrutura
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

-- Verificação do fundamento
sunos.estruturas.casa.verif_fund = function(pos)
	local meta = minetest.get_meta(pos)
	local vila = meta:get_string("vila")
	if not vila then return end
	vila = tonumber(vila)
	local tipo = meta:get_string("tipo")
	local dist = tonumber(meta:get_string("dist"))
	local nd = tonumber(meta:get_string("nodes")) -- numero de nodes inicial
	
	-- Pega o numero de nodes real
	local ndrl = sunos.verificar_blocos_estruturais(pos)
	
	-- Verifica se a casa está muito destruida
	if ndrl < nd - 4 then
		-- Montar ruinas no local da antiga casa
		sunos.montar_ruinas(pos, dist)
	
		-- Exclui o arquivo da estrutura do banco de dados
		sunos.bd:remover("vila_"..meta:get_string("vila"), tipo.."_"..meta:get_string("estrutura"))
	
		-- Trocar bloco de fundamento por madeira
		minetest.set_node(pos, {name="default:tree"})
	
		-- Atualizar banco de dados da vila
		sunos.atualizar_bd_vila(vila)
		
		return
	end
	
end

-- Verificação de estrutura de casa defendida
sunos.estruturas.casa.defendido = function(pos)
	
	-- Verificar se tem um mob dos sunos comum por perto pertencente à mesma vila
	
	-- Verificar vila do fundamento
	local vila = minetest.get_meta(pos):get_string("vila")
	
	-- Analizar objetos (possiveis npcs) perto
	for _,obj in ipairs(minetest.get_objects_inside_radius(pos, (tonumber(minetest.get_meta(pos):get_string("dist"))))) do
		local ent = obj:get_luaentity() or {}
		if ent 
			and ent.name == "sunos:npc" -- Verifica se for npc comum
			and tonumber(ent.vila) == tonumber(vila) -- Verifica se é da mesma vila
		then 
			return true
		end
	end
	
	return false
	
end

-- Nodes criadores de vilas (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/casa/nodes.lua") 


