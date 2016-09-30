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
	["Casa Pequena"] = { -- Nome do items
		-- Texto descritivo do item
		desc = "Aumenta um pouco o numero de moradores da vila",
		-- População necessaria
		pop = 0, 
		-- Item a receber (apenas 1 item e 1 unidade)
		item_add = "sunos:fundamento_casa_pequena", 
		-- Itens a pagar (de 1 a 14 itens diferentes de qualquer quantidade) 
		item_rem = {"default:tree 20", "default:cobble 15", "default:stonebrick 15", "xpanes:pane 5", "default:torch 10"} 
	},
	["Casa Mediana"] = {
		desc = "Aumenta o numero de moradores da vila",
		pop = 5,
		item_add = "sunos:fundamento_casa_mediana", 
		item_rem = {"default:tree 25", "default:cobble 30", "default:stonebrick 25", "xpanes:pane 15", "default:torch 10"}
	},
	["Casa Grande"] = {
		desc = "Aumenta bastante o numero de moradores da vila",
		pop = 5,
		item_add = "sunos:fundamento_casa_grande", 
		item_rem = {"default:tree 40", "default:cobble 45", "default:stonebrick 35", "xpanes:pane 20", "default:torch 15"}
	},
	-- Kit Reparador
	["Kit Reparador"] = {
		desc = "Esse Kit serve para reconstruir uma estrutura do povo Suno",
		pop = 5,
		item_add = "sunos:kit_reparador", 
		item_rem = {"default:tree 20", "default:cobble 20", "wool:yellow 5", "xpanes:pane 15"}
	},
	-- Fundamento de Loja
	["Feirinha"] = {
		desc = "Uma feirinha para a troca de itens basicos",
		pop = 7,
		item_add = "sunos:fundamento_loja", 
		item_rem = {"default:tree 20", "default:stonebrick 40", "default:torch 10", "xpanes:pane 25"}
	},
}

-- Tabela de população por tamanho de casa
sunos.tb_pop_casa = {
	-- Largura da casa	População
	["5"] = 			2,
	["7"] =			3,
	["9"] =			4,
	["11"] =			6,
}

