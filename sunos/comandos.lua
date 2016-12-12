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
	params = sunos.S("<s ou c> <tipo> <nome> <largura> | Salvar(s) ou carrega(c) estrutura"),
	description = sunos.S("Opera algumas funcionalidades do mod sunos"),
	func = function(name,  param)		
		local m = string.split(param, " ")
		local param1, param2, param3, param4 = m[1], m[2], m[3], m[4]
		if (param1 == "s" or param1 == "c") and tonumber(param4) then
			param4 = tonumber(param4)
			if param4 == 3 or param4 == 5 or param4 == 7 or param4 == 9 or param4 == 11 or param4 == 13 then
				
				-- Pegando dados do local
				local player = minetest.get_player_by_name(name)
				local pos = player:getpos()
				
				-- Dimensões da estrutura
				local largura = param4
				local altura = 15
				
				-- Coordenadas dos extremos
				local p1 = pos
				local p2 = {x=pos.x+largura-1, y=pos.y+15, z=pos.z+largura-1}
				local arquivo = modpath .. "/estruturas/"..param2.."/"..param3.."."..largura..".mts"
				
				if param1 == "s" then
					-- Serializando a estrutura
					minetest.create_schematic(p1, p2, {}, arquivo)

					-- Estrutura serializada com sucesso
					minetest.chat_send_player(name, sunos.S("Salvamento concluido"))
					minetest.chat_send_player(name, sunos.S("Arquivo: @1", param3))
					minetest.chat_send_player(name, sunos.S("Largura: @1", param4))
					minetest.chat_send_player(name, sunos.S("Tipo: @1", param2))
				else
					-- Cria a estrutura
					minetest.place_schematic(pos, arquivo, nil, nil, true)
					minetest.chat_send_player(name, sunos.S("Estrutura montada"))
					
				end
				return true
			else
				minetest.chat_send_player(name, sunos.S("Largura invalida"))
				return false
			end
		else
			minetest.chat_send_player(name, sunos.S("Comando invalido"))
			return false
		end
	end
})

