local version = 1

if _G.ncUtils and _G.ncUtils.version and _G.ncUtils.version >= version then
	return
end

_G.ncUtils = {
	version = version,
}

function ncUtils:save_json(path, data)
	local file = io.open(path, "w+")
	file:write(json.encode(data))
	file:close()
end

function ncUtils:load_json(path)
	local data
	local file = io.open(path, "r")
	if file then
		data = json.decode(file:read("*all"))
		file:close()
	end
	return data
end

function ncUtils:save_settings(Mod)
	local save_file = Mod and Mod.meta and Mod.meta.save_file
	local settings = Mod and Mod.settings
	if not save_file or not settings then
		return
	end

	self:save_json(save_file, settings)
end

--Mod.settings table should contain keys and default values
--Keys that are in the save file but are not in Mod.settings will not be loaded
function ncUtils:load_settings(Mod)
	local save_file = Mod and Mod.meta and Mod.meta.save_file
	local settings = Mod and Mod.settings
	if not save_file or not settings then
		return
	end

	local data = self:load_json(save_file) or {}
	for k, _ in pairs(Mod.settings) do
		if data[k] ~= nil then
			Mod.settings[k] = data[k]
		end
	end
end

function ncUtils:get_menu(Mod)
	local menu_id = Mod and Mod.meta and Mod.meta.menu_id
	local menu = menu_id and MenuHelper:GetMenu(menu_id)
	return menu
end

function ncUtils:get_menu_item(setting_id, Mod)
	local menu = self:get_menu(Mod)
	if not menu then
		return
	end
	for _, item in pairs(menu._items or {}) do
		local name = item._parameters and item._parameters.name
		if name == setting_id then
			return item
		end
	end
end

--Visually set a menu item value, does not modify settings
function ncUtils:set_menu_item_value(setting_id, value, Mod)
	local item = self:get_menu_item(setting_id, Mod)
	if not item then
		return
	end

	if item._type == "toggle" then
		item.selected = value and 1 or 2
		item:dirty_callback()
	elseif item._type == "slider" then
		item._value = value
		item:dirty_callback()
	elseif item._type == "multi_choice" then
		item._current_index = value
		item:dirty_callback()
	end
end

--Revert a menu item value to whatever is in Mod.settings
function ncUtils:revert_menu_item_value(setting_id, Mod)
	local item = self:get_menu_item(setting_id, Mod)
	if not item then
		return
	end

	if item._type == "toggle" then
		item.selected = Mod.settings[setting_id] and 1 or 2
		item:dirty_callback()
	elseif item._type == "slider" then
		item._value = Mod.settings[setting_id]
		item:dirty_callback()
	elseif item._type == "multi_choice" then
		item._current_index = Mod.settings[setting_id]
		item:dirty_callback()
	end
end

function ncUtils:disable_menu_item(setting_id, Mod)
	local item = self:get_menu_item(setting_id, Mod)
	if not item then
		return
	end

	item._enabled = false
	item:dirty_callback()
end

function ncUtils:enable_menu_item(setting_id, Mod)
	local item = self:get_menu_item(setting_id, Mod)
	if not item then
		return
	end

	item._enabled = true
	item:dirty_callback()
end

--Get the name (text_id) of the current multiple choice setting
function ncUtils:get_multi_choice_name(setting_id, Mod)
	local item = self:get_menu_item(setting_id, Mod)
	if not item then
		return
	end

	if item._type ~= "multi_choice" then
		return
	end

	local value = Mod.settings[setting_id]
	local option = value and item._options and item._options[value]
	local option_name = option and option._parameters and option._parameters.text_id

	return option_name
end
