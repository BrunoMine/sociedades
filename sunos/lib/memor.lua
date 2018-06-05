--[[
	Lib Memor para Minetest
	Memor v2.0.0 Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Autoria do código:
	Originalmente por BrunoMine, Bruno Borges <borgesdossantosbruno@gmail.com>
  ]]
  
local modname = minetest.get_current_modname()

local modpath = minetest.get_modpath(modname)

-- Variavel global
memor = {}

-- Rotinas de interação com arquivos

-- Diretorio do mundo
local wpath = minetest.get_worldpath()

-- Cria um diretório na pasta do mundo
function memor.mkdir(dir)
	if not dir then
		minetest.log("error", "[Memor] Nenhum diretorio especificado (em memor.mkdir)")
		return false
	end
	
	dir = wpath.."/"..dir
	
	if minetest.mkdir then
		minetest.mkdir(dir)
	else
		os.execute('mkdir "' .. dir .. '"')
	end
	return true
end

-- Criar um arquivo com os dados serializados (Salvar)
function memor.escrever(dir, arquivo, dados)
	
	if dir == nil or arquivo == nil or dados == nil then 
		minetest.log("error", "[Memor] Faltou dados (em memor.escrever)")
		return false 
	end
	
	local dados = minetest.serialize(dados)
	if dados == "" then
		minetest.log("error", "[Memor] Dado fornecido invalido (em memor.escrever)")
		return false
	end
	
	local saida = io.open(wpath .. "/" .. modname .. "/" .. dir .. "/" .. arquivo, "w")
	if saida then
		saida:write(dados)
		io.close(saida)
		return true
	else
		minetest.log("info", "[Memor] memor.escrever tentou escrever num diretorio inexistente")
		return false
	end
end

-- Ler dados de um arquivo de memória (Carregar)
function memor.ler(dir, arquivo) 
	
	if dir == nil or arquivo == nil then 
		minetest.log("error", "[Memor] Faltou dados (em memor.ler)") 
		return nil
	end
	
	local entrada = io.open(wpath .. "/" .. modname .. "/" .. dir .. "/" .. arquivo, "r")
	if entrada then
		local dados = entrada:read("*l")
		if dados ~= "" or dados ~= nil then
			dados = minetest.deserialize(dados)
		end
		io.close(entrada)
		return dados
	else
		minetest.log("error", "[Memor] pasta e/ou arquivo inexiste(s) (em memor.ler)")
		return nil
	end
end

-- Deletar um arquivo
function memor.deletar(dir, arquivo)	
	
	if not dir or not arquivo then 
		minetest.log("error", "[Memor] Faltou dados (em memor.deletar)")
		return false 
	end
	
	os.remove(wpath .. "/" .. modname .. "/" .. dir .. "/" .. arquivo)
	return true
end


-- Deletar um diretório
function memor.deletar_dir(dir)	
	
	if not dir then 
		minetest.log("error", "[Memor] Faltou dados (em memor.deletar_dir)")
		return false 
	end
	
	local list = minetest.get_dir_list(wpath .. "/" .. modname .. "/" .. dir)
	
	for n, arquivo in ipairs(list) do
		os.remove(wpath .. "/" .. modname .. "/" .. dir .. "/" .. arquivo)
	end
	
	os.remove(wpath .. "/" .. modname .. "/" .. dir)
	return true
end

-- Fim

-- Rotinas de consutas a arquivos

-- Verifica diretorios e corrige
verificar = function(subdir)
	
	local dir = modname
	
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
memor.inserir = function(tb, index, valor)
	
	-- Tenta inserir direto
	if memor.escrever(tb, index, valor) == true then return true end
	
	verificar(tb)
	
	if memor.escrever(tb, index, valor) then 
		return true 
	else
		minetest.log("error", "[Memor] Impossivel salvar dados (em memor.inserir)")
		return false
	end
	
end


-- Ler dados
memor.consultar = function(tb, index)
	
	local r = memor.ler(tb, index)
	if r == nil then 
		local mod = modname
		minetest.log("error", "[Memor] Registro acessado inexistente ("..dump(mod).."/"..dump(tb).."/"..dump(index)..") (em memor.consultar)")
	end
	
	return r
	
end


-- Verificar dados
memor.verificar = function(subdir, arquivo)
	
	local dir = modname
	
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
memor.listar = function(subdir)

	local dir = modname
        
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

-- Fim

-- Montagem de banco de dados

bd = {}

-- Inserir dados
bd.salvar = function(tb, index, valor)
	return memor.inserir(tb, index, valor)
end

-- Consultar dados
bd.pegar = function(tb, index)
	return memor.consultar(tb, index)
end

-- Verificar dados
bd.verif = function(tb, index)
	return memor.verificar(tb, index)
end

-- Remover dados
bd.remover = function(tb, index)
	return memor.deletar(tb, index)
end

-- Remover tabela
bd.drop_tb = function(tb)
	return memor.deletar_dir(tb)
end

-- Listar dados
bd.listar = function(tb)
	return memor.listar(tb)
end

return bd
	
-- Fim
