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
	params = "<funcao> [Salvar estrutura | s <tipo> <nome> <largura>] ",
	description = "Opera algumas funcionalidades",
	func = function(name,  param)		
		local m = string.split(param, " ")
		local param1, param2, param3, param4 = m[1], m[2], m[3], m[4]
		if param1 == "s" and tonumber(param4) then
			param4 = tonumber(param4)
			if param4 == 3 or param4 == 5 or param4 == 7 or param4 == 9 or param4 == 11 then
				
				-- Pegando dados do local
				local player = minetest.get_player_by_name(name)
				local pos = player:getpos()
				
				-- Dimensões da estrutura
				local largura = param4
				local altura = 15
				
				-- Coordenadas dos extremos
				local p1 = pos
				local p2 = {x=pos.x+largura, y=pos.y+15, z=pos.z+largura}
				
				-- Serializando a estrutura
				minetest.create_schematic(p1, p2, {}, modpath .. "/estruturas/"..param2.."/"..param3.."."..largura..".mts")

				-- Estrutura serializada com sucesso
				minetest.chat_send_all("Salvamento concluida.")
				minetest.chat_send_all("Nome: "..param3)
				minetest.chat_send_all("Largura: "..param4)
				minetest.chat_send_all("Tipo: "..param2)
				
				
			end
		else
			minetest.chat_send_all("Falha ao salvar estrutura.")
			return false
		end
	end
})

