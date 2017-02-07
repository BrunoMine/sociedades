--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Métodos para controle de inimigos
  ]]

-- Tabela de inimigos de vilas
local inimigos = {}

-- Remover um inimigo da lista de inimigos de uma vila
local remover_inimigo = function(vila, name)
	
	-- Verifica se ainda existe a tabela
	if not inimigos[vila] then return end 
	
	-- Remove o nome da listagem
	inimigos[vila][name] = nil
	
	-- verifica se tem algum outro nome na lista para destrui-la
	for i,v in pairs(inimigos[vila]) do
		-- Achou então encerra por aqui		
		return
	end
	
	-- Se chegar até aqui, elimina a tabela
	inimigos[vila] = nil
	
end

-- Armazenar novo inimigo de uma vila
sunos.novo_inimigo = function(vila, name)
	if not vila or not name then return end
	
	-- Verifica se a vila está na tabela
	if not inimigos[tostring(vila)] then inimigos[tostring(vila)] = {} end
	
	-- Armazena nome do inimigo
	inimigos[tostring(vila)][tostring(name)] = true
	
	-- Remove o nome da lista após um tempo
	minetest.after(60, remover_inimigo, tostring(vila), tostring(name))
	
end

-- Verificar se um jogador é um inimigo de uma vila
sunos.verif_inimigo = function(vila, name)
	if not vila or not name then return end
	
	if not inimigos[tostring(vila)] or not inimigos[tostring(vila)][tostring(name)] then return true end
	
end

