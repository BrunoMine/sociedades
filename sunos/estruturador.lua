--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Montagem de estruturas
  ]]

-- Caminho do diretório do mod
local modpath = minetest.get_modpath("sunos")

-- Montar uma estrutura
sunos.montar_estrutura = function(cpos, dist, tipo)
	if cpos == nil then
		minetest.log("error", "[Sunos] Tabela cpos nula (em sunos.montar_estrutura)")
		return false
	end
	if tipo == nil then
		minetest.log("error", "[Sunos] Tipo de estrutura nula (em sunos.montar_estrutura)")
		return nil
	end
	
	-- Pegando dados do local
	local pos = {x=cpos.x-dist, y=cpos.y, z=cpos.z-dist}
	
	-- Largura
	local largura = 2*dist+1
	
	-- Caminho do arquivo da estrutura
	local arquivo = modpath.."/estruturas/"..tipo.."/"..sunos.pegar_arquivo(largura, tipo).."."..largura..".mts"
	
	-- Criar estrutura
	minetest.place_schematic(pos, arquivo, nil, nil, true)
	
	return true
end
