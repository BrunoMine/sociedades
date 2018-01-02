--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Montagem de estruturas
  ]]

-- Caminho do diretório do mod
local modpath = minetest.get_modpath("sunos")

-- Montar uma estrutura
sunos.montar_estrutura = function(cpos, dist, tipo, rotat, schem)
	sunos.checkvar(cpos, "Coordenada central nula ao montar estrutura")
	sunos.checkvar(dist, "Nenhuma distancia centro-borda fornecida ao montar estrutura")
	sunos.checkvar(tipo, "Nenhum tipo fornecido ao montar estrutura")
	
	-- Pegando dados do local
	local pos = {x=cpos.x-dist, y=cpos.y, z=cpos.z-dist}
	
	-- Largura
	local largura = 2*dist+1
	
	-- Nome do arquivo esquematico da estrutura
	schem = schem or sunos.pegar_arquivo(largura, tipo).."."..largura..".mts"
	
	-- Caminho do arquivo da estrutura
	local caminho_arquivo = modpath.."/schems/"..tipo.."/"..schem
	
	-- Criar estrutura
	minetest.place_schematic(pos, caminho_arquivo, rotat, sunos.var.nodes_trocados, true)
	
	return true, schem
end

-- Verificar estagio
sunos.verif_estrutura_step = function(pos)
	local meta = minetest.get_meta(pos)
	local tipo = meta:get_string("tipo")
	local schem = meta:get_string("schem")
	local step = tonumber(meta:get_string("step"))
	
	-- Verifica se terminou
	if step == 5 then
	
	--
	else
		
	end
	
end
