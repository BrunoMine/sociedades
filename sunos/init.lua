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

-- Banco de dados (Memor)
sunos.bd = memor.montar_bd()

-- Carregar scripts
notificar("Carregando...")
dofile(modpath.."/intllib.lua")
dofile(modpath.."/diretrizes.lua")
dofile(modpath.."/comum.lua")
dofile(modpath.."/estrutural.lua")
dofile(modpath.."/verif_terreno.lua")
dofile(modpath.."/estruturador.lua")
dofile(modpath.."/vila.lua")
dofile(modpath.."/mapgen.lua")
-- Nodes
dofile(modpath.."/nodes/rua.lua")
dofile(modpath.."/nodes/fundamento.lua")
dofile(modpath.."/nodes/bau.lua")
dofile(modpath.."/nodes/decor_repo.lua")
dofile(modpath.."/nodes/bancada.lua")
dofile(modpath.."/nodes/bancada_de_trabalho.lua")
dofile(modpath.."/craftitens.lua")
dofile(modpath.."/comandos.lua")
dofile(modpath.."/interface.lua")
dofile(modpath.."/npc/npc.lua")
-- Recusos básicos
dofile(modpath.."/estruturas/casa_comunal.lua")
dofile(modpath.."/npc/npc_casa_comunal.lua")
dofile(modpath.."/gerenciador_de_vilas.lua")
-- Estruturas adicionadas
dofile(modpath.."/estruturas/casa.lua")
dofile(modpath.."/estruturas/decor.lua")
dofile(modpath.."/estruturas/loja.lua")
notificar("[OK]!")
