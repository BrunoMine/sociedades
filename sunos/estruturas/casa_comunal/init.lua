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

-- Tabela global de Casa Comunal
sunos.estruturas.casa_comunal = {}

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
		<n_estrutura> é o numero da estrutura da casa comunal
		<force_area> OPCIONAL | Para ignorar as verificações de area limpa
  ]]
sunos.estruturas.casa_comunal.construir = function(pos, vila, nivel, n_estrutura, force_area)
	-- Validar argumentos de entrada
	if pos == nil then
		minetest.log("error", "[Sunos] Tabela pos nula (sunos.estruturas.casa_comunal.construir)")
		return "Erro interno (pos nula)"
	end
	if nivel == nil then
		minetest.log("error", "[Sunos] variavel nivel nula (em sunos.estruturas.casa_comunal.construir)")
		return "Erro interno (nivel nulo)"
	end
	if vila == nil then
		minetest.log("error", "[Sunos] variavel vila nula (em sunos.estruturas.casa_comunal.construir)")
		return "Erro interno (vila inexistente)"
	end
	if n_estrutura == nil then
		minetest.log("error", "[Sunos] variavel n_estrutura nula (em sunos.estruturas.casa_comunal.construir)")
		return "Erro interno (Numero de estrutura inexistente)"
	end
	
	-- Distancia centro a borda padrão
	local dist = 6 
	
	-- Variaveis auxiliares
	local largura = 13
	
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
	
	-- Criar casa comunal
	-- Caminho do arquivo da estrutura
	local arquivo = modpath.."/schems/casa_comunal/nivel_"..nivel..".13.mts"
	
	-- Criar estrutura
	minetest.place_schematic({x=pos.x-dist,y=pos.y,z=pos.z-dist}, arquivo, nil, nil, true)
	
	-- Criar fundamento e configurar
	minetest.set_node(pos, {name="sunos:fundamento"})
	local meta = minetest.get_meta(pos)
	meta:set_string("vila", vila) -- Numero da vila
	meta:set_string("tipo", "casa_comunal") -- Numero da vila
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
	sunos.bd:salvar("vila_"..vila, "casa_comunal", registros)
	
	-- Ajustar nodes da estrutura
	
	-- Ajustar baus
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
		meta:set_string("estrutura", n_estrutura) -- Numero da estrutura
		meta:set_string("pos_fundamento", minetest.serialize(pos)) -- Pos do fundamento
		meta:set_string("infotext", sunos.S("Bau da Casa Comunal dos Sunos"))
	end
	
	return true
end

-- Verificação do fundamento
sunos.estruturas.casa_comunal.verif_fund = function(pos)
	local meta = minetest.get_meta(pos)
	local vila = meta:get_string("vila")
	if not vila then return end
	vila = tonumber(vila)
	local tipo = meta:get_string("tipo")
	local dist = tonumber(meta:get_string("dist"))
	
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
				sunos.bd:remover("vila_"..vila, "casa_comunal")
			
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

-- Chamada de on_rightclick de fundamento colocado
sunos.estruturas.casa_comunal.fund_on_rightclick = function(pos, node, player, itemstack, pointed_thing)
	local meta = minetest.get_meta(pos)
	local vila = meta:get_string("vila")
	local tipo = meta:get_string("tipo")
		
	if meta:get_string("status") == "destruida" then
		if itemstack:get_name() == "sunos:kit_reparador" then
			local n_estrutura = meta:get_string("estrutura")
		
			-- Obter dados do fundamento
			local nivel = meta:get_string("nivel")
			local n_estrutura = meta:get_string("estrutura")
		
			-- Alterar o status para permitir que seja destruido para ser remontada
			meta:set_string("status", "recon") 
		
			-- Construir casa comunal nova
			local r = sunos.construir_casa_comunal(pos, vila, nivel, n_estrutura, true)
		
			if r == true then
				-- Salvar novo total de estruturas da vila
				sunos.bd:salvar("vila_"..vila, "estruturas", n_estrutura)

				-- Retorna mensagem de montagem concluida
				minetest.chat_send_player(player:get_player_name(), sunos.S("Casa Comunal reconstruida"))
				itemstack:take_item()
				return itemstack
			else
				-- Retorna mensagem de falha
				minetest.chat_send_player(player:get_player_name(), r)
				return itemstack
			end
		else
			minetest.chat_send_player(player:get_player_name(), sunos.S("Casa Comunal em decadencia. Use o Kit de Reparo"))
		end
	end
end

-- Chamada on_destruct personalizada
sunos.estruturas.casa_comunal.fund_on_destruct = function(pos)
	local meta = minetest.get_meta(pos)
	local vila = meta:get_string("vila")
	local tipo = meta:get_string("tipo")
	local dist = meta:get_string("dist")
	
	local status = meta:get_string("status")
	
	if status ~= "recon" then
		sunos.montar_ruinas(pos, dist)
		sunos.bd:remover("vila_"..meta:get_string("vila"), "casa_comunal")
	end
end

-- Chamada personalizada para momento de atualização da vila
sunos.estruturas.casa_comunal.atualizando_vila = function(vila, arq, reg)
	
	-- Verifica se o fundamento ainda existe
	local n = pegar_node(reg.estrutura.pos)
	if n.name ~= "sunos:fundamento" then

		-- Elimina o arquivo
		sunos.bd:remover("vila_"..vila, arq)
	
	else
	
		-- Verifica se os metadados estao correspondendo ao banco
		local meta = minetest.get_meta(reg.estrutura.pos)
	
		if not meta:get_string("vila") or tonumber(meta:get_string("vila")) ~= vila then
	
			--Elimina o arquivo
			sunos.bd:remover("vila_"..vila, arq)
		
		end
	
	end

end

-- Fundamento de casa comunal
--[[
	Esse é o node usado para construir uma casa comunal
]]
minetest.register_node("sunos:fundamento_casa_comunal", {
	description = sunos.S("Fundamento de Casa Comunal dos Sunos"),
	tiles = {"default_tree_top.png^sunos_fundamento.png", "default_tree_top.png", "default_tree.png"},
	inventory_image = "sunos_inv_fundamento.png^sunos_inv_fundamento_casa_comunal.png",
	wield_image = "sunos_inv_fundamento.png^sunos_inv_fundamento_casa_comunal.png",
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
		
		-- Numero da estrutura da nova casa comunal
		local n_estrutura = sunos.bd:pegar("vila_"..vila, "estruturas")+1 -- Numero da nova estrutura
		
		-- Verificar se a vila pode criar uma nova casa comunal
		sunos.atualizar_bd_vila(vila) -- Atualizar o banco de dados
		
		-- Verificar se ainda existe um banco de dados da vila
		if sunos.bd:verif("vila_"..vila, "numero") == false then
			return minetest.chat_send_player(placer:get_player_name(), sunos.S("Vila abandonada"))
		end
		
		-- Verificar se ja existe uma casa comunal
		if sunos.bd:verif("vila_"..vila, "casa_comunal") == true then
			return minetest.chat_send_player(placer:get_player_name(), sunos.S("Ja existe uma Casa Comunal nessa vila"))
		end
		
		local r = sunos.estruturas.casa_comunal.construir(pointed_thing.under, vila, 1, n_estrutura)
		if r == true then
			-- Salvar novo total de estruturas da vila
			sunos.bd:salvar("vila_"..vila, "estruturas", n_estrutura)
			
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

-- Bau da casa comunal (para spawnar atendentes)
--[[
	Esse é o node usado para construir uma casa comunal
]]
minetest.register_node("sunos:bau_casa_comunal", {
	description = sunos.S("Bau da Casa Comunal dos Sunos"),
	tiles = {"default_chest_top.png^sunos_bau_topo.png", "default_chest_top.png", "default_chest_side.png^sunos_bau_lado.png",
		"default_chest_side.png^sunos_bau_lado.png", "default_chest_side.png^sunos_bau_lado.png", "default_chest_lock.png^sunos_bau_frente.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	stack_max = 1,
	drop = "default:chest",
})

