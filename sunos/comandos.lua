--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Comandos
  ]]

-- Diretorio do Mod
local modpath = minetest.get_modpath("sunos")

-- Comando de serializar estrutura
minetest.register_chatcommand("sunos", {
	privs = {server=true},
	params = "<funcao> [Salvar estrutura | s <nome> <largura>] ",
	description = "Opera algumas funcionalidades",
	func = function(name,  param)		
		local m = string.split(param, " ")
		local param1, param2, param3 = m[1], m[2], m[3]
		if param1 == "s" and tonumber(param3) then
			param3 = tonumber(param3)
			if param3 == 3 or param3 == 5 or param3 == 7 or param3 == 9 or param3 == 11 then
				
				-- Pegando dados do local
				local player = minetest.get_player_by_name(name)
				local pos = player:getpos()
				
				-- Dimensões da estrutura
				local largura = param3
				local altura = 15
				
				-- Coordenadas dos extremos
				local p1 = pos
				local p2 = {x=pos.x+largura, y=pos.y+15, z=pos.z+largura}
				
				-- Serializando a estrutura
				minetest.create_schematic(p1, p2, {}, modpath .. "/estruturas/"..param2.."."..largura..".mts")

				-- Estrutura serializada com sucesso
				minetest.chat_send_all("Serializacao concluida.")
				
				
			end
		else
			return false
		end
	end
})

