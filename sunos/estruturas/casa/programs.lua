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

-- Interagir com movel da casa
npc.programs.register("sunos:interagir", function(self, args)
	local tempo = args.tempo or 5
	local pos = npc.programs.helper.get_pos_argument(self, args.pos)
	
	-- Vira para "pos"
	npc.exec.proc.enqueue(self, "advanced_npc:rotate", {
		start_pos = self.object:getpos(),
		end_pos = pos,
	})
	
	-- Fica parado por um tempo
	npc.exec.proc.enqueue(self, "advanced_npc:wait", {
		time = tempo,
	})
end)

