local repoStore = game:GetService('ReplicatedStorage');
local players = game:GetService('Players');

local lplr = players.LocalPlayer;

local net = repoStore.Modules.Net;

local punch = repoStore.PUNCHEVENT;
local pullHair = repoStore.JALADADEPELOEVENT;
local stopSignHit = net['RE/stopsignalHit'];

local stomp = repoStore.STOMPEVENT;

local function getClosest()
	local root = lplr.Character and lplr.Character.PrimaryPart;
	if (not root) then return; end;

	local player, distance = nil, 8;

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

	local target = getClosest();
	if (not target or not target.Character) then task.wait(); continue; end;

	local targetRoot = target.Character.PrimaryPart;
	if (not targetRoot) then task.wait(); continue; end;

	local dir = Vector3.new(targetRoot.CFrame.Position.X - root.CFrame.Position.X, 0, targetRoot.CFrame.Position.Z - root.CFrame.Position.Z).Unit;
	root.CFrame = CFrame.new(root.CFrame.Position, root.CFrame.Position + dir);

	pullHair:FireServer();
	punch:FireServer(1);
	stopSignHit:FireServer(1);

	if (target.Character.Humanoid.Health <= 2) then
		stomp:FireServer();
	end;

	task.wait();
until _G.stop;