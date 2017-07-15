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

-- Envia uma formspec simples de aviso
local avisar = function(player, texto)
	sunos.checkvar(player, "Nenhum player fornecido para avisar com formspec")
	sunos.checkvar(texto, "Nenhum texto fornecido para avisar player com formspec")
	
	minetest.show_formspec(player:get_player_name(), "sunos:npc", "size[12,1]"
		..default.gui_bg
		..default.gui_bg_img
		.."label[0.5,0;"..S("Aviso").." \n"..texto.."]")
	return true
end

sunos.npcs.npc.registrar("caseiro", {
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
		{name = "default:apple", chance = 2, min = 1, max = 2},
	},
})
