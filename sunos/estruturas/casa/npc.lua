--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	NPC das casas
  ]]

-- Cronograma de atividades do NPC da casa (carregamento de script)
dofile(minetest.get_modpath("sunos").."/estruturas/casa/cronograma_npc.lua") 

-- Tradução de strings
local S = sunos.S

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
		.."label[0.5,0;"..S("Aviso").." \n"..texto.."]")
	return true
end

-- Configurar lugares do npc
local set_npc_places = function(self)
	local pf = self.sunos_fundamento
	if not pf then return end
	
	-- Cama
	if sunos.estruturas.casa.buscar_nodes(pf, {"beds:bed_bottom"})[1] then
		local pos_cama = sunos.estruturas.casa.buscar_nodes(pf, {"beds:bed_bottom"})[1]
		local v = minetest.facedir_to_dir(minetest.get_node(pos_cama).param2)
		local pos_acesso = {x=pos_cama.x-v.x,y=pos_cama.y, z=pos_cama.z-v.z}
		npc.places.add_owned(self, "house_bed", "bed_primary", pos_cama, pos_acesso)
	end
	
	-- Saidas da casa
	if sunos.estruturas.casa.buscar_nodes(pf, {"doors:door_wood_a"})[1] then
		local pos_porta = sunos.estruturas.casa.buscar_nodes(pf, {"doors:door_wood_a"})[1]
		local v = minetest.facedir_to_dir(minetest.get_node(pos_porta).param2)
		local pos_porta_dentro = {x=pos_porta.x-v.x,y=pos_porta.y, z=pos_porta.z-v.z}
		local pos_porta_fora = {x=pos_porta.x+v.x,y=pos_porta.y, z=pos_porta.z+v.z}
		npc.places.add_owned(self, "home_outside", "home_inside", pos_porta_dentro, nil)
		npc.places.add_owned(self, "home_inside", "home_outside", pos_porta_fora, nil)
	end
end

-- Criar entidade NPC
sunos.npcs.npc.registrar("caseiro", {
	max_dist = 100,	
	node_spawner = "sunos:bau_casa",
	
	on_spawn = function(self)
		
		if self.dias_roteiro == nil -- Sem roteiro ainda
			or self.dias_roteiro + 2 < minetest.get_day_count() -- Ja é o terceiro dia com esse roteiro
		then
			-- Configurar lugares (espera para que alores sejam atualizados)
			minetest.after(1, set_npc_places, self)
			
			-- Configura agenda de tarefas
			minetest.after(2, sunos.estruturas.casa.atribuir_cronograma_npc, self)
		end
	end,
	
	on_step = function(self, dtime)
		return npc.step(self, dtime)
	end,
	
	
	drops = {
		{name = "default:apple", chance = 2, min = 1, max = 2},
	},
})


