--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Métodos para verificação de defesa de uma estrutura
	
  ]]

-- Função para redirecionamento
sunos.verificar_defesa = function(pos)
	if not pos then return end
	
	-- Verificar tipo de estrutura
	local tipo = minetest.get_meta(p):get_string("tipo")
	if tipo == "" then return end
	
	-- Verifica se existe um método para a verificação ja registrado
	if not sunos.estruturas[tipo] -- Estrutura não registrada?
		or not sunos.estruturas[tipo].defendido -- Não tem metodo para verificar se esta defendido?
		or sunos.estruturas[tipo].defendido(pos) ~= true -- Não está defendido?
	then 
		-- Desprotegido
		return false 
	else
		-- Protegido
		return true
	end
	
end
