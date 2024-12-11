local players = game:GetService('Players');
local replicatedStore = game:GetService('ReplicatedStorage');

local playerUi = players.LocalPlayer.PlayerGui;
local reelRemote = replicatedStore.events.reelfinished;

_G.autoreel = true;

repeat
	local reelUi = playerUi:FindFirstChild('reel');
	if (not reelUi) then task.wait(); continue; end;

	reelRemote:FireServer(100, false);

	task.wait();
until _G.autoreel == false;