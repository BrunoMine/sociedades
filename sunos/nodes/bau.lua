--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Bau
  ]]

-- Tradução de strings
local S = sunos.S

-- Bau dos Sunos
do
	-- Copiar tabela de definições do bau comum
	local def = {}
	for n,d in pairs(minetest.registered_nodes["default:chest"]) do
		def[n] = d
	end
	-- Altera alguns paremetros
	def.description = S("Bau dos Sunos")
	def.tiles = {"default_chest_top.png^sunos_bau_topo.png", "default_chest_top.png", "default_chest_side.png^sunos_bau_lado.png",
		"default_chest_side.png^sunos_bau_lado.png", "default_chest_side.png^sunos_bau_lado.png", "default_chest_lock.png^sunos_bau_frente.png"}
	-- Registra o novo node
	minetest.register_node("sunos:bau", def)
end
