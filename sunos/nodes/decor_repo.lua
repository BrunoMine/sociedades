--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Intes de decoração para serem repostos
  ]]

-- SobreBancada comum (item com aspecto parecido com o bau)
minetest.register_node("sunos:sobrebancada_repo", {
	description = "bloco para ficar em cima de bancada (reposicao de gerador)",
	tiles = {"default_chest_top.png", "default_chest_top.png", "default_chest_side.png",
		"default_chest_side.png", "default_chest_side.png", "default_chest_lock.png^sunos_repo.png"},
	paramtype2 = "facedir",
	groups = {dig_immediate = 3, sunos_repo=1},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

-- Bancada comum (normalmente convertido para bancada normal)
minetest.register_node("sunos:bancada_repo", {
	description = "bancada (reposicao de gerador)",
	tiles = {"default_chest_top.png^sunos_repo.png", "default_chest_top.png", "default_chest_side.png",
		"default_chest_side.png", "default_chest_side.png", "default_chest_lock.png^sunos_repo.png"},
	paramtype2 = "facedir",
	groups = {dig_immediate = 3, sunos_repo=1},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

-- Decoração simples (tipo vaso, totem e etc)
minetest.register_node("sunos:simples_repo", {
	description = "Decoracao simples (tipo vaso, totem e etc)",
	drawtype = "plantlike",
	tiles = {"sunos_repo.png"},
	inventory_image = "sunos_repo.png",
	wield_image = "sunos_repo.png",
	paramtype = "light",
	is_ground_content = false,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
	},
	groups = {dig_immediate = 3, attached_node = 1, sunos_repo=1},
	sounds = default.node_sound_glass_defaults(),
})


-- Metodo para trocar itens de reposicao por itens reais
--[[
	Argumentos:
		<pos> do centro do chao
		<dist> em brocos do centro a borda (exemplo: 2 para uma largura total de 5 blocos)
  ]]
sunos.decor_repo = function(pos, dist, itens)
	if itens == nil then
		minetest.log("error", "[Sunos] Tabela itens nula (sunos.decor_repo)")
		return "Erro interno (pos nula)"
	end
	
	if itens.bancadas then
		-- Pegar todas bancadas
		local bancadas = minetest.find_nodes_in_area(
			{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
			{x=pos.x+dist, y=pos.y+14, z=pos.z+dist}, 
			{"sunos:bancada_repo"}
		)
		-- Trocar por bancadas reais
		local is = itens.bancadas[1][1] -- itemstring do item a ser colocado
		local ii = itens.bancadas[1][2] -- quantidade de itens "is" a ser colocado
		while (table.maxn(bancadas) > 0) and (ii > 0) do
			local ip = math.random(1, table.maxn(bancadas)) -- index da pos escolhida
			local p = bancadas[ip]
			
			local n = minetest.get_node(p)
			minetest.set_node(p, {name=is,param2=n.param2})
			ii = ii - 1
			
			-- Limpa o que estiver em cima caso exigido
			if itens.bancadas[1][3] then
				minetest.remove_node({x=p.x,y=p.y+1,z=p.z})
			end
			
			table.remove(bancadas, ip) -- exclui a pos
			
			-- Verifica se ja acabaram todos os itens "is"
			if ii <= 0 then 
				table.remove(itens.bancadas, 1)
				-- Passa as variaveis para o proximo da lista
				if itens.bancadas[1] then
					is = itens.bancadas[1][1]
					ii = itens.bancadas[1][2]
				else
					break
				end
			end
			
		end
	end
	
	-- Transforma todas as bancadas restantes para bancada normal
	-- Pegar todas bancadas
	local bancadas = minetest.find_nodes_in_area(
		{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
		{x=pos.x+dist, y=pos.y+14, z=pos.z+dist}, 
		{"sunos:bancada_repo"}
	)
	for _,p in ipairs(bancadas) do
		local n = minetest.get_node(p)
		minetest.set_node(p, {name="sunos:bancada",param2=n.param2})
	end
	
	if itens.sobrebancadas then
	
		-- Pegar todas bancadas
		local sobrebancadas = minetest.find_nodes_in_area(
			{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
			{x=pos.x+dist, y=pos.y+14, z=pos.z+dist}, 
			{"sunos:sobrebancada_repo"}
		)
		-- Trocar por bancadas reais
		local is = itens.sobrebancadas[1][1] -- itemstring do item a ser colocado
		local ii = itens.sobrebancadas[1][2] -- quantidade de itens "is" a ser colocado
		while (table.maxn(sobrebancadas) > 0) and (ii > 0) do
			local ip = math.random(1, table.maxn(sobrebancadas)) -- index da pos escolhida
			local p = sobrebancadas[ip]
			
			local n = minetest.get_node(p)
			minetest.set_node(p, {name=is,param2=n.param2})
			ii = ii - 1
			
			table.remove(sobrebancadas, ip) -- exclui a pos
			
			-- Verifica se ja acabaram todos os itens "is"
			if ii <= 0 then 
				table.remove(itens.sobrebancadas, 1)
				-- Passa as variaveis para o proximo da lista
				if itens.sobrebancadas[1] then
				
					is = itens.sobrebancadas[1][1]
					ii = itens.sobrebancadas[1][2]
				else
					break
				end
			end
			
		end
		
	end
	
	-- Transforma todas as sobrebancadas restantes para decoração simples normal
	-- Pegar todas bancadas
	local sobrebancadas = minetest.find_nodes_in_area(
		{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
		{x=pos.x+dist, y=pos.y+14, z=pos.z+dist}, 
		{"sunos:sobrebancada_repo"}
	)
	for _,p in ipairs(sobrebancadas) do
		local n = minetest.get_node(p)
		minetest.set_node(p, {name="sunos:simples_repo"})
	end
	
	if itens.simples then
		
		-- Pegar todas bancadas
		local simples = minetest.find_nodes_in_area(
			{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
			{x=pos.x+dist, y=pos.y+14, z=pos.z+dist}, 
			{"sunos:simples_repo"}
		)
		-- Trocar por bancadas reais
		local is = itens.simples[1][1] -- itemstring do item a ser colocado
		local ii = itens.simples[1][2] -- quantidade de itens "is" a ser colocado
		while (table.maxn(simples) > 0) and (ii > 0) do
			local ip = math.random(1, table.maxn(simples)) -- index da pos escolhida
			local p = simples[ip]
			
			local n = minetest.get_node(p)
			minetest.set_node(p, {name=is,param2=n.param2})
			ii = ii - 1
			
			table.remove(simples, ip) -- exclui a pos
			
			-- Verifica se ja acabaram todos os itens "is"
			if ii <= 0 then 
				table.remove(itens.simples, 1)
				-- Passa as variaveis para o proximo da lista
				if itens.simples[1] then
					is = itens.simples[1][1]
					ii = itens.simples[1][2]
				else
					break
				end
			end
			
		end
		
	end
	
	-- Remove itens de reposição restantes
	-- Pegar todas bancadas
	local simples = minetest.find_nodes_in_area(
		{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
		{x=pos.x+dist, y=pos.y+14, z=pos.z+dist}, 
		{"sunos:simples_repo"}
	)
	for _,p in ipairs(simples) do
		local n = minetest.get_node(p)
		minetest.remove_node(p)
	end
	
end
