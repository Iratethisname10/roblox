local function getScript(url)
	if (type(url) ~= 'string') then return warn('getscript failed 1'); end;

	local baseUrl = 'https://raw.githubusercontent.com/Iratethisname10/roblox/refs/heads/main/helpers/';
	local suc, res = pcall(function() return game:HttpGet(string.format('%s%s.lua', baseUrl, url)); end);
	if (not suc or table.find({'404: Not Found', '400: Invalid Request'}, res)) then return warn('getscript failed 2'); end;

	local fun, err = loadstring(res, url);
	if (not fun) then return warn('getscript syntax err', err); end;

	return fun();
end;

local Maid = getScript('maid');

local cloneref = cloneref or function(inst) return inst; end;

local players = cloneref(game:GetService('Players'));
local runService = cloneref(game:GetService('RunService'));
local inputService = cloneref(game:GetService('UserInputService'));
local lighting = cloneref(game:GetService('Lighting'));

local lplr = players.localPlayer;
local cam = workspace.CurrentCamera;

local maid = Maid.new();

local basics = {};

function basics.speed(t, speed, noVelo)
	if (not t) then
		maid.speed = nil;

		local root = lplr.Character and lplr.Character.PrimaryPart;
		if (root) then
			root.AssemblyLinearVelocity = Vector3.zero;
			root.AssemblyAngularVelocity = Vector3.zero;
		end;

		return;
	end;

	maid.speed = runService.Heartbeat:Connect(function(dt)
		local root = lplr.Character and lplr.Character.PrimaryPart;
		if (not root) then return; end;

		local hum = lplr.Character:FindFirstChildOfClass('Humanoid');
		if (not hum) then return; end;

		if (noVelo) then
			root.AssemblyLinearVelocity *= Vector3.yAxis;
			root.AssemblyAngularVelocity *= Vector3.yAxis;
		end;

		local moveDir = hum.MoveDirection;
		root.CFrame += Vector3.new(moveDir.X, 0, moveDir.Z) * speed * dt;
	end);
end;

function basics.speedVelo(t, speed)
	if (not t) then
		maid.speedVelo = nil;

		local root = lplr.Character and lplr.Character.PrimaryPart;
		if (root) then
			root.AssemblyLinearVelocity = Vector3.zero;
			root.AssemblyAngularVelocity = Vector3.zero;
		end;

		return;
	end;

	maid.speedVelo = runService.Heartbeat:Connect(function()
		local root = lplr.Character and lplr.Character.PrimaryPart;
		if (not root) then return; end;

		local hum = lplr.Character:FindFirstChildOfClass('Humanoid');
		if (not hum) then return; end;

		local moveDir = hum.MoveDirection;
		local preVelo = root.AssemblyLinearVelocity;
		root.AssemblyLinearVelocity = Vector3.new(moveDir.X * speed, preVelo.Y, moveDir.Z * speed);
	end);
end;

function basics.fly(t, speed, noVelo, useMover)
	if (not t) then
		maid.fly = nil;
		maid.mover = nil;

		local root = lplr.Character and lplr.Character.PrimaryPart;
		if (root) then
			root.AssemblyLinearVelocity = Vector3.zero;
			root.AssemblyAngularVelocity = Vector3.zero;
		end;

		return;
	end;

	local vertical = 0;

	maid.fly = runService.Heartbeat:Connect(function(dt)
		local root = lplr.Character and lplr.Character.PrimaryPart;
		if (not root) then return; end;

		local hum = lplr.Character:FindFirstChildOfClass('Humanoid');
		if (not hum) then return; end;

		if (inputService:IsKeyDown(Enum.KeyCode.Space) and not inputService:GetFocusedTextBox()) then
			vertical = 1;
		elseif (inputService:IsKeyDown(Enum.KeyCode.LeftControl) and not inputService:GetFocusedTextBox()) then
			vertical = -1;
		else
			vertical = 0;
		end;

		if (noVelo) then
			root.AssemblyLinearVelocity = Vector3.zero;
			root.AssemblyAngularVelocity = Vector3.zero;
		end;

		local moveDir = hum.MoveDirection;

		if (useMover) then
			maid.mover = maid.mover or Instance.new('BodyVelocity');
			maid.mover.MaxForce = Vector3.one * math.huge;
			maid.mover.Velocity = Vector3.new(moveDir.X, vertical, moveDir.Z) * speed * dt;
			maid.mover.Parent = root;
		end;

		root.CFrame += Vector3.new(moveDir.X, vertical, moveDir.Z) * speed * dt;
	end)
end;

function basics.flyVelo(t, speed)
	if (not t) then
		maid.flyVelo = nil;

		local root = lplr.Character and lplr.Character.PrimaryPart;
		if (root) then
			root.AssemblyLinearVelocity = Vector3.zero;
			root.AssemblyAngularVelocity = Vector3.zero;
		end;

		return;
	end;

	local vertical = 0;

	maid.flyVelo = runService.Heartbeat:Connect(function()
		local root = lplr.Character and lplr.Character.PrimaryPart;
		if (not root) then return; end;

		local hum = lplr.Character:FindFirstChildOfClass('Humanoid');
		if (not hum) then return; end;

		if (inputService:IsKeyDown(Enum.KeyCode.Space) and not inputService:GetFocusedTextBox()) then
			vertical = 1;
		elseif (inputService:IsKeyDown(Enum.KeyCode.LeftControl) and not inputService:GetFocusedTextBox()) then
			vertical = -1;
		else
			vertical = 0;
		end;

		local moveDir = hum.MoveDirection;

		root.AssemblyLinearVelocity = Vector3.new(moveDir.X, vertical, moveDir.Z) * speed;
	end)
end;

function basics.noclip(t, instRevert)
	if (not t) then
		maid.noclip = nil;

		local hum = lplr.Character and lplr.Character:FindFirstChildOfClass('Humanoid');
		if (hum and instRevert) then
			hum:ChangeState('Physics');
			task.wait();
			hum:ChangeState('RunningNoPhysics');
		end;

		return;
	end;

	maid.noclip = runService.Heartbeat:Connect(function()
		local parts = lplr.Character and lplr.Character:GetDescendants();
		for _, v in next, parts do
			if (not v:IsA('BasePart')) then continue; end;
			if (not v.CanCollide) then continue; end;

			v.CanCollide = false;
		end;
	end);
end;

local moddedParts = {};
function basics.noclipParts(t)
	if (not t) then
		maid.noclipParts = nil;
		for i in next, moddedParts do if (i) then i.CanCollide = true; end; end;
		table.clear(moddedParts);
		return;
	end;

	local overlap = OverlapParams.new()
	overlap.MaxParts = 9e9
	overlap.FilterDescendantsInstances = {}

	maid.noclipParts = runService.Heartbeat:Connect(function()
		local root = lplr.Character and lplr.Character.PrimaryPart;
		if (not root) then return; end;

		local hum = lplr.Character:FindFirstChildOfClass('Humanoid');
		if (not hum) then return; end;

		local ignore = {cam, lplr.Character};
		for _, v in next, players:GetPlayers() do table.insert(ignore, v.Character); end;
		overlap.FilterDescendantsInstances = ignore;

		local pos = root.CFrame.Position;
		local parts = workspace:GetPartBoundsInRadius(pos, 2, overlap);

		for _, v in next, parts do
			if (not v.CanCollide) then continue; end;
			if ((v.Position.Y + (v.Size.Y / 2)) < (pos.Y - hum.HipHeight)) then continue; end;

			moddedParts[v] = true;
			v.CanCollide = false;
		end;

		for i in next, moddedParts do
			if (table.find(parts, i)) then continue; end;
			moddedParts[i] = nil;
			i.CanCollide = true;
		end;
	end);
end;

function basics.infJump(t)
	if (not t) then
		maid.infJump = nil;
		return;
	end;

	maid.infJump = runService.Heartbeat:Connect(function()
		local root = lplr.Character and lplr.Character.PrimaryPart;
		if (not root or not inputService:IsKeyDown(Enum.KeyCode.Space) or inputService:GetFocusedTextBox()) then return; end;

		local oldVelo = root.AssemblyLinearVelocity;
		root.AssemblyLinearVelocity = Vector3.new(oldVelo.X, 50, oldVelo.Z);
	end);
end;

function basics.spinBot(t)
	if (not t) then
		maid.antiAim = nil;
		return;
	end;

	maid.antiAim = runService.Heartbeat:Connect(function(dt)
		local root = lplr.Character and lplr.Character.PrimaryPart;
		if (not root) then return; end;

		root.CFrame *= CFrame.Angles(0, 150 * dt, 0);
	end);
end;

local oldAmbient, oldBrightness;
function basics.fullBright(t)
	if (not t) then
		maid.fullBright = nil;

		if (oldAmbient) then lighting.Ambient = oldAmbient; end;
		if (oldBrightness) then lighting.Brightness = oldBrightness; end;
		return;
	end;

	oldAmbient, oldBrightness = lighting.Ambient, lighting.Brightness;
	maid.fullBright = lighting:GetPropertyChangedSignal('Ambient'):Connect(function()
		oldAmbient, oldBrightness = lighting.Ambient, lighting.Brightness;

		lighting.Ambient = Color3.fromRGB(255, 255, 255);
		lighting.Brightness = 1;
	end);

	lighting.Ambient = Color3.fromRGB(255, 255, 255);
	lighting.Brightness = 1;
end;

local oldFov;
function basics.fovChanger(t, fov)
	if (not t) then
		maid.fovChanger = nil;

		if (oldFov) then cam.FieldOfView = oldFov; end;
		return;
	end;

	oldFov = cam.FieldOfView;
	maid.fovChanger = runService.RenderStepped:Connect(function()
		cam.FieldOfView = fov;
	end);
end;

function basics.closeToMouse(fov, part, wallCheck, teamCheck, aliveCheck)
	local player, distance = nil, fov;

	for _, v in next, players:getPlayers() do
		if (v == lplr) then continue; end;

		local char = v.Character;
		if (not char) then continue; end;

		local hum = char:FindFirstChildOfClass('Humanoid');
		if (not hum) then continue; end;

		local targetPart = char:FindFirstChild(part);
		if (not targetPart) then continue; end;

		if (wallCheck and basics.behindWall(v, targetPart)) then continue; end;
		if (teamCheck and basics.isTeam(v)) then continue; end;
		if (aliveCheck and hum.Health <= 0) then continue; end;

		local vector, inViewport = cam:WorldToViewportPoint(targetPart.CFrame.Position);
		local magnitude = (inputService:GetMouseLocation() - Vector2.new(vector.X, vector.Y)).Magnitude;

		if (magnitude <= distance and inViewport) then
			distance = magnitude;
			player = v;
		end;
	end;

	return player;
end;

function basics.closeToCharacter(dist, part, wallCheck, teamCheck, aliveCheck)
	local player, distance = nil, dist;

	local root = lplr.Character and lplr.Character.PrimaryPart;
	if (not root) then return {Character = nil}; end;

	for _, v in next, players:getPlayers() do
		if (v == lplr) then continue; end;

		local char = v.Character;
		if (not char) then continue; end;

		local hum = char:FindFirstChildOfClass('Humanoid');
		if (not hum) then continue; end;

		local targetPart = char:FindFirstChild(part);
		if (not targetPart) then continue; end;

		if (wallCheck and basics.behindWall(v, targetPart)) then continue; end;
		if (teamCheck and basics.isTeam(v)) then continue; end;
		if (aliveCheck and hum.Health <= 0) then continue; end;

		local magnitude = (root.CFrame.Position - targetPart.CFrame.Position).Magnitude;
		if (magnitude <= distance) then
			distance = magnitude;
			player = v;
		end;
	end;

	return player;
end;

function basics.isTeam(player)
	local myTeam, thierTeam = lplr.Team, player.Team;

	if (not myTeam or not thierTeam) then
		return;
	end;

	return myTeam == thierTeam;
end;

function basics.behindWall(player, part)
	return #cam:GetPartsObscuringTarget({part.CFrame.Position}, player.Character:GetDescendants()) > 0
end;

return basics;