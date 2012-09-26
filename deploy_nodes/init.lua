--[[

Deploy Nodes for Minetest

Copyright (c) 2012 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-deploy_nodes
License: GPLv3

MAIN LOADER

]]--

-- expose api
deploy_nodes = {}

-- check for non-air blocks before deploying structure
deploy_nodes.check_for_space = true

-- blueprint
minetest.register_craftitem("deploy_nodes:blueprint", {
	description = "Empty Blueprint",
	inventory_image = "deploy_nodes_blueprint.png",
})
minetest.register_craft({
	output = "deploy_nodes:blueprint",
	recipe = {{"default:paper", "default:coal_lump", "default:stick"}},
})

-- log that we started
minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- loaded from "..minetest.get_modpath(minetest.get_current_modname()))
