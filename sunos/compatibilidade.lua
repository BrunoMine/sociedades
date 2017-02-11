--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Métodos para atualizar mundos tornandos compativeis 
	com as novas versões do projeto quando atualizada
  ]]

-- Verifica se a versao informada é compativel com a versao atual
sunos.verif_comp = function(versao)
	for _,v in ipairs(sunos.versao_comp) do
		if versao == v then return true end
	end 
	return false
end 

-- Remover nodes incompativeis

-- LBM para remover fundamentos incompativeis a 1.4
minetest.register_lbm({
	name = "sunos:update_1dot4",
	nodenames = {"sunos:fundamento"},
	action = function(pos, node)
		local v = minetest.get_meta(pos):get_string("versao")
		if v == "" or sunos.verif_comp(v) ~= true then
			-- Pega distancia do centro a borda
			local dist = minetest.get_meta(pos):get_string("dist")
			if dist == "" then dist = 1 end
			-- Monta uma ruina no local
			sunos.montar_estrutura(pos, tonumber(dist), "ruina")
		end
	end,
})

