--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Diretrizes gerais
  ]]


-- Salvar dados variaveis
sunos.var = {}


-- Intervalo de tempo (em segundos) que uma vila se mantem inimigo de um jogador apos ser atacada
sunos.var.tempo_inimigo = 300

-- Intervalo de tempo (em segundos) de verificação dos rastreadores de jogadores perto de fundamentos dos sunos
sunos.var.tempo_atualizar_jogadores_perto = 5

-- Tempo (em segundos) entre as verificações de estrutura obstruida
sunos.var.tempo_verif_estruturas = tonumber(minetest.setting_get("sunos_verif_fundamento") or 60)

-- Tempo (em segundos) em que uma casa comunal pode ficar em decadencia antes de perder o fundamento
sunos.var.tempo_decadencia = tonumber(minetest.setting_get("sunos_comunal_decadencia") or 300)

-- Lista de nodes estruturais
--[[
	Esses nodes são considerados importantes nas estruturas pois, 
	caso eles sejam removidos pelo jogador, a estrutura deve ser limpa
  ]]
sunos.var.nodes_estruturais = {
	"default:wood", 
	"default:cobble", 
	"default:stonebrick", 
	"group:stair", 
	"group:slab", 
	"farming:straw"
}

-- Nodes trocados na montagem de qualquer estrutura
sunos.var.nodes_trocados = {
	["default:bookshelf"] = "sunos:default_bookshelf_nodrop",
	["vessels:shelf"] = "sunos:vessels_shelf_nodrop",
	["sunos:bancada"] = "sunos:bancada_nodrop",
	["sunos:bancada_de_trabalho"] = "sunos:bancada_de_trabalho_nodrop",
	["sunos:carpete_palha"] = "sunos:carpete_palha_nodrop",
	["sunos:tear_palha"] = "sunos:tear_palha_nodrop",
}
