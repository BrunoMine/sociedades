--
-- Mod Tror
--
-- Inicializador de scripts Lua
--


-- Verifica se o mod original tror presente
if minetest.get_modpath("tror") then return end

-- Notificador de Inicializador
local notificar = function(msg)
	if minetest.setting_get("log_mods") then
		minetest.debug("[TROR]"..msg)
	end
end

local modpath = minetest.get_modpath("sunos_tror")

-- Variavel global
tror = {}

-- Carregar scripts
notificar("Carregando scripts...")
dofile(modpath.."/troca.lua")
notificar("OK")

