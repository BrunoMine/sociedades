--[[
	Mod Sovagxas para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Mapgen
  ]]


-- Pega ignore apenas se bloco nao foi gerado
local function pegar_node(pos)
	local node = minetest.get_node(pos)
	if node.name == "ignore" then
		minetest.get_voxel_manip():read_from_map(pos, pos)
		node = minetest.get_node(pos)
	end
	return node
end


-- Encontrar solo
--[[
	Verifica 80 blocos de uma coluna.
	Feita para verificar MapBlocks (blocos de mapa)
  ]]
local function pegar_solo(pos)
	local y = 0
	local r = nil
	while y <= 79 do
		local node = pegar_node({x=pos.x, y=pos.y-y, z=pos.z})
		if node.name == "default:dirt" then
			r = {x=pos.x, y=pos.y-y, z=pos.z}
			break
		end
		y = y + 1
	end
	return r
end


-- Verifica se um ponto existe na malha
local function verificar_ponto(x, z)
	if x < 1 or x > 7 or z < 1 or z > 7 then 
		return false
	else
		return true
	end
end

-- Comparar valor max
local function comparar_max(max, n)
	if max == nil then
		return n
	elseif max < n then
		return n
	else
		return max
	end
end

-- Comparar valor min
local function comparar_min(min, n)
	if min == nil then
		return n
	elseif min > n then
		return n
	else
		return min
	end
end

-- Montar malha e coletar dados nos pontos
local pegar_malha = function(minp, maxp)	
	local vetor = {}
	
	-- Vetor de dados
	for x=1, 7 do
		vetor[x] = {}
		for z=1, 7 do
			vetor[x][z] = {}
		end
	end
	
	-- Pegando dados para cada posicao
	for x,_ in ipairs(vetor) do
		for z,_ in ipairs(vetor[x]) do
		
			-- Pegar solo
			vetor[x][z].p = pegar_solo({x=minp.x+(10*x), y=maxp.y, z=minp.z+(10*z)})
			
			-- Calcular variacao dos pontos adjacentes
			local max, min = nil, nil
			local div = 0
			for xi=-1, 1 do
				for zi=-1, 1 do
					local xn, zn = x+xi, z+zi
					if verificar_ponto(xn, zn) then
						if vetor[xn][zn].p then
							max = comparar_max(max, vetor[xn][zn].p.y)
							min = comparar_min(min, vetor[xn][zn].p.y)
							div = div + 1
						end
					end
				end
			end
			if div >= 5 then
				vetor[x][z].var = max - min
			else
				vetor[x][z].var = nil
			end
		end
	end
	
	return vetor
end


-- Chamada de função para verificar mapa gerado
--[[
	São feita algumas verificações prévias importantes e 
	extração de posições de chão plano.
	Deve-se ter cuidado para evitar alto uso de memoria nas verificações
  ]]
local verificar_mapa_gerado = function(minp, maxp)
	
	-- Verificar altura
	if minp.y < -70 or minp.y > 120 then return end
	
	-- Procura um tronco de arvore selvagem no bloco de mapa gerado
	local t = minetest.find_node_near({x=minp.x+20, y=minp.y+40, z=minp.z+20}, 8, {"default:jungletree"})
	
	-- Verifica se encontrou um tronco
	if not t then return end
	
	-- Pega a coordenada do solo do tronco encontrado
	local pos = pegar_solo(t)
	
	-- Verifica se encontrou um solo
	if not pos then return end
	
	-- Verifica se tem terra ou pedra no local onde vai ficar a copa da arvore
	if minetest.find_node_near({x=pos.x, y=pos.y+15, z=pos.z}, 10, {"group:stone", "group:dirt", "group:sand"}) then return end
	
	-- Sortear chance de criar arvore
	if math.random(1, 100) > sovagxas.RARIDADE then return end
	
	-- gerar arvore no local
	sovagxas.montar_arvore(pos)
end

minetest.register_on_generated(function(minp, maxp, seed)
	
	-- A verificação é feita apos um intervalo de tempo para garantir que o mapa foi corretamente gerado
	minetest.after(2, verificar_mapa_gerado, minp, maxp)
end)



































