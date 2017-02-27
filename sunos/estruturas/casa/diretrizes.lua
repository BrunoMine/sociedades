--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Diretrizes das casas
  ]]

-- Tabela de variaveis da estrutura personalizadas
sunos.estruturas.casa.var = {}

-- Nodes estruturais
sunos.estruturas.casa.var.nodes_estruturais = {
	-- Palha
	"farming:straw", 
	"stairs:stair_straw", 
	"stairs:slab_straw", 
	-- Madeiras
	"default:wood", 
	"default:fence_wood", 
	"stairs:stair_wood",
	-- Pedrosos
	"default:cobble", 
	"stairs:stair_cobble",
	"walls:cobble",
	"default:stonebrick",
	"default:furnace",
	"default:furnace_active",
	-- Moveis domesticos
	"vessels:shelf",
	"default:bookshelf",
	"sunos:bancada_nodrop",
	"sunos:bancada_de_trabalho_nodrop",
	-- Vidro
	"xpanes:pane",
	"xpanes:pane_flat",
	-- Portas
	"doors:door_wood_a",
	"doors:door_wood_b",
	-- Iluminação
	"default:torch",
	"default:torch_wall",
	"default:torch_ceiling"
}

-- Nodes decorativos simples
sunos.estruturas.casa.var.decor_simples = {
	"flowers:rose",
	"flowers:tulip",
	"flowers:geranium",
	"flowers:mushroom_brown",
	"vessels:glass_bottle",
	"vessels:drinking_glass"
}

-- Tabela de população por tamanho de casa
sunos.estruturas.casa.var.tb_pop_casa = {
	-- Largura da casa	População
	["5"] = 		2,
	["7"] =			3,
	["9"] =			4,
	["11"] =		6,
}

-- Itens que aparecem nas estantes de livros
sunos.estruturas.casa.var.estante_livros = {
	"default:book",
}


-- Itens que aparecem nas estantes de frascos
sunos.estruturas.casa.var.estante_frascos = {
	"vessels:glass_bottle"
}
