--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	NPC das casas
  ]]

sunos.npcs.npc.registrar("comunal", {})

-- Chamadas no npc para verificar hash
sunos.npcs.npc.registrados.comunal.on_step = function(self)
	-- Verifica se o hash esta atual
	if minetest.get_meta(self.mypos):get_string("npc_hash") ~= self.myhash then
		-- Remove npc
		self.object:remove()
	end
end

