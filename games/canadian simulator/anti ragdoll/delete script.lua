-- // make sure to only run this when you are not ragdolled

local players = game:GetService('Players');
local lplr = players.LocalPlayer;

repeat
	local things = lplr.Character and lplr.Character:FindFirstChild('PlayerThings');
	if (not things) then task.wait(); continue; end;

	local handler = things:FindFirstChild('RagdollValuesHandler');
	if (not handler) then task.wait(); continue; end;

	handler:Destroy();

	task.wait();
until _G.stop;