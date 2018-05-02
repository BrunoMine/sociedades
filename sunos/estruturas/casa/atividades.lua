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

-- Esperar por comando de ida ao checkin
sunos.estruturas.casa.alertar_fora_checkin = {
	[1] = {
		program_name = "advanced_npc:internal_property_change",
		arguments = {
			property = "flag",
			args = {
				action = "set",
				flag_name = "sunos_checkin_status",
				flag_value = "fora",
			}
		},
	},
	[2] = {
		program_name = "advanced_npc:idle",
		arguments = {
			acknowledge_nearby_objs = true,
			wander_chance = 0
		},
		interrupt_options = {},
		is_state_program = true
	}
}

-- Ficar em frente a um node (se definido corretamente no Place Map do npc)
-- ´tempo´ é o tempo em segundos de permanencia em frente à bancada 
local interagir_bancada = function(place_type, tempo)
	return {
		[1] = {
			program_name = "advanced_npc:walk_to_pos",
			arguments = {
				end_pos = place_type,
				walkable = sunos.estruturas.casa.walkable_nodes
			},
			interrupt_options = {}
		},
		[2] = {
			program_name = "sunos:interagir",
			arguments = {
				pos = place_type,
				time = tempo,
			},
		},
	}
end


local interagir_bancada_de_trabalho = function(tempo)
	return {
		[1] = {
			program_name = "advanced_npc:walk_to_pos",
			arguments = {
				end_pos = "bancada_de_trabalho",
				walkable = sunos.estruturas.casa.walkable_nodes
			},
			interrupt_options = {}
		},
		[2] = {
			program_name = "sunos:interagir",
			arguments = {
				pos = "bancada_de_trabalho",
				time = tempo,
			},
		},
	}
end

-- Interagir em casa
sunos.estruturas.casa.interagir_casa = {
	[1] = {
		program_name = "advanced_npc:node_query",
		arguments = {
			range = 6,
			count = 1,
			nodes = {
				"sunos:bau_casa",
				"default:furnace", 
				"sunos:wood_barrel_nodrop",
				"sunos:tear_palha_nodrop",
				"sunos:bancada_de_trabalho_nodrop",
				"sunos:kit_culinario_nodrop"
			},
			walkable_nodes = sunos.estruturas.casa.walkable_nodes,
			prefer_last_acted_upon_node = false,
			on_found_executables = {
				["sunos:bau_casa"] = interagir_bancada("bau", 3),
				["sunos:wood_barrel_nodrop"] = interagir_bancada("compostagem", 3),
				["sunos:tear_palha_nodrop"] = interagir_bancada("tear", 3),
				["sunos:bancada_de_trabalho_nodrop"] = interagir_bancada("bancada_de_trabalho", 1),
				["sunos:kit_culinario_nodrop"] = interagir_bancada("kit_culinario", 2),
				["default:furnace"] = interagir_bancada("forno", 5),
			},
			on_not_found_executables = interagir_bancada("bau", 3),
		},
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

