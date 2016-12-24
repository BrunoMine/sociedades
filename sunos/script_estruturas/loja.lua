--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Loja dos sunos
  ]]


-- Caminho do diretório do mod
local modpath = minetest.get_modpath("sunos")

-- Construir loja de sunos
--[[
	Essa função construi uma loja de sunos e configura o fundamento
	Retorno:
		^ true caso ocorra tudo bem
		^ string de erro caso algo de errado
	Argumentos:
		<pos> é a coordenada do fundamento da estrutura
		<vila> é o numero da vila a qual a loja pertence
		<dist> distancia centro a borda da nova estrutura
  ]]
sunos.construir_loja = function(pos, dist, force, vila)
	-- Validar argumentos de entrada
	if pos == nil then
		minetest.log("error", "[Sunos] Tabela pos nula (sunos.construir_loja)")
		return "Erro interno (pos nula)"
	end
	if dist == nil then
		minetest.log("error", "[Sunos] variavel dist nula (em sunos.construir_loja)")
		return "Erro interno (tamanho de loja inexistente)"
	end
	
	-- Variaveis auxiliares
	local largura = (dist*2)+1
	
	if not vila then
		-- Verificar Vila e pegar dados (buscando por um fundamento proximo)
		local pos_fund_prox = minetest.find_node_near(pos, 25, {"sunos:fundamento"})
		if pos_fund_prox == nil then 
			return sunos.S("Nenhuma vila por perto")
		end
	
		-- Pegar dados da vila encontrada
		local meta_fund_prox = minetest.get_meta(pos_fund_prox)
		vila = meta_fund_prox:get_string("vila")
	end
	
	-- Verificações de area
	if not force or force == false then
	
		-- Verificar se ainda existe um banco de dados da vila
		if sunos.bd:verif("vila_"..vila, "numero") == false then
			return sunos.S("Vila abandonada")
		end
		
		-- Verificar se o local esta limpo, gramado e plano (contando o entorno da estrutura)
		local nodes_solo = minetest.find_nodes_in_area(
			{x=pos.x-dist-1, y=pos.y, z=pos.z-dist-1}, 
			{x=pos.x+dist+1, y=pos.y, z=pos.z+dist+1}, 
			{"default:dirt_with_grass", "default:dirt"}
		)
		local nodes_acima_solo = minetest.find_nodes_in_area(
			{x=pos.x-dist-1, y=pos.y+1, z=pos.z-dist-1}, 
			{x=pos.x+dist+1, y=pos.y+1, z=pos.z+dist+1}, 
			{"air"}
		)
		if table.maxn(nodes_solo) < ((2*(dist+1))+1)^2
			or table.maxn(nodes_acima_solo) < (((2*(dist+1))+1)^2)-1
		then
			return sunos.S("O local precisa estar limpo, gramado e plano para uma estrutura com @1x@1 blocos da largura", largura)
		end

		-- Verificar se tem outra estrutura de suno interferindo na area da nova estrutura
		if sunos.verif_fundamento(pos, dist) == false then
			return sunos.S("Muito perto de outra estrutura dos Sunos (afaste um pouco)")
		end
	end
	
	-- Criar loja
	sunos.montar_estrutura(pos, dist, "loja")
	
	-- Numero da estrutura da nova loja
	local n_estrutura = sunos.bd:pegar("vila_"..vila, "estruturas")+1 -- Numero da nova estrutura
	
	-- Criar fundamento e configurar
	minetest.set_node(pos, {name="sunos:fundamento"})
	local meta = minetest.get_meta(pos)
	meta:set_string("vila", vila) -- Numero da vila
	meta:set_string("tipo", "loja") -- Tipo da estrutura
	meta:set_string("estrutura", n_estrutura) -- Numero da estrutura
	meta:set_string("dist", dist) -- Distancia centro a borda da estrutura
	sunos.contabilizar_blocos_estruturais(pos) -- Armazena quantidade de nodes estruturais
	
	-- Verifica se tem baus na estrutura montada
	local baus = minetest.find_nodes_in_area(
		{x=pos.x-dist, y=pos.y, z=pos.z-dist}, 
		{x=pos.x+dist, y=pos.y+14, z=pos.z+dist}, 
		{"sunos:bau_loja"}
	)
	-- Salva dados da estrutura no bau dela
	for _,pos_bau in ipairs(baus) do
		local meta = minetest.get_meta(pos_bau)
		meta:set_string("infotext", sunos.S("Bau de Venda dos Sunos"))
		meta:set_string("formspec", "size[9,9]"
			..default.gui_bg_img
			.."image[0,0;3,3;sunos.png]"
			.."label[3,0;"..sunos.S("Bau de Venda dos Sunos").."]"
			.."label[3,1;"..sunos.S("Troque alguns itens aqui").."]"
			.."image[7.5,-0.2;2,2;default_apple.png]"
			.."image[6.6,0;2,2;default_apple.png]"
			.."image[6.6,1;2,2;default_apple.png]"
			.."image[7.5,0.8;2,2;default_apple.png]"
			-- Botoes de trocas
			.."item_image_button[0,3;3,3;default:tree;trocar_madeira;2]"
			.."item_image_button[0,6;3,3;default:stonebrick;trocar_pedra;2]"
			.."item_image_button[3,3;3,3;default:gold_ingot;trocar_ouro;10]"
			.."item_image_button[3,6;3,3;default:steel_ingot;trocar_ferro;6]"
			.."item_image_button[6,3;3,3;default:coal_lump;trocar_carvao;1]"
			.."item_image_button[6,6;3,3;default:glass;trocar_vidro;1]"
		)
	end
	
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
	sunos.bd:salvar("vila_"..vila, "loja_"..n_estrutura, registros)
	
	-- Salvar novo total de estruturas da vila
	sunos.bd:salvar("vila_"..vila, "estruturas", n_estrutura)
	
	return true
end

-- Bau de venda simples
minetest.register_node("sunos:bau_loja", {
	description = sunos.S("Bau de Venda dos Sunos"),
	tiles = {"default_chest_top.png^sunos_bau_topo.png", "default_chest_top.png", "default_chest_side.png^sunos_bau_lado.png",
		"default_chest_side.png^sunos_bau_lado.png", "default_chest_side.png^sunos_bau_lado.png", "default_chest_lock.png^sunos_bau_frente.png"},
	paramtype2 = "facedir",
	groups = {choppy = 2, oddly_breakable_by_hand = 2},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	drop = "default:chest",
	
	-- Nao pode ser escavado/quebrado por jogadores
	--on_dig = function() end,
	
	-- Receptor dos botos
	on_receive_fields = function(pos, formname, fields, sender)
		if fields.trocar_madeira then
			-- Tenta trocar
			if tror.trocar_plus(sender, {"default:tree"}, {"default:apple 2"}) == false then
				return minetest.chat_send_player(sender:get_player_name(), sunos.S("Precisa do item para trocar"))
			else
				return minetest.chat_send_player(sender:get_player_name(), sunos.S("Troca feita"))
			end
		elseif fields.trocar_pedra then
			-- Tenta trocar
			if tror.trocar_plus(sender, {"default:stonebrick"}, {"default:apple 2"}) == false then
				return minetest.chat_send_player(sender:get_player_name(), sunos.S("Precisa do item para trocar"))
			else
				return minetest.chat_send_player(sender:get_player_name(), sunos.S("Troca feita"))
			end
		elseif fields.trocar_ouro then
			-- Tenta trocar
			if tror.trocar_plus(sender, {"default:gold_ingot"}, {"default:apple 10"}) == false then
				return minetest.chat_send_player(sender:get_player_name(), sunos.S("Precisa do item para trocar"))
			else
				return minetest.chat_send_player(sender:get_player_name(), sunos.S("Troca feita"))
			end
		elseif fields.trocar_ferro then
			-- Tenta trocar
			if tror.trocar_plus(sender, {"default:steel_ingot"}, {"default:apple 6"}) == false then
				return minetest.chat_send_player(sender:get_player_name(), sunos.S("Precisa do item para trocar"))
			else
				return minetest.chat_send_player(sender:get_player_name(), sunos.S("Troca feita"))
			end
		elseif fields.trocar_carvao then
			-- Tenta trocar
			if tror.trocar_plus(sender, {"default:coal_lump"}, {"default:apple 1"}) == false then
				return minetest.chat_send_player(sender:get_player_name(), sunos.S("Precisa do item para trocar"))
			else
				return minetest.chat_send_player(sender:get_player_name(), sunos.S("Troca feita"))
			end
		elseif fields.trocar_vidro then
			-- Tenta trocar
			if tror.trocar_plus(sender, {"default:glass"}, {"default:apple 10"}) == false then
				return minetest.chat_send_player(sender:get_player_name(), sunos.S("Precisa do item para trocar"))
			else
				return minetest.chat_send_player(sender:get_player_name(), sunos.S("Troca feita"))
			end
		end
	end,
})

-- Fundamento de loja
minetest.register_node("sunos:fundamento_loja", {
	description = sunos.S("Fundamento de Loja dos Sunos"),
	tiles = {"default_tree_top.png^sunos_fundamento.png", "default_tree_top.png", "default_tree.png"},
	inventory_image = "sunos_inv_fundamento.png^sunos_inv_fundamento_loja.png",
	wield_image = "sunos_inv_fundamento.png^sunos_inv_fundamento_loja.png",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	stack_max = 1,
	
	-- Colocar uma loja
	on_place = function(itemstack, placer, pointed_thing)
		
		local r = sunos.construir_loja(pointed_thing.under, 3)
		if r == true then
			
			-- Retorna mensagem de montagem concluida
			minetest.chat_send_player(placer:get_player_name(), sunos.S("Loja construida"))
			itemstack:take_item()
			return itemstack
			
		else
			-- Retorna mensagem de falha
			minetest.chat_send_player(placer:get_player_name(), r)
			return itemstack
		end
	end,
})
