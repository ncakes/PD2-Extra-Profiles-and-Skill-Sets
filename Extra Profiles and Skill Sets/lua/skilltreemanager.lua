--Unlock all skill sets if using autobind
Hooks:PostHook(SkillTreeManager, "load", "EPSS-PostHook-SkillTreeManager:load", function(self)
	if not EPSS.settings.autobind_skillsets then
		return
	end

	for i, switch_data in ipairs(self._global.skill_switches) do
		if not switch_data.unlocked then
			switch_data.unlocked = true
			switch_data.specialization = Application:digest_value(1, true)
		end
	end
end)
