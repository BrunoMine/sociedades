--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Diretrizes gerais
  ]]

-- Tabela do menu da casa comunal 
sunos.tb_menu_casa_comunal = {
	-- Casas
	[sunos.S("Casa Pequena")] = { -- Nome do items
		-- Texto descritivo do item
		desc = sunos.S("Aumenta um pouco a quantidade de moradores da vila"),
		-- População necessaria
		pop = 0, 
		-- Item a receber (apenas 1 item e 1 unidade)
		item_add = "sunos:fundamento_casa_pequena", 
		-- Itens a pagar (de 1 a 14 itens diferentes de qualquer quantidade) 
		item_rem = {"default:tree 20", "default:cobble 15", "default:stonebrick 15", "xpanes:pane_flat 5", "default:torch 10", "farming:straw 15"} 
	},
	[sunos.S("Casa Mediana")] = {
		desc = sunos.S("Aumenta a quantidade de moradores da vila"),
		pop = 5,
		item_add = "sunos:fundamento_casa_mediana", 
		item_rem = {"default:tree 25", "default:cobble 30", "default:stonebrick 25", "xpanes:pane_flat 15", "default:torch 10", "farming:straw 20"}
	},
	[sunos.S("Casa Grande")] = {
		desc = sunos.S("Aumenta bastante a quantidade de moradores da vila"),
		pop = 5,
		item_add = "sunos:fundamento_casa_grande", 
		item_rem = {"default:tree 40", "default:cobble 45", "default:stonebrick 35", "xpanes:pane_flat 20", "default:torch 15", "farming:straw 25"}
	},
	-- Kit Reparador
	[sunos.S("Kit Reparador")] = {
		desc = sunos.S("Esse Kit pode ser usado para reconstruir uma estrutura da vila dos Sunos"),
		pop = 5,
		item_add = "sunos:kit_reparador", 
		item_rem = {"default:tree 20", "default:cobble 20", "wool:yellow 5", "xpanes:pane_flat 15", "farming:straw 20"}
	},
	-- Fundamento de Loja
	[sunos.S("Feirinha")] = {
		desc = sunos.S("Uma feirinha simples para trocar itens"),
		pop = 7,
		item_add = "sunos:fundamento_loja", 
		item_rem = {"default:tree 10", "default:cobble 20", "default:torch 4", "farming:straw 15"}
	},
}

-- Tabela de população por tamanho de casa
sunos.tb_pop_casa = {
	-- Largura da casa	População
	["5"] = 		2,
	["7"] =			3,
	["9"] =			4,
	["11"] =		6,
}

