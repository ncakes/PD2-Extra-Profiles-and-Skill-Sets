--More characters for profile names
Hooks:PostHook(MultiProfileItemGui, "init", "EPSS-PostHook-MultiProfileItemGui:init", function(self, ...)
	self._max_length = 30
	self:update()
end)

--Display number before profile name
Hooks:PreHook(MultiProfileItemGui, "trigger", "EPSS-PreHook-MultiProfileItemGui:trigger", function(self, ...)
	if not EPSS.settings.number_prefix then
		return
	end

	if not self._editing then
		local mult = managers.multi_profile
		if not mult then
			return
		end
		if mult:current_profile() then
			self._name_text:set_text(mult:current_profile().name or "")
		end
	end
end)

Hooks:PostHook(MultiProfileItemGui, "trigger", "EPSS-PostHook-MultiProfileItemGui:trigger", function(self, ...)
	if not EPSS.settings.number_prefix then
		return
	end

	if not self._editing then
		local mult = managers.multi_profile
		if not mult then
			return
		end
		if mult:current_profile() and self._name_text:text() == "" then
			mult:current_profile().name = nil
		end
		self._name_text:set_text(mult:current_profile_name())
	end
end)
