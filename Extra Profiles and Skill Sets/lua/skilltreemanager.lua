--Automatically unlock added skill sets
Hooks:PostHook(SkillTreeManager, "load", "EPSS-PostHook-SkillTreeManager:load", function(self)
	for i, switch_data in ipairs(self._global.skill_switches) do
		switch_data.unlocked = true
	end
end)
