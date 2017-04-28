--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Internacionalização de strings de texto exibido
	
	O arquivo template.txt deve conter as strings originais do código 
	para serem traduzidas. Evitar o uso de acentos e caracteres especiais.
  ]]

-- Carregar suporte de tradução intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/lib/intllib.lua")

-- Variavel global do sunos
sunos.S = S

