--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Broa de Frutas dos Sunos
  ]]

-- Tradução de strings
local S = sunos.S

-- Broa de Frutas dos Sunos
minetest.register_craftitem("sunos:broa_frutas", {
	description = "Broa de Frutas dos Sunos",
	inventory_image = "sunos_broa_frutas.png",
	on_use = minetest.item_eat(7),
	groups = {flammable = 2},
})
