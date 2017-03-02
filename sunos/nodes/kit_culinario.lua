--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Kit Culinario
  ]]

-- Tradução de strings
local S = sunos.S


-- Kit Culinario
minetest.register_node("sunos:kit_culinario", {
	-- Geral
	description = "Kit Culinario",
	
	-- Arte
	tiles = {"sunos_kit_culinario.png"},
	drawtype = "mesh",
	mesh = "sunos_kit_culinario.b3d",
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.35, 0.5},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.2, 0.5},
		},
	},
	
	-- Características
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	groups = {choppy = 2, oddly_breakable_by_hand = 2,attached_node = 1},
	sounds = default.node_sound_wood_defaults(),
	
	-- Chamadas de eventos
	--on_rightclick = function(pos, node, player, itemstack, pointed_thing)
	--end,
	
})

-- Criar cópia sem Drop (para evitar furtos em estruturas dos sunos)
do
	-- Copiar tabela de definições
	local def = {}
	for n,d in pairs(minetest.registered_nodes["sunos:kit_culinario"]) do
		def[n] = d
	end
	-- Altera alguns paremetros
	def.description = def.description .. " ("..S("Sem Drop")..")"
	def.groups.not_in_creative_inventory = 1
	def.drop = ""
	-- Registra o novo node
	minetest.register_node("sunos:kit_culinario_nodrop", def)
end

