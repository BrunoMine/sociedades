--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Verificar um terreno para construir
  ]]

-- Metodo para verificar se um terreno esta obstruido para construir
--[[
	Argumentos
		'pos' é a coordenada do centro do solo (primeira camada (de terra))
		'dist' distancia de blocos que vai do centro a cada direção 
	Retornos
		'0' sem obtrucoes
		'1' em cima da faixa de solo existem obstrucoes (nao esta limpo e plano)
		'2' faixa de solo (superficial) falta blocos de terra
		'3' fixa de subsolo (considerando 2 faixas) falta blocos de terra
  ]]
sunos.verif_terreno = function(pos, dist)
	if not pos then
		minetest.log("error", "[Sunos] minp nulo (em sunos:verif_terreno)")
		return false
	end
	if not dist then
		minetest.log("error", "[Sunos] dist nulo (em sunos:verif_terreno)")
		return false
	end
	
	-- Verificar faixa de solo superficial
	do
		-- Pegar nodes da faixa de terra
		local superf = minetest.find_nodes_in_area(
			{x=pos.x-dist, y=pos.y+1, z=pos.z-dist}, 
			{x=pos.x+dist, y=pos.y+1, z=pos.z+dist}, 
			{"air", "group:flower", "group:grass"}
		)
	
		if table.maxn(superf) < ((2*dist+1)^2) then
			return 1
		end
	end
	
	-- Verificar faixa de solo superficial
	do
		-- Pegar nodes da faixa de terra
		local solo = minetest.find_nodes_in_area(
			{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
			{x=pos.x+dist, y=pos.y, z=pos.z+dist}, 
			{"default:dirt", "group:spreading_dirt_type"}
		)
	
		if table.maxn(solo) < ((2*dist+1)^2) then
			return 2
		end
	end
	
	-- Verificar faixa de subsolo considerando 2 faixas
	do
		-- Pegar nodes da faixa de terra
		local subsolo = minetest.find_nodes_in_area(
			{x=pos.x-dist, y=pos.y-2, z=pos.z-dist}, 
			{x=pos.x+dist, y=pos.y-1, z=pos.z+dist}, 
			{"group:stone", "group:cobble", "default:dirt", "group:spreading_dirt_type"}
		)
	
		if table.maxn(subsolo) < ( ((2*dist+1)^2) * 2) then
			return 3
		end
	end
	
	-- Retorna sem erros
	return 0
end

-- Node test
minetest.register_node("sunos:test", {
	description = "Node test",
	tiles = {"default_stone.png^default_apple.png"},
	is_ground_content = true,
	groups = {cracky=1},
	drop = 'default:cobble',
	legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.above then
			local p = pointed_thing.above
			
			p.y = p.y-1
			
			local r = sunos.verif_terreno(p, 3)
			if r == 0 then
				minetest.chat_send_all("terreno ok")
			elseif r == 1 then
				minetest.chat_send_all("em cima da faixa de solo existem obstrucoes")
			elseif r == 2 then
				minetest.chat_send_all("falta blocos de terra no solo superficial")
			elseif r == 3 then
				minetest.chat_send_all("falta blocos de terra no subsolo")
			end
		end
	end,
})
