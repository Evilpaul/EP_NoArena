local EPNoArena = CreateFrame("Frame")
EPNoArena:RegisterEvent("ARENA_TEAM_INVITE_REQUEST")
EPNoArena:RegisterEvent("PETITION_SHOW")

local arenaDeclineMessage = "This is an automated message, all arena invitations will be declined"

function EPNoArena:MessageOutput(inputMessage)
	ChatFrame1:AddMessage("|cffDAFF8A[No Arena]|r " .. inputMessage)
end

function EPNoArena:DeclineArenaInvite()

	-- automatically decline
	DeclineArenaTeam()

	-- The popup is shown, make sure it goes away
	for i = 1, STATICPOPUP_NUMDIALOGS do
		local popup = _G["StaticPopup" .. i]

		if popup and
		   popup:IsVisible() and
		   popup.which == "ARENA_TEAM_INVITE" then
			popup:Hide()
		end
	end

	-- report to user
	self:MessageOutput(string.format("Declined invitation from %s to join %s", arg1, arg2))

	-- tell the idiot
	SendChatMessage(arenaDeclineMessage, "WHISPER", nil, arg1)
end

function EPNoArena:DeclineArenaPetition(arenaName, originator, isOriginator)

	-- automatically decline the petition
	ClosePetition()

	if isOriginator == true then
		-- report to user
		self:MessageOutput(string.format("Declined arena petition from %s to join %s", originator, arenaName))

		-- tell the idiot
		SendChatMessage(arenaDeclineMessage, "WHISPER", nil, arg1)
	else
		-- report to user
		self:MessageOutput(string.format("Declined arena petition to join %s", arenaName))
	end
end

function EPNoArena:FilterPetition()
	local petitionType, title, _, _, originator, isOriginator, _ = GetPetitionInfo()

	-- we do not care about guild, or other, petitions
	if petitionType == "arena" then
		self:DeclineArenaPetition(title, originator, isOriginator)
	end
end

EPNoArena:SetScript("OnEvent", function(self, event, ...)
	if (event == "ARENA_TEAM_INVITE_REQUEST") then
		self:DeclineGuildInvite()
	elseif (event == "PETITION_SHOW") then
		self:FilterPetition()
	end
end)

-- filter out our responses
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", function(_, _, msg, player)
	if msg == arenaDeclineMessage then return true; end; -- filter out the reply whisper
end)
