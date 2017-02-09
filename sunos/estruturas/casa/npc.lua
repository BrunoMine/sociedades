--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	NPC das casas
  ]]

sunos.npcs.npc.registrar("caseiro", {
	
})

-- Verificação do bau quanto aos npcs da casa
local verif_bau_casa = function(pos)
	if not pos then return end
	
	if minetest.get_meta(pos):get_string("vila") ~= "" then
			
		-- Pegar metadados do bau
		local meta = minetest.get_meta(pos)
		
		-- Coordenada do fundamento
		local pf = minetest.deserialize(meta:get_string("pos_fundamento"))
		
		-- Verificar se o fundamento ainda esta no lugar
		if minetest.get_node(pf).name ~= "sunos:fundamento" then 
			minetest.set_node(pos, {name="default:chest", param2=minetest.get_node(pos).param2})
			return 
		end
		
		-- Distancia centro a borda da estrutura
		local dist = minetest.get_meta(pf):get_string("dist")
		if dist == "" then
			minetest.log("error", "[Sunos] dist invalida ("..dump(dist)..") (em verif_bau_casa em estruturas/casa/npc.lua)")
			return 
		end
		dist = tonumber(dist)
		-- Verificar se ja tem npc perto
		
		-- Analizar objetos (possiveis npcs) perto
		for _,obj in ipairs(minetest.get_objects_inside_radius(pf, dist)) do
			
			-- Evita jogadores por perto para nao spawnar de repente
			if obj:is_player() then return end
			
			local ent = obj:get_luaentity() or {}
			if ent 
				and ent.name == "sunos:npc" -- Verifica se for npc comum
				and ent.tipo == "caseiro" -- Verifica se for npc comum é caseiro
				and tonumber(ent.vila) == tonumber(minetest.get_meta(pos):get_string("vila")) -- Verifica se é da mesma vila
			then 
				-- Encerra o procedimento
				return
			end
		end
		
		-- Spawnar um novo npc
		sunos.npcs.npc.spawn("caseiro", minetest.get_meta(pos):get_string("vila"), pos)
	end
end


-- Spawnar NPCs caseiros nas casas
minetest.register_abm({
	label = "Spawn npc caseiro",
	nodenames = {"sunos:bau_casa"},
	interval = 15,
	chance = 1,
	action = function(pos)
		-- Verificar se tem vila apos um tempo para evitar leitura de mapa ainda nao carregado
		minetest.after(5, verif_bau_casa, pos)
	end,
})
