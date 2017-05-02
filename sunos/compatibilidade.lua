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
	if not versao or versao == "" then return false end
	if versao == sunos.versao then return true end
	if sunos.versao_comp[versao] then return true end
	return false
end 

-- Remover nodes incompativeis

-- LBM para remover fundamentos incompativeis a 1.4
minetest.register_lbm({
	name = "sunos:update_1dot4",
	nodenames = {"sunos:fundamento"},
	action = function(pos, node)
		local v = minetest.get_meta(pos):get_string("versao")
		if sunos.verif_comp(v) == false then
			-- Pega distancia do centro a borda
			local dist = minetest.get_meta(pos):get_string("dist")
			if dist == "" then dist = 1 end
			-- Remover fundamento
			minetest.set_node(pos, {name="default:tree"})
		end
	end,
})

-- LBM para remover nodes obsoletos anteriores a 1.4
minetest.register_lbm({
	name = "sunos:remove_oldnodes_1dot4",
	nodenames = {"sunos:bau", "sunos:bau_casa_comunal", "sunos:bau_loja"},
	action = function(pos, node)
		minetest.remove_node(pos)
	end,
})

