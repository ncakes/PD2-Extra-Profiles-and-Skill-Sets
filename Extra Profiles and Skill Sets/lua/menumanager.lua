Hooks:PostHook(MenuManager, "init", "EPSS-PostHook-MenuManager:init", function(...)
	local item = EPSS:get_menu_item("total_profiles_deferred")
	if not EPSS.settings.allow_fewer then
		item._min = EPSS._base_num_profiles
	else
		item._min = 1
	end
	--Adjust slider max if someone manually edited their save
	if EPSS.settings.total_profiles_deferred > item._max then
		item._max = EPSS.settings.total_profiles_deferred
		item._value = EPSS.settings.total_profiles_deferred
	end
end)
