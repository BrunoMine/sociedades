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
		
		if tipo == "casa" or tipo == "casa_comunal" or tipo == "decor" then
			
			if sunos.verificar_blocos_estruturais(pos) == false -- Verificar Estrutura danificada
				-- or sunos.verificar_estrutura(pos, tonumber(meta:get_string("dist"))) == false -- [CANCELADO]
			then
				
				-- Tornar estrutura em ruinas
				-- Pega todas elementos pedrosos
				local nodes = minetest.find_nodes_in_area(
					{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
					{x=pos.x+dist, y=pos.y+15, z=pos.z+dist}, 
					{"group:stone", "group:cobble"}
				)
				-- Limpa toda a area
				for x=pos.x-dist, pos.x+dist do
					for z=pos.z-dist, pos.z+dist do
						for y=pos.y, pos.y+14 do
							minetest.remove_node({x=x,y=y,z=z})
						end
					end
				end
				-- Recoloca pedregulho no lugar de elementos pedrosos
				for _,p in ipairs(nodes) do
					minetest.set_node(p, {name="default:cobble"})
				end
				
				
				
				
				-- Remover do bando de dados
				if tipo == "casa" then
					sunos.bd:remover("vila_"..meta:get_string("vila"), "casa_"..meta:get_string("estrutura"))
				elseif tipo == "casa_comunal" then
					sunos.bd:remover("vila_"..meta:get_string("vila"), "casa_comunal")
				elseif tipo == "decor" then
					sunos.bd:remover("vila_"..meta:get_string("vila"), "decor_"..meta:get_string("estrutura"))
				end
				
				-- Trocar bloco de fundamento por madeira
				minetest.set_node(pos, {name="default:tree"})
				
				-- Atualizar banco de dados da vila
				sunos.atualizar_bd_vila(vila)
			end
		else
			minetest.set_nodes(pos, {name="default:tree"})
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
		minetest.log("error", "[Sunos] Banco de dados da vila inesistente (em sunos.atualizar_bd_vila)")
		return false
	end
	
	local casas = {}
	for _,arq in ipairs(list) do
		local v = string.split(arq, "_")
		if v[1] == "casa" then casas[arq] = 1 end
	end
	
	for casa,pop in pairs(casas) do
		local reg = sunos.bd:pegar("vila_"..vila, casa)
		pop_total = pop_total + reg.pop
	end
	
	-- Salva a população atual
	sunos.bd:salvar("vila_"..vila, "pop", pop_total)
	
	return true
end


