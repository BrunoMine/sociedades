--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Bau da casa dos sunos
  ]]

-- Tradução de strings
local S = sunos.S

-- Tempo para cada ciclo de on_timer
local timeout_bau = 180

-- Bau dos sunos
--[[
	Esse é o node que tem nas casas dos sunos
]]
minetest.register_node("sunos:bau_casa", {
	description = S("Bau da Casa dos Sunos"),
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
sunos.npc_checkin.register_spawner("sunos:bau_casa", {
	func_spawn = function(pos, npc_tipo)
		
		local meta = minetest.get_meta(pos)
			
		-- Verificar a coordenada do fundamento
		local pf = meta:get_string("pos_fundamento")
		if pf == "" then
			minetest.set_node(pos, {name="default:chest", param2=minetest.get_node(pos).param2})
			return
		end
		pf = minetest.deserialize(pf)
		
		-- Verificar se o fundamento ainda existe
		if minetest.get_node(pf).name ~= "sunos:fundamento" then
			minetest.set_node(pos, {name="default:chest", param2=minetest.get_node(pos).param2})
			return
		end
		
		-- Verifica se NPC já está ativo
		if sunos.npcs.is_active(pos) then
			return
		end
		
		local dist = tonumber(minetest.get_meta(pf):get_string("dist"))
		
		-- Verifica se a area está carregada
		if minetest.get_node(pf).name == "ignore" then
			minetest.get_voxel_manip():read_from_map(
				{x=pf.x-dist, y=pf.y, z=pf.z-dist},
				{x=pf.x+dist, y=pf.y+14, z=pf.z+dist}
			)
		end
		
		-- Analizar objetos (possiveis npcs) perto
		do
			for i = 0, math.floor(15/dist)-1 do
				for _,obj in ipairs(minetest.get_objects_inside_radius({x=pf.x, y=pf.y+(i*dist), z=pf.z}, dist)) do
				
					-- Evita jogadores por perto para nao spawnar de repente
					if obj:is_player() then
						return
					end
				end
			end
		end
		
		-- Escolher uma coordenada para spawnar
		local spos = {}
		do
			local nok = {} -- tabela de nodes ok 
			-- Pegar nodes de madeira
			local nodes = minetest.find_nodes_in_area(
				{x=pf.x-dist, y=pf.y, z=pf.z-dist}, 
				{x=pf.x+dist, y=pf.y+14, z=pf.z+dist}, 
				{"sunos:wood_nodrop", "default:stonebrick", "sunos:cobble_nodrop"})
			for _,p in ipairs(nodes) do
				if minetest.get_node({x=p.x, y=p.y+1, z=p.z}).name == "sunos:carpete_palha_nodrop"
					and minetest.get_node({x=p.x, y=p.y+2, z=p.z}).name == "air"
				then
					table.insert(nok, {x=p.x, y=p.y+1.5, z=p.z})
				end
			end
			-- Verifica se achou algum
			if not nok[1] then 
				return
			end
			
			-- Sorteia uma coordenada
			spos = nok[math.random(1, table.maxn(nok))]
		end
		
		-- Spawnar um novo npc na casa
		sunos.npcs.npc.spawn(npc_tipo, minetest.get_meta(pos):get_string("vila"), pos, spos)
		
	end,
})

