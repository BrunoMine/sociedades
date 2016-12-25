--[[
	Mod Memor para Minetest
	Memor v1.2 Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Operadores de arquivamento e leitura
  ]]


-- Diretorio do mundo
local wpath = minetest.get_worldpath()

-- Cria um diretório na pasta do mundo
function memor.mkdir(dir, sub)
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
function memor.escrever(mod, dir, arquivo, dados)
	if mod == nil or dir == nil or arquivo == nil or dados == nil then 
		minetest.log("error", "[Memor] Faltou dados (em memor.escrever)")
		return false 
	end
	
	local dados = minetest.serialize(dados)
	if dados == "" then
		minetest.log("error", "[Memor] Dado fornecido invalido (em memor.escrever)")
		return false
	end
	
	local saida = io.open(wpath .. "/" .. mod .. "/" .. dir .. "/" .. arquivo, "w")
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
function memor.ler(mod, dir, arquivo) 
	if mod == nil or dir == nil or arquivo == nil then 
		minetest.log("error", "[Memor] Faltou dados (em memor.ler)") 
		return nil
	end
	
	local entrada = io.open(wpath .. "/" .. mod .. "/" .. dir .. "/" .. arquivo, "r")
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
function memor.deletar(mod, dir, arquivo)
	if not mod or not dir or not arquivo then 
		minetest.log("error", "[Memor] Faltou dados (em memor.deletar)")
		return false 
	end
	
	os.remove(wpath .. "/" .. mod .. "/" .. dir .. "/" .. arquivo)
	return true
end


-- Deletar um diretório
function memor.deletar_dir(mod, dir)
	if not mod or not dir then 
		minetest.log("error", "[Memor] Faltou dados (em memor.deletar_dir)")
		return false 
	end
	
	local list = minetest.get_dir_list(wpath .. "/" .. mod .. "/" .. dir)
	
	for n, arquivo in ipairs(list) do
		os.remove(wpath .. "/" .. mod .. "/" .. dir .. "/" .. arquivo)
	end
	
	os.remove(wpath .. "/" .. mod .. "/" .. dir)
	return true
end
