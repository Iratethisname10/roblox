local players = game:GetService('Players');
local playerUi = players.LocalPlayer.PlayerGui;

while (true) do
	local shakeUi = playerUi:FindFirstChild('shakeui');
	if (not shakeUi) then task.wait(); continue; end;

	local buttonArea = shakeUi:FindFirstChild('safezone');
	if (not buttonArea) then task.wait(); continue; end;

	local button = buttonArea:FindFirstChild('button');
	if (not button) then task.wait(); continue; end;

	for _, v in next, getconnections(button.MouseButton1Click) do
		if (not v.Function) then continue; end;
		v.Function();
	end;

	task.wait();
end;