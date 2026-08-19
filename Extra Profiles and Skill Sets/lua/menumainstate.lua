--Autobind when entering menu state instead of MultiProfileManager:load
--Need to check every time in case there were suspended skillsets, that became available
Hooks:PostHook(MenuMainState, "at_enter", "EPSS-PostHook-MenuMainState:at_enter", function(...)
	if EPSS.settings.autobind_skillsets then
		managers.multi_profile:epss_bind_all_skillsets()
	end
end)
