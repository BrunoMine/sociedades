--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Métodos comuns
  ]]

-- Caminho do diretório do mod
local modpath = minetest.get_modpath("sunos")

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

-- Pega um node
--[[
	Pega o node normalmente e tenta carregar o node
	caso resulte em ignore. Se o node não tiver sido gerado
	o retorno será ignore.
  ]]
sunos.pegar_node = function(pos)
	local node = minetest.get_node(pos)
	if node.name == "ignore" then
		minetest.get_voxel_manip():read_from_map(pos, pos)
		node = minetest.get_node(pos)
	end
	return node
end

-- Encontrar solo
--[[
	Essa função recebe uma pos e tenta encontrar
	o solo de terra com grama através de um loop que desce
	verificando a partir da altura da pos.
	Retorno:
		<pos> é a pos do solo encontrado ou nil caso não encontre
	Argumentos:
		<dist> OPCIONAL | é a distancia que o loop 
			acontece descendo (padrão é 10) 
		<subir> OPCIONAL | é uma distância para cima que o
			loop deve iniciar (padrão é 0) 
  ]]
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

-- Pegar uma arquivo de estrutura aleatoriamente
--[[
	Essa função retorna um nome aleatorio de arquivo para estrutura.
	Argumentos:
		<largura> Largura da estrutura
		<tipo> Tipo da estrutura
	Retorno:
		<nome> Nome da estrutura (Ex. casa_simples)
  ]]
sunos.pegar_arquivo = function(largura, tipo)
	if largura == nil then
		minetest.log("error", "[Sunos] Largura nula (em sunos.pegar_arquivo)")
		return nil
	end
	if tipo == nil then
		minetest.log("error", "[Sunos] Tipo de estrutura nula (em sunos.pegar_arquivo)")
		return nil
	end
	
	local estruturas = minetest.get_dir_list(modpath.."/estruturas/"..tipo)
	
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


-- Mover pos para uma direcao
--[[
	Essa função calcula uma pos deslocada para uma direção
	definida.
	Retorno:
		<pos> é a pos deslocada
	Argumentos:
		<pos> é a pos de onde o descolamento ocorre
		<dir> é a string da direção que o deslocamento ocorre
			("x+", "x-", "z+" ou "z-")
		<dist> OPCIONAL | é a distância de deslocamento
			(padrão é 1)
  ]]
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
--[[
	Essa função calcula uma direção rotacionada.
	Para ajudar o entendimento, imagine que você
	(como jogador) está vidade para a direção "x+",
	caso vire para a esquerda estará virado para "z+".
	Essa é a lógica aqui.
	Retorno:
		<dir> é a direção rotacionada
	Argumentos:
		<dir> é a direção inicial
		<lado> é pra que lado ela deve virar
			("<"(direita) ou ">"(esquerda))
  ]]
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
--[[
	Essa função retona uma direção aleatoriamente
	Retorno:
		<dir> é uma direção aleatória
	Argumentos:
		<exeto> OPCIONAL | é uma tabela ordenada
			de direção que devem ser evitadas
			(ex. {"x+", "z-"})
  ]]
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
--[[
	Essa função é similar à sunos.pegar_solo, mas
	não força um retorno não nulo.
	Retorno:
		<pos> pos de um solo
	Argumentos:
		<pos> é uma pos onde será analizado
		<degrau> é um valor booleano para que retorne
			uma <pos> com apenas 1 de diferença de altura
			(util para montar diferença suave de alturas/degrais)
		<dist> OPCIONAL | é a distancia que o loop 
			acontece descendo (padrão é o mesmo de sunos.pegar_solo) 
		<subir> OPCIONAL | é uma distância para cima que o
			loop deve iniciar (padrão é 0)
  ]]
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
