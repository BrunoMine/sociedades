--
-- Mod PlaGen (Adaptado para modpack Sociedades)
--
-- Inicializador de scripts Lua
--

-- Verifica se o mod original tror presente
if minetest.get_modpath("plagen") then return end

-- Notificador de Inicializador
local notificar = function(msg)
	if minetest.setting_get("log_mods") then
		minetest.debug("[SOCIEDADES_PLAGEN]"..msg)
	end
end

local modpath = minetest.get_modpath("sociedades_plagen")

-- Variavel global
plagen = {}

-- Carregar scripts
notificar("Carregando scripts...")
dofile(modpath.."/planificador.lua")
dofile(modpath.."/nodes.lua")
notificar("OK")
