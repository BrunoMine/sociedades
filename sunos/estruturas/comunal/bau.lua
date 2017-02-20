--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Bau da casa comunal dos sunos
  ]]

-- Tempo para cada ciclo de on_timer
local timeout_bau = 180

-- Bau dos sunos
--[[
	Esse é o node que tem nas casas dos sunos
]]
minetest.register_node("sunos:bau_comunal", {
	description = sunos.S("Bau da Casa Comunal dos Sunos"),
	tiles = {"default_chest_top.png^sunos_bau_topo.png", "default_chest_top.png", "default_chest_side.png^sunos_bau_lado.png",
		"default_chest_side.png^sunos_bau_lado.png", "default_chest_side.png^sunos_bau_lado.png", "default_chest_lock.png^sunos_bau_frente.png"},
	paramtype2 = "facedir",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory=1},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	drop = "default:chest",
	
	-- Nao pode ser escavado/quebrado por jogadores
	on_dig = function() end,
	
	-- Ao terminar temporizador
	on_timer = function(pos, elapsed)
		local meta = minetest.get_meta(pos)
		
		-- Verifica se esta com registros de vila
		if meta:get_string("vila") == "" then 
			minetest.set_node(pos, {name="default:chest", param2=minetest.get_node(pos).param2})
			return 
		end
		
		-- Pega a coordenada do fundamento
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
		
		local dist = tonumber(minetest.get_meta(pf):get_string("dist"))
		
		-- Analizar objetos (possiveis npcs) perto
		do
			for i = 0, math.floor(15/dist)-1 do
				for _,obj in ipairs(minetest.get_objects_inside_radius({x=pf.x, y=pf.y+(i*dist), z=pf.z}, dist)) do
				
					-- Evita jogadores por perto para nao spawnar de repente
					if obj:is_player() then
						-- Encerra o procedimento para tentar novamente apos um tempo
						minetest.get_node_timer(pos):set(5, 0)
						return false
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
				{x=pos.x-1, y=pos.y-1, z=pos.z-1}, 
				{x=pos.x+1, y=pos.y-1, z=pos.z+1}, 
				{"default:wood", "default:stonebrick"})
			for _,p in ipairs(nodes) do
				if minetest.get_node({x=p.x, y=p.y+1, z=p.z}).name == "air"
					and minetest.get_node({x=p.x, y=p.y+2, z=p.z}).name == "air"
				then
					table.insert(nok, {x=p.x, y=p.y+1.5, z=p.z})
				end
			end
			-- Verifica se achou algum
			if not nok[1] then 
				-- Reinicia o ciclo com um tempo definido
				minetest.get_node_timer(pos):set(timeout_bau, 0)
				return false
			end
			-- Sorteia uma coordenada
			spos = nok[math.random(1, table.maxn(nok))]
		end
		
		-- Spawnar um novo npc
		do
			local ent = sunos.npcs.npc.spawn("comunal", minetest.get_meta(pos):get_string("vila"), pos, spos)
			-- Salva o hash
			local hash = os.date("%Y%m%d%H%M%S") -- Gera um hash numerico com a data
			ent.myhash = hash -- Salva no npc
			meta:set_string("npc_hash", hash)
		end
		
		
		-- Reinicia o ciclo com um tempo definido
		minetest.get_node_timer(pos):set(timeout_bau, 0)
		return false -- Evita que repita com um tempo diferente do definido
	end,
})

-- LBM para iniciar nodetimer caso ainda nao tenha
minetest.register_lbm({
	name = "sunos:comunal_start_nodetimer",
	nodenames = {"sunos:bau_comunal"},
	run_at_every_load = true,
	action = function(pos, node)
		if minetest.get_node_timer(pos):is_started() == false then
			minetest.get_node_timer(pos):set(2, 0)
		end
	end,
})



