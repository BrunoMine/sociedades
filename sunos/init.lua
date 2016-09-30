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

-- Tabela do menu da casa comunal 
--[[
	Ordenar de cima para baixo em ordem de mais valiosos até os menos valiosso)
  ]]
sunos.tb_menu_casa_comunal = {
	["Kit Reparador"] = { -- Nome do items
		desc = "Esse Kit serve para reconstruir uma estrutura do povo Suno",
		pop = 5, -- População necessaria
		item_add = "sunos:kit_reparador", -- Item a receber (apenas 1 item e 1 unidade)
		item_rem = {"default:tree 20", "default:cobble 20", "wool:yellow 5"} -- Itens a pagar (de 1 a 14 itens diferentes de qualquer quantidade) 
	},
}

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
