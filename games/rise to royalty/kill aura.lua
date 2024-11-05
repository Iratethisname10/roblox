-- // you have to hold "Punch" i think

local repoStore = game:GetService('ReplicatedStorage');
local players = game:GetService('Players');

local lplr = players.LocalPlayer;

local remote = repoStore.Events.Stats;

local function getClosest()
	local root = lplr.Character and lplr.Character.PrimaryPart;
	if (not root) then return; end;

	local player, distance = nil, 17;

	for _, v in next, players:GetPlayers() do
		if (v == lplr) then continue; end;
		if (not v.Character) then continue; end;

		local otherRoot = v.Character.PrimaryPart;
		if (not otherRoot) then continue; end;

		local sheild = v.Character:FindFirstChildOfClass('ForceField');
		if (sheild) then continue; end;

		local otherHum = v.Character:FindFirstChildOfClass('Humanoid');
		if (not otherHum) then continue; end;

		local magnitude = (root.CFrame.Position - otherRoot.CFrame.Position).Magnitude;
		if (magnitude < distance) then
			player = v;
			distance = magnitude;
		end;
	end;

	return player;
end;

repeat
	local root = lplr.Character and lplr.Character.PrimaryPart;
	if (not root) then task.wait(); continue; end;

	local target = getClosest();
	if (not target or not target.Character) then task.wait(); continue; end;

	remote:FireServer('PunchTarget', target.Character);

	task.wait();
until _G.stop;