--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	taverna dos sunos
  ]]

-- Tradução de strings
local S = sunos.S

-- Tabela global de taverna
sunos.estruturas.taverna = {}

-- Caminho do diretório do mod
local modpath = minetest.get_modpath("sunos")

-- Diretrizes (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/taverna/diretrizes.lua") 

-- Placa de taverna (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/taverna/placa.lua") 

-- Barril de taverna (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/taverna/barril.lua") 

-- Nectar de frutas (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/taverna/nectar.lua") 

-- Petisco de frutas (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/taverna/petisco.lua") 

-- bau (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/taverna/bau.lua") 

-- npc (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/taverna/npc.lua")

-- Geradores de itens de reposição (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/taverna/repo_nodes.lua")

-- Nodes estruturais
local nodes_estruturais = {
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
	"sunos:nectar_nodrop",
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


-- Verificar nivel de acordo com a populacao
local verif_nivel = function(pop)
	if not pop then return end
	local pop = tonumber(pop)
	for n,p in ipairs(sunos.estruturas.taverna.var.niveis) do
		if n == table.maxn(sunos.estruturas.taverna.var.niveis) then
			return n
		end
		if pop >= p and pop < sunos.estruturas.taverna.var.niveis[n+1] then
			return n
		end
	end
	
	-- Caso pop nao seja menor que nenhum dos niveis (maior que todos os exigidos) retorna nivel maximo
	return table.maxn(sunos.estruturas.taverna.var.niveis)
	
end

local set_bau = function(pos, vila, dist)

	-- Verifica se tem baus na estrutura montada
	local baus = minetest.find_nodes_in_area(
		{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
		{x=pos.x+dist, y=pos.y+14, z=pos.z+dist}, 
		{"sunos:bau_taverna"}
	)
	-- Salva dados da estrutura no bau dela
	for _,pos_bau in ipairs(baus) do
		local meta = minetest.get_meta(pos_bau)
		meta:set_string("obs", "n") -- Verifica se esta obstruido
		meta:set_string("vila", vila) -- Numero da vila
		meta:set_string("pos_fundamento", minetest.serialize(pos)) -- Pos do fundamento
		meta:set_string("infotext", S("Bau de Taverna dos Sunos"))
	end
	
end


-- Tabela para valores de rotação
local tb_rotat = {"0", "90", "180", "270"}

-- Verificar se pode construir
sunos.estruturas.taverna.verif = function(pos, verif_area)

	-- Validar argumentos de entrada
	if pos == nil then
		minetest.log("error", "[Sunos] Tabela pos nula (em sunos.estruturas.taverna.construir)")
		return "Erro interno (pos nula)"
	end
	
	-- Variaveis auxiliares
	local dist = 5
	local largura = (dist*2)+1
	local vila
	
	-- Verificar se vila existe (caso especificado)
	if vila and sunos.verificar_vila_existente(vila) == false then
		return S("Vila abandonada")
		
	-- Encontrar vila ativa
	else
		vila = sunos.encontrar_vila(pos, 25)
		if not vila then
			return S("Nenhuma vila habitavel encontrada")
		end
	end
	
	-- Verificar se ja existe um taverna
	if sunos.bd.verif("vila_"..vila, "taverna") == true then
		return S("Ja existe @1 nessa vila", S("Taverna"))
	end
	
	-- Verifica se tem populacao suficiente
	if tonumber(sunos.bd.pegar("vila_"..vila, "pop_total")) < sunos.estruturas.taverna.var.niveis[1] then
		return S("A vila precisa ter ao menos @1 habitantes", sunos.estruturas.taverna.var.niveis[1])
	end
	
	-- Verificações de area
	if verif_area == true then
		local r = sunos.verificar_area_para_fundamento(pos, dist)
		if r ~= true then
			return r
		end
	end
	
	return true, vila
end


-- Construir taverna de sunos
--[[
	Essa função construi uma taverna de sunos e configura o fundamento
	Retorno:
		^ true caso ocorra tudo bem
		^ string de erro caso algo de errado
	Argumentos:
		<pos> é a coordenada do fundamento da estrutura
		<vila> OPCIONAL | é o numero da vila a qual a estrutura decorativa pertence
		<verif_area> OPCIONAL | true verificar a area antes de montar a estrutura (retorna strings dos erros)
		<itens_repo> OPCIONAL | Repassado ao comando sunos.decor_repo para substituir itens de reposição
]]
sunos.estruturas.taverna.construir = function(pos, vila, verif_area)
	
	-- Verifica se pode construir a casa
	local verif, vila = sunos.estruturas.taverna.verif(pos, verif_area)
	if verif ~= true then
		return verif
	end
	
	-- Variaveis auxiliares
	local dist = 5
	local largura = (dist*2)+1
	
	-- Escolhe uma rotação aleatória
	local rotat = tb_rotat[math.random(1, 4)]
	
	-- Pegar nivel
	local nivel = verif_nivel(sunos.bd.pegar("vila_"..vila, "pop_total"))
	
	-- Atualizar schem do nivel
	local schem = "nivel_" .. nivel
	
	-- Caminho do arquivo da estrutura
	local caminho_arquivo = modpath.."/schems/taverna/"..schem..".11.mts"
	
	-- Criar estrutura
	minetest.place_schematic({x=pos.x-dist, y=pos.y, z=pos.z-dist}, caminho_arquivo, rotat, sunos.var.nodes_trocados, true)
	
	-- Recoloca itens reais (apartir dos itens de reposição)
	sunos.decor_repo(pos, dist, sunos.estruturas.taverna.gerar_itens_repo[tostring(nivel)]())
	
	-- Configurar bau de taverna
	minetest.after(1, set_bau, {x=pos.x,y=pos.y,z=pos.z}, vila, dist)
	
	-- Criar fundamento e configurar
	minetest.set_node(pos, {name="sunos:fundamento"})
	local meta = minetest.get_meta(pos)
	meta:set_string("versao", sunos.versao) -- Salva a versão atual do projeto
	meta:set_string("schem", schem) -- Nome do arquivo da esquematico da estrutura
	meta:set_string("rotat", rotat) -- Rotação da estrutura
	meta:set_string("vila", vila) -- Numero da vila
	meta:set_string("tipo", "taverna") -- Tipo da estrutura
	meta:set_string("dist", dist) -- Distancia centro a borda da estrutura
	sunos.contabilizar_blocos_estruturais(pos, nodes_estruturais) -- Armazena quantidade de nodes estruturais
	
	
	-- Registros a serem salvos
	local registros = {
		tipo = "taverna",
		estrutura = {
			dist = dist,
			largura = largura,
			pos = pos
		}
	}
	
	-- Salva no banco de dados
	sunos.bd.salvar("vila_"..vila, "taverna", registros)
	
	-- Remover jogadores da area construida (evitar travar em paredes)
	sunos.ajustar_jogadores(pos)
	
	return true
end


-- Verificação do fundamento
sunos.estruturas.taverna.verificar = function(pos)
	local meta = minetest.get_meta(pos)
	local vila = meta:get_string("vila")
	if not vila then return end
	vila = tonumber(vila)
	local tipo = meta:get_string("tipo")
	local dist = 5
	local nd = tonumber(meta:get_string("nodes")) -- numero de nodes inicial
	
	-- Pega o numero de nodes real
	local ndrl = sunos.verificar_blocos_estruturais(pos, nodes_estruturais)
	
	-- Verifica se a taverna está muito destruida
	if ndrl < nd - 4 then
	
		-- Montar ruinas no local da antiga casa
		sunos.montar_ruinas(pos, dist)
		
		-- Exclui o arquivo da estrutura do banco de dados
		sunos.bd.remover("vila_"..meta:get_string("vila"), tipo.."_"..meta:get_string("estrutura"))
		
		-- Trocar bloco de fundamento por madeira
		minetest.set_node(pos, {name="default:tree"})
		
		-- Atualizar banco de dados da vila
		sunos.atualizar_bd_vila(vila)
	end
end

-- Fundamento de taverna
minetest.register_node("sunos:fundamento_taverna", {
	description = S("Fundamento de taverna dos Sunos"),
	tiles = {"default_tree_top.png^sunos_fundamento.png", "default_tree_top.png", "default_tree.png"},
	inventory_image = "sunos_inv_fundamento.png^sunos_fundamento_taverna_inv.png",
	wield_image = "sunos_inv_fundamento.png^sunos_fundamento_taverna_inv.png",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	stack_max = 1,
	
	-- Colocar uma taverna
	on_place = function(itemstack, placer, pointed_thing)
		
		local pos = pointed_thing.under
		
		local r, vila = sunos.estruturas.taverna.verif(pos, true)
		
		if r == true then
			
			-- Coloca rua em torno
			sunos.colocar_rua(pos, 5)
			
			-- Coloca fundamento step para construir estrutura
			minetest.set_node(pointed_thing.under, {name="sunos:fundamento_step"})
			local meta = minetest.get_meta(pos)
			meta:set_string("tipo", "taverna")
			meta:set_string("dist", 5)
			meta:set_string("versao", sunos.versao)
			meta:set_string("vila", vila)
			meta:set_string("step", 1)
			meta:set_string("data_inicio", minetest.get_day_count())
			meta:set_string("tempo_inicio", minetest.get_timeofday())
			meta:set_string("duracao", 36000) -- 1,5 dias no jogo
			meta:set_string("schem", "nivel_1")
			meta:set_string("rotat", sunos.pegar_rotat())
			minetest.get_node_timer(pos):set(0.1, 0) -- Inicia temporizador
			
			-- Retorna mensagem de montagem concluida
			minetest.chat_send_player(placer:get_player_name(), S("Taverna sendo construido"))
			itemstack:take_item()
			return itemstack
			
		else
			-- Mostra area necessaria
			sunos.criar_caixa_de_area(pos, 5+1)
			-- Retorna mensagem de falha
			minetest.chat_send_player(placer:get_player_name(), r)
			return itemstack
		end
	end,
})

-- Caminho do diretório do mod
local modpath = minetest.get_modpath("sunos")

-- Reforma as casas aleatoriamente
minetest.register_abm({
	label = "Reforma do taverna",
	nodenames = {"sunos:fundamento"},
	interval = 600,
	chance = 4,
	action = function(pos)
	
		local meta = minetest.get_meta(pos)
		local table = meta:to_table() -- salva metadados numa tabela
		local vila = meta:get_string("vila")
		if vila == "" then return end
		vila = tonumber(vila)
		local tipo = meta:get_string("tipo")
		if tipo ~= "taverna" then return end
		local dist = 5
		local schem = meta:get_string("schem")
		local rotat = meta:get_string("rotat")
		if schem == "" then return end
		
		-- Atualizar schem do nivel
		schem = "nivel_" .. verif_nivel(sunos.bd.pegar("vila_"..vila, "pop_total"))
		
		-- Caminho do arquivo da estrutura
		local caminho_arquivo = modpath.."/schems/"..tipo.."/"..schem..".11.mts"
		
		-- Criar estrutura
		minetest.place_schematic({x=pos.x-dist, y=pos.y, z=pos.z-dist}, caminho_arquivo, rotat, sunos.var.nodes_trocados, true)
		
		table.schem = schem
		minetest.set_node(pos, {name="sunos:fundamento"})
		minetest.get_meta(pos):from_table(table) -- recoloca metadados no novo fumdamento
		
	end,
})
