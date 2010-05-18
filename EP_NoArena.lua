local format = string.format

local EPNoArena = CreateFrame('Frame')
EPNoArena:RegisterEvent('ARENA_TEAM_INVITE_REQUEST')
EPNoArena:RegisterEvent('PETITION_SHOW')

local arenaDeclineMessage = 'This is an automated message, all arena invitations will be declined'

function EPNoArena:MessageOutput(inputMessage)
	ChatFrame1:AddMessage(format('|cffDAFF8A[No Arena]|r %s', inputMessage))
end

function EPNoArena:ARENA_TEAM_INVITE_REQUEST(event, originator, arenaTeamName)

	-- automatically decline
	DeclineArenaTeam()

	-- The popup is shown, make sure it goes away
	for i = 1, STATICPOPUP_NUMDIALOGS do
		local popup = _G['StaticPopup' .. i]

		if popup and
		   popup:IsVisible() and
		   popup.which == 'ARENA_TEAM_INVITE' then
			popup:Hide()
		end
	end

	-- report to user
	self:MessageOutput(format('Declined invitation from %s to join %s', originator, arenaTeamName))

	-- tell the idiot
	SendChatMessage(arenaDeclineMessage, 'WHISPER', nil, originator)
end

function EPNoArena:PETITION_SHOW(event)
	local petitionType, title, _, _, originator, isOriginator, _ = GetPetitionInfo()

	-- we do not care about guild, or other, petitions
	if petitionType == 'arena' then

		-- automatically decline the petition
		ClosePetition()

		if isOriginator == true then
			-- report to user
			self:MessageOutput(format('Declined arena petition from %s to join %s', originator, title))

			-- tell the idiot
			SendChatMessage(arenaDeclineMessage, 'WHISPER', nil, originator)
		else
			-- report to user
			self:MessageOutput(format('Declined arena petition to join %s', title))
		end
	end
end

EPNoArena:SetScript('OnEvent', function(self, event, ...)
	self[event](self, event, ...)
end)

-- filter out our responses
ChatFrame_AddMessageEventFilter('CHAT_MSG_WHISPER_INFORM', function(_, _, msg, _)
	if msg == arenaDeclineMessage then return true end
end)
