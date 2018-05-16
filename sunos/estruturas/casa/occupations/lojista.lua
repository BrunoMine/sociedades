--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Roteiro para NPC caseiro lojista
	
	Esse NPC apenas vai na loja e volta para casa
  ]]

-- Tradução de strings
local S = sunos.S

local interagir_casa = sunos.estruturas.casa.interagir_casa

local interagir_feirinha = {
	-- Força ir para perto do centro da loja
	[1] = {
		program_name = "advanced_npc:internal_property_change",
		arguments = {
			property = "flag",
			args = {
				action = "set",
				flag_name = "sunos_target_status",
				flag_value = "sunos_feirinha",
			}
		},
	},
	-- Anda no carpete ou olha os baus da loja
	[2] = {
		check = true,
		range = 3,
		count = 5,
		nodes = {
			"sunos:carpete_palha_nodrop",
			"sunos:bau_loja",
		},
		walkable_nodes = sunos.estruturas.casa.walkable_nodes,
		prefer_last_acted_upon_node = false,
		actions = {
			-- Andar até o carpete
			["sunos:carpete_palha_nodrop"] = {
				[1] = {
					program_name = "advanced_npc:walk_to_pos",
					arguments = {
						end_pos = "schedule_target_pos",
						walkable = sunos.estruturas.casa.walkable_nodes
					},
					chance = 50
				},
			},
			-- Olhar para um bau da loja
			["sunos:bau_loja"] = {
				[1] = {
					program_name = "advanced_npc:rotate",
					arguments = {
						end_pos = "schedule_target_pos",
					},
				},
				[2] = {
					program_name = "advanced_npc:wait",
					arguments = {
						time = 5,
					},
				},
			}
		},
		none_actions = sunos.estruturas.casa.alertar_fora_checkin,
	},
}

-- Registra ocupação padrão no NPC caseiro
npc.occupations.register_occupation("sunos_npc_caseiro_lojista", {
	dialogues = {},
	textures = {
		{name="sunos_npc_male.png", tags={"male", "adult", "sunos_npc_caseiro"}},
		{name="sunos_npc_female.png", tags={"female", "adult", "sunos_npc_caseiro"}}
	},
	building_types = {},
	surrounding_building_types = {},
	walkable_nodes = sunos.estruturas.casa.walkable_nodes,
	initial_inventory = {},
	schedules_entries = sunos.copy_tb({
		
		-- Durmir
		[0] = sunos.estruturas.casa.durmir,
		[1] = sunos.estruturas.casa.durmir,
		[2] = sunos.estruturas.casa.durmir,
		[3] = sunos.estruturas.casa.durmir,
		[4] = sunos.estruturas.casa.durmir,
		[5] = sunos.estruturas.casa.durmir,
		[6] = sunos.estruturas.casa.acordar,
		-- Olhar a feirinha
		[7] = interagir_feirinha,
		[8] = interagir_feirinha,
		[9] = interagir_feirinha,
		[10] = interagir_feirinha,
		[11] = interagir_feirinha,
		[12] = interagir_feirinha,
		-- Mecher em casa
		[13] = interagir_casa,
		[14] = interagir_casa,
		[15] = interagir_casa,
		[16] = interagir_casa,
		[17] = interagir_casa,
		[18] = interagir_casa,
		[19] = interagir_casa,
		[20] = interagir_casa,
		[21] = interagir_casa,
		-- Durmir
		[22] = sunos.estruturas.casa.durmir,
		[23] = sunos.estruturas.casa.durmir
		
	})
			
})
