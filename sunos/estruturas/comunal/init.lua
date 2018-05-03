--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Casa comunal
  ]]

-- Tradução de strings
local S = sunos.S

-- Diretorio do mod
local modpath = minetest.get_modpath("sunos")

-- Tabela global de Casa Comunal
sunos.estruturas.comunal = {}

-- Diretrizes
dofile(modpath.."/estruturas/comunal/diretrizes.lua") 

-- Bau de casa dos sunos (carregamento de script)
dofile(modpath.."/estruturas/comunal/bau.lua") 

-- Registros do NPC da casa (carregamento de script)
dofile(modpath.."/estruturas/comunal/npc.lua") 

-- Interface de atendimento da casa comunal (carregamento de script)
dofile(modpath.."/estruturas/comunal/interface.lua") 

-- Nodes estruturais
local nodes_estruturais = sunos.estruturas.comunal.var.nodes_estruturais

local function pegar_node(pos)
	local node = minetest.get_node(pos)
	if node.name == "ignore" then
		minetest.get_voxel_manip():read_from_map(pos, pos)
		node = minetest.get_node(pos)
	end
	return node
end


-- Verificar nivel de acordo com a populacao
local verif_nivel = function(pop)
	if not pop then return end
	local pop = tonumber(pop)
	for n,p in ipairs(sunos.estruturas.comunal.var.niveis) do
		if n == table.maxn(sunos.estruturas.comunal.var.niveis) then
			return n
		end
		if pop >= p and pop < sunos.estruturas.comunal.var.niveis[n+1] then
			return n
		end
	end
	
	-- Caso pop nao seja menor que nenhum dos niveis (maior que todos os exigidos) retorna nivel maximo
	return table.maxn(sunos.estruturas.comunal.var.niveis)
	
end


-- Configurar baus de uma estrutura
local set_bau = function(pos, vila, dist)

	-- Ajustar baus
	-- Verifica se tem baus na estrutura montada
	local baus = minetest.find_nodes_in_area(
		{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
		{x=pos.x+dist, y=pos.y+15, z=pos.z+dist}, 
		{"default:chest"}
	)
	-- Salva dados da estrutura no bau dela
	for _,pos_bau in ipairs(baus) do
		local node = minetest.get_node(pos_bau)
		minetest.set_node(pos_bau, {name="sunos:bau_comunal", param2=node.param2})
		local meta = minetest.get_meta(pos_bau)
		meta:set_string("vila", vila) -- Numero da vila
		meta:set_string("pos_fundamento", minetest.serialize(pos)) -- Pos do fundamento
		meta:set_string("infotext", S("Bau da Casa Comunal dos Sunos"))
		
		sunos.npcnode.set_npcnode(pos_bau, {
			tipo = "comunal",
			occupation = "sunos:atendente_comunal",
			checkin = sunos.npc_checkin.montar_checkin_simples(pos_bau),
		})
	end
end

-- Tabela para valores de rotação
local tb_rotat = {"0", "90", "180", "270"}

-- Verificar se pode construir e envontra vila 
sunos.estruturas.comunal.verif = function(pos, nivel, verif_area)
	
	-- Validar argumentos de entrada
	if pos == nil then
		minetest.log("error", "[Sunos] Tabela pos nula (sunos.estruturas.comunal.construir)")
		return "Erro interno (pos nula)"
	end
	if nivel == nil then
		minetest.log("error", "[Sunos] variavel nivel nula (em sunos.estruturas.comunal.construir)")
		return "Erro interno (nivel nulo)"
	end
	
	local vila
	
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
	
	-- Verificar casa comunal ja existente
	if sunos.bd.verif("vila_"..vila, "comunal") == true then
		return S("Ja existe @1 nessa vila", "Casa Comunal")
	end
	
	-- Distancia centro a borda padrão
	local dist = 6 
	
	-- Variaveis auxiliares
	local largura = 13
	
	-- Verificações de area
	if verif_area == true then
		local r = sunos.verificar_area_para_fundamento(pos, dist)
		if r ~= true then
			return r
		end
	end
	
	return true, vila
end

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
		<verif_area> OPCIONAL | Para ignorar as verificações de area limpa
		<update> OPCIONAL | Informa que se trata de uma atualização de uma estrutura que ja existe
  ]]
sunos.estruturas.comunal.construir = function(pos, nivel, verif_area)
	
	-- Verifica se pode construir a casa comunal
	local verif, vila = sunos.estruturas.comunal.verif(pos, nivel, verif_area)
	if verif ~= true then
		return verif
	end
	
	-- Distancia centro a borda padrão
	local dist = 6 
	
	-- Variaveis auxiliares
	local largura = 13
	local pos1 = {x=pos.x-dist, y=pos.y, z=pos.z-dist}
	local pos2 = {x=pos.x+dist, y=pos.y+14, z=pos.z+dist}
	
	-- Limpar metadados dos nodes que possam estar la
	sunos.limpar_metadados(pos1, pos2)
	
	-- Criar casa comunal
	
	-- Escolhe uma rotação aleatória
	local rotat = tb_rotat[math.random(1, 4)]
	
	-- Pegar nivel
	local nivel = verif_nivel(sunos.bd.pegar("vila_"..vila, "pop_total"))
	
	-- Atualizar schem do nivel
	local schem = "nivel_" .. nivel
	
	-- Caminho do arquivo da estrutura
	local arquivo = modpath.."/schems/comunal/"..schem..".13.mts"
	
	-- Criar estrutura
	minetest.place_schematic({x=pos.x-dist,y=pos.y,z=pos.z-dist}, arquivo, rotat, sunos.var.nodes_trocados, true)
	
	-- Numero da estrutura
	local n_estrutura = 0
	if update then
		-- Pega o antigo numero de estrutura
		n_estrutura = sunos.bd.pegar("vila_"..vila, "estruturas")
	else
		-- Pega um novo numero de estrutura
		n_estrutura = sunos.nova_estrutura(vila) -- Numero da estrutura da nova casa comunal
	end
	
	-- Criar fundamento e configurar
	minetest.set_node(pos, {name="sunos:fundamento"})
	local meta = minetest.get_meta(pos)
	meta:set_string("versao", sunos.versao) -- Salva a versão atual do projeto
	meta:set_string("vila", vila) -- Numero da vila
	meta:set_string("schem", schem) -- Nome do arquivo da esquematico da estrutura
	meta:set_string("rotat", rotat) -- Rotação da estrutura
	meta:set_string("tipo", "comunal") -- Numero da vila
	meta:set_string("estrutura", n_estrutura) -- Numero da estrutura
	meta:set_string("nivel", nivel) -- Nivel da casa comunal
	meta:set_string("dist", dist) -- Distancia centro a borda da estrutra
	meta:set_string("tempo", 0) -- Tempo de decadencia (em segundos)
	sunos.contabilizar_blocos_estruturais(pos, nodes_estruturais) -- Armazena quantidade de nodes estruturais
	
	-- Salvar nova dados da estrutura no banco de dados da vila
	local registros = {
		vila = vila, -- Numero da vila
		nivel = nivel, -- Nivel da Casa Comunal
		estrutura = {
			dist = dist,
			largura = largura,
			pos = pos
		}
	}
	sunos.bd.salvar("vila_"..vila, "comunal", registros)
	
	-- Ajustar nodes da estrutura
	
	-- Ajustar baus
	set_bau(pos, vila, dist)
	
	-- Remover jogadores da area construida (evitar travar em paredes)
	sunos.ajustar_jogadores(pos)
	
	return true
end


-- Verificação do fundamento
sunos.estruturas.comunal.verificar = function(pos)
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
		sunos.bd.remover("vila_"..meta:get_string("vila"), "comunal")
		
		-- Trocar bloco de fundamento por madeira
		minetest.set_node(pos, {name="default:tree"})
	
		-- Atualizar banco de dados da vila
		sunos.atualizar_bd_vila(vila)
		
	end
	
end


-- Fundamento de casa comunal
--[[
	Esse é o node usado para construir uma casa comunal
]]
minetest.register_node("sunos:fundamento_comunal", {
	description = S("Fundamento de Casa Comunal dos Sunos"),
	tiles = {"default_tree_top.png^sunos_fundamento.png", "default_tree_top.png", "default_tree.png"},
	inventory_image = "sunos_fundamento_fundo_inv.png^sunos_fundamento_comunal_inv.png",
	wield_image = "sunos_fundamento_estrutura_namao.png^sunos_fundamento_comunal_namao.png",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	stack_max = 1,
	
	-- Colocar uma casa comunal
	on_place = function(itemstack, placer, pointed_thing)
		
		local pos = pointed_thing.under
		
		local r = sunos.estruturas.comunal.verif(pos, 1, verif_area)
		
		if r == true then
			
			-- Coloca rua em torno
			sunos.colocar_rua(pos, 5)
			
			-- Coloca fundamento step para construir estrutura
			minetest.set_node(pointed_thing.under, {name="sunos:fundamento_step"})
			local meta = minetest.get_meta(pos)
			meta:set_string("tipo", "comunal")
			meta:set_string("dist", 6)
			meta:set_string("versao", sunos.versao)
			meta:set_string("vila", vila)
			meta:set_string("step", 1)
			meta:set_string("data_inicio", minetest.get_day_count())
			meta:set_string("tempo_inicio", minetest.get_timeofday())
			meta:set_string("duracao", 24000) -- 1 dia no jogo
			meta:set_string("schem", "nivel_1")
			meta:set_string("rotat", sunos.pegar_rotat())
			minetest.get_node_timer(pos):set(0.1, 0) -- Inicia temporizador
			
			-- Retorna mensagem de montagem concluida
			minetest.chat_send_player(placer:get_player_name(), S("Casa Comunal sendo construida"))
			itemstack:take_item()
			return itemstack
			
		else
			-- Mostra area necessaria
			sunos.criar_caixa_de_area(pointed_thing.under, 6+2)
			-- Retorna mensagem de falha
			minetest.chat_send_player(placer:get_player_name(), r)
			return itemstack
		end
	end,
})

-- Reforma as casas aleatoriamente
minetest.register_abm({
	label = "Reforma da casa comunal",
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
		if tipo ~= "comunal" then return end
		local dist = tonumber(meta:get_string("dist"))
		local schem = meta:get_string("schem")
		local rotat = meta:get_string("rotat")
		local nivel = meta:get_string("nivel")
		if schem == "" then return end
		
		-- Atualizar schem do nivel
		schem = "nivel_" .. verif_nivel(sunos.bd.pegar("vila_"..vila, "pop_total"))
		
		-- Caminho do arquivo da estrutura
		local caminho_arquivo = modpath.."/schems/"..tipo.."/"..schem..".13.mts"
		
		-- Criar estrutura
		minetest.place_schematic({x=pos.x-dist, y=pos.y, z=pos.z-dist}, caminho_arquivo, nil, nil, true)
		
		table.schem = schem
		minetest.set_node(pos, {name="sunos:fundamento"})
		minetest.get_meta(pos):from_table(table) -- recoloca metadados no novo fumdamento
		
		-- Ajustar baus
		set_bau(pos, vila, dist)
		
	end,
})

