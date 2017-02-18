--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Casa comunal
  ]]

-- Diretorio do mod
local modpath = minetest.get_modpath("sunos")

-- Tabela global de Casa Comunal
sunos.estruturas.comunal = {}

-- Diretrizes
dofile(minetest.get_modpath("sunos").."/estruturas/comunal/diretrizes.lua") 

-- Registros do NPC da casa (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/comunal/npc.lua") 

-- Interface de atendimento da casa comunal (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/comunal/interface.lua") 

-- Bau de casa dos sunos (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/comunal/bau.lua") 

local function pegar_node(pos)
	local node = minetest.get_node(pos)
	if node.name == "ignore" then
		minetest.get_voxel_manip():read_from_map(pos, pos)
		node = minetest.get_node(pos)
	end
	return node
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
sunos.estruturas.comunal.construir = function(pos, vila, nivel, verif_area)
	-- Validar argumentos de entrada
	if pos == nil then
		minetest.log("error", "[Sunos] Tabela pos nula (sunos.estruturas.comunal.construir)")
		return "Erro interno (pos nula)"
	end
	if nivel == nil then
		minetest.log("error", "[Sunos] variavel nivel nula (em sunos.estruturas.comunal.construir)")
		return "Erro interno (nivel nulo)"
	end
	if vila == nil then
		minetest.log("error", "[Sunos] variavel vila nula (em sunos.estruturas.comunal.construir)")
		return "Erro interno (vila inexistente)"
	end
	
	-- Distancia centro a borda padrão
	local dist = 6 
	
	-- Variaveis auxiliares
	local largura = 13
	
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
	
	-- Criar casa comunal
	-- Caminho do arquivo da estrutura
	local arquivo = modpath.."/schems/comunal/nivel_"..nivel..".13.mts"
	
	-- Criar estrutura
	minetest.place_schematic({x=pos.x-dist,y=pos.y,z=pos.z-dist}, arquivo, nil, nil, true)
	
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
	meta:set_string("tipo", "comunal") -- Numero da vila
	meta:set_string("estrutura", n_estrutura) -- Numero da estrutura
	meta:set_string("nivel", nivel) -- Nivel da casa comunal
	meta:set_string("dist", dist) -- Distancia centro a borda da estrutra
	meta:set_string("status", "ativa") -- Status da casa comunal
	meta:set_string("tempo", 0) -- Tempo de decadencia (em segundos)
	sunos.contabilizar_blocos_estruturais(pos) -- Armazena quantidade de nodes estruturais
	
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
	sunos.bd:salvar("vila_"..vila, "comunal", registros)
	
	-- Ajustar nodes da estrutura
	
	-- Ajustar baus
	-- Verifica se tem baus na estrutura montada
	local baus = minetest.find_nodes_in_area(
		{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
		{x=pos.x+dist, y=pos.y+15, z=pos.z+dist}, 
		{"sunos:bau_comunal"}
	)
	-- Salva dados da estrutura no bau dela
	for _,pos_bau in ipairs(baus) do
		local meta = minetest.get_meta(pos_bau)
		meta:set_string("obs", "n") -- Verifica se o bau está obstruido
		meta:set_string("vila", vila) -- Numero da vila
		meta:set_string("estrutura", n_estrutura) -- Numero da estrutura
		meta:set_string("pos_fundamento", minetest.serialize(pos)) -- Pos do fundamento
		meta:set_string("infotext", sunos.S("Bau da Casa Comunal dos Sunos"))
		
		-- Inicia temporizador
		minetest.get_node_timer(pos_bau):set(2, 0)
	end
	
	return true
end

-- Verificação do fundamento
sunos.estruturas.comunal.verif_fund = function(pos)
	local meta = minetest.get_meta(pos)
	local vila = meta:get_string("vila")
	if not vila then return end
	vila = tonumber(vila)
	local tipo = meta:get_string("tipo")
	local dist = tonumber(meta:get_string("dist"))
	local status = meta:get_string("status")
	
	-- Caso esteja ativa
	if status == "ativa" then
		if sunos.verificar_blocos_estruturais(pos) == false then -- Verificar Estrutura danificada
	
			-- Tornar estrutura em ruinas
			sunos.montar_ruinas(pos, dist)
	
			-- Inicia processo de decadencia da casa comunal
			meta:set_string("status", "destruida")
			meta:set_string("tempo", 0) -- Tempo de decadencia (em segundos)
		end

	-- Caso esteja em decadencia
	else
	
		local tempo = tonumber(meta:get_string("tempo")) + sunos.var.tempo_verif_estruturas
	
		if tempo > sunos.var.tempo_decadencia then
		
			-- Verifica se ainda tem habitantes mantem a decadencia
			local pop = sunos.bd:pegar("vila_"..vila, "pop_total")
			if pop > 0 then
				meta:set_string("tempo", 0)
			else
				-- Remove casa comunal de vez
				-- Remove do banco de dados
				sunos.bd:remover("vila_"..vila, "comunal")
			
				-- Trocar bloco de fundamento por madeira
				minetest.set_node(pos, {name="default:tree"})
			
				-- Atualizar banco de dados da vila
				sunos.atualizar_bd_vila(vila)
			end
		else
			meta:set_string("tempo", tempo) -- Salva o tempo que passou e continua a decadencia
		end
	end
end


-- Fundamento de casa comunal
--[[
	Esse é o node usado para construir uma casa comunal
]]
minetest.register_node("sunos:fundamento_comunal", {
	description = sunos.S("Fundamento de Casa Comunal dos Sunos"),
	tiles = {"default_tree_top.png^sunos_fundamento.png", "default_tree_top.png", "default_tree.png"},
	inventory_image = "sunos_inv_fundamento.png^sunos_inv_fundamento_comunal.png",
	wield_image = "sunos_inv_fundamento.png^sunos_inv_fundamento_comunal.png",
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
		
		if vila == "" or not vila then return minetest.chat_send_player(placer:get_player_name(), sunos.S("Vila abandonada")) end
		
		-- Verificar se a vila está abandonada
		if not sunos.bd:pegar("vila_"..vila, "estruturas") then
			return minetest.chat_send_player(placer:get_player_name(), sunos.S("Vila abandonada"))
		end
		
		-- Verificar se a vila pode criar uma nova casa comunal
		sunos.atualizar_bd_vila(vila) -- Atualizar o banco de dados
		
		-- Verificar se ainda existe um banco de dados da vila
		if sunos.bd:verif("vila_"..vila, "numero") == false then
			return minetest.chat_send_player(placer:get_player_name(), sunos.S("Vila abandonada"))
		end
		
		-- Verificar se ja existe uma casa comunal
		if sunos.bd:verif("vila_"..vila, "comunal") == true then
			return minetest.chat_send_player(placer:get_player_name(), sunos.S("Ja existe uma Casa Comunal nessa vila"))
		end
		
		local r = sunos.estruturas.comunal.construir(pointed_thing.under, vila, 1, true)
		if r == true then
			
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

