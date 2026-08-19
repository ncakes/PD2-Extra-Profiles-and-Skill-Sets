--Add extra profiles
--skilltreetweakdata already updated EPSS._session_profiles if needed
function MultiProfileManager:_check_amount()
	--Change wanted amount
	local wanted_amount = EPSS._session_profiles
	if not self:current_profile() then
		self:save_current()
	end
	if wanted_amount < self:profile_count() then
		--If current profile OOB, load last profile then drop the rest
		if self._global._current_profile > wanted_amount then
			self._global._current_profile = wanted_amount
			self:load_current()
		end
		table.crop(self._global._profiles, wanted_amount)
	elseif wanted_amount > self:profile_count() then
		local prev_current = self._global._current_profile
		self._global._current_profile = self:profile_count()
		while wanted_amount > self._global._current_profile do
			self._global._current_profile = self._global._current_profile + 1
			self:save_current()
		end
		self._global._current_profile = prev_current
	end
end

--Display name prefix
local orig_MultiProfileManager_profile_name = MultiProfileManager.profile_name
function MultiProfileManager:profile_name(index)
	if EPSS.settings.number_prefix then
		local profile = self:profile(index)
		if profile then
			if not profile.name then
				return tostring(index)
			else
				return string.format("%d. %s", index, profile.name)
			end
		end
	end
	return orig_MultiProfileManager_profile_name(self, index)
end

--Bind skillset to profile if available
function MultiProfileManager:epss_bind_skillset(profile_idx)
	if not EPSS.settings.autobind_skillsets then
		return
	end

	--Save current profile before checking
	local is_current_profile = profile_idx == self:current_profile_index()
	if is_current_profile then
		self:save_current()
	end

	local profile_data = self:profile(profile_idx)
	if profile_data.skillset == profile_idx then
		return
	end

	local skt = managers and managers.skilltree
	if not skt then
		return
	end

	local switch_data = skt._global.skill_switches[profile_idx]
	if not switch_data.unlocked then
		return
	end
	if skt:is_skill_switch_suspended(switch_data) then
		return
	end

	profile_data.skillset = profile_idx
	profile_data.perk_deck = Application:digest_value(switch_data.specialization, false)

	if is_current_profile then
		self:load_current()
	end
end

function MultiProfileManager:epss_bind_all_skillsets()
	if not EPSS.settings.autobind_skillsets then
		return
	end

	for i = 1, #self._global._profiles do
		self:epss_bind_skillset(i)
	end
end

--Move skillsets when profiles are moved
Hooks:PostHook(MultiProfileManager, "move_profile", "EPSS-PostHook-MultiProfileManager:move_profile", function(self, old_index, new_index)
	if not EPSS.settings.autobind_skillsets then
		return
	end

	if new_index == old_index then
		return
	end

	local skill_switches = managers.skilltree._global.skill_switches
	local switch = skill_switches and skill_switches[old_index]
	if not switch then
		return
	end

	--Make sure current profile is saved
	self:save_current()

	--Move skillsets
	table.remove(skill_switches, old_index)
	table.insert(skill_switches, new_index, switch)

	local change_start = math.min(old_index, new_index)
	local change_end = math.max(old_index, new_index)

	--Get all affected skillsets
	--Create a map from old_idx -> new_idx
	local map = {}
	local offset = (new_index < old_index) and 1 or -1
	for i = change_start, change_end do
		if i == change_start and new_index > old_index then
			map[i] = new_index
		elseif i == change_end and new_index < old_index then
			map[i] = new_index
		else
			map[i] = i + offset
		end
	end

	--For each profile, update the skillset if it's in the map
	--Need to check all profiles because if a skillset is suspended the profile can use a random skillset
	for _, profile_data in pairs(self._global._profiles) do
		local i = profile_data.skillset
		profile_data.skillset = map[i] or i
	end

	--Reload current profile
	self:load_current()
end)

Hooks:PostHook(MultiProfileManager, "infamy_reset", "EPSS-PostHook-MultiProfileManager:infamy_reset", function(self)
	if EPSS.settings.autobind_skillsets then
		self:epss_bind_all_skillsets()
	end
end)
