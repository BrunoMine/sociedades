--[[
	Lib Tror para Minetest
	Tror v2.0.0 Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Autoria do código:
	Originalmente por BrunoMine, Bruno Borges <borgesdossantosbruno@gmail.com>
  ]]

local tror = {}

local ajustar_tabela = function(items)
	if not items then return end
	
	-- Torna tabela
	if type(items) == "string" then
		items = {items}
	end
	
	-- Torna itens em tabelas
	if items[1] then
		for i,item in ipairs(items) do
			if type(item) == "string" then
				local n = string.split(item, " ")
				items[i] = {name=n[1]}
			end
		end
	end
	
	-- Consolida dados de cada item
	for i,item in ipairs(items) do
		local wear = tonumber(item.wear or 0)
		items[i].wear = wear
		items[i].count = tonumber(item.count or 1)
		items[i].metadata = tostring(item.metadata or "")
	end
	
	-- Evita redundancias de itens
	-- Transforma a tabela em desordenada para poder remover valores sem alterar a sequencia
	local old_items = minetest.deserialize(minetest.serialize(items))
	items = {}
	for i,item in ipairs(old_items) do
		items[tostring(i)] = minetest.deserialize(minetest.serialize(item))
	end
	-- Acumula os itens exatamente iguais
	for i,item in pairs(items) do
		for ii,iitem in pairs(items) do
			if item and iitem and ii ~= i then
				if iitem.name == item.name 
					and iitem.name == item.name 
					and iitem.metadata  == item.metadata 
					and iitem.wear == item.wear 
				then
					items[i].count = items[i].count + items[ii].count
					items[ii] = nil
				end
			end
		end
	end
	-- Restaura a tabela
	old_items = minetest.deserialize(minetest.serialize(items))
	items = {}
	for i,item in pairs(old_items) do
		table.insert(items, minetest.deserialize(minetest.serialize(item)))
	end
	
	return items
end

-- Verificar viabilidade de uma troca
tror.verificar = function(player, item_rem, item_add)

	if not player or not item_add or not item_rem then
		minetest.log("error", "[Tror] Faltou dados em (em tror.verificar)")
		return false
	end
	
	local inv = player:get_inventory()
	
	-- Verificar jogador
	if not inv:contains_item("main", item_rem) then
		return 1 -- Jogador nao pode pagar
	elseif not inv:room_for_item("main", item_add) then
		return 2 -- Jogador com inventario lotado
	end
	
	return true
end


-- Tenta trocar itens
tror.trocar = function(player, item_rem, item_add)
	
	if not player then
		minetest.log("error", "[Tror] Faltou player (em tror.trocar_plus)")
		return false
	end
	
	-- Ajusta para tabelas
	item_rem = ajustar_tabela(item_rem)
	item_add = ajustar_tabela(item_add)
	
	local pos = player:getpos()
	
	local inv = player:get_inventory()
	
	-- Verificar se o jogador possui os itens requisitados
	local possui = true
	for _,item in ipairs(item_rem) do
		
		if not inv:contains_item("main", item) then
			possui = false
			break
		end
	end
	
	-- Retorna false por jogador não ter os itens requisitados
	if possui == false then
		return false
	end
	
	-- Retira itens do jogador
	for _,item in ipairs(item_rem) do
		for r=1, tonumber(item.count), 1 do -- tira 1 por vez
			inv:remove_item("main", item.name) 
		end
	end
	
	-- Transfere todos os itens ao jogador (e dropa os que nao couberem no inventario)
	local dropou = false
	for _,item in ipairs(item_add) do
		if inv:room_for_item("main", item) then
			inv:add_item("main", item)
		else
			dropou = true
			minetest.env:add_item({x = pos.x + math.random() * 2 - 1, y = pos.y+1, z = pos.z + math.random() * 2 - 1}, item)
		end
	end
	
	return true
	
end


return tror
