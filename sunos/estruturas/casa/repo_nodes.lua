--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Casa dos sunos
  ]]


-- Itens simples decorativos para casas
local decor_simples = {
	"flowers:rose",
	"flowers:tulip",
	"flowers:dandelion_yellow",
	"flowers:geranium",
	"flowers:viola",
	"flowers:dandelion_white",
	"flowers:mushroom_brown",
	"vessels:glass_bottle",
	"vessels:drinking_glass"
}

-- Funções para geração de tabelas de itens de reposição
sunos.estruturas.casa.gerar_itens_repo = {}
-- Gerar itens de reposição para casa mediana
sunos.estruturas.casa.gerar_itens_repo["2"] = function()
	return {
		bancadas = {
			{"sunos:bau_casa", 1},
			{"sunos:bancada_de_trabalho", 1, true},
		},
		simples = {
			{decor_simples[math.random(1, table.maxn(decor_simples))], 1},
			{decor_simples[math.random(1, table.maxn(decor_simples))], 1}
		},
	}
end
-- Gerar itens de reposição para casa mediana
sunos.estruturas.casa.gerar_itens_repo["3"] = function()
	return {
		bancadas = {
			{"sunos:bau_casa", 1},
			{"sunos:bancada_de_trabalho", 1, true},
		},
		simples = {
			{decor_simples[math.random(1, table.maxn(decor_simples))], math.random(1, 2)},
			{decor_simples[math.random(1, table.maxn(decor_simples))], math.random(1, 2)}
		},
	}
end
-- Gerar itens de reposição para casa grande
sunos.estruturas.casa.gerar_itens_repo["4"] = function()
	return {
		bancadas = {
			{"sunos:bau_casa", 1},
			{"sunos:bancada_de_trabalho", 1, true},
		},
		simples = {
			{decor_simples[math.random(1, table.maxn(decor_simples))], math.random(1, 2)},
			{decor_simples[math.random(1, table.maxn(decor_simples))], math.random(1, 2)},
			{decor_simples[math.random(1, table.maxn(decor_simples))], math.random(1, 2)},
			{decor_simples[math.random(1, table.maxn(decor_simples))], math.random(1, 2)}
		},
	}
end


