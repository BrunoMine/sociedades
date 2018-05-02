--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Cronograma de tarefas do NPC das casas
  ]]

-- Tradução de strings
local S = sunos.S

-- Atividades estruturadas
dofile(minetest.get_modpath("sunos").."/estruturas/casa/atividades.lua") 

-- Carregar roteiros
dofile(minetest.get_modpath("sunos").."/estruturas/casa/roteiros/lojista.lua") 
dofile(minetest.get_modpath("sunos").."/estruturas/casa/roteiros/caseiro.lua") 

-- Escolhe uma tarefa para o npc
sunos.estruturas.casa.escolher_roteiro_npc = function(pos, vila)
	
	-- Escolha padrao "caseiro"
	local escolha = "caseiro"
	
	-- Checkin padrão
	local checkin = {
		["0"] = pos,
		["1"] = pos,
		["2"] = pos,
		["3"] = pos,
		["4"] = pos,
		["5"] = pos,
		["6"] = pos,
		["7"] = pos,
		["8"] = pos,
		["9"] = pos,
		["10"] = pos,
		["11"] = pos,
		["12"] = pos,
		["13"] = pos,
		["14"] = pos,
		["15"] = pos,
		["16"] = pos,
		["17"] = pos,
		["18"] = pos,
		["19"] = pos,
		["20"] = pos,
		["21"] = pos,
		["22"] = pos,
		["23"] = pos,
	}
	
	local loja = sunos.verif_estrutura_existe(vila, "loja")
	
	-- Sorteia numero entre 1 e 100
	local s = math.random(1, 100)
	
	if s >= 1 and s <= 40 then -- minimo 40% é caseiro
		
		return "caseiro", checkin, "caseiro"
		
	elseif s >= 41 and s <= 70 and loja then -- 30% é lojista
	
		local dados_loja = sunos.bd.pegar("vila_"..vila, sunos.verif_estrutura_existe(vila, "loja"))
		
		checkin["7"] = dados_loja.estrutura.pos
		checkin["8"] = dados_loja.estrutura.pos
		checkin["9"] = dados_loja.estrutura.pos
		checkin["10"] = dados_loja.estrutura.pos
		checkin["11"] = dados_loja.estrutura.pos
		checkin["12"] = dados_loja.estrutura.pos
		
		return "lojista", checkin, "caseiro"
	end
	
	-- Os outros 30% tambem vira caseiro
	-- Se nao houver o escolhido, vira caseiro
	return "caseiro", checkin, "caseiro"
end

-- Atribuir cronograma de atividades no NPC caseiro e retorna uma agenda escolhida
sunos.estruturas.casa.atribuir_cronograma_npc = function(self, roteiro)
	
	-- Trabalha em casa
	if roteiro == "caseiro" then
		
		npc.occupations.initialize_occupation_values(self, "sunos_npc_caseiro")
	
	else
	
		npc.occupations.initialize_occupation_values(self, "sunos_npc_caseiro_"..roteiro)
		
	end
end

-- Atribuir roteiro ao bau
sunos.estruturas.casa.atribuir_cronograma_bau = function(pos)

	local meta = minetest.get_meta(pos)
	local vila = tonumber(meta:get_string("vila"))
	
	-- Escolher novo roteiro
	local roteiro, checkin, tipo_npc = sunos.estruturas.casa.escolher_roteiro_npc(pos, vila)
	
	-- Data da escolha
	local data = minetest.get_day_count()
	
	-- Registra checkins
	for time,pc in pairs(checkin) do
		sunos.npc_checkin.add_checkin(pc, pos, time)
	end
	
	-- Armazena dados no bau
	meta:set_string("sunos_npc_tipo", tipo_npc)
	meta:set_string("roteiro", roteiro)
	meta:set_string("sunos_mynpc_checkin", minetest.serialize(checkin))
	meta:set_string("data_roteiro", data)
	
end
