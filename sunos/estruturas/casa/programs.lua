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

-- Interagir aleatoriamente com a mobilia da casa
npc.programs.register("sunos:interagir_mobilia", function(self, args)
	
	-- Verificar distancia de casa
	if verif_dist_pos(self.object:getpos(), self.sunos_fundamento) > 16 then
		return
	end
	
	local places = npc.locations.get_by_type(self, "mobilia")
	
	p = places[math.random(1, #places)]
	
	npc.locations.add_shared(self, "sunos_alvo_mobilia", "sunos_alvo_mobilia", p.pos, p.access_node)
	
	npc.exec.proc.enqueue(self, "advanced_npc:interrupt", {
		new_program = "advanced_npc:walk_to_pos",
		new_args = {
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
	
	-- Fica parado por um tempo
	npc.exec.proc.enqueue(self, "advanced_npc:wait", {
		time = 5,
	})
	
end)
