--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Ruas das vilas
  ]]
  
-- Rua Calcetada
minetest.register_node("sunos:rua_calcetada", {
	description = sunos.S("Rua Calcetada"),
	tiles = {"default_grass.png^sunos_rua_calcetada_cima.png", "default_dirt.png",
		{name = "default_dirt.png^default_grass_side.png^sunos_rua_calcetada_lado.png",
			tileable_vertical = false}},
	groups = {crumbly = 3, soil = 1, spreading_dirt_type = 1},
	drop = 'default:dirt',
	sounds = default.node_sound_dirt_defaults({
		footstep = {name = "default_hard_footstep", gain = 0.4},
	}),
})

-- Placa de Rua Calcetada
stairs.register_stair_and_slab(
	"rua_calcetada",
	"sunos:rua_calcetada",
	{crumbly = 3, soil = 1, spreading_dirt_type = 1},
	{"default_grass.png^sunos_rua_calcetada_cima.png", "default_dirt.png",
		{
			name = "default_dirt.png^default_grass_side.png^sunos_rua_calcetada_lado.png",
			tileable_vertical = false
		}
	},
	"Degrau de Rua Calcetada",
	"Placa de Rua Calcetada",
	default.node_sound_dirt_defaults({
		footstep = {name = "default_hard_footstep", gain = 0.4},
	})
)

-- Remover receitas pois nao deve ser montado
minetest.clear_craft({output = 'stairs:slab_rua_calcetada'})
minetest.clear_craft({output = 'stairs:stair_rua_calcetada'})
