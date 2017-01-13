--[[
	Mod Sovagxas para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Inicializador de scripts
  ]]

-- Variavel grobal dos metodos
sovagxas = {}

-- DIRETRIZES
-- Raridade de arvores de sovagxas (chance de 1 em N definido) (numero inteiro maior que zero)
sovagxas.CHANCE = tonumber(minetest.setting_get("sovagxas_CHANCE") or 75)

-- Itens que aparecem no bau
sovagxas.itens_bau = {
-- 		Item							qtd min		qtd max		raridade (em porcentagem de 0.1% a 100%)
	{	"default:stick",					10,		25,		65		},
	{	"default:jungletree",					5,		10,		25		},
	{	"default:axe_wood",					1,		1,		15		},
	{	"default:axe_stone",					1,		1,		15		},
	{	"default:sword_stone",					1,		1,		5		},
	{	"default:sword_wood",					1,		1,		10		},
	{	"default:dirt",						10,		15,		25		},
	{	"default:junglewood",					15,		25,		40		},
	{	"default:apple",					10,		15,		15		},
	{	"default:cobble",					10,		15,		25		},
	{	"default:coal_lump",					3,		7,		15		},
	{	"default:torch",					5,		10,		15		},
	{	"default:shovel_wood",					1,		1,		25		},
	{	"default:shovel_stone",					1,		1,		20		},
	{	"default:pick_wood",					1,		1,		20		},
	{	"default:junglesapling",				2,		5,		15		},
	{	"farming:seed_algodao",					3,		8,		15		},
}

-- Notificador de Inicializador
local notificar = function(msg)
	if minetest.setting_get("log_mods") then
		minetest.debug("[SOVAGXAS]"..msg)
	end
end

-- Modpath
local modpath = minetest.get_modpath("sovagxas")

-- Carregar scripts
notificar("Carregando...")
dofile(modpath.."/nodes.lua")
dofile(modpath.."/npc.lua")
dofile(modpath.."/arvore.lua")
dofile(modpath.."/mapgen.lua")
notificar("[OK]!")
