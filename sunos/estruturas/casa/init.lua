--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Casa dos sunos
  ]]

-- Tradução de strings
local S = sunos.S

-- Tabela global de Casa
sunos.estruturas.casa = {}

-- Esse tipo de estrutura tem população
sunos.estruturas.casa.pop = true

-- Diretrizes das casas (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/casa/diretrizes.lua") 

-- Métodos para gerar tabelas de itens para reposição de nodes (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/casa/repo_nodes.lua") 

-- Bau de casa dos sunos (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/casa/bau.lua") 

-- Registros do NPC da casa (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/casa/npc.lua") 

-- Registros do NPC da casa (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/casa/interface.lua") 




-- Nodes estruturais de uma casa
local nodes_estruturais = sunos.estruturas.casa.var.nodes_estruturais

-- Buscar nodes numa casa
sunos.estruturas.casa.buscar_nodes = function(pos, nodes)
	local meta = minetest.get_meta(pos)
	local dist = meta:get_string("dist")
	return minetest.find_nodes_in_area(
		{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
		{x=pos.x+dist, y=pos.y+14, z=pos.z+dist}, 
		nodes
	)
end

local set_bau = function(pos, vila, dist)

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
		meta:set_string("pos_fundamento", minetest.serialize(pos)) -- Pos do fundamento
		meta:set_string("infotext", S("Bau da Casa dos Sunos"))
	end

end

-- Verifica a possibilidade de construir uma casa no local
sunos.estruturas.casa.verif = function(pos, dist, vila, verif_area, verif_pop)

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
			return S("Nenhuma vila por perto")
		end
	
		-- Pegar dados da vila encontrada
		local meta_fund_prox = minetest.get_meta(pos_fund_prox)
		vila = meta_fund_prox:get_string("vila")
	
		-- Verificar se ainda existe um banco de dados da vila
		if sunos.bd.verif("vila_"..vila, "numero") == false then
			return S("Vila abandonada")
		end
	end
	
	-- Verificar se a vila ja atingiu limite
	if verif_pop then
		if sunos.verif_pop_vila(vila) ~= true then
			return S("Limite de @1 habitantes foi atingido", sunos.var.max_pop)
		end
	end
	
	-- Verificações de area
	if verif_area == true then
		
		-- Verifica status do terreno
		local st = sunos.verif_terreno(pos, dist+1)
		
		-- Problema: em cima da faixa de solo existem obstrucoes (nao esta limpo e plano)
		if st == 1 then
			return S("O local precisa estar limpo e plano em uma area de @1x@1 blocos da largura", (largura+2))
		
		-- Problema: faixa de solo (superficial) falta blocos de terra
		elseif st == 2 then
			return S("O solo precisa estar plano e gramado em uma area de @1x@1 blocos da largura", (largura+2))
		
		-- Problema: faixa de subsolo (considerando 2 faixas) falta blocos de terra
		elseif st == 3 then
			return S("O subsolo precisa estar preenchido (ao menos 2 blocos de profundidade) em uma area de @1x@1 blocos da largura", (largura+2))
		end
	end
	
	return true, vila
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
		<verif_pop> OPCIONAL | Para verificações de população da vila
  ]]
sunos.estruturas.casa.construir = function(pos, dist, vila, verif_area, itens_repo, verif_pop)
	
	-- Verifica se pode construir a casa
	local verif, vila = sunos.estruturas.casa.verif(pos, dist, vila, verif_area, verif_pop)
	if verif ~= true then
		return verif
	end
	
	-- Variaveis auxiliares
	local largura = (dist*2)+1
	
	-- Escolhe uma rotação aleatória
	local rotat = sunos.pegar_rotat()
	
	-- Criar casa e pega o nome do arquivo da estrutura
	local rm, schem = sunos.montar_estrutura(pos, dist, "casa", rotat)
	
	-- Recoloca itens reais (apartir dos itens de reposição)
	if itens_repo then
		sunos.decor_repo(pos, dist, sunos.estruturas.casa.gerar_itens_repo[tostring(dist)]())
	end
	
	-- Ajustar fornos
	sunos.ajustar_fornos(pos, dist)
	
	-- Ajustar estantes
	sunos.ajustar_estantes_livro(pos, dist, sunos.estruturas.casa.var.estante_livros) -- livros
	sunos.ajustar_estantes_frasco(pos, dist, sunos.estruturas.casa.var.estante_frascos) -- frascos
	
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
	sunos.contabilizar_blocos_estruturais(pos, nodes_estruturais) -- Armazena quantidade de nodes estruturais
	
	-- Configurar bau de casas
	minetest.after(1, set_bau, {x=pos.x,y=pos.y,z=pos.z}, vila, dist)
	
	-- Registros a serem salvos
	local registros = {
		numero = n_estrutura,
		tipo = "casa",
		pop = sunos.estruturas.casa.var.tb_pop_casa[tostring(largura)] or 1,
		estrutura = {
			dist = dist,
			largura = largura,
			pos = pos
		}
	}
	
	-- Salva no banco de dados
	sunos.bd.salvar("vila_"..vila, "casa_"..n_estrutura, registros)
	
	-- Salvar novo total de estruturas da vila
	sunos.bd.salvar("vila_"..vila, "estruturas", n_estrutura)
	
	-- Remover jogadores da area construida (evitar travar em paredes)
	sunos.ajustar_jogadores(pos)
	
	return true
end

-- Verificação do fundamento
sunos.estruturas.casa.verificar = function(pos)
	local meta = minetest.get_meta(pos)
	local vila = meta:get_string("vila")
	if not vila then return end
	vila = tonumber(vila)
	local tipo = meta:get_string("tipo")
	local dist = tonumber(meta:get_string("dist"))
	local nd = tonumber(meta:get_string("nodes")) -- numero de nodes inicial
	
	-- Pega o numero de nodes real
	local ndrl = sunos.verificar_blocos_estruturais(pos, nodes_estruturais)
	
	-- Verifica se a casa está muito destruida
	if ndrl < nd - 4 then
	
		-- Exclui o arquivo da estrutura do banco de dados
		sunos.bd.remover("vila_"..meta:get_string("vila"), tipo.."_"..meta:get_string("estrutura"))
		
		-- Trocar bloco de fundamento por madeira
		minetest.set_node(pos, {name="default:tree"})
	
		-- Atualizar banco de dados da vila
		sunos.atualizar_bd_vila(vila)
		
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

-- Nodes (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/casa/nodes.lua") 

-- Caminho do diretório do mod
local modpath = minetest.get_modpath("sunos")

-- Reforma as casas aleatoriamente
minetest.register_abm({
	label = "Reforma da casa",
	nodenames = {"sunos:fundamento"},
	interval = 600,
	chance = 4,
	action = function(pos)
	
		local meta = minetest.get_meta(pos)
		local table = meta:to_table() -- salva metadados numa tabela
		local vila = meta:get_string("vila")
		if vila == "" then return end
		vila = tonumber(vila)
		local tipo = meta:get_string("tipo")
		if tipo ~= "casa" then return end
		local dist = tonumber(meta:get_string("dist"))
		local schem = meta:get_string("schem")
		local rotat = meta:get_string("rotat")
		if schem == "" then return end
	
		-- Remonta estrutura
		sunos.montar_estrutura(pos, dist, "casa", rotat, schem)
		
		-- Troca os itens de reposição
		sunos.decor_repo(pos, dist, sunos.estruturas.casa.gerar_itens_repo[tostring(dist)]())
		
		-- Estantes e fornos se mantem altomaticamente por sobreposição
		
		-- Reestabelece fundamento
		minetest.set_node(pos, {name="sunos:fundamento"})
		minetest.get_meta(pos):from_table(table) -- recoloca metadados no novo fumdamento
		
		-- Configura novos baus
		set_bau({x=pos.x,y=pos.y,z=pos.z}, vila, dist)
	end,
})

