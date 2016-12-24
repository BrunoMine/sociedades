--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Interface
  ]]

-- Tabela de entidade acessada na casa comunal
sunos.acesso = memor.online()

-- Lista que relaciona numero com titulo od item
local tb_itens_menu_casa_comunal = {}

-- Lista de itens do menu da casa comunal em formato de string
local string_menu_casa_comunal = ""
for item,_ in pairs(sunos.tb_menu_casa_comunal) do
	if string_menu_casa_comunal ~= "" then string_menu_casa_comunal = string_menu_casa_comunal .. "," end
	string_menu_casa_comunal = string_menu_casa_comunal .. item
	table.insert(tb_itens_menu_casa_comunal, item)
end

-- Envia uma formspec simples de aviso
local avisar = function(player, texto)
	if not player then
		minetest.log("error", "[Sunos] player nulo (em avisar do script interface.lua)")
		return false
	end
	if not texto then
		minetest.log("error", "[Sunos] texto nulo (em avisar do script interface.lua)")
		return false
	end
	
	minetest.show_formspec(player:get_player_name(), "sunos:npc", "size[12,1]"
		..default.gui_bg
		..default.gui_bg_img
		.."label[0.5,0;"..sunos.S("Aviso").." \n"..texto.."]")
	return true
end

-- Acessar NPC
sunos.acessar_npc = function(ent, player, fields)
	
	-- Verifica se NPC ainda existe
	if not ent then
		return
	end
	
	-- Salva a entidade acessada
	sunos.acesso[player:get_player_name()].ent = ent
	
	-- NPC suno comum
	if ent.name == "sunos:npc" then
		
		-- Verifica se nao tem casa comunal e oferece para construir
		if sunos.bd:verif("vila_"..ent.vila, "casa_comunal") == false then
			local formspec = "size[6,3]"
				..default.gui_bg
				..default.gui_bg_img
				.."label[0,0;"..sunos.S("Oi. Ajude essa vila a \nmontar uma Casa Comunal").."]"
				.."item_image_button[0,1;1,1;default:tree 20;item1;]" -- Item 1
				.."item_image_button[1,1;1,1;default:stone 70;item1;]" -- Item 2
				.."item_image_button[2,1;1,1;farming:straw 30;item1;]" -- Item 3
				.."item_image_button[5,1;1,1;sunos:fundamento_casa_comunal;fundamento;]" -- Fundamento de Casa Comunal
				.."button_exit[0,2;6,1;trocar;"..sunos.S("Trocar por Fundamento").."]"
			return minetest.show_formspec(player:get_player_name(), "sunos:npc", formspec)
		end
		
		-- Avisa para ir ate a casa comunal
		return minetest.chat_send_player(player:get_player_name(), sunos.S("Nenhuma atividade disponivel"))
	
	-- NPC da casa Comunal
	elseif ent.name == "sunos:npc_casa_comunal" then
		
		-- Atualizar banco de dados da vila
		sunos.atualizar_bd_vila(ent.vila)
		
		-- Verifica se existe casa comunal na vila
		if sunos.bd:verif("vila_"..ent.vila, "casa_comunal") == false then
			return minetest.chat_send_player(player:get_player_name(), sunos.S("Nenhuma Casa Comunal nessa vila"))
		end
		
		-- Coletar dados da vila
		local habitantes = sunos.bd:pegar("vila_"..ent.vila, "pop_total") or "Erro interno"
		
		-- Formspec de NPC da casa comunal
		local formspec = "size[12,8.3]"
			..default.gui_bg
			..default.gui_bg_img
			.."image[0,0;3,3;sunos.png]"
			.."label[3,0;"..sunos.S("Bem vindo a Casa Comunal").."]"
			.."label[3,0.5;"..sunos.S("Habitantes atuais: @1", habitantes).."]"
			.."textlist[0,3;4.8,5.3;menu;"..string_menu_casa_comunal.."]"
			
		-- Painel do item escolhido
		if fields and fields.menu then
			local n = string.split(fields.menu, ":")
			local escolha = n[2] or 1
			
			-- Dados do item escolhido
			local titulo = tb_itens_menu_casa_comunal[tonumber(escolha)]
			local dados = sunos.tb_menu_casa_comunal[titulo]
			
			-- Armazena o item escolhido
			sunos.acesso[player:get_player_name()].item = titulo
			
			-- Titulo do item
			formspec = formspec .."label[5,3;"..titulo.."]"
			
			-- Botao de trocar
			formspec = formspec .. "item_image_button[5,3.5;2,2;"..dados.item_add..";trocar;"..sunos.S("Trocar").."]"
			
			-- Texto descritivo
			formspec = formspec .. "textarea[7.2,3.5;5.1,2.25;desc;;"..dados.desc.."]"
			
			-- Requisitos
			formspec = formspec .."label[5,5.5;"..sunos.S("Requisitos").."]"
			
			-- População minima
			formspec = formspec .."label[5,6;"..sunos.S("Habitantes: @1", dados.pop).."]"
			
			-- Organizando formspec dos itens
			for n,item in pairs(dados.item_rem) do
				if n == 1 then -- Item 1
					formspec = formspec .. "item_image_button[5,6.5;1,1;"..item..";item1;]"
				elseif n == 2 then -- Item 2
					formspec = formspec .. "item_image_button[6,6.5;1,1;"..item..";item2;]"
				elseif n == 3 then -- Item 3
					formspec = formspec .. "item_image_button[7,6.5;1,1;"..item..";item3;]"
				elseif n == 4 then -- Item 4
					formspec = formspec .. "item_image_button[8,6.5;1,1;"..item..";item4;]"
				elseif n == 5 then -- Item 5
					formspec = formspec .. "item_image_button[9,6.5;1,1;"..item..";item5;]"
				elseif n == 6 then -- Item 6
					formspec = formspec .. "item_image_button[10,6.5;1,1;"..item..";item6;]"
				elseif n == 7 then -- Item 7
					formspec = formspec .. "item_image_button[11,6.5;1,1;"..item..";item7;]"
				elseif n == 8 then -- Item 8
					formspec = formspec .. "item_image_button[5,7.5;1,1;"..item..";item8;]"
				elseif n == 9 then -- Item 9
					formspec = formspec .. "item_image_button[6,7.5;1,1;"..item..";item9;]"
				elseif n == 10 then -- Item 10
					formspec = formspec .. "item_image_button[7,7.5;1,1;"..item..";item10;]"
				elseif n == 11 then -- Item 11
					formspec = formspec .. "item_image_button[8,7.5;1,1;"..item..";item11;]"
				elseif n == 12 then -- Item 12
					formspec = formspec .. "item_image_button[9,7.5;1,1;"..item..";item12;]"
				elseif n == 13 then -- Item 13
					formspec = formspec .. "item_image_button[10,7.5;1,1;"..item..";item13;]"
				elseif n == 14 then -- Item 14
					formspec = formspec .. "item_image_button[11,7.5;1,1;"..item..";item14;]"
				end
			end
			
		else
			formspec = formspec .."label[6,5;"..sunos.S("Escolha algo da lista").."]"
		end
		
		return minetest.show_formspec(player:get_player_name(), "sunos:npc_casa_comunal", formspec)
	end
end

-- Receptor de botoes
minetest.register_on_player_receive_fields(function(player, formname, fields)

	-- NPC suno comum
	if formname == "sunos:npc" then 
		-- Validar entidade acessada
		local ent = sunos.acesso[player:get_player_name()].ent
		if not ent then return end
		
		if fields.trocar then -- Trocar fundamento de casa comunal
			
			-- Tenta trocar pelo fundamento de casa comunal
			if tror.trocar_plus(player, 
				{"default:tree 20", "default:stone 70", "farming:straw 30"}, 
				{"sunos:fundamento_casa_comunal"}
			) == false 
			then
				return minetest.chat_send_player(player:get_player_name(), sunos.S("Faltou itens para trocar pelo fundamento de Casa Comunal"))
			else
				minetest.chat_send_player(player:get_player_name(), sunos.S("Recebeste um Fundamento de Casa Comunal"))
				minetest.chat_send_player(player:get_player_name(), sunos.S("Coloque em um local adequado para que seja construida"))
				return
			end
		end
	end
	
	if formname == "sunos:npc_casa_comunal" then
		-- Validar entidade acessada
		local ent = sunos.acesso[player:get_player_name()].ent
		if not ent then return end
		
		if fields.menu then		
			-- Retorna o acesso
			sunos.acessar_npc(ent, player, fields)
		end
		
		if fields.trocar then
		
			-- Dados do item escolhido
			local titulo = sunos.acesso[player:get_player_name()].item
			local dados = sunos.tb_menu_casa_comunal[titulo]
			
			-- Verifica se tem os habitantes necessarios
			-- Atualizar banco de dados da vila
			sunos.atualizar_bd_vila(ent.vila)
			local pop_atual = sunos.bd:pegar("vila_"..ent.vila, "pop_total")
			if pop_atual == nil or pop_atual < dados.pop then
				return avisar(player, sunos.S("A vila precisa de mais habitantes para isso"))
			end   
			
			-- Tenta trocar
			if tror.trocar_plus(player, dados.item_rem, {dados.item_add}) == false then
				return avisar(player, sunos.S("Precisa dos itens exigidos para a trocar por \n@1", titulo))
			else
				return avisar(player, sunos.S("Recebeste um @1", titulo))
			end
		end
	end
	
end)
