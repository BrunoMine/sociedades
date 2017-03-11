--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	emporio dos sunos
  ]]

-- Tradução de strings
local S = sunos.S

-- Tabela global de emporio
sunos.estruturas.emporio = {}

-- Caminho do diretório do mod
local modpath = minetest.get_modpath("sunos")

-- Diretrizes (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/emporio/diretrizes.lua") 

-- Placa de Emporio (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/emporio/placa.lua") 


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
	for n,p in ipairs(sunos.estruturas.emporio.var.niveis) do
		if n == table.maxn(sunos.estruturas.emporio.var.niveis) then
			return n
		end
		if pop >= p and pop < sunos.estruturas.emporio.var.niveis[n+1] then
			return n
		end
	end
	
	-- Caso pop nao seja menor que nenhum dos niveis (maior que todos os exigidos) retorna nivel maximo
	return table.maxn(sunos.estruturas.emporio.var.niveis)
	
end


-- Tabela para valores de rotação
local tb_rotat = {"0", "90", "180", "270"}

-- Construir emporio de sunos
--[[
	Essa função construi uma emporio de sunos e configura o fundamento
	Retorno:
		^ true caso ocorra tudo bem
		^ string de erro caso algo de errado
	Argumentos:
		<pos> é a coordenada do fundamento da estrutura
		<vila> OPCIONAL | é o numero da vila a qual a estrutura decorativa pertence
		<verif_area> OPCIONAL | true verificar a area antes de montar a estrutura (retorna strings dos erros)
]]
sunos.estruturas.emporio.construir = function(pos, vila, verif_area)
	-- Validar argumentos de entrada
	if pos == nil then
		minetest.log("error", "[Sunos] Tabela pos nula (em sunos.estruturas.emporio.construir)")
		return "Erro interno (pos nula)"
	end
	
	-- Variaveis auxiliares
	local dist = 5
	local largura = (dist*2)+1
	
	if not vila then
		-- Verificar Vila e pegar dados (buscando por um fundamento proximo)
		local pos_fund_prox = minetest.find_node_near(pos, 25, {"sunos:fundamento"})
		if pos_fund_prox == nil then 
			return S("Nenhuma vila por perto")
		end
	
		-- Pegar dados da vila encontrada
		local meta_fund_prox = minetest.get_meta(pos_fund_prox)
		vila = meta_fund_prox:get_string("vila")
	end
	
	-- Verificações de area
	if verif_area == true then
	
		-- Verificar se ainda existe um banco de dados da vila
		if sunos.bd:verif("vila_"..vila, "numero") == false then
			return S("Vila abandonada")
		end
		
		-- Verifica status do terreno
		local st = sunos.verif_terreno(pos, dist+1)
		
		-- Problema: em cima da faixa de solo existem obstrucoes (nao esta limpo e plano)
		if st == 1 then
			return S("O local precisa estar limpo e plano em uma area de @1x@1 blocos da largura", (largura+2))
		
		-- Problema: faixa de solo (superficial) falta blocos de terra
		elseif st == 2 then
			return S("O solo precisa estar plano e gramado em uma area de @1x@1 blocos da largura", (largura+2))
		
		-- Problema: faixa de subsolo (considerando 2 faixas) falta blocos de terra
		elseif st == 3 then
			return S("O subsolo precisa estar preenchido (ao menos 2 blocos de profundidade) em uma area de @1x@1 blocos da largura", (largura+2))
		end
	end
	
	-- Escolhe uma rotação aleatória
	local rotat = tb_rotat[math.random(1, 4)]
	
	-- Atualizar schem do nivel
	local schem = "nivel_" .. verif_nivel(sunos.bd:pegar("vila_"..vila, "pop_total"))
	
	-- Caminho do arquivo da estrutura
	local caminho_arquivo = modpath.."/schems/emporio/"..schem..".11.mts"
	
	-- Criar estrutura
	minetest.place_schematic({x=pos.x-dist, y=pos.y, z=pos.z-dist}, caminho_arquivo, rotat, sunos.var.nodes_trocados, true)
	
	-- Criar fundamento e configurar
	minetest.set_node(pos, {name="sunos:fundamento"})
	local meta = minetest.get_meta(pos)
	meta:set_string("versao", sunos.versao) -- Salva a versão atual do projeto
	meta:set_string("schem", schem) -- Nome do arquivo da esquematico da estrutura
	meta:set_string("rotat", rotat) -- Rotação da estrutura
	meta:set_string("vila", vila) -- Numero da vila
	meta:set_string("tipo", "emporio") -- Tipo da estrutura
	meta:set_string("dist", dist) -- Distancia centro a borda da estrutura
	sunos.contabilizar_blocos_estruturais(pos, nodes_estruturais) -- Armazena quantidade de nodes estruturais
	
	
	-- Registros a serem salvos
	local registros = {
		tipo = "emporio",
		estrutura = {
			dist = dist,
			largura = largura,
			pos = pos
		}
	}
	
	-- Salva no banco de dados
	sunos.bd:salvar("vila_"..vila, "emporio", registros)
	
	return true
end


-- Verificação do fundamento
sunos.estruturas.emporio.verificar = function(pos)
	local meta = minetest.get_meta(pos)
	local vila = meta:get_string("vila")
	if not vila then return end
	vila = tonumber(vila)
	local tipo = meta:get_string("tipo")
	local dist = 5
	local nd = tonumber(meta:get_string("nodes")) -- numero de nodes inicial
	
	-- Pega o numero de nodes real
	local ndrl = sunos.verificar_blocos_estruturais(pos, nodes_estruturais)
	
	-- Verifica se a emporio está muito destruida
	if ndrl < nd - 4 then
	
		-- Montar ruinas no local da antiga casa
		sunos.montar_ruinas(pos, dist)
		
		-- Exclui o arquivo da estrutura do banco de dados
		sunos.bd:remover("vila_"..meta:get_string("vila"), tipo.."_"..meta:get_string("estrutura"))
		
		-- Trocar bloco de fundamento por madeira
		minetest.set_node(pos, {name="default:tree"})
		
		-- Atualizar banco de dados da vila
		sunos.atualizar_bd_vila(vila)
	end
end

-- Fundamento de emporio
minetest.register_node("sunos:fundamento_emporio", {
	description = S("Fundamento de Emporio dos Sunos"),
	tiles = {"default_tree_top.png^sunos_fundamento.png", "default_tree_top.png", "default_tree.png"},
	inventory_image = "sunos_inv_fundamento.png^sunos_fundamento_emporio_inv.png",
	wield_image = "sunos_inv_fundamento.png^sunos_fundamento_emporio_inv.png",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	stack_max = 1,
	
	-- Colocar uma emporio
	on_place = function(itemstack, placer, pointed_thing)
		
		-- Verificar Vila e pegar dados (buscando por um fundamento proximo)
		local pos_fund_prox = minetest.find_node_near(pointed_thing.under, 25, {"sunos:fundamento"})
		if pos_fund_prox == nil then 
			return minetest.chat_send_player(placer:get_player_name(), S("Nenhuma vila por perto"))
		end
		
		-- Pegar dados da vila encontrada
		local meta_fund_prox = minetest.get_meta(pos_fund_prox)
		local vila = meta_fund_prox:get_string("vila")
		
		if vila == "" or not vila then return minetest.chat_send_player(placer:get_player_name(), S("Vila abandonada")) end
		
		-- Verificar se a vila está abandonada
		if not sunos.bd:pegar("vila_"..vila, "estruturas") then
			return minetest.chat_send_player(placer:get_player_name(), S("Vila abandonada"))
		end
		
		-- Atualizar banco de dados da vila
		sunos.atualizar_bd_vila(vila)
		
		-- Verifica se tem populacao suficiente
		if tonumber(sunos.bd:pegar("vila_"..vila, "pop_total")) < sunos.estruturas.emporio.var.niveis[1] then
			return minetest.chat_send_player(placer:get_player_name(), S("A vila precisa ter ao menos @1 habitantes", sunos.estruturas.emporio.var.niveis[1]))
		end
		
		-- Verificar se ja existe um emporio
		if sunos.bd:verif("vila_"..vila, "emporio") == true then
			return minetest.chat_send_player(placer:get_player_name(), S("Ja existe @1 nessa vila", S("Emporio")))
		end
		
		sunos.criar_caixa_de_area(pointed_thing.under, 5+1)
		
		local r = sunos.estruturas.emporio.construir(pointed_thing.under, vila, true)
		if r == true then
			
			-- Coloca rua em torno
			sunos.colocar_rua(pointed_thing.under, 4)
			
			-- Retorna mensagem de montagem concluida
			minetest.chat_send_player(placer:get_player_name(), S("Emporio construido"))
			itemstack:take_item()
			return itemstack
			
		else
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
	label = "Reforma do emporio",
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
		if tipo ~= "emporio" then return end
		local dist = 5
		local schem = meta:get_string("schem")
		local rotat = meta:get_string("rotat")
		if schem == "" then return end
		
		-- Atualizar schem do nivel
		schem = "nivel_" .. verif_nivel(sunos.bd:pegar("vila_"..vila, "pop_total"))
		
		-- Caminho do arquivo da estrutura
		local caminho_arquivo = modpath.."/schems/"..tipo.."/"..schem..".11.mts"
		
		-- Criar estrutura
		minetest.place_schematic({x=pos.x-dist, y=pos.y, z=pos.z-dist}, caminho_arquivo, rotat, sunos.var.nodes_trocados, true)
		
		minetest.set_node(pos, {name="sunos:fundamento"})
		minetest.get_meta(pos):from_table(table) -- recoloca metadados no novo fumdamento
		
	end,
})
