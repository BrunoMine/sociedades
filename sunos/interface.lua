--[[
	Mod Sunos para Minetest
	Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Interface
  ]]


-- Acessar NPC
sunos.acessar_npc = function(ent, player)
	
	-- NPC suno comum
	if ent.name == "sunos:npc" then
		
		-- Verifica se nao tem casa comunal e oferece para construir
		if sunos.bd:verif("vila_"..ent.vila, "casa_comunal") == false then
			local formspec = "size[6,3]"
				..default.gui_bg
				..default.gui_bg_img
				.."label[0,0;Oi. Ajude essa vila a \nmontar uma Casa Comunal]"
				.."item_image_button[0,1;1,1;default:tree 20;item1;]" -- Item 1
				.."item_image_button[1,1;1,1;default:cobble 30;item1;]" -- Item 2
				.."item_image_button[2,1;1,1;wool:yellow 10;item1;]" -- Item 3
				.."item_image_button[5,1;1,1;sunos:fundamento_casa_comunal;fundamento;]" -- Fundamento de Casa Comunal
				.."button_exit[0,2;6,1;trocar;Trocar por Fundamento]"
			return minetest.show_formspec(player:get_player_name(), "sunos:npc", formspec)
		end
		
		-- Avisa para ir ate a casa comunal
		return minetest.chat_send_player(player:get_player_name(), "Nenhuma atividade disponivel.")
	
	-- NPC da casa Comunal
	elseif ent.name == "sunos:npc_casa_comunal" then
		
		-- Verifica se casa comunal existe
		if sunos.bd:verif("vila_"..ent.vila, "casa_comunal") == false then
			return minetest.chat_send_player(player:get_player_name(), "Nenhuma Casa Comunal ativa nessa vila.")
		else
			return minetest.chat_send_player(player:get_player_name(), "Nenhuma atividade disponivel.")
		end
	end
end

-- Receptor de botoes
minetest.register_on_player_receive_fields(function(player, formname, fields)

	-- NPC suno comum
	if formname == "sunos:npc" then 
		if fields.trocar then -- Trocar fundamento de casa comunal
			
			-- Tenta trocar pelo fundamento de casa comunal
			if tror.trocar_plus(player, 
				{"default:tree 20", "default:cobble 30", "wool:yellow 10"}, 
				{"sunos:fundamento_casa_comunal"}
			) == false 
			then
				return minetest.chat_send_player(player:get_player_name(), "Precisa conseguir os itens para montar um fundamento de Casa Comunal")
			else
				return minetest.chat_send_player(player:get_player_name(), "Recebeste um Fundamento de Casa Comunal. Coloque em um local adequado para que seja construida")
			end
		end
	end
end)