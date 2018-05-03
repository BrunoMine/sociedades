--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Bau da taverna dos sunos
  ]]

-- Tradução de strings
local S = sunos.S

-- Bau dos sunos
--[[
	Esse é o node que tem nas tavernas dos sunos
]]
minetest.register_node("sunos:bau_taverna", {
	description = S("Bau de Taverna dos Sunos"),
	tiles = {"default_chest_top.png^sunos_bau_topo.png", "default_chest_top.png", "default_chest_side.png^sunos_bau_lado.png",
		"default_chest_side.png^sunos_bau_lado.png", "default_chest_side.png^sunos_bau_lado.png", "default_chest_lock.png^sunos_bau_frente.png"},
	paramtype2 = "facedir",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory=1},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	drop = "",
	
	-- Nao pode ser escavado/quebrado por jogadores
	on_dig = function() end,
})

-- Registrar Spawner
sunos.npc_checkin.register_spawner("sunos:bau_taverna", {
	func_spawn = function(pos, npc_tipo)
		
		local meta = minetest.get_meta(pos)
		
		-- Verifica fundamento
		local pf = sunos.verificar_fundamento_bau_sunos(pos)
		if not pf then return end
		
		local spos
		if npc_tipo == "barman" then
			spos = sunos.npcs.select_pos_spawn(pf, {
				tipo = "fundamento",
				nodes = {"sunos:solo_barman"},
			})
		else
			spos = sunos.npcs.select_pos_spawn(pf, {
				tipo = "fundamento",
			})
		end
		
		if spos then
			-- Spawnar um novo npc na casa
			sunos.npcs.npc.spawn(npc_tipo, minetest.get_meta(pos):get_string("vila"), pos, spos)
		end
	end,
})
