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

-- Tabelas
local sunos_walkable_nodes = {
	"sunos:carpete_palha",
	"sunos:carpete_palha_nodrop"
}

-- Escolhe uma tarefa para o npc durante o dia
sunos.estruturas.casa.escolher_roteiro_npc = function(vila)

	local loja = sunos.verif_estrutura_existe(vila, "loja")
	
	if loja then
		return "ir_na_loja"
	end
end


-- Atribuir cronograma de atividades no NPC caseiro e retorna uma agenda escolhida
sunos.estruturas.casa.atribuir_cronograma_npc = function(self, roteiro)
	
	-- Adicionar agenda padrao
	npc.occupations.initialize_occupation_values(self, "sunos_npc_caseiro")
	
	roteiro = roteiro or sunos.estruturas.casa.escolher_roteiro_npc(self.vila)
	
	--Ir na loja
	if roteiro == "ir_na_loja" then
		
		local dados_loja = sunos.bd.pegar("vila_"..self.vila, sunos.verif_estrutura_existe(self.vila, "loja"))
		
		-- Configura checkin
		sunos.npcs.npc.set_checkin(self, dados_loja.estrutura.pos, 7, 12)
		
	end
	
	-- Salva o numero do dia que o cronograma foi atribuido
	self.dias_roteiro = minetest.get_day_count()
	
end


-- Registra ocupação padrão no NPC caseiro
npc.occupations.register_occupation("sunos_npc_caseiro", {
	dialogues = {},
	textures = {},
	building_types = {},
	surrounding_building_types = {},
	walkable_nodes = sunos_walkable_nodes,
	initial_inventory = {},
	schedules_entries = {
	
		[6] = {
		    -- Get out of bed
		    [1] = {
			task = npc.actions.cmd.USE_BED, 
			args = {
			    pos = "bed_primary",
			    action = npc.actions.const.beds.GET_UP
			}
		    },
		    -- Allow mobs_redo wandering
		    [2] = {action = npc.actions.cmd.FREEZE, 
		    	args = {freeze = false}
		    }
		    -- Walk to home inside
		    
		},
		-- Ir para a jola
		[7] = {
			[1] = {
				task = npc.actions.cmd.WALK_TO_POS, 
				args = {
					end_pos = npc.places.PLACE_TYPE.OTHER.HOME_OUTSIDE,
					walkable = {}
				},
			},
		},
		
		[22] = {
		    [1] = {
			task = npc.actions.cmd.WALK_TO_POS, 
			args = {
			    end_pos = "bed_primary",
			    walkable = sunos_walkable_nodes,
			}
		    },
		    -- Use bed
		    [2] = {
			task = npc.actions.cmd.USE_BED, 
			args = {
			    pos = "bed_primary",
			    action = npc.actions.const.beds.LAY
			}
		    },
		    -- Stay put on bed
		    [3] = {
		    	action = npc.actions.cmd.FREEZE, 
		    	args = {
		    		freeze = true
		    	} 
		    }
		}
	}
})
