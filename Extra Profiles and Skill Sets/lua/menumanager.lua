Hooks:PostHook(MenuManager, "init", "EPSS-PostHook-MenuManager:init", function(...)
	--Slider minimum is either 1 or base game number of profiles.
	EPSS:adjust_slider_min()

	--Adjust slider max if someone manually edited their save
	local item = ncUtils:get_menu_item("total_profiles", EPSS)
	if item then
		if EPSS._session_profiles > item._max then
			item._max = EPSS._session_profiles
			item._value = EPSS._session_profiles
		end
	end
end)

--Not allowed to switch skill sets if not suspended
local orig_MenuCallbackHandler_set_active_skill_switch = MenuCallbackHandler.set_active_skill_switch
function MenuCallbackHandler:set_active_skill_switch(item)
	if EPSS.settings.autobind_skillsets then
		local profile_idx = managers.multi_profile:current_profile_index()
		local switch_data = managers.skilltree._global.skill_switches[profile_idx]
		if switch_data and switch_data.unlocked and not managers.skilltree:is_skill_switch_suspended(switch_data) then
			local menu_title = managers.localization:text("epss_dialog_title")
			local menu_message = managers.localization:text("epss_dialog_skill_switch_blocked")
			local menu_options = {{text = managers.localization:text("dialog_ok"), is_cancel_button = true}}
			QuickMenu:new(menu_title, menu_message, menu_options, true)
			return
		end
	end
	orig_MenuCallbackHandler_set_active_skill_switch(self, item)
end

--Auto-equip on unsuspend
local orig_MenuCallbackHandler_unsuspend_skill_switch_dialog_yes = MenuCallbackHandler.unsuspend_skill_switch_dialog_yes
function MenuCallbackHandler:unsuspend_skill_switch_dialog_yes(skill_switch)
	orig_MenuCallbackHandler_unsuspend_skill_switch_dialog_yes(self, skill_switch)

	if EPSS.settings.autobind_skillsets then
		managers.multi_profile:epss_bind_skillset(skill_switch)
	end
end
