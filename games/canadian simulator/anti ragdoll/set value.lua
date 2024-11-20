local players = game:GetService('Players');
local lplr = players.LocalPlayer;

repeat
	local things = lplr.Character and lplr.Character:FindFirstChild('PlayerThings');
	if (not things) then task.wait(); continue; end;

	local downed = things:FindFirstChild('Downed');
	if (not downed) then task.wait(); continue; end;

	local forcedDown = things:FindFirstChild('FORCEDDOWN');
	if (not forcedDown) then task.wait(); continue; end;

	local v = things:FindFirstChild('V');
	if (not v) then task.wait(); continue; end;

	if (forcedDown.Value) then forcedDown.Value = false; end;
	if (v.Value) then v.Value = false; end;
	if (downed.Value) then downed.Value = false; end;

	task.wait();
until _G.stop;