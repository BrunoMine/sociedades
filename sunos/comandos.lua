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
				
				-- Serializando a estrutura
				
				local player = minetest.get_player_by_name(name)
				local pos = player:getpos()

				local largura = param3
				local altura = 15
				
				-- Criar estrutura
				local estrutura = {}
				local ix, iy, iz = 1, 1, 1
				local x, y, z = pos.x, pos.y, pos.z
				local limx, limy, limz = (pos.x+largura-1), (pos.y+altura-1), (pos.z+largura-1)
				local i = 0
				while (x <= limx) do
					while (y <= limy) do
						while (z <= limz) do
							estrutura[ix.." "..iy.." "..iz] = minetest.get_node({x = x, y = y, z = z})
							i = i + 1
							z = z + 1
							iz = iz + 1
						end
						z = pos.z
						iz = 1
						y = y + 1
						iy = iy + 1
					end
					y = pos.y
					iy = 1
					x = x + 1
					ix = ix + 1
				end

				-- Criar arquivo
				local output = io.open(modpath .. "/estruturas/"..param2.."."..largura, "w")
				output:write(minetest.serialize(estrutura))
				io.close(output)

				-- Estrutura serializada com sucesso
				minetest.chat_send_all("Serializacao concluida.")
				
				
			end
		else
			return false
		end
	end
})
