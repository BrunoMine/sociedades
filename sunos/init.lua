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
sunos.RARIDADE = 3


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
dofile(modpath.."/comum.lua")
dofile(modpath.."/estruturador.lua")
dofile(modpath.."/vila.lua")
dofile(modpath.."/mapgen.lua")
dofile(modpath.."/nodes.lua")
dofile(modpath.."/craftitens.lua")
dofile(modpath.."/comandos.lua")
dofile(modpath.."/interface.lua")
dofile(modpath.."/npc.lua")
dofile(modpath.."/casa_comunal.lua")
dofile(modpath.."/npc_casa_comunal.lua")
dofile(modpath.."/gerenciador_de_vilas.lua")
notificar("[OK]!")
