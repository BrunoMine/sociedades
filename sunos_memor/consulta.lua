--[[
	Mod Memor para Minetest
	Memor v1.2 Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Operadores de consulta
  ]]

-- Diretório do Mundo
local wpath = minetest.get_worldpath()

-- Verifica diretorios e corrige
verificar = function(dir, subdir)
	
	-- Verifica e corrige diretorio
	local list = minetest.get_dir_list(minetest.get_worldpath(), true)
	local r = false
	for n, ndir in ipairs(list) do
		if ndir == dir then
			r = true
			break
		end
	end
	-- Diretorio inexistente
	if r == false then
		memor.mkdir(dir)
	end
	
	-- Verifica e corrige subdiretorio
	list = minetest.get_dir_list(minetest.get_worldpath().."/"..dir, true)
	r = false
	for n, ndir in ipairs(list) do
		if ndir == subdir then
			r = true
			break
		end
	end
	-- Subdiretorio inexistente
	if r == false then
		memor.mkdir(dir.."/"..subdir)
	end
	
end


-- Inserir dados
memor.inserir = function(mod, tb, index, valor)

	-- Tenta inserir direto
	if memor.escrever(mod, tb, index, valor) == true then return true end
	
	verificar(mod, tb)
	
	if memor.escrever(mod, tb, index, valor) then 
		return true 
	else
		minetest.log("error", "[Memor] Impossivel salvar dados (em memor.inserir)")
		return false
	end
	
end


-- Ler dados
memor.consultar = function(mod, tb, index)
	
	local r = memor.ler(mod, tb, index)
	if r == nil then 
		minetest.log("error", "[Memor] Registro acessado inexistente ("..dump(mod).."/"..dump(tb).."/"..dump(index)..") (em memor.consultar)")
	end
	
	return r
	
end


-- Verificar dados
memor.verificar = function(dir, subdir, arquivo)

	list = minetest.get_dir_list(wpath .. "/" .. dir .. "/" .. subdir)
	r = false
	for n, arq in ipairs(list) do
		if arq == arquivo then
			r = true
			break
		end
	end
	
	if r then
		return true
	else 
		return false
	end
end

-- Listar
memor.listar = function(dir, subdir)
        if dir == nil then 
                minetest.log("error", "[Memor] Diretorio inexistente (em memor.listar)")
                return false
        end
        
        if subdir then
        
                local list = minetest.get_dir_list(wpath .. "/" .. dir .. "/" .. subdir)
                
                if list == nil then
                        minetest.log("error", "[Memor] Impossivel listar diretorio (em memor.listar)")
                        return false
                else
                        return list
                end
	
	else
	        local list = minetest.get_dir_list(wpath .. "/" .. dir)
                
                if list == nil then
                        minetest.log("error", "[Memor] Impossivel listar diretorio (em memor.listar)")
                        return false
                else
                        return list
                end
	end
end


