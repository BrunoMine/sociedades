--[[
	Mod Sovagxas para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Craftitens
  ]]

-- Muda de Arvore dos Sovagxas
minetest.register_craftitem("sovagxas:muda_sovagxas", {
	description = "Muda de Arvore dos Sovagxas",
	inventory_image = "default_junglesapling.png",
	
	on_place = function(itemstack, placer, pointed_thing)
		sovagxas.montar_arvore(pointed_thing.above)
	end,
})
