--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Manipulacao de ruas
  ]]

-- Caminho do diretório do mod
local modpath = minetest.get_modpath("sunos")

local colocar_rua = function(pos)
	minetest.set_node(pos, {name="sunos:rua_calcetada"})
end


local porta_para_rua = function(pos, dist)
	
	-- Localiza todas as portas da estrutura
	local portas = minetest.find_nodes_in_area(
		{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
		{x=pos.x+dist, y=pos.y+14, z=pos.z+dist}, 
		{"doors:door_wood_a"}
	)
	
	-- Separar portas para a rua
	do
		-- Coordenadas das portas para a rua
		local pr = {}
	
		for _,p in ipairs(portas) do
		
			-- Procura node de rua perto da porta (do solo da porta para pegar a rua caso ela esteja mais para baixo)
			local r =  minetest.find_node_near({x=p.x, y=p.y-1, z=p.z}, 2, {"sunos:rua_calcetada"})
			if r then
				table.insert(pr, p)
			end
		end
		
		-- Atualiza lista de portas analizadas
		portas = pr
	end
	
	-- Coloca nodes para a rua nas portas para a rua
	for _,p in ipairs(portas) do
		
		-- Pega a altura da rua para os verificadores posteriores acertarem a altura do node desejado
		local y = minetest.find_node_near({x=p.x, y=p.y-1, z=p.z}, 2, {"sunos:rua_calcetada", "stairs:slab_rua_calcetada"}).y
		
		-- Verifica para que lado está a rua
		if minetest.get_node({x=p.x+2, y=y, z=p.z}).name == "sunos:rua_calcetada" 
			or minetest.get_node({x=p.x+2, y=y, z=p.z}).name == "stairs:slab_rua_calcetada"
		then -- X+
			colocar_rua({x=p.x+1, y=p.y-1, z=p.z})
			
		elseif minetest.get_node({x=p.x-2, y=y, z=p.z}).name == "sunos:rua_calcetada" 
			or minetest.get_node({x=p.x-2, y=y, z=p.z}).name == "stairs:slab_rua_calcetada"
		then -- X-
			colocar_rua({x=p.x-1, y=p.y-1, z=p.z})
			
		elseif minetest.get_node({x=p.x, y=y, z=p.z+2}).name == "sunos:rua_calcetada" 
			or minetest.get_node({x=p.x, y=y, z=p.z+2}).name == "stairs:slab_rua_calcetada"

		then -- Z+
			colocar_rua({x=p.x, y=p.y-1, z=p.z+1})
			
		elseif minetest.get_node({x=p.x, y=y, z=p.z-2}).name == "sunos:rua_calcetada" 
			or minetest.get_node({x=p.x, y=y, z=p.z-2}).name == "stairs:slab_rua_calcetada"
		then -- Z-
			colocar_rua({x=p.x, y=p.y-1, z=p.z-1})
		end
	end
end

-- Coloca rua em volta de uma estrutura
sunos.colocar_rua = function(pos, dist)

	-- Pegar nodes de terra superficial
	local nodes1 = minetest.find_nodes_in_area( -- X+
		{x=pos.x+dist+2, y=pos.y-1, z=pos.z-dist-2-1}, {x=pos.x+dist+2+2, y=pos.y+1, z=pos.z+dist+2+1}, {"group:spreading_dirt_type"})
	local nodes2 = minetest.find_nodes_in_area( -- Z+
		{x=pos.x-dist-2-1, y=pos.y-1, z=pos.z+dist+2}, {x=pos.x+dist+2+1, y=pos.y+1, z=pos.z+dist+2+2}, {"group:spreading_dirt_type"})
	local nodes3 = minetest.find_nodes_in_area( -- X-
		{x=pos.x-dist-2-2, y=pos.y-1, z=pos.z-dist-2-1}, {x=pos.x-dist-2, y=pos.y+1, z=pos.z+dist+2+1}, {"group:spreading_dirt_type"})
	local nodes4 = minetest.find_nodes_in_area( -- Z-
		{x=pos.x-dist-2-1, y=pos.y-1, z=pos.z-dist-2-2}, {x=pos.x+dist+2+1, y=pos.y+1, z=pos.z-dist-2}, {"group:spreading_dirt_type"})

	for _,p in ipairs(nodes1) do
		minetest.set_node(p, {name="sunos:rua_calcetada"})
	end
	for _,p in ipairs(nodes2) do
		minetest.set_node(p, {name="sunos:rua_calcetada"})
	end
	for _,p in ipairs(nodes3) do
		minetest.set_node(p, {name="sunos:rua_calcetada"})
	end
	for _,p in ipairs(nodes4) do
		minetest.set_node(p, {name="sunos:rua_calcetada"})
	end
	
	-- Colocar rua ate a porta
	porta_para_rua(pos, dist)
end
