--[[
	Mod Sunos para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Cronograma de tarefas do NPC das casas
  ]]

-- Tradução de strings
local S = sunos.S


-- Interagir em casa
sunos.estruturas.casa.interagir_casa = {
	[1] = {
		program_name = "sunos:interagir_mobilia",
		arguments = {},
		is_state_program = true,
	},
}


-- Durmir
sunos.estruturas.casa.durmir = {
	[1] = {
		program_name = "advanced_npc:internal_property_change",
		arguments = {
			property = "flag",
			args = {
				action = "set",
				flag_name = "sunos_repouso_status",
				flag_value = "durmir",
			}
		},
	}
}

-- Durmir
sunos.estruturas.casa.acordar = {
	[1] = {
		program_name = "advanced_npc:use_bed",
		arguments = {
			pos = "bed_primary",
			action = npc.programs.const.node_ops.beds.GET_UP
		}
	},
	[2] = {
		program_name = "advanced_npc:walk_to_pos",
		arguments = {
			end_pos = "kit_culinario",
			walkable = sunos.estruturas.casa.walkable_nodes
		}
	},
	[3] = {
			program_name = "sunos:interagir",
			arguments = {
				pos = "kit_culinario",
				time = tempo,
			},
		},
	[4] = sunos.estruturas.casa.interagir_casa[1],
}

