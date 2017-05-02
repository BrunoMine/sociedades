--[[
	Mod Sovagxas para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Métodos para atualizar mundos tornandos compativeis 
	com as novas versões do projeto quando atualizada
  ]]

-- Verifica se a versao informada é compativel com a versao atual
sovagxas.verif_comp = function(versao)
	if not versao or versao == "" then return false end
	if versao == sovagxas.versao then return true end
	if sovagxas.versao_comp[versao] then return true end
	return false
end
