--[[
	Mod Sunos para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Programas de atividades do npc
  ]]

-- Tradução de strings
local S = sunos.S

-- Sons
local sons = {
	["sunos_batidas_bancada"] = {
		gain = 0.9,
	},
	["sunos_revirando_terra"] = {
		gain = 1,
	},
	["sunos_pilao"] = {
		gain = 0.8,
	},
	["sunos_bau_abrir_fechar"] = {
		gain = 0.8,
	},
}

-- tabela de animações
local animacoes = {
	["sunos_movimento_bancada.b3d"] = {
		-- Arquivo de malha
		name = "sunos_movimento_bancada.b3d",
		-- Animação para inicio
		pre_act_time = 1,
		pre_act_frame_start = 1,
		pre_act_frame_end = 60,
		pre_act_frame_speed = 25,
		-- Animação principal
		act_frame_start = 20,
		act_frame_end = 60,
		act_frame_speed = 25,
		-- Animação para fim
		pos_act_time = 1.7,
		pos_act_frame_start = 55,
		pos_act_frame_end = 160,
		pos_act_frame_speed = 20,
	},
	["sunos_movimento_bau.b3d"] = {
		-- Arquivo de malha
		name = "sunos_movimento_bau.b3d",
		-- Animação principal
		act_frame_start = 1,
		act_frame_end = 80,
		act_frame_speed = 25,
		act_time = 1.7,
	},
}

-- Tabela de caracteristicas de interação com cada mobilia
local mobilias = {
	["sunos:bancada_de_trabalho"] = {
		-- Tempo de atividade
		time = 8,
		-- Animações
		anim = animacoes["sunos_movimento_bancada.b3d"],
		-- Particulas
		particulas = {
			tipo = "simples",
			textura = "sunos_poeirinha.png",
		},
		-- Som
		som = {
			name = "sunos_batidas_bancada",
			gain = sons["sunos_batidas_bancada"].gain,
			alcance = 7,
		},
	},
	["sunos:caixa_de_musica"] = {
		-- Tempo de atividade
		time = 0,
		-- Animações
		anim = animacoes["sunos_movimento_bau.b3d"],
		-- Particulas
		-- Nenhum
		-- Som
		-- Nenhum
		-- Função pos ação
		pos_func = function(self, pos)
			minetest.registered_nodes["sunos:caixa_de_musica"].on_timer(pos, minetest.get_node_timer(pos):get_elapsed())
		end,
	},
	["sunos:bau_casa"] = {
		-- Tempo de atividade
		time = 0,
		-- Animações
		anim = animacoes["sunos_movimento_bau.b3d"],
		-- Particulas
		-- Nenhuma
		-- Som
		som = {
			name = "sunos_bau_abrir_fechar",
			gain = sons["sunos_bau_abrir_fechar"].gain,
			alcance = 7,
		},
	},
	["sunos:kit_culinario"] = {
		-- Tempo de atividade
		time = 8,
		-- Animações
		anim = animacoes["sunos_movimento_bancada.b3d"],
		-- Particulas
		particulas = {
			tipo = "simples",
			textura = "sunos_poeirinha_comida.png",
		},
		-- Som
		som = {
			name = "sunos_pilao",
			gain = sons["sunos_pilao"].gain,
			alcance = 7,
		},
	},
	["sunos:tear_palha"] = {
		-- Tempo de atividade
		time = 8,
		-- Animações
		anim = animacoes["sunos_movimento_bancada.b3d"],
		-- Particulas
		particulas = {
			tipo = "simples",
			textura = "sunos_poeirinha_palha.png",
		},
		-- Som
		som = {
			name = "sunos_batidas_bancada",
			gain = sons["sunos_batidas_bancada"].gain,
			alcance = 7,
		},
	},
	["sunos:wood_barrel"] = {
		-- Tempo de atividade
		time = 8,
		-- Animações
		anim = animacoes["sunos_movimento_bancada.b3d"],
		-- Particulas
		particulas = {
			tipo = "simples",
			textura = "sunos_poeirinha_marrom.png",
		},
		-- Som
		som = {
			name = "sunos_revirando_terra",
			gain = sons["sunos_revirando_terra"].gain,
			alcance = 7,
		},
	},
}
-- Copiando tabela para versoes nodrop
mobilias["sunos:bancada_de_trabalho_nodrop"] = mobilias["sunos:bancada_de_trabalho"]
mobilias["sunos:tear_palha_nodrop"] = mobilias["sunos:tear_palha"]
mobilias["sunos:kit_culinario_nodrop"] = mobilias["sunos:kit_culinario"]
mobilias["sunos:wood_barrel_nodrop"] = mobilias["sunos:wood_barrel"]
mobilias["sunos:caixa_de_musica_nodrop"] = mobilias["sunos:caixa_de_musica"]

-- Verificar distancia entre duas pos
local verif_dist_pos = function(pos1, pos2)
	local x = math.abs(math.abs(pos1.x)-math.abs(pos2.x))
	local y = math.abs(math.abs(pos1.y)-math.abs(pos2.y))
	local z = math.abs(math.abs(pos1.z)-math.abs(pos2.z))
	if x > z and x > y then return x end
	if y > x and y > z then return y end
	if z > x and z > y then return z end
	return x or y or z
end

npc.programs.instr.register("sunos:rotate_to_pos", function(self, args)
	npc.programs.instr.execute(self, "advanced_npc:rotate", {
		start_pos = self.object:getpos(), 
		end_pos = args.pos,
	})
end)

npc.programs.instr.register("sunos:set_animation", function(self, args)
	self.object:set_properties({mesh = args.mesh})
	self.object:set_animation(
		{x = args.start_frame, y = args.end_frame},
		args.frame_speed, 
		0
	)

	-- Reset programado da animação
	if args.pos_reset_time then
		minetest.after(args.pos_reset_time, npc.programs.instr.execute, self, "sunos:reset_animation", {})
	end
end)

npc.programs.instr.register("sunos:reset_animation", function(self, args)
	self.object:set_properties({mesh = "character.b3d"})
	self.object:set_animation(
		{x = npc.ANIMATION_STAND_START, y = npc.ANIMATION_STAND_END},
        	30, 
        	0
        )
end)

-- Executa funcao mobilia do node
npc.programs.instr.register("sunos:execute_func_mobilia", function(self, args)
	-- Função para inicio do trabalho na mobilia
	if args.tipo == "pre" then
		args.m.pre_func(self, args.pos)
	elseif args.tipo == "pos" then
		args.m.pos_func(self, args.pos)
	end
end)

-- Cria particular de movimento
npc.programs.instr.register("sunos:add_efeito_interacao_mobilia", function(self, args)
	
	local mypos = self.object:getpos()
	
	-- Adiciona particulas em cima da bancada
	if args.m.particulas then
		-- Simples
		if args.m.particulas.tipo == "simples" then
			self.sunos_particlespawner_id = minetest.add_particlespawner({
				amount = args.m.time*10,
				time = args.m.time,
				minpos = {x = args.pos.x - 0.6, y = mypos.y + 1, z = args.pos.z - 0.6},
				maxpos = {x = args.pos.x + 0.6, y = mypos.y + 1.4, z = args.pos.z + 0.6},
				minvel = {x= -0.02, y= -0.02, z= -0.02},
				maxvel = {x= 0.02, y= 0.02, z= 0.02},
				minacc = {x= -0.02, y= -0.02, z= -0.02},
				maxacc = {x= 0.02, y= 0.05, z= 0.02},
				minexptime = 3,
				maxexptime = 3,
				minsize = 4,
				maxsize = 5,
				collisiondetection = false,
				texture = args.m.particulas.textura,
			})
		end
	end
	
	-- Tocar som
	if args.m.som then
		if (args.m.time or 0) > 0 then
			self.sunos_particlespawner_sound_handle = minetest.sound_play(args.m.som.name, {
				pos = args.pos,
				max_hear_distance = args.m.som.alcance,
				gain = args.m.som.gain,
				loop = true,
			})
			minetest.after(args.m.time, minetest.sound_stop, self.sunos_particlespawner_sound_handle)
		else
			self.sunos_particlespawner_sound_handle = minetest.sound_play(args.m.som.name, {
				pos = args.pos,
				max_hear_distance = args.m.som.alcance,
				gain = args.m.som.gain,
				loop = false,
			})
		end
	end
end)


-- Interagir aleatoriamente com a mobilia da casa
npc.programs.register("sunos:interagir_mobilia", function(self, args)
	
	local mypos = self.object:getpos()
	
	-- Verificar distancia de casa
	if verif_dist_pos(mypos, self.sunos_fundamento) > 16 then
		return
	end
	
	local places = npc.locations.get_by_type(self, "mobilia")
	
	local p = places[math.random(1, #places)]
	
	-- Analisa node escolhido
	local m = mobilias[sunos.pegar_node(p.pos).name]
	if not m then
		minetest.chat_send_all("node nao catalogado para interagir ("..sunos.pegar_node(p.pos).name..")")
		return
	end
	
	npc.locations.add_shared(self, "sunos_alvo_mobilia", "sunos_alvo_mobilia", p.pos, p.access_node)
	
	npc.exec.proc.enqueue(self, "advanced_npc:interrupt", {
		new_program = "advanced_npc:walk_to_pos",
		new_args = {
			optimize_one_node_distance = verif_dist_pos(p.pos, mypos) > 3,
			end_pos = {
				place_type="sunos_alvo_mobilia",
				use_access_node=true
			},
			walkable = sunos.estruturas.casa.walkable_nodes
		},
		interrupt_options = {}
	})
	
	-- Vira para "pos"
	npc.exec.proc.enqueue(self, "sunos:rotate_to_pos", {
		pos = p.pos,
	})
	
	-- Pré animação
	if (m.anim.pre_act_time or 0) > 0 then
		npc.exec.proc.enqueue(self, "sunos:set_animation", {
			mesh = m.anim.name,
			start_frame = m.anim.pre_act_frame_start,
			end_frame = m.anim.pre_act_frame_end,
			frame_speed = m.anim.pre_act_frame_speed,
		})
		npc.exec.proc.enqueue(self, "advanced_npc:wait", {
			time = m.anim.pre_act_time,
		})
	end
	
	-- Muda animação
	npc.exec.proc.enqueue(self, "sunos:set_animation", {
		mesh = m.anim.name,
		start_frame = m.anim.act_frame_start,
		end_frame = m.anim.act_frame_end,
		frame_speed = m.anim.act_frame_speed,
		-- Caso seja animação rapida sem loop
		pos_reset_time = m.anim.act_time,
	})
	
	-- Particulas
	npc.exec.proc.enqueue(self, "sunos:add_efeito_interacao_mobilia", {
		pos = p.pos,
		m = m,
	})
	
	-- Executa pré funcao da mobilia
	if m.pre_func then
		npc.exec.proc.enqueue(self, "sunos:execute_func_mobilia", {
			tipo = "pre",
			pos = p.pos,
			m = m,
		})
	end
	
	-- Mantem trabalhando
	if (m.time or 0) > 0 then
		npc.exec.proc.enqueue(self, "advanced_npc:wait", {
			time = m.time,
		})
	end
	
	-- Executa pos funcao da mobilia
	if m.pos_func then
		npc.exec.proc.enqueue(self, "sunos:execute_func_mobilia", {
			tipo = "pos",
			pos = p.pos,
			m = m,
		})
	end
	
	-- Pós animação
	if (m.anim.pos_act_time or 0) > 0 then
		npc.exec.proc.enqueue(self, "sunos:set_animation", {
			mesh = m.anim.name,
			start_frame = m.anim.pos_act_frame_start,
			end_frame = m.anim.pos_act_frame_end,
			frame_speed = m.anim.pos_act_frame_speed,
			pos_reset = true,
			pos_reset_time = m.anim.pos_act_time,
		})
	end
	
end)
