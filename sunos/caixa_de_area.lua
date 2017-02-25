--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Caixa de demarcação de area
  ]]

-- Registro da entidade
minetest.register_entity("sunos:caixa_de_area", {
	hp_max = 1,
	physical = false,
	weight = 1,
	collisionbox = {0,0,0, 0,0,0},
	visual = "mesh",
	visual_size = {x=5, y=5},
	mesh = "sunos_caixa_de_area.b3d",
	textures = {"sunos_caixa_de_area.png"}, -- number of required textures depends on visual
	spritediv = {x=1, y=1},
	initial_sprite_basepos = {x=0, y=0},
	is_visible = true,
	makes_footstep_sound = false,
	automatic_rotate = false,
	on_step = function(self, dtime)
		if not self.ok and self.object then
			self.object:remove()
		end
	end,
})

-- Remoção de caixa de area
local remover_caixa = function(obj)
	if not obj then return end
	obj:remove()
end

-- Colocação de uma caixa
sunos.criar_caixa_de_area = function(pos, dist)
	
	if not pos then
		minetest.log("error", "[Sunos] pos nulo (em sunos.criar_caixa_de_area)")
		return false
	end
	if not dist then
		minetest.log("error", "[Sunos] dist nulo (em sunos.criar_caixa_de_area)")
		return false
	end
	
	-- Remove caixas proximas para evitar colisão
	for  _,obj in ipairs(minetest.get_objects_inside_radius(pos, 13)) do
		local ent = obj:get_luaentity() or {}
		if ent and ent.name == "sunos:caixa_de_area" then
			obj:remove()
		end
	end
	
	-- Cria o objeto
	local obj = minetest.add_entity({x=pos.x, y=pos.y+7, z=pos.z}, "sunos:caixa_de_area")
	
	-- Verifica se foi criado
	if not obj then
		minetest.log("error", "[Sunos] Falha ao criar objecto (em sunos.criar_caixa_de_area)")
		return false
	end
	
	-- Pega a entidade
	local ent = obj:get_luaentity()
	
	-- Salva dados temporarios
	ent.name = "sunos:caixa_de_area" -- nome para reconhecimento
	ent.ok = true -- ok que evita auto remoção
	
	-- Redimensiona para o tamanho da area
	if tonumber(dist) == 1 then
		obj:set_properties({visual_size = {x=15, y=75}})
	elseif tonumber(dist) == 2 then
		obj:set_properties({visual_size = {x=25, y=75}})
	elseif tonumber(dist) == 3 then
		obj:set_properties({visual_size = {x=35, y=75}})
	elseif tonumber(dist) == 4 then
		obj:set_properties({visual_size = {x=45, y=75}})
	elseif tonumber(dist) == 5 then
		obj:set_properties({visual_size = {x=55, y=75}})
	elseif tonumber(dist) == 6 then
		obj:set_properties({visual_size = {x=65, y=75}})
	elseif tonumber(dist) == 7 then -- Na pratica isso serve para verificar area um pouco maior que as de largura 13
		obj:set_properties({visual_size = {x=75, y=75}})
	elseif tonumber(dist) == 8 then -- Na pratica isso serve para verificar area um pouco maior que as de largura 13
		obj:set_properties({visual_size = {x=85, y=75}})
	end
	
	-- Remove a caixa apos 5 segundos
	minetest.after(5, remover_caixa, obj)
	
	return true
	
end
