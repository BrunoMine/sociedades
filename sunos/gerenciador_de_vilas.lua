--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Gerenciador de Vilas
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
		
		-- Correção para estrutura "casa_comunal" por ter "_" no termo
		if arq == "casa_comunal" then v[1] = "casa_comunal" end
		
		-- Verifica se o arquivo é de uma estrutura registrada
		if sunos.estruturas[v[1]] then
			
			-- Status do registro (para caso seja deletado durante a verificação)
			local stdata = true
			
			-- Pegar dados do arquivo
			local reg = sunos.bd:pegar("vila_"..vila, arq)
			
			-- Verifica se o fundamento ainda existe
			do
				-- Pega o node
				local n = pegar_node(reg.estrutura.pos)
				
				-- Verifica se é um fundamento
				if n.name ~= "sunos:fundamento" then
					
					stdata = false
					
					-- Elimina o arquivo
					sunos.bd:remover("vila_"..vila, arq)
				
				end
			end
			
			-- Verificar metadados
			if stdata == true then
			
				-- Pega matadados
				local meta = minetest.get_meta(reg.estrutura.pos)
				
				-- Verificar numero da vila
				if meta:get_string("vila") == "" or tonumber(meta:get_string("vila")) ~= tonumber(vila) then
				
					stdata = false
					
					-- Elimina o arquivo
					sunos.bd:remover("vila_"..vila, arq)
				
				end
			end
			
			-- Caso o arquivo seja de uma estrutura com população
			if stdata == true and sunos.estruturas[v[1]].pop then
	
				-- Contabiliza a população
				pop_total = pop_total + reg.pop	
				
			end
		
			-- Executa funções personalizadas
			if stdata == true and sunos.estruturas[v[1]].atualizando_vila then
				
				sunos.estruturas[v[1]].atualizando_vila(vila, arq, reg)
				
			end
		end
	end
	
	-- Salva a população atual
	sunos.bd:salvar("vila_"..vila, "pop_total", pop_total)
	
	-- Sem população a vila está abandonada
	if pop_total == 0 then
		
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
	if sunos.estruturas[tipo] then
		
		sunos.estruturas[tipo].verif_fund(pos)
		
	-- Caso nao seja de nenhum tipo encontrado
	else
		minetest.set_node(pos, {name="default:tree"})
	end
end

-- Atualiza as estruturas verificando se estao obstruidas
minetest.register_abm({
	nodenames = {"sunos:fundamento"},
	interval = sunos.var.tempo_verif_estruturas,
	chance = 1,
	action = function(pos)
		if minetest.get_meta(pos):get_string("vila") ~= sunos.versao then
			minetest.set_node(pos, {name = "default:tree"})
		end
		minetest.after(4, verificar_fundamento, {x=pos.x, y=pos.y, z=pos.z})	
	end,
})

