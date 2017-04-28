--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	NPC das casas
  ]]

-- Tradução de strings
local S = sunos.S

-- Solo de barman (separa as areas do barman)
do
	-- Copiar tabela de definições do bau comum
	local def = {}
	for n,d in pairs(minetest.registered_nodes["default:cobble"]) do
		def[n] = d
	end
	-- Altera alguns paremetros
	def.description = S("Solo de Barman dos Sunos")
	def.tiles = {"default_cobble.png^sunos_solo_barman.png"}
	def.drop = "default:cobble"
	-- Registra o novo node
	minetest.register_node("sunos:solo_barman", def)
end

-- Registrar npc
sunos.npcs.npc.registrar("barman", {
	on_step = function(self)
	
		-- Verifica se o hash esta atual
		if minetest.get_meta(self.mypos):get_string("npc_hash") ~= self.myhash then
			-- Remove npc
			self.object:remove()
		end
	
		-- Verifica se algum dos jogadores proximos é um inimigo
		if self.state ~= "attack" then -- Verifica se ja não está em um ataque
			for _,obj in ipairs(minetest.get_objects_inside_radius(self.object:getpos(), 13)) do
				if obj:is_player() then
				
					-- Verifica se o jogador é inimigo
					if sunos.verif_inimigo(self.vila, obj:get_player_name()) == true then
						self.attack = obj
						self.state = "attack"
						return
					end
			
				end
			end
		end
		
	end,
	
	drops = {
		{name = "default:wood", chance = 1, min = 1, max = 3},
		{name = "default:apple", chance = 2, min = 1, max = 2},
		{name = "default:axe_stone", chance = 5, min = 1, max = 1},
	},
})

-- interface do npc (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/taverna/interface.lua")
