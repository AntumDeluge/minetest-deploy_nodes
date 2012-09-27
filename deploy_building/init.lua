--[[

Deploy Nodes for Minetest

Copyright (c) 2012 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-deploy_nodes
License: GPLv3

Shape based on livehouse mod by neko259: http://minetest.net/forum/viewtopic.php?id=1675

BUILDING

]]--


-- expose api
deploy_building = {}


-- get_files
deploy_building.get_files = function(size)
	local directory = minetest.get_modpath("deploy_building").."/buildings/"..size
	local command = 'dir "'..directory..'\\*.we" /b' -- windows
	if os.getenv('home')~=nil then 
		command = 'ls -a "'..directory..'/*.we"' -- linux/mac
	end
    local i, t, popen = 0, {}, io.popen
    for filename in popen(command):lines() do
        i = i + 1
        t[i] = filename
    end
    return t
end


-- deploy
deploy_building.deploy = function(originpos, placer, size)

	-- load building data
	local files = deploy_building.get_files(size)
	local filepath = minetest.get_modpath("deploy_building").."/buildings/"..size.."/"..files[math.random(#files)]
	local file, err = io.open(filepath, "rb")
	if err ~= nil then
		minetest.chat_send_player(placer:get_player_name(), "[deploy_building] error: could not open file \"" .. filepath .. "\"")
		return
	end
	local contents = file:read("*a")
	file:close()
	
	-- check for space
	if deploy_nodes.check_for_space==true then
		local minpos = {x=0,y=0,z=0}
		local maxpos = {x=0,y=0,z=0}
		for x, y, z, name, param1, param2 in contents:gmatch("([+-]?%d+)%s+([+-]?%d+)%s+([+-]?%d+)%s+([^%s]+)%s+(%d+)%s+(%d+)[^\r\n]*[\r\n]*") do
			x = tonumber(x)
			y = tonumber(y)
			z = tonumber(z)
			if x < minpos.x then minpos.x = x end
			if y < minpos.y then minpos.y = y end
			if z < minpos.z then minpos.z = z end
			if x > maxpos.x then maxpos.x = x end
			if y > maxpos.y then maxpos.y = y end
			if z > maxpos.z then maxpos.z = z end
		end
		for x=minpos.x,maxpos.x do
		for y=minpos.y,maxpos.y do
		for z=minpos.z,maxpos.z do
			if x~=0 or y~=0 or z~=0 then
			local checkpos = {x=originpos.x+x,y=originpos.y+y,z=originpos.z+z}
			local checknode = minetest.env:get_node(checkpos).name
				if checknode~="air" then
					minetest.chat_send_player(placer:get_player_name(), "[deploy_building] no room to build because "..checknode.." is in the way at "..dump(checkpos).."")
					return
				end
			end
		end
		end
		end
	end
	
	-- remove building node
	minetest.env:remove_node(originpos)
	
	-- create building
	local pos = {x=0, y=0, z=0}
	local node = {name="", param1=0, param2=0}
	for x, y, z, name, param1, param2 in contents:gmatch("([+-]?%d+)%s+([+-]?%d+)%s+([+-]?%d+)%s+([^%s]+)%s+(%d+)%s+(%d+)[^\r\n]*[\r\n]*") do
		pos.x = originpos.x + tonumber(x)
		pos.y = originpos.y + tonumber(y)
		pos.z = originpos.z + tonumber(z)
		node.name = name
		node.param1 = param1
		node.param2 = param2
		minetest.env:add_node(pos, node)
	end
	
end


-- small
minetest.register_node("deploy_building:small", {
    description = "Small Building",
    tiles = {"default_wood.png^deploy_building_small.png"},
    groups = {dig_immediate=3},
	after_place_node = function(pos,placer)
		deploy_building.deploy(pos,placer,"small")
	end,
})
minetest.register_craft({
    output = "deploy_building:small",
    recipe = {
		{"deploy_building:blueprint", "default:wood", "default:stone"},
    },
})

-- medium
minetest.register_node("deploy_building:medium", {
    description = "Medium Building",
    tiles = {"default_wood.png^deploy_building_medium.png"},
    groups = {dig_immediate=3},
	after_place_node = function(pos,placer)
		deploy_building.deploy(pos,placer,"medium")
	end,
})
minetest.register_craft({
    output = "deploy_building:medium",
    recipe = {
		{"deploy_building:blueprint", "deploy_building:small", "deploy_building:small"},
    },
})

-- large
minetest.register_node("deploy_building:large", {
    description = "Large Building",
    tiles = {"default_wood.png^deploy_building_large.png"},
    groups = {dig_immediate=3},
	after_place_node = function(pos,placer)
		deploy_building.deploy(pos,placer,"large")
	end,
})
minetest.register_craft({
    output = "deploy_building:large",
    recipe = {
		{"deploy_building:blueprint", "deploy_building:medium", "deploy_building:medium"},
    },
})

-- blueprint
minetest.register_craftitem("deploy_building:blueprint", {
	description = "Building Blueprint",
	inventory_image = "deploy_building_blueprint.png",
})
minetest.register_craft({
	output = "deploy_building:blueprint",
	recipe = {
		{"deploy_nodes:blueprint", "", "deploy_nodes:blueprint"},
		{"deploy_nodes:blueprint", "deploy_nodes:blueprint", "deploy_nodes:blueprint"},
		{"deploy_nodes:blueprint", "deploy_nodes:blueprint", "deploy_nodes:blueprint"},
	},
})

-- log that we started
minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- loaded from "..minetest.get_modpath(minetest.get_current_modname()))
