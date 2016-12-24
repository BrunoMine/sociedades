--[[
	Mod Memor para Minetest
	Memor v1.2 Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Inicializador de scripts
  ]]
  
-- Verifica se o mod memor original esta ativo
if minetest.get_modpath("memor") then return end


-- Notificador de Inicializador
local notificar = function(msg)
	if minetest.setting_get("log_mods") then
		minetest.debug("[MEMOR]"..msg)
	end
end

local modpath = minetest.get_modpath("sunos_memor")

-- Variavel global
memor = {}

-- Carregar scripts
notificar("Carregando scripts...")
dofile(modpath.."/arquivo.lua")
dofile(modpath.."/consulta.lua")
dofile(modpath.."/montagem.lua")
dofile(modpath.."/online.lua")
notificar("OK")

