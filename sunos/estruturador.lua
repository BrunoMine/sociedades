--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Montagem de estruturas
  ]]

local modpath = minetest.get_modpath("sunos")

-- Pegar um nome de uma arquivo de estrutura aleatoriamente
local pegar_arquivo = function(largura)
	if largura == nil then
		minetest.log("error", "[Sunos] Largura nula (em pegar_arquivo)")
		return false
	end
	
	local estruturas = minetest.get_dir_list(modpath.."/estruturas")
	
	local validos = {}
	if estruturas ~= nil then
		for _,nome in ipairs(estruturas) do
			local n = string.split(nome, ".")
			if n[2] and tonumber(n[2]) == tonumber(largura) then
				table.insert(validos, n[1])
			end
		end
	else
		return nil
	end
		
	
	if validos[1] then
		return validos[math.random(1, table.maxn(validos))]
	else
		return nil
	end
end

-- Montar uma estrutura
sunos.montar_estrutura = function(cpos, dist)
	if cpos == nil then
		minetest.log("error", "[Sunos] Tabela cpos nula (em sunos.montar_estrutura)")
		return false
	end
	
	-- Coleta de dados
	local pos = {x=cpos.x-dist, y=cpos.y, z=cpos.z-dist}
	
	-- Largura
	local largura = 2*dist+1
	local altura = 15
	
	-- Estrutura
	local ESTRUTURA = {}
	
	if pegar_arquivo(largura) == nil then return false end
	
	local input = io.open(modpath .. "/estruturas/"..pegar_arquivo(largura).."."..largura, "r")
	if input then
		ESTRUTURA = minetest.deserialize(input:read("*l"))
	else
		return false
	end
	io.close(input)
	
	-- Criar estrutura
	local ix, iy, iz = 1, 1, 1
	local x, y, z = pos.x, pos.y, pos.z
	local limx, limy, limz = (pos.x+largura-1), (pos.y+altura-1), (pos.z+largura-1)
	local i = 0
	while (x <= limx) do
		while (y <= limy) do
			while (z <= limz) do
				local node = ESTRUTURA[ix.." "..iy.." "..iz] or {node={name="air"}}
				minetest.set_node({x = x, y = y, z = z}, node)
				i = i + 1
				z = z + 1
				iz = iz + 1
			end
			z = pos.z
			iz = 1
			y = y + 1
			iy = iy + 1
		end
		y = pos.y
		iy = 1
		x = x + 1
		ix = ix + 1
	end
	
	return true
end
