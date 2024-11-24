-- // get the boar hunting job first
-- // cant find out how to make you get the job
-- // sry ><

local repoStore = game:GetService('ReplicatedStorage');
local players = game:GetService('Players');

local lplr = players.LocalPlayer
local attack = repoStore.Events.Attack;

local function getBoar()
	local root = lplr.Character and lplr.Character.PrimaryPart;
	if (not root) then return; end;

	local bRoot, bHum, distance = nil, nil, math.huge;

	for _, v in next, workspace:GetChildren() do
		if (v.Name:sub(1, 8) ~= 'testboar') then continue; end;

		local otherHum = v:FindFirstChildOfClass('Humanoid');
		if (not otherHum) then continue; end;

		local otherRoot = v:FindFirstChild('HumanoidRootPart');
		if (not otherRoot) then continue; end;

		local dead = v:FindFirstChild('deadanimal');
		if (not dead or dead.Value) then continue; end;

		local magnitude = (root.CFrame.Position - otherRoot.CFrame.Position).Magnitude;
		if (magnitude < distance) then
			bRoot, bHum = otherRoot, otherHum;
			distance = magnitude;
		end;
	end;

	return bRoot, bHum;
end;

repeat
	local root = lplr.Character and lplr.Character:FindFirstChild('HumanoidRootPart');
	if (not root) then task.wait(); continue; end;

	local tool = lplr.Character:FindFirstChild('Fists');
	if (not tool) then task.wait(); continue; end;

	local toolHithox = tool:FindFirstChild('Hitbox');
	if (not toolHithox) then task.wait(); continue; end;

	local targetRoot, targetHum = getBoar();
	if (not targetRoot or not targetHum) then task.wait(); continue; end;

	root.CFrame = targetRoot.CFrame;

	attack:FireServer(unpack({
		[1] = targetRoot,
		[2] = targetHum,
		[3] = 7,
		[4] = false,
		[5] = 'None',
		[6] = false,
		[7] = true,
		[8] = 1,
		[9] = 'HitSound',
		[10] = toolHithox,
		[11] = 'Blunt'
	}));

	task.wait();
until _G.stop;
