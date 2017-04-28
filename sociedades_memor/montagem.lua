--[[
	Mod Memor para Minetest
	Memor v1.2 Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Montagem de bando de dados
  ]]


-- Montar banco de dados em um mod
function memor.montar_bd(mod)
	v = {}
	v.mod = mod or minetest.get_current_modname()
	
	-- Inserir dados
	v.salvar = function(v, tb, index, valor)
		return memor.inserir(v.mod, tb, index, valor)
	end
	
	-- Consultar dados
	v.pegar = function(v, tb, index)
		return memor.consultar(v.mod, tb, index)
	end
	
	-- Verificar dados
	v.verif = function(v, tb, index)
		return memor.verificar(v.mod, tb, index)
	end
	
	-- Remover dados
	v.remover = function(v, tb, index)
		return memor.deletar(v.mod, tb, index)
	end
	
	-- Remover tabela
	v.drop_tb = function(v, tb)
		return memor.deletar_dir(v.mod, tb)
	end
	
	-- Listar dados
	v.listar = function(v, tb)
		return memor.listar(v.mod, tb)
	end
	
	return v
end
