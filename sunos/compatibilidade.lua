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
	
	if versao == sunos.versao 
		or sunos.versao_comp[versao]
	then 
		return true 
	end
	
	return false
end 

-- Remover nodes incompativeis

-- LBM para atualizar fundamentos
minetest.register_lbm({
	name = "sunos:update_fundamentos",
	nodenames = {"sunos:fundamento"},
	action = function(pos, node)
		-- Pega a versão armazenada
		local v = minetest.get_meta(pos):get_string("versao")
		
		-- Verifica se é compativel
		if sunos.verif_comp(v) == false then
			-- Pega distancia do centro a borda
			local dist = minetest.get_meta(pos):get_string("dist")
			if dist == "" then dist = 1 end
			-- Remover fundamento
			minetest.set_node(pos, {name="default:tree"})
		end
		
		-- Realiza procedimentos de atualização para compativeis
		
		-- Reconstroi estrutura da versão 2.0
		if v == "2.0" then
			local meta = minetest.get_meta(pos)
			
			-- Coleta dados da estrutura
			local vila = meta:get_string("vila")
			local dist = meta:get_string("dist")
			local tipo = meta:get_string("tipo")
			
			-- Verifica se vila existe
			if sunos.verificar_vila_existente(vila) == false then
				-- Remover fundamento
				minetest.set_node(pos, {name="default:tree"})
				sunos.montar_ruinas(pos, dist)
				return
			end
			
			-- Reconstroi casa
			if tipo == "casa" then
				local itens_repo = sunos.estruturas.casa.gerar_itens_repo[dist]()
				sunos.estruturas.casa.construir(pos, dist, vila, false, itens_repo, false, true)
				
			-- Destroi outras estruturas
			else
				-- Remover fundamento
				minetest.set_node(pos, {name="default:tree"})
				sunos.montar_ruinas(pos, dist)
			end
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

