--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Gerenciador de Vilas
  ]]
  
-- Variaveis do sistema
-- Tempo (em segundos) entre as verificações de estrutura obstruida
local tempo_verif_estruturas = tonumber(minetest.setting_get("sunos_verif_fundamento") or 7)
-- Tempo (em segundos) em que uma casa comunal pode ficar em decadencia antes de perder o fundamento
local tempo_decadencia = tonumber(minetest.setting_get("sunos_casa_comunal_decadencia") or 300)

-- Pega ignore apenas se bloco nao foi gerado
local function pegar_node(pos)
	local node = minetest.get_node(pos)
	if node.name == "ignore" then
		minetest.get_voxel_manip():read_from_map(pos, pos)
		node = minetest.get_node(pos)
	end
	return node
end

-- Diretorio do mundo
local worldpath = minetest.get_worldpath()
-- Atualizar banco de dados da vila
sunos.atualizar_bd_vila = function(vila)
	if vila == nil then
		minetest.log("error", "[Sunos] Variavel vila nula (em sunos.atualizar_bd_vila)")
		return false
	end
	
	-- Pegar lista de tabelas da vila
	local list = minetest.get_dir_list(worldpath.."/sunos/vila_"..vila)
	if not list then
		minetest.log("error", "[Sunos] Banco de dados da vila inexistente (em sunos.atualizar_bd_vila)")
		return false
	end
	
	-- População total
	local pop_total = 0
	
	-- Analiza os arquivos do banco de dados
	for _,arq in ipairs(list) do
		
		-- Separa os termos de cada arquivo a ser analizado
		local v = string.split(arq, "_")
		
		-- Caso o arquivo seja de uma casa
		if v[1] == "casa" and tonumber(v[2]) then
		
			-- Pegar dados do arquivo
			local reg = sunos.bd:pegar("vila_"..vila, arq)
			
			-- Verifica se o fundamento ainda existe
			local n = pegar_node(reg.estrutura.pos)
			
			if n.name ~= "sunos:fundamento" then
				
				-- Elimina o arquivo
				sunos.bd:remover("vila_"..vila, arq)
				
			else
				-- Verifica se os metadados estao correspondendo ao banco de dados
				local meta = minetest.get_meta(reg.estrutura.pos)
				
				if not meta:get_string("vila") or tonumber(meta:get_string("vila")) ~= tonumber(vila) then
				
					--Elimina o arquivo
					sunos.bd:remover("vila_"..vila, arq)
					
				else
					
					-- Contabiliza a população
					pop_total = pop_total + reg.pop	
					
				end
			end
		
		-- Caso o arquivo seja de uma casa comunal
		elseif v[1] == "casa_comunal" then
			
			-- Pegar dados do arquivo
			local reg = sunos.bd:pegar("vila_"..vila, arq)
			
			-- Verifica se o fundamento ainda existe
			local n = pegar_node(reg.estrutura.pos)
			if n.name ~= "sunos:fundamento" then
			
				-- Elimina o arquivo
				sunos.bd:remover("vila_"..vila, arq)
				
			else
				
				-- Verifica se os metadados estao correspondendo ao banco
				local meta = minetest.get_meta(reg.estrutura.pos)
				
				if not meta:get_string("vila") or tonumber(meta:get_string("vila")) ~= vila then
				
					--Elimina o arquivo
					sunos.bd:remover("vila_"..vila, arq)
					
				end
				
			end
		end
	end
	
	-- Salva a população atual
	sunos.bd:salvar("vila_"..vila, "pop_total", pop_total)
	
	-- Remove banco de dados da vila caso esteja deserta e sem casa comunal
	if pop_total == 0 and sunos.bd:verif("vila_"..vila, "casa_comunal") == false then
		
		sunos.bd:drop_tb("vila_"..vila)
	end
	
	return true
end

-- Funcao para verificar fundamentos
local verificar_fundamento = function(pos)
	if not pos then return end
	
	local node = minetest.get_node(pos)
	
	if node.name ~= "sunos:fundamento" then return end
	
	local meta = minetest.get_meta(pos)
	local vila = meta:get_string("vila")
	if not vila then return end
	vila = tonumber(vila)
	local tipo = meta:get_string("tipo")
	local dist = tonumber(meta:get_string("dist"))
	
	if not vila then return end
	
	-- Verificar mapa carregado antes de verificar estruturas
	if sunos.verif_carregamento(pos, tonumber(dist)) == false then
		return
	end
	
	-- Verifica se o registro da vila ainda existe no banco de dados
	if table.maxn(minetest.get_dir_list(worldpath.."/sunos/vila_"..vila)) == 0 then
		
		-- Montar ruinas no local
		sunos.montar_ruinas(pos, dist)
		
		-- Trocar bloco de fundamento por madeira
		minetest.set_node(pos, {name="default:tree"})
		return
	end
	
	-- Verificação de casa comunal
	if tipo == "casa_comunal" then
		local status = meta:get_string("status")
		
		-- Caso esteja ativa
		if status == "ativa" then
			if sunos.verificar_blocos_estruturais(pos) == false then -- Verificar Estrutura danificada
			
				-- Tornar estrutura em ruinas
				sunos.montar_ruinas(pos, dist)
			
				-- Inicia processo de decadencia da casa comunal
				meta:set_string("status", "destruida")
				meta:set_string("tempo", 0) -- Tempo de decadencia (em segundos)
			end
		
		-- Caso esteja em decadencia
		else
			local tempo = tonumber(meta:get_string("tempo")) + tempo_verif_estruturas
			
			if tempo > tempo_decadencia then
				
				-- Verifica se ainda tem habitantes mantem a decadencia
				local pop = sunos.bd:pegar("vila_"..vila, "pop")
				if pop > 0 then
					meta:set_string("tempo", 0)
				else
					-- Remove casa comunal de vez
					-- Remove do banco de dados
					sunos.bd:remover("vila_"..vila, "casa_comunal")
					
					-- Trocar bloco de fundamento por madeira
					minetest.set_node(pos, {name="default:tree"})
					
					-- Atualizar banco de dados da vila
					sunos.atualizar_bd_vila(vila)
				end
			else
				meta:set_string("tempo", tempo) -- Salva o tempo que passou e continua a decadencia
			end
		end
		
	-- Verificação de estrutura comum
	elseif tipo == "casa" or tipo == "decor" or tipo == "loja" then
		
		if sunos.verificar_blocos_estruturais(pos) == false then -- Verificar Estrutura danificada
			
			-- Montar ruinas no local da antiga casa
			sunos.montar_ruinas(pos, dist)
			
			-- Exclui o arquivo da estrutura do banco de dados
			sunos.bd:remover("vila_"..meta:get_string("vila"), tipo.."_"..meta:get_string("estrutura"))
			
			-- Trocar bloco de fundamento por madeira
			minetest.set_node(pos, {name="default:tree"})
			
			-- Atualizar banco de dados da vila
			sunos.atualizar_bd_vila(vila)
		end
		
	-- Caso nao seja de nenhum tipo encontrado
	else
		minetest.set_node(pos, {name="default:tree"})
	end
end

-- Atualiza as estruturas verificando se estao obstruidas
minetest.register_abm({
	nodenames = {"sunos:fundamento"},
	interval = tempo_verif_estruturas,
	chance = 1,
	action = function(pos)
		minetest.after(1, verificar_fundamento, {x=pos.x, y=pos.y, z=pos.z})	
	end,
})

