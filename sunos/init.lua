--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Inicializador de scripts
  ]]

-- Tabela global
sunos = {}

-- Versão do projeto
sunos.versao = "1.4"

-- Versoes compativeis
sunos.versao_comp = {}

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



-- Banco de dados (Memor)
sunos.bd = memor.montar_bd()

-- Tabela de dados volateis para jogadores online
sunos.online = memor.online()

-- Tabela de estruturas e funções
sunos.estruturas = {}

-- Carregar scripts
notificar("Carregando...")
dofile(modpath.."/tradutor.lua")
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
dofile(modpath.."/verif_defesa.lua")
dofile(modpath.."/verif_ataques.lua")
dofile(modpath.."/compatibilidade.lua")
dofile(modpath.."/editor_schems.lua")
dofile(modpath.."/caixa_de_area.lua")
dofile(modpath.."/ajuste_fornos.lua")
dofile(modpath.."/ajuste_estantes.lua")
dofile(modpath.."/rua_manip.lua")
-- Nodes
dofile(modpath.."/nodes/rua.lua")
dofile(modpath.."/nodes/fundamento.lua")
dofile(modpath.."/nodes/decor_repo.lua")
dofile(modpath.."/nodes/bancada.lua")
dofile(modpath.."/nodes/bancada_de_trabalho.lua")
-- Outros Recursos
dofile(modpath.."/craftitens.lua")
dofile(modpath.."/comandos.lua")
-- NPCs e interface basica
sunos.npcs = {} -- Tabela global de NPCs
dofile(modpath.."/npc/npc.lua")
-- Estruturas básicas
dofile(modpath.."/estruturas/comunal/init.lua")
dofile(modpath.."/estruturas/casa/init.lua")
dofile(modpath.."/estruturas/decor/init.lua")
-- Estruturas adicionais
dofile(modpath.."/estruturas/loja/init.lua")
notificar("[OK]!")
