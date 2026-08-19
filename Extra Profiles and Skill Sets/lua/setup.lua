if _G.EPSS then return end

_G.EPSS = {}
EPSS.meta = {
	mod_path = ModPath,
	save_path = SavePath,
	menu_id = "epss_options_menu",
	menu_file = ModPath.."menu/options.json",
	save_file = SavePath.."extraprofiles_settings.txt",
}
dofile(ModPath.."lua/ncUtils.lua")

EPSS.settings = {
	total_profiles = 45,
	allow_fewer = false,
	autobind_skills_2 = false,--Legacy
	autobind_skillsets = false,
	number_prefix = false,
}
ncUtils:load_settings(EPSS)

--TEMP: Migrate legacy autobind setting name
if EPSS.settings.autobind_skills_2 then
	EPSS.settings.autobind_skillsets = true
end
EPSS.settings.autobind_skills_2 = nil
ncUtils:save_settings(EPSS)

--Copy settings so we can revert changes
EPSS._backup_settings = deep_clone(EPSS.settings)

--Cache session profiles. Make sure it's higher than base later.
EPSS._session_profiles = EPSS.settings.total_profiles
--Base game number of skill sets, get from skilltreetweakdata
--EPSS._base_num_profiles = ...
function EPSS:update_session_settings(base_num_profiles)
	self._base_num_profiles = base_num_profiles
	if self._session_profiles < base_num_profiles and not self.settings.allow_fewer then
		self._session_profiles = base_num_profiles
		self.settings.total_profiles = base_num_profiles
		ncUtils:save_settings(self)
		self._backup_settings = deep_clone(self.settings)
	end
end

Hooks:Add("LocalizationManagerPostInit", "EPSS-Hooks-LocalizationManagerPostInit", function(loc)
	loc:load_localization_file(EPSS.meta.mod_path.."localizations/english.json")
end)

Hooks:Add("MenuManagerInitialize", "EPSS-Hooks-MenuManagerInitialize", function(menu_manager)
	MenuCallbackHandler.epss_callback_slider_discrete = function(self, item)
		EPSS.settings[item:name()] = math.floor(item:value()+0.5)
	end

	MenuCallbackHandler.epss_callback_toggle = function(self, item)
		EPSS.settings[item:name()] = item:value() == "on"
		if item:name() == "allow_fewer" then
			EPSS:adjust_slider_min()
		end
	end

	MenuCallbackHandler.epss_callback_button = function(self, item)
		EPSS[item:name()](EPSS)
	end

	MenuCallbackHandler.epss_callback_save = function(self, item)
		EPSS:discard_changes()
	end

	MenuHelper:LoadFromJsonFile(EPSS.meta.menu_file, EPSS, EPSS.settings)
end)

function EPSS:adjust_slider_min()
	local item = ncUtils:get_menu_item("total_profiles", self)
	if item then
		if not self.settings.allow_fewer then
			item._min = self._base_num_profiles
		else
			item._min = 1
		end

		if item._value < item._min then
			item._value = item._min
			self.settings.total_profiles = item._value
		end

		item:dirty_callback()
	end
end

--WIP
function EPSS:commit_settings()
	--Settings cannot be changed while playing.
	if _G.game_state_machine:current_state_name() ~= "menu_main" then
		self:dialog_not_allowed()
		return
	end

	local settings_changed = false
	for k, _ in pairs(self.settings) do
		if self.settings[k] ~= self._backup_settings[k] then
			settings_changed = true
			break
		end
	end

	--No changes
	if not settings_changed then
		self:dialog_no_changes()
		return
	end

	local profiles_changed = self.settings.total_profiles ~= self._backup_settings.total_profiles
	local autobind_enabled = self.settings.autobind_skillsets and not self._backup_settings.autobind_skillsets
	local restart_required = profiles_changed or autobind_enabled

	--Save, no restart required
	if not restart_required then
		self:save_changes(false)
		return
	end

	--Confirmation
	self:commit_settings_confirmation()
end

--Settings cannot be changed while playing.
function EPSS:dialog_not_allowed()
	local menu_title = managers.localization:text("epss_dialog_title")
	local menu_message = managers.localization:text("epss_dialog_save_settings_blocked")
	local menu_options = {{text = managers.localization:text("dialog_ok"), is_cancel_button = true}}
	QuickMenu:new(menu_title, menu_message, menu_options, true)
end

--Settings not changed
function EPSS:dialog_no_changes()
	local menu_title = managers.localization:text("epss_dialog_title")
	local menu_message = managers.localization:text("epss_dialog_unchanged")
	local menu_options = {{text = managers.localization:text("dialog_ok"), is_cancel_button = true}}
	QuickMenu:new(menu_title, menu_message, menu_options, true)
end

function EPSS:commit_settings_confirmation()
	local menu_title = managers.localization:text("epss_dialog_title")
	local menu_message = ""

	--Number of profiles
	local new_num = self.settings.total_profiles
	local old_num = self._backup_settings.total_profiles
	if new_num ~= old_num then
		menu_message = menu_message..managers.localization:text("epss_dialog_number_profiles", {new_num=new_num, old_num=old_num})

		local operation = (new_num > old_num) and "add" or "rem"
		if math.abs(new_num - old_num) == 1 then
			local macros = {
				profile_num = math.max(old_num, new_num),
			}
			menu_message = menu_message.."\n\n"..managers.localization:text("epss_dialog_single_"..operation, macros)
		else
			local macros = {
				profile_min = math.min(old_num, new_num) + 1,
				profile_max = math.max(old_num, new_num),
			}
			menu_message = menu_message.."\n\n"..managers.localization:text("epss_dialog_multiple_"..operation, macros)
		end
	end

	--Autobind
	local warn_autobind = self.settings.autobind_skillsets and not self._backup_settings.autobind_skillsets
	if warn_autobind then
		if menu_message ~= "" then
			menu_message = menu_message .. "\n\n"
		end

		menu_message = menu_message..managers.localization:text("epss_dialog_autobind_enable")
	end

	menu_message = menu_message.."\n\n"..managers.localization:text("epss_dialog_ask_continue")

	local menu_options = {
		{
			text = managers.localization:text("dialog_continue"),
			callback = callback(self, self, "save_changes", true),
			is_focused_button = true,
		},
		{
			text = managers.localization:text("dialog_cancel"),
			is_cancel_button = true,
		}
	}
	QuickMenu:new(menu_title, menu_message, menu_options, true)
end

--Save and show message
function EPSS:save_changes(restart)
	ncUtils:save_settings(self)
	self._backup_settings = deep_clone(self.settings)

	local menu_title = managers.localization:text("epss_dialog_title")
	local menu_message = managers.localization:text("epss_dialog_saved")
	local menu_options

	if not restart then
		menu_options = {{text = managers.localization:text("dialog_ok"), is_cancel_button = true}}
	else
		menu_message = menu_message.."\n\n"..managers.localization:text("epss_dialog_restart")
		menu_options = {
			{
				text = managers.localization:text("dialog_yes"),
				callback = callback(MenuCallbackHandler, MenuCallbackHandler, "_dialog_quit_yes"),
				is_focused_button = true,
			},
			{
				text = managers.localization:text("dialog_no"),
				is_cancel_button = true,
			}
		}
	end
	QuickMenu:new(menu_title, menu_message, menu_options, true)
end

--Discard changes
function EPSS:discard_changes()
	self.settings = deep_clone(self._backup_settings)

	for k, _ in pairs(self.settings) do
		ncUtils:revert_menu_item_value(k, self)
	end

	self:adjust_slider_min()
end
