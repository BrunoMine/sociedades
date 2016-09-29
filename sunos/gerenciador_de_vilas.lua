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
local tempo_verif_estruturas = 5--60
-- Tempo (em segundos) em que uma casa comunal pode ficar em decadencia antes de perder o fundamento
local tempo_decadencia = 10--300

-- Atualiza as estruturas verificando se estao obstruidas
minetest.register_abm({
	nodenames = {"sunos:fundamento"},
	interval = tempo_verif_estruturas,
	chance = 1,
	action = function(pos)	
		local meta = minetest.get_meta(pos)
		local vila = meta:get_string("vila")
		local tipo = meta:get_string("tipo")
		local dist = meta:get_string("dist")
		
		-- Verificação de caasa comunal
		if tipo == "casa_comunal" then
			local status = meta:get_string("status")
			
			if status == "ativa" then
				if sunos.verificar_blocos_estruturais(pos) == false then -- Verificar Estrutura danificada
				
					-- Tornar estrutura em ruinas (mantendo o solo e fundamento)
					-- Pega todas elementos pedrosos
					local nodes = minetest.find_nodes_in_area(
						{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
						{x=pos.x+dist, y=pos.y+14, z=pos.z+dist}, 
						{"group:stone", "group:cobble"}
					)
					-- Limpa toda a area
					for x=pos.x-dist, pos.x+dist do
						for z=pos.z-dist, pos.z+dist do
							for y=pos.y+1, pos.y+14 do
								minetest.remove_node({x=x,y=y,z=z})
							end
						end
					end
					-- Recoloca pedregulho no lugar de elementos pedrosos
					for _,p in ipairs(nodes) do
						minetest.set_node(p, {name="default:cobble"})
					end
				
					-- Inicia processo de decadencia da casa comunal
					meta:set_string("status", "destruida")
					meta:set_string("tempo", 0) -- Tempo de decadencia (em segundos)
				end
			
			-- Casa comunal em decadencia
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
					end
				else
					meta:set_string("tempo", tempo) -- Salva o tempo que passou e continua a decadencia
				end
			end
			
		-- Verificação de casa e estrutura decorativa
		elseif tipo == "casa" or tipo == "decor" then
			
			if sunos.verificar_blocos_estruturais(pos) == false -- Verificar Estrutura danificada
				-- or sunos.verificar_estrutura(pos, tonumber(meta:get_string("dist"))) == false -- [CANCELADO]
			then
				
				-- Montar ruinas no local da antiga casa
				sunos.montar_ruinas(pos, dist)
				
				-- Remover do bando de dados
				if tipo == "casa" then
					sunos.bd:remover("vila_"..meta:get_string("vila"), "casa_"..meta:get_string("estrutura"))
					-- Trocar bloco de fundamento por madeira
					minetest.set_node(pos, {name="default:tree"})
				elseif tipo == "casa_comunal" then
					meta:set_string("status", "destruida")
				elseif tipo == "decor" then
					sunos.bd:remover("vila_"..meta:get_string("vila"), "decor_"..meta:get_string("estrutura"))
					-- Trocar bloco de fundamento por madeira
					minetest.set_node(pos, {name="default:tree"})
				end
				
				-- Atualizar banco de dados da vila
				sunos.atualizar_bd_vila(vila)
			end
		else
			minetest.set_node(pos, {name="default:tree"})
		end
	end,
})

-- Atualizar banco de dados da vila
sunos.atualizar_bd_vila = function(vila)
	if vila == nil then
		minetest.log("error", "[Sunos] Variavel vila nula (em sunos.atualizar_bd_vila)")
		return false
	end
	
	-- População total
	local pop_total = 0
	
	-- Verificar população
	local list = minetest.get_dir_list(minetest.get_worldpath().."/sunos/vila_"..vila)
	if list == nil then
		minetest.log("error", "[Sunos] Banco de dados da vila inexistente (em sunos.atualizar_bd_vila)")
		return false
	end
	
	local casas = {}
	for _,arq in ipairs(list) do
		local v = string.split(arq, "_")
		if v[1] == "casa" and tonumber(v[2]) then
			local reg = sunos.bd:pegar("vila_"..vila, arq)
			pop_total = pop_total + reg.pop
		end
	end
	
	-- Verifica a população de todas as casas
	for casa,pop in pairs(casas) do
		
	end
	
	-- Salva a população atual
	sunos.bd:salvar("vila_"..vila, "pop", pop_total)
	
	-- Remove banco de dados da vila caso esteja deserta e sem casa comunal
	if pop_total == 0 and sunos.bd:verif("vila_"..vila, "casa_comunal") == false then
		
		sunos.bd:drop_tb("vila_"..vila)
	end
	
	return true
end


