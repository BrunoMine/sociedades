--[[
	Mod Sunos para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Métodos para tratamento de ruinas
  ]]

-- Traduções
local S = sunos.S


-- Montar ruinas
sunos.montar_ruinas = function(pos, dist)
	sunos.checkvar(pos, dist, "Parametro(s) invalido(s) para montar ruinas")
	
	-- Pegar blocos a serem removidos
	local nodes_rem = minetest.find_nodes_in_area(
		{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
		{x=pos.x+dist, y=pos.y+14, z=pos.z+dist}, 
		sunos.var.node_group.remover_da_ruina
	)
	
	-- Limpar nodes a serem removidos
	for _,p in ipairs(nodes_rem) do
		minetest.remove_node(p)
	end
	
	-- Pega todos elementos pedrosos
	local nodes = minetest.find_nodes_in_area(
		{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
		{x=pos.x+dist, y=pos.y+14, z=pos.z+dist}, 
		{"group:stone"}
	)
	
	-- Recoloca pedregulho no lugar de elementos pedrosos
	for _,p in ipairs(nodes) do
		minetest.set_node(p, {name="default:cobble"})
	end
	
	return true
end
