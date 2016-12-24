--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Montagem de vilas
  ]]


-- Validar bando de dados
if sunos.bd:verif("geral", "vilas") ~= true then
	sunos.bd:salvar("geral", "vilas", 0)
end

-- Registrar nova vila (retorna o numero da vila registrada)
local registrar_vila = function(n_estruturas)
	if n_estruturas == nil then n_estruturas = tonumber(0) end
	
	-- Pegar quantidade vilas
	local qtd = tonumber(sunos.bd:pegar("geral", "vilas"))
	
	qtd = qtd + 1
	
	-- Criar registro
	sunos.bd:salvar("vila_"..qtd, "numero", qtd)
	
	-- Salvar numero incial de estruturas
	sunos.bd:salvar("vila_"..qtd, "estruturas", n_estruturas)
	
	-- Atualizar quantidade de vilas
	sunos.bd:salvar("geral", "vilas", qtd)
	
	return qtd
end

-- Criar assentamento de construcao
local criar_assent = function(pos, dist)
	for x=pos.x-dist, pos.x+dist do
		for z=pos.z-dist, pos.z+dist do
			local y = pos.y + 6
			while y > pos.y-5 do
				local p = {x=x, y=y, z=z}
				if y > pos.y then
					minetest.set_node(p, {name="air"})
				elseif y == pos.y then
					minetest.set_node(p, {name="default:cobble"})
				elseif y == pos.y-1 then
					minetest.set_node(p, {name="default:dirt"})
				else
					minetest.set_node(p, {name="default:stone"})
				end
				y = y - 1
			end
		end
	end
	
	-- Criar faixa de terra ao redor
	local y = pos.y + 6
	while y > pos.y-5 do
		for x=pos.x-dist-1, pos.x+dist+1 do
			local p1 = {x=x, y=y, z=pos.z+dist+1}
			local p2 = {x=x, y=y, z=pos.z-dist-1}
			if y > pos.y then
				minetest.set_node(p1, {name="air"})
				minetest.set_node(p2, {name="air"})
			elseif y == pos.y then
				minetest.set_node(p1, {name="default:dirt_with_grass"})
				minetest.set_node(p2, {name="default:dirt_with_grass"})
			elseif y == pos.y-1 then
				minetest.set_node(p1, {name="default:dirt"})
				minetest.set_node(p2, {name="default:dirt"})
			else
				minetest.set_node(p1, {name="default:stone"})
				minetest.set_node(p2, {name="default:stone"})
			end
		end
		for z=pos.z-dist-1, pos.z+dist+1 do
			local p1 = {x=pos.x+dist+1, y=y, z=z}
			local p2 = {x=pos.x-dist-1, y=y, z=z}
			if y > pos.y then
				minetest.set_node(p1, {name="air"})
				minetest.set_node(p2, {name="air"})
			elseif y == pos.y then
				minetest.set_node(p1, {name="default:dirt_with_grass"})
				minetest.set_node(p2, {name="default:dirt_with_grass"})
			elseif y == pos.y-1 then
				minetest.set_node(p1, {name="default:dirt"})
				minetest.set_node(p2, {name="default:dirt"})
			else
				minetest.set_node(p1, {name="default:stone"})
				minetest.set_node(p2, {name="default:stone"})
			end
		end
		y = y - 1
	end
end


-- Verifica uma pos obstruida (pode verificar largura disponivel de assentamento)
local verif_obs = function(pos, assent)
	if pos == nil then
		minetest.log("error", "[Sunos] Tabela pos nula (em verif_obs)")
		return false
	end
	
	-- Amplitude das verificações
	local subir = 1 -- Subir antes de descer verificando
	local desce = 2 -- Descer verificando
	
	if assent and tonumber(assent) then
		local a = 0
		while a <= assent do
			local i = 0
			local p = {x=pos.x, y=pos.y, z=pos.z}
			
			-- Quinas
			p = {x=pos.x+a, y=pos.y, z=pos.z+a}
			if sunos.pegar_solo(p, desce, subir) then i = i + 1 end
			
			p = {x=pos.x+a, y=pos.y, z=pos.z-a}
			if sunos.pegar_solo(p, desce, subir) then i = i + 1 end
			
			p = {x=pos.x-a, y=pos.y, z=pos.z+a}
			if sunos.pegar_solo(p, desce, subir) then i = i + 1 end
			
			p = {x=pos.x-a, y=pos.y, z=pos.z-a}
			if sunos.pegar_solo(p, desce, subir) then i = i + 1 end
			
			-- Lados
			p = {x=pos.x+a, y=pos.y, z=pos.z}
			if sunos.pegar_solo(p, desce, subir) then i = i + 1 end
			
			p = {x=pos.x-a, y=pos.y, z=pos.z}
			if sunos.pegar_solo(p, desce, subir) then i = i + 1 end
			
			p = {x=pos.x, y=pos.y, z=pos.z+a}
			if sunos.pegar_solo(p, desce, subir) then i = i + 1 end
			
			p = {x=pos.x, y=pos.y, z=pos.z-a}
			if sunos.pegar_solo(p, desce, subir) then i = i + 1 end
			
			if i < 8 then 
				a = a - 1
				break 
			end 
			a = a + 1
		end
		return a
	end
	
	-- verifica bloco um bloco
	if sunos.pegar_solo(pos, 4, 2) then 
		return true 
	else
		return false	
	end
end

-- Verifica direcoes obstruidas (retorna tabela de disponiveis como segundo valor)
local verif_obs_dir = function(pos, dist)
	if pos == nil then
		minetest.log("error", "[Sunos] Tabela pos nula (em verif_obs_dir)")
		return false
	end
	if dist == nil then dist = 4 end
	
	local obs = {}
	local disp = {}
	
	for _,dir in ipairs({"x+", "x-", "z+", "z-"}) do
		
		if verif_obs(sunos.ir_dir(pos, dir, dist)) == false then 
			table.insert(obs, dir) 
		else 
			table.insert(disp, dir) 
		end
		
	end
	
	return obs, disp
end


-- Tentar colocar assentamentos
--[[
	Essa função tenta colocar um assentamento
	da melhor maneira possivel dentre as 4 direções possiveis
  ]]
local tentar_assentamento = function(pos)
	if pos == nil then
		minetest.log("error", "[Sunos] Tabela pos nula (em verif_assentamento)")
		return false
	end
	
	-- Distancia centro-borda do assentamento
	local dist_assent = math.random(4, 6)
	
	-- Distancia da rua ao centro do terreno
	local dist = dist_assent + 2
	
	-- Pegando lugares obstruidos e disponiveis
	local obs, disp = verif_obs_dir(pos, dist)
	
	-- Descarta caso nao encontre possibilidades
	if table.maxn(disp) == 0 then return false end
	
	-- Montando metapos de possiveis lugares
	local mpos = {}
	for n,dir in ipairs(disp) do
		local p = sunos.pegar_solo(sunos.ir_dir(pos, dir, dist), 4, 2)
		local dist_disp = verif_obs(p, dist_assent)
		-- Desconta a dintancia entre obstrucoes (assentamentos, ruas e etc)
		dist_disp = dist_disp - 3
		-- armazenando
		if dist_disp >= 1 and minetest.find_node_near(p, dist_assent, {"group:leaves", "group:tree", "group:water"}) == nil then
			table.insert(mpos, {p=p, dist=dist_disp})
		end
	end
	
	-- Pega o metapos
	local max = 0
	local nmax = nil
	for n,dados in ipairs(mpos) do
		if dados.dist > max then
			max = dados.dist
			nmax = n
		end
	end
	
	if nmax == nil or max == 0 then
		return nil
	end
	
	criar_assent(mpos[nmax].p, mpos[nmax].dist)
	
	return {pos=mpos[nmax].p, dist=mpos[nmax].dist}
end


-- Montar uma vila
sunos.criar_vila = function(pos, vpos)
	if pos == nil then
		minetest.log("error", "[Sunos] Tabela pos nula (em sunos.criar_vila)")
		return false
	end
	if vpos == nil then
		vpos = {}
	end	
	
	-- Metanode que guia a montagem
	-- Realizar ciclos para montar a vila
	local dir = nil
	local dir_ant = nil
	local assent_rest = math.random(6, 10) 
	local assentamentos = {}
	local ciclo = 0
	while ciclo <= 50 and assent_rest > 0 do
		
		-- Verificar lados obstruidos (dir_ant se inclui altomaticamente)
		local obs = verif_obs_dir(pos, 4)
		
		
		-- Verifica se todas as direcoes estao obstruidas
		if table.maxn(obs) < 4 
			and minetest.find_node_near(pos, 6, {"group:leaves", "group:tree", "group:water"}) == nil
		then
		
			-- Define nova direcao
			dir = sunos.pegar_dir_aleatoria(obs)
		
			-- Move metapos para o novo lugar
			pos = sunos.ir_dir(pos, dir, 4)
			pos = sunos.f_pegar_solo(pos, false, 5, 10)
		
			-- Prepara direcao anterior para o proximo loop
			dir_ant = dir
		
			-- Tenta montar um assentamento antes de finalizar o loop (a cada um certo tanto de ruas)
			if assent_rest > 0 then
				local assent = tentar_assentamento(pos)
				if assent then
					table.insert(assentamentos, assent)
					assent_rest = assent_rest - 1
				end
			end
		else
			if table.maxn(vpos) > 1 then
				pos = vpos[1]
				table.remove(vpos, 1)
			else
				break
			end
		end
		
		ciclo = ciclo + 1
	end
	
	-- Variavel que verifica se ja colocou ao menos uma casa
	local tem_casa = false
	
	-- Variavel que verifica se tem uma feirinha
	local tem_loja = false
	
	-- Montar estruturas nos assentamentos criados
	if assentamentos then
		
		-- Registra a nova vila
		local vila = registrar_vila(table.maxn(assentamentos))
		
		-- Cria cada casa
		for n,dados in ipairs(assentamentos) do
			
			-- Tipo
			local tipo = "casa"
			
			-- Largura
			local largura = dados.dist*2+1
			
			-- Verifica se deve colocar uma feirinha
			if largura == 5 and tem_casa and tem_loja == false then tipo = "loja" end
			
			-- Troca o tipo para decor caso a largura seja 3
			if largura == 3 then tipo = "decor" end
			
			
			if tipo == "casa" then
				
				-- Montar casa
				sunos.construir_casa_comum(dados.pos, dados.dist, vila, true)
				
				-- Recoloca itens reais (apartir dos itens de reposição)
				sunos.decor_repo(dados.pos, dados.dist, sunos.tb_repo_casas[tostring(dados.dist)]())
				
				tem_casa = true
				
			elseif tipo == "decor" then
				
				-- Montar estrutura decorativa
				sunos.construir_decor(dados.pos, dados.dist, vila, true)
				
			elseif tipo == "loja" then
				
				sunos.construir_loja(dados.pos, dados.dist, true, vila)
				
				tem_loja = true
			end
		end
		
		-- Atualizar banco de dados
		sunos.atualizar_bd_vila(vila)
	end
end
