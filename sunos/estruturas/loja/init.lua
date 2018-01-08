--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Loja dos sunos
  ]]

-- Tradução de strings
local S = sunos.S

-- Caminho do diretório do mod
local modpath = minetest.get_modpath("sunos")

-- Tabela global de Loja
sunos.estruturas.loja = {}


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

local set_bau = function(pos, vila, dist)

	-- Verifica se tem baus na estrutura montada
	local baus = minetest.find_nodes_in_area(
		{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
		{x=pos.x+dist, y=pos.y+14, z=pos.z+dist}, 
		{"sunos:bau_loja"}
	)
	-- Salva dados da estrutura no bau dela
	for _,pos_bau in ipairs(baus) do
		local meta = minetest.get_meta(pos_bau)
		meta:set_string("infotext", S("Bau de Venda dos Sunos"))
		meta:set_string("formspec", "size[9,9]"
			..default.gui_bg_img
			.."image[0,0;3,3;sunos.png]"
			.."label[3,0;"..S("Bau de Venda dos Sunos").."]"
			.."label[3,1;"..S("Troque alguns itens aqui").."]"
			.."image[7.5,-0.2;2,2;default_apple.png]"
			.."image[6.6,0;2,2;default_apple.png]"
			.."image[6.6,1;2,2;default_apple.png]"
			.."image[7.5,0.8;2,2;default_apple.png]"
			-- Botoes de trocas
			.."item_image_button[0,3;3,3;default:tree;trocar_madeira;2]"
			.."item_image_button[0,6;3,3;default:stonebrick;trocar_pedra;2]"
			.."item_image_button[3,3;3,3;default:gold_ingot;trocar_ouro;10]"
			.."item_image_button[3,6;3,3;default:steel_ingot;trocar_ferro;6]"
			.."item_image_button[6,3;3,3;default:coal_lump;trocar_carvao;2]"
			.."item_image_button[6,6;3,3;default:glass;trocar_vidro;2]"
		)
	end

end

-- Tabela para valores de rotação
local tb_rotat = {"0", "90", "180", "270"}


-- Verificar se pode construir
sunos.estruturas.loja.verif = function(pos, dist, verif_area)
	
	-- Validar argumentos de entrada
	if pos == nil then
		minetest.log("error", "[Sunos] Tabela pos nula (em sunos.estruturas.loja.construir)")
		return "Erro interno (pos nula)"
	end
	if dist == nil then
		minetest.log("error", "[Sunos] variavel dist nula (em sunos.estruturas.loja.construir)")
		return "Erro interno (tamanho de loja inexistente)"
	end
	
	-- Variaveis auxiliares
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
	
	-- Verificações de area
	if verif_area == true then
		local r = sunos.verificar_area_para_fundamento(pos, dist)
		if r ~= true then
			return r
		end
	end
	
	return true, vila
end

-- Construir loja de sunos
--[[
	Essa função construi uma loja de sunos e configura o fundamento
	Retorno:
		^ true caso ocorra tudo bem
		^ string de erro caso algo de errado
	Argumentos:
		<pos> é a coordenada do fundamento da estrutura
		<dist> distancia centro a borda da nova estrutura
		<vila> OPCIONAL | é o numero da vila a qual a estrutura decorativa pertence
		<verif_area> OPCIONAL | true verificar a area antes de montar a estrutura (retorna strings dos erros)
]]
sunos.estruturas.loja.construir = function(pos, dist, verif_area, force)
	
	-- Verifica se pode construir a casa
	if force ~= true then
		local verif, vila = sunos.estruturas.loja.verif(pos, dist, verif_area)
		if verif ~= true then
			return verif
		end
	end
	
	local pos1 = {x=pos.x-dist, y=pos.y, z=pos.z-dist}
	local pos2 = {x=pos.x+dist, y=pos.y+14, z=pos.z+dist}
	
	-- Limpar metadados dos nodes que possam estar la
	sunos.limpar_metadados(pos1, pos2)
	
	-- Escolhe uma rotação aleatória
	local rotat = tb_rotat[math.random(1, 4)]
	
	-- Criar loja
	local rm, schem = sunos.montar_estrutura(pos, dist, "loja", rotat)
	
	-- Numero da estrutura da nova loja
	local n_estrutura = sunos.nova_estrutura(vila) -- Numero da nova estrutura
	
	-- Criar fundamento e configurar
	minetest.set_node(pos, {name="sunos:fundamento"})
	local meta = minetest.get_meta(pos)
	meta:set_string("versao", sunos.versao) -- Salva a versão atual do projeto
	meta:set_string("schem", schem) -- Nome do arquivo da esquematico da estrutura
	meta:set_string("rotat", rotat) -- Rotação da estrutura
	meta:set_string("vila", vila) -- Numero da vila
	meta:set_string("tipo", "loja") -- Tipo da estrutura
	meta:set_string("estrutura", n_estrutura) -- Numero da estrutura
	meta:set_string("dist", dist) -- Distancia centro a borda da estrutura
	sunos.contabilizar_blocos_estruturais(pos, nodes_estruturais) -- Armazena quantidade de nodes estruturais
	
	-- Ajustar baus
	set_bau(pos, vila, dist)
	
	-- Registros a serem salvos
	local registros = {
		numero = n_estrutura,
		tipo = "loja",
		estrutura = {
			dist = dist,
			largura = largura,
			pos = pos
		}
	}
	
	-- Salva no banco de dados
	sunos.bd.salvar("vila_"..vila, "loja_"..n_estrutura, registros)
	
	-- Salvar novo total de estruturas da vila
	sunos.bd.salvar("vila_"..vila, "estruturas", n_estrutura)
	
	-- Remover jogadores da area construida (evitar travar em paredes)
	sunos.ajustar_jogadores(pos)
	
	return true
end

-- Bau de loja (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/loja/bau.lua") 

-- Verificação do fundamento
sunos.estruturas.loja.verificar = function(pos)
	local meta = minetest.get_meta(pos)
	local vila = meta:get_string("vila")
	if not vila then return end
	vila = tonumber(vila)
	local tipo = meta:get_string("tipo")
	local dist = tonumber(meta:get_string("dist"))
	local nd = tonumber(meta:get_string("nodes")) -- numero de nodes inicial
	
	-- Pega o numero de nodes real
	local ndrl = sunos.verificar_blocos_estruturais(pos, nodes_estruturais)
	
	-- Verifica se a loja está muito destruida
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

-- Fundamento de loja
minetest.register_node("sunos:fundamento_loja", {
	description = S("Fundamento de Loja dos Sunos"),
	tiles = {"default_tree_top.png^sunos_fundamento.png", "default_tree_top.png", "default_tree.png"},
	inventory_image = "sunos_fundamento_fundo_inv.png^sunos_fundamento_loja_inv.png",
	wield_image = "sunos_fundamento_estrutura_namao.png^sunos_fundamento_loja_namao.png",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	stack_max = 1,
	
	-- Colocar uma loja
	on_place = function(itemstack, placer, pointed_thing)
		
		local pos = pointed_thing.under
		
		local r, vila = sunos.estruturas.loja.verif(pos, 3, true)
		
		if r == true then
			
			-- Coloca rua em torno
			sunos.colocar_rua(pos, 3)
			
			-- Coloca fundamento step para construir estrutura
			minetest.set_node(pointed_thing.under, {name="sunos:fundamento_step"})
			local meta = minetest.get_meta(pos)
			meta:set_string("tipo", "loja")
			meta:set_string("dist", 3)
			meta:set_string("versao", sunos.versao)
			meta:set_string("vila", vila)
			meta:set_string("step", 1)
			meta:set_string("data_inicio", minetest.get_day_count())
			meta:set_string("tempo_inicio", minetest.get_timeofday())
			meta:set_string("duracao", 24000) -- 1,5 dias no jogo
			meta:set_string("schem", "feirinha")
			meta:set_string("rotat", sunos.pegar_rotat())
			minetest.get_node_timer(pos):set(0.1, 0) -- Inicia temporizador
			
			-- Retorna mensagem de montagem concluida
			minetest.chat_send_player(placer:get_player_name(), S("Loja sendo construida"))
			itemstack:take_item()
			return itemstack
			
		else
			-- Marcar area necessaria
			sunos.criar_caixa_de_area(pointed_thing.under, 3+1)
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
	label = "Reforma da loja",
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
		if tipo ~= "loja" then return end
		local dist = tonumber(meta:get_string("dist"))
		local schem = meta:get_string("schem")
		local rotat = meta:get_string("rotat")
		if schem == "" then return end
	
		-- Caminho do arquivo da estrutura
		local caminho_arquivo = modpath.."/schems/"..tipo.."/"..schem
	
		-- Criar estrutura
		minetest.place_schematic({x=pos.x-dist, y=pos.y, z=pos.z-dist}, caminho_arquivo, rotat, nil, true)
		
		minetest.set_node(pos, {name="sunos:fundamento"})
		minetest.get_meta(pos):from_table(table) -- recoloca metadados no novo fumdamento
		
		-- Ajustar baus
		set_bau(pos, vila, dist)
	end,
})
