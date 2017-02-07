--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Inicializador de scripts
  ]]

-- Tabela global
sunos = {}


-- Configurações / Settings
--[[ 
	Quanto maior, mais raro (Minimo é 1).
	The larger, more rare (Minimo is 1).
  ]]
sunos.CHANCE = tonumber(minetest.setting_get("sunos_chance") or 100)


-- Notificador de Inicializador
local notificar = function(msg)
	if minetest.setting_get("log_mods") then
		minetest.debug("[SUNOS]"..msg)
	end
end

-- Modpath
local modpath = minetest.get_modpath("sunos")

-- Salvar dados variaveis
sunos.var = {}
-- Intervalo de tempo (em segundos) de verificação dos rastreadores de jogadores perto de fundamentos dos sunos
sunos.var.tempo_atualizar_jogadores_perto = 5
-- Tempo (em segundos) entre as verificações de estrutura obstruida
sunos.var.tempo_verif_estruturas = tonumber(minetest.setting_get("sunos_verif_fundamento") or 7)
-- Tempo (em segundos) em que uma casa comunal pode ficar em decadencia antes de perder o fundamento
sunos.var.tempo_decadencia = tonumber(minetest.setting_get("sunos_casa_comunal_decadencia") or 300)
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
	"farming:straw"
}



-- Banco de dados (Memor)
sunos.bd = memor.montar_bd()

-- Tabela de estruturas e funções
sunos.estruturas = {}

-- Carregar scripts
notificar("Carregando...")
dofile(modpath.."/intllib.lua")
dofile(modpath.."/rollback.lua")
dofile(modpath.."/diretrizes.lua")
dofile(modpath.."/comum.lua")
dofile(modpath.."/estrutural.lua")
dofile(modpath.."/verif_terreno.lua")
dofile(modpath.."/verif_estrutura.lua")
dofile(modpath.."/estruturador.lua")
dofile(modpath.."/vila.lua")
dofile(modpath.."/mapgen.lua")
dofile(modpath.."/gerenciador_de_vilas.lua")
dofile(modpath.."/inimigos.lua")
dofile(modpath.."/verif_guarda.lua")
dofile(modpath.."/verif_ataques.lua")
-- Nodes
dofile(modpath.."/nodes/rua.lua")
dofile(modpath.."/nodes/fundamento.lua")
dofile(modpath.."/nodes/bau.lua")
dofile(modpath.."/nodes/decor_repo.lua")
dofile(modpath.."/nodes/bancada.lua")
dofile(modpath.."/nodes/bancada_de_trabalho.lua")
-- Outros Recursos
dofile(modpath.."/craftitens.lua")
dofile(modpath.."/comandos.lua")
-- NPCs e interface basica
dofile(modpath.."/interface.lua")
dofile(modpath.."/npc/npc.lua")
dofile(modpath.."/npc/npc_casa_comunal.lua")
-- Estruturas básicas
dofile(modpath.."/estruturas/casa_comunal/init.lua")
dofile(modpath.."/estruturas/casa/init.lua")
dofile(modpath.."/estruturas/decor/init.lua")
-- Estruturas adicionais
dofile(modpath.."/estruturas/loja/init.lua")
notificar("[OK]!")
