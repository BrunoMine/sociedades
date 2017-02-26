--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Itens de craftação
  ]]

-- Kit reparador de estruturas
minetest.register_craftitem("sunos:kit_reparador", {
	description = sunos.S("Kit Reparador de estrutura dos Sunos"),
	inventory_image = "sunos_inv_fundamento.png^sunos_kit_reparador.png",
	stack_max = 1,
})
