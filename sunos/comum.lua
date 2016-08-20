--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Métodos comuns
  ]]

-- Pegar direcao oposta
sunos.pegar_dir_oposta = function(dir)
	if dir == "x+" then
		return "x-"
	end
	if dir == "x-" then
		return "x+"
	end
	if dir == "z+" then
		return "z-"
	end
	if dir == "z-" then
		return "z+"
	end
end

-- Pega ignore apenas se bloco nao foi gerado
sunos.pegar_node = function(pos)
	local node = minetest.get_node(pos)
	if node.name == "ignore" then
		minetest.get_voxel_manip():read_from_map(pos, pos)
		node = minetest.get_node(pos)
	end
	return node
end

-- Encontrar solo
sunos.pegar_solo = function(pos, dist, subir)
	if pos == nil then
		minetest.log("error", "[Sunos] Tabela pos nula (em sunos.pegar_solo)")
		return false
	end	
	
	if dist == nil then dist = 10 end
	if subir == nil then subir = 0 end
	local np = {x=pos.x, y=pos.y+subir, z=pos.z}
	local y = 0
	local r = nil
	while y <= dist do
		local node = sunos.pegar_node({x=np.x, y=np.y-y, z=np.z})
		if node.name == "default:dirt_with_grass" then
			r = {x=np.x, y=np.y-y, z=np.z}
			break
		end
		y = y + 1
	end
	return r
end


-- Mover pos para uma direcao
sunos.ir_dir = function(pos, dir, dist)
	if pos == nil then
		minetest.log("error", "[Sunos] Tabela pos nula (em sunos.ir_dir)")
		return false
	end
	
	if dist == nil then dist = 1 end
	
	if dir == "x+" then
		return {x=pos.x+dist, y=pos.y, z=pos.z}
	elseif dir == "x-" then
		return {x=pos.x-dist, y=pos.y, z=pos.z}
	elseif dir == "z+" then
		return {x=pos.x, y=pos.y, z=pos.z+dist}
	elseif dir == "z-" then
		return {x=pos.x, y=pos.y, z=pos.z-dist}
	else
		return pos
	end
end

-- Gira uma direcao
sunos.girar_dir = function(dir, lado)
	if dir == nil then
		minetest.log("error", "[Sunos] String dir nula (em sunos.girar_dir)")
		return false
	end
	if lado ~= "<" and lado ~= ">" then
		minetest.log("error", "[Sunos] String lado invalida (em sunos.girar_dir)")
		return false
	end
	
	if dir == "x+" then
		if lado == "<" then 
			return "z+"
		else
			return "z-"
		end 
	elseif dir == "x-" then
		if lado == "<" then 
			return "z-"
		else
			return "z+"
		end 
	elseif dir == "z+" then
		if lado == "<" then 
			return "x-"
		else
			return "x+"
		end 
	elseif dir == "z-" then
		if lado == "<" then 
			return "x+"
		else
			return "x-"
		end
	end
end


-- Pegar uma direcao aleatoriamente
sunos.pegar_dir_aleatoria = function(exeto)
	local d = {"x+", "x-", "z+", "z-"}
	if table.maxn(exeto) >= 4 then 
		minetest.log("error", "[Sunos] todas as direcoes foram proibidas (em sunos.pegar_dir_aleatoria)")
		return nil 
	end
	
	if exeto and table.maxn(exeto) > 0 then
		for _,dir2 in ipairs(exeto) do
			for n,dir in ipairs(d) do
				if dir == dir2 then
					table.remove(d, n)
				end
			end
		end
	end
	
	return d[math.random(1, table.maxn(d))]
end


-- Forçar tentar pegar solo
sunos.f_pegar_solo = function(p, degrau, dist, subir)
	if p == nil then
		minetest.log("error", "[Sunos] Tabela p nula (em sunos.f_pegar_solo)")
		return false
	end
	if subir == nil then subir = 0 end
	local s = sunos.pegar_solo(p, dist, subir)
	if s == nil then
		s = p
		local pp = minetest.find_node_near(p, 2, {"default:cobble"})
		if pp then s.y = pp.y end
	end
	if degrau then
		if s.y > p.y then
			s.y = p.y + 1
		elseif s.y < p.y then
			s.y = p.y - 1
		end
	end
	return s
end
