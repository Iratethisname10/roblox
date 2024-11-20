local repoStore = game:GetService('ReplicatedStorage');
local players = game:GetService('Players');

local lplr = players.LocalPlayer
local attack = repoStore.Events.Attack;

local function getClosest()
	local root = lplr.Character and lplr.Character.PrimaryPart;
	if (not root) then return; end;

	local player, distance = nil, 20;

	for _, v in next, players:GetPlayers() do
		if (v == lplr) then continue; end;
		if (not v.Character) then continue; end;

		local otherRoot = v.Character.PrimaryPart;
		if (not otherRoot) then continue; end;

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

	local tool = lplr.Character:FindFirstChildOfClass('Tool');
	if (not tool) then task.wait(); continue; end;

	local toolHithox = tool:FindFirstChild('Hitbox');
	if (not toolHithox) then task.wait(); continue; end;

	local target = getClosest();
	if (not target or not target.Character) then task.wait(); continue; end;

	local targetRoot = target.Character.PrimaryPart;
	if (not targetRoot) then task.wait(); continue; end;

	local targetHum = target.Character.Humanoid;
	if (not targetHum) then task.wait(); continue; end;

	attack:FireServer(unpack({
		[1] = targetRoot,
		[2] = targetHum,
		[3] = 25,
		[4] = true,
		[5] = 'StabWoundInBody',
		[6] = false,
		[7] = true,
		[8] = 2,
		[9] = 'HitSound',
		[10] = toolHithox,
		[11] = 'Sharp'
	}));

	task.wait();
until _G.stop;
