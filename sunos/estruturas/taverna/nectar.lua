--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Nectar de fruta dos sunos
  ]]

-- Tradução de strings
local S = sunos.S

-- Node Garrafa de Nectar (decorativo)
minetest.register_node("sunos:nectar", {
	description = S("Nectar de Frutas dos Sunos"),
	tiles = {
		"sunos_nectar_cima.png", -- cima
		"sunos_nectar_baixo.png", -- baixo
		"sunos_nectar_lado.png", -- direita
		"sunos_nectar_lado.png", -- esquerda
		"sunos_nectar_lado.png", -- fundo
		"sunos_nectar_lado.png" -- frente
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.125, 0.125, 0.125, 0.125}, -- Centro
			{-0.1875, -0.4375, -0.0625, 0.1875, 0, 0.0625}, -- Face_1
			{-0.0625, -0.4375, -0.1875, 0.0625, 0, 0.1875}, -- Face_2
			{-0.0625, -0.5, -0.0625, 0.0625, 0.375, 0.0625}, -- tubo_fino
		}
	},
	stack_max = 10,
	on_use = core.item_eat(tonumber(minetest.setting_get("sunos_item_nectar_eat") or 4)),
	groups = {attached_node=1,choppy=2,dig_immediate=3},
	sounds = default.node_sound_defaults(),
})

-- Registrar comida no hbhunger
if minetest.get_modpath("hbhunger") then
	hbhunger.register_food("sunos:nectar", tonumber(minetest.setting_get("sunos_item_nectar_eat") or 4), "vessels:glass_bottle", nil, 2, "sunos_bebendo_garrafa_de_vidro")
end

-- Criar cópia sem Drop (para evitar furtos em estruturas dos sunos)
do
	-- Copiar tabela de definições
	local def = {}
	for n,d in pairs(minetest.registered_nodes["sunos:nectar"]) do
		def[n] = d
	end
	-- Mantem a tabela groups separada
	def.groups = minetest.deserialize(minetest.serialize(def.groups))
	
	-- Altera alguns paremetros
	def.description = def.description .. " ("..S("Sem Drop")..")"
	def.groups.not_in_creative_inventory = 1
	def.drop = ""
	-- Registra o novo node
	minetest.register_node("sunos:nectar_nodrop", def)
end
