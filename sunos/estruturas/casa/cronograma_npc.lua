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

-- Escolhe uma tarefa para o npc durante o dia
sunos.estruturas.casa.escolher_roteiro_npc = function(vila)
	
	-- Escolha padrao "caseiro"
	local escolha = "caseiro"
	
	local loja = sunos.verif_estrutura_existe(vila, "loja")
	
	-- Sorteia numero entre 1 e 100
	local s = math.random(1, 100)
	
	if s >= 1 and s <= 40 then -- minimo 40% é caseiro
		return "caseiro"
	elseif s >= 41 and s <= 70 and loja then -- 30% é lojista
		return "lojista"
	end
	
	-- Os outros 30% tambem vira caseiro
	
	-- Se nao houver o escolhido, vira caseiro
	return "caseiro"
end

-- Atribuir cronograma de atividades no NPC caseiro e retorna uma agenda escolhida
sunos.estruturas.casa.atribuir_cronograma_npc = function(self, roteiro, data)
		
	roteiro = roteiro or sunos.estruturas.casa.escolher_roteiro_npc(self.vila)
	data = data or minetest.get_day_count()
	
	-- Trabalha em casa
	if roteiro == "caseiro" then
		
		npc.occupations.initialize_occupation_values(self, "sunos_npc_caseiro")
		
	-- Visita lojas da cidade
	elseif roteiro == "lojista" then
	
		local dados_loja = sunos.bd.pegar("vila_"..self.vila, sunos.verif_estrutura_existe(self.vila, "loja"))
		
		-- Configura checkin
		sunos.npcs.npc.set_checkin(self, dados_loja.estrutura.pos, 7, 12)
		npc.places.add_shared(self, "sunos_feirinha_1", "sunos_feirinha", sunos.copy_tb(dados_loja.estrutura.pos), acesso)
		
		
		npc.occupations.initialize_occupation_values(self, "sunos_npc_caseiro_"..roteiro)
		
	end
	
	-- Salva roteiro no NPC
	self.roteiro = roteiro
	self.data_roteiro = data
	-- Salva no bau
	local meta = minetest.get_meta(self.mypos)
	meta:set_string("roteiro", roteiro)
	meta:set_string("data_roteiro", data)
	
end

