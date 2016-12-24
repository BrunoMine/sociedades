--[[
	Mod Memor para Minetest
	Memor v1.2 Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Controle de jogadores online
  ]]


-- Controle de jogadores de cada mod
memor.online_mods = {}

-- Montar banco de dados simples de jogadores online
function memor.online(mod)
	local mod = mod or minetest.get_current_modname()
	
	memor.online_mods[mod] = {}
	
	return memor.online_mods[mod]
end

-- Adiciona o jogador em todas listas quando entrar no servidor
minetest.register_on_joinplayer(function(player)
	for mod,l in pairs(memor.online_mods) do
		memor.online_mods[mod][player:get_player_name()] = {}
	end
end)

-- Remove o jogador de todas listas quando entrar no servidor
minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	for mod,l in pairs(memor.online_mods) do
		local np = {}
		for _,p in ipairs(minetest.get_connected_players()) do
			local n = p:get_player_name()
			if n ~= name then
				np[n] = memor.online_mods[mod][n]
			end
		end
		memor.online_mods[mod] = np
	end
end)
