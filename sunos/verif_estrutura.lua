--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Métodos para verificação de estruturas
  ]]

-- Contabilizar blocos estruturais
--[[
	Contabiliza quantos blocos estruturais tem na estrutura
	do fundamento da pos informada
	Retorno:
		Nenhum
	Argumentos:
		<pos> é a coordenada do fundamento da estrutura
  ]]
sunos.contabilizar_blocos_estruturais = function(pos)
	if pos == nil then
		minetest.log("error", "[Sunos] Tabela pos nula (em sunos.contabilizar_blocos_estruturais)")
		return false
	end
	
	local meta = minetest.get_meta(pos)
	local dist = tonumber(meta:get_string("dist"))
	
	local nodes = minetest.find_nodes_in_area(
		{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
		{x=pos.x+dist, y=pos.y+15, z=pos.z+dist}, 
		sunos.var.nodes_estruturais
	)
	
	meta:set_string("nodes", table.maxn(nodes))
end

-- Verifica quantidade de blocos estruturais
--[[
	Verifica quantos blocos estruturais tem na estrutura
	do fundamento da pos informada e compara com a quatidade
	armazenada para verificar obstrução
	Retorno:
		numero de nodes encontrados
	Argumentos:
		<pos> é a coordenada do fundamento da estrutura
  ]]
sunos.verificar_blocos_estruturais = function(pos)
	if pos == nil then
		minetest.log("error", "[Sunos] Tabela pos nula (em sunos.verificar_blocos_estruturais)")
		return false
	end
	
	-- Acessar metadados do fundamento
	local meta = minetest.get_meta(pos)
	
	-- Pegar distancia centro a borda da estrutura
	local dist = meta:get_string("dist")
	
	-- Pegar numero de nodes estruturais que a estrutura deve ter
	local nodes_reg = tonumber(meta:get_string("nodes"))
	
	-- Pega todos os nodes estruturais presentes na estrutura atual
	local nodes = minetest.find_nodes_in_area(
		{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
		{x=pos.x+dist, y=pos.y+14, z=pos.z+dist}, 
		sunos.var.nodes_estruturais
	)
	
	return table.maxn(nodes)
end
