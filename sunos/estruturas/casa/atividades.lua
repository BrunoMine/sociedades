--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
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
		property = "flag",
		args = {
			action = "set",
			flag_name = "sunos_checkin_status",
			flag_value = "fora",
		}
	},
	[2] = {
		action = npc.actions.cmd.WALK_STEP,
		args = {
			dir = "random"
		}
	},
	[3] = {
		action = npc.actions.cmd.SET_INTERVAL,
		args = {
			interval = 1,
			freeze = false,
		}
	}
}

-- Ficar em frente a um node (se definido corretamente no Place Map do npc)
-- ´tempo´ é o tempo em segundos de permanencia em frente à bancada 
local interagir_bancada = function(place_type, tempo)
	return {
		[1] = {
			task = npc.actions.cmd.WALK_TO_POS,
			args = {
				end_pos = place_type,
				walkable = sunos.estruturas.casa.walkable_nodes
			}
		},
		[2] = {
			action = npc.actions.cmd.SET_INTERVAL,
			args = {
				interval = tempo or 1,
				freeze = true,
			}
		},
	}
end


local interagir_bancada_de_trabalho = function(tempo)
	return {
		[1] = {
			task = npc.actions.cmd.WALK_TO_POS,
			args = {
				end_pos = "bancada_de_trabalho",
				walkable = sunos.estruturas.casa.walkable_nodes
			}
		},
		[2] = {
			action = npc.actions.cmd.SET_INTERVAL,
			args = {
				interval = tempo or 1,
				freeze = true,
			}
		},
	}
end

-- Interagir em casa
sunos.estruturas.casa.interagir_casa = {
	[1] = {
		check = true,
		range = 6,
		count = 5,
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
		actions = {
			["sunos:bau_casa"] = interagir_bancada("bau", 3),
			["sunos:wood_barrel_nodrop"] = interagir_bancada("compostagem", 3),
			["sunos:tear_palha_nodrop"] = interagir_bancada("tear", 3),
			["sunos:bancada_de_trabalho_nodrop"] = interagir_bancada("bancada_de_trabalho", 1),
			["sunos:kit_culinario_nodrop"] = interagir_bancada("kit_culinario", 2),
			["default:furnace"] = interagir_bancada("furnace_primary", 5),
		},
		none_actions = sunos.estruturas.casa.alertar_fora_checkin,
	},
	
}


-- Durmir
sunos.estruturas.casa.durmir = {
	[1] = {
		property = "flag",
		args = {
			action = "set",
			flag_name = "sunos_repouso_status",
			flag_value = "durmir",
		}
	}
}

-- Durmir
sunos.estruturas.casa.acordar = {
	[1] = {
		task = npc.actions.cmd.USE_BED, 
		args = {
			pos = "bed_primary",
			action = npc.actions.const.beds.GET_UP
		}
	},
	[2] = {
		action = npc.actions.cmd.FREEZE, 
		args = {freeze = false}
	},
	[3] = {
		task = npc.actions.cmd.WALK_TO_POS,
		args = {
			end_pos = "kit_culinario",
			walkable = sunos.estruturas.casa.walkable_nodes
		}
	},
	[4] = {
		action = npc.actions.cmd.SET_INTERVAL,
		args = {
			interval = 2,
			freeze = true,
		}
	},
	[5] = {
		task = npc.actions.cmd.WALK_TO_POS,
		args = {
			end_pos = "bau",
			walkable = sunos.estruturas.casa.walkable_nodes
		}
	},
	[6] = {
		action = npc.actions.cmd.SET_INTERVAL,
		args = {
			interval = 3,
			freeze = true,
		}
	},
}

