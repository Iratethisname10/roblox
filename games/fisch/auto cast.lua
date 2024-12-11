local players = game:GetService('Players');
local character = players.LocalPlayer.Character;

_G.autocast = true;

repeat
	local rod = character:FindFirstChildOfClass('Tool');
	if (not rod) then task.wait(); continue; end;

	local values = rod:FindFirstChild('values');
	if (not values) then task.wait(); continue; end;

	local casted = values:FindFirstChild('values');
	if (not casted or casted.Value == true) then task.wait(); continue; end;

	local events = rod:FindFirstChild('events');
	if (not events) then task.wait(); continue; end;

	local remote = events:FindFirstChild('cast');
	if (not remote) then task.wait(); continue; end;

	remote:FireServer(math.random(90, 100));

	task.wait();
until _G.autocast == false;