--
-- Mod PlaGen
--
-- Nodes
--

-- Node teste
--[[
minetest.register_node("plagen:teste", {
	description = "Node teste de Planificador",
	paramtype2 = "facedir",
	place_param2 = 0,
	tiles = {"default_wood.png"},
	is_ground_content = false,
	groups = {oddly_breakable_by_hand = 2},
	on_place = function(itemstack, placer, pointed_thing)
		local node = {name="default:dirt_with_grass"}
		local subsolo = "default:dirt"
		local solo = "default:dirt_with_grass"
		
		if pointed_thing.above then
			node = minetest.get_node(pointed_thing.under)
		end
		solo = node.name
		
		if node.name == "default:dirt" then solo = "default:dirt_with_grass" end
		
		if node.name ~= "default:dirt_with_grass" then subsolo = node.name end
		
		local r = plagen.planificar(pointed_thing.under, "quadrada", 50, 15, {rocha="default:stone", subsolo=subsolo, solo=solo}, 15, true, true)
		
	end,
})]]
