local players = game:GetService('Players');
local me = players.LocalPlayer;

local remote = me.Character.C4.Place;

for _, v in next, players:GetPlayers() do
	if (v == me) then continue; end;
	if (not v.Character) then continue; end;
	if (not v.Character:FindFirstChild('HumanoidRootPart')) then continue; end;

	remote:FireServer(unpack({
		[1] = CFrame.new(math.huge, -math.huge, math.huge),
		[2] = v.Character.HumanoidRootPart
	}));
end;