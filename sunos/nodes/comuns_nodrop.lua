--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Bancada dos sunos
  ]]

-- Tradução de strings
local S = sunos.S

local nodes_trocaveis_nodrop = {
	["default:tree"] = {name="sunos:tree_nodrop"},
	["default:glass"] = {name="sunos:glass_nodrop"},
	["default:cobble"] = {name="sunos:cobble_nodrop"},
	["default:wood"] = {name="sunos:wood_nodrop"},
	["farming:straw"] = {name="sunos:straw_nodrop"},
}

-- Criar cópia sem Drop (para evitar furtos em estruturas dos sunos)
for nodename,dados in pairs(nodes_trocaveis_nodrop) do

	-- Copiar tabela de definições
	local def = {}
	for n,d in pairs(minetest.registered_nodes[nodename]) do
		def[n] = d
	end
	
	-- Mantem a tabela groups separada
	def.groups = minetest.deserialize(minetest.serialize(def.groups))
	
	-- Altera alguns paremetros
	def.description = def.description .. " ("..S("Sem Drop")..")"
	def.groups.not_in_creative_inventory = 1
	def.drop = ""
	
	-- Registra o novo node
	minetest.register_node(dados.name, def)
end
