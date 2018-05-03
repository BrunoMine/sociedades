--[[
	Mod Sunos para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Metodos de spawn
	
	Metodos para escolher o node certo para spawnar
  ]]

-- Tabela de metodos
--[[
	Definições:
		
		tipo = "", 
			^ Tipo escolhido
			^ "fundamento" : Escolhe um node dentro de area de uma estrutura.
			                 A coordenada `pos` deve ser o proprio fundamento.
		
		no_players = true, -- OPICIONAL, Se quer evitar jogadores, retorna nil se houver.
		
		nodes = {"nodename1", "nodename2", "nodename2"}, 
			^ OPICIONAL. Tabela de nodes sobre o qual vai spawnar
			^ Padrão é {"sunos:wood_nodrop", "default:stonebrick", "sunos:cobble_nodrop"}
		
		carpete = "nodename",
			^ OPICIONAL. Node a ser considerado como carpete e deve estar acima do node, 
			^ Colocar "air" para evitar qualquer carpete
			^ Padrão é "sunos:carpete_palha_nodrop"
			
  ]]
sunos.npcs.select_pos_spawn = function(pos, def)
	
	if def.tipo == "fundamento" then
	
		local meta = minetest.get_meta(pos)
		
		local pf = pos
		
		-- Verifica se a area está carregada
		if minetest.get_node(pf).name == "ignore" then
			minetest.get_voxel_manip():read_from_map(
				{x=pf.x-dist, y=pf.y, z=pf.z-dist},
				{x=pf.x+dist, y=pf.y+14, z=pf.z+dist}
			)
		end
		
		local dist = tonumber(minetest.get_meta(pf):get_string("dist"))
		
		-- Analizar objetos (possiveis npcs) perto
		if def.no_players ~= false then
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
		do
			local nok = {} -- tabela de nodes ok 
			-- Pegar nodes de madeira
			local nodes = minetest.find_nodes_in_area(
				{x=pf.x-dist, y=pf.y, z=pf.z-dist}, 
				{x=pf.x+dist, y=pf.y+14, z=pf.z+dist}, 
				def.nodes or {"sunos:wood_nodrop", "default:stonebrick", "sunos:cobble_nodrop"})
			for _,p in ipairs(nodes) do
				if minetest.get_node({x=p.x, y=p.y+1, z=p.z}).name == def.carpete or "sunos:carpete_palha_nodrop"
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
			return nok[math.random(1, table.maxn(nok))]
		end
	end
end
