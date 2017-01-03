--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Algoritimos de formação de estruturas
  ]]

-- Tabela de metodos
sunos.estrutural = {}

-- Preenche uma area com um node
sunos.estrutural.preencher = function(minp, maxp, node)
	if minp == nil then
		minetest.log("error", "[Sunos] minp nulo (em sunos.estrutural.preencher)")
		return false
	end
	if maxp == nil then
		minetest.log("error", "[Sunos] maxp nulo (em sunos.estrutural.preencher)")
		return false
	end
	if node == nil then
		minetest.log("error", "[Sunos] node nulo (em sunos.estrutural.preencher)")
		return false
	end
	
	for x = minp.x, maxp.x, 1 do
		for y = minp.y, maxp.y, 1 do
			for z = minp.z, maxp.z, 1 do
				minetest.set_node({x=x,y=y,z=z}, {name=node})
			end 
		end 
	end 
	
	-- Retorna sem erros
	return true
end



