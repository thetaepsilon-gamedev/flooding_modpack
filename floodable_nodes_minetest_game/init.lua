local patch_node = function(nodename)
	print(nodename)
	local def = minetest.registered_nodes[nodename]
	if not def then
		return
	end
	minetest.override_item(nodename, {
		floodable = true,
		on_flood = minetest.on_flood_drop_self,
	})
end

local targets = {
	"default:torch",
	"default:torch_wall",
	"default:torch_ceiling",
}
local extra_targets = {}
local add = function(n)
	extra_targets[n] = true
end

-- farming wheat
for i = 1, 8, 1 do
	add("farming:wheat_"..i)
end





for i, n in ipairs(targets) do
	patch_node(n)
end
for n, _ in pairs(extra_targets) do
	patch_node(n)
end
