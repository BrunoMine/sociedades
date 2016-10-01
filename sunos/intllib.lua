--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Internacionalização de strings de texto exibido
	
	O arquivo template.txt deve conter as strings originais do código 
	para serem traduzidas. Evitar o uso de acentos e caracteres especiais.
  ]]

-- Clichê para apoiar cadeias localizadas se mod intllib está instalado.
local S
if minetest.get_modpath("intllib") then
    S = intllib.Getter()
else
    S = function(s,a,...)if a==nil then return s end a={a,...}return s:gsub("(@?)@(%(?)(%d+)(%)?)",function(e,o,n,c)if e==""then return a[tonumber(n)]..(o==""and c or"")else return"@"..o..n..c end end) end
end

-- Variavel global do sunos
sunos.S = S

