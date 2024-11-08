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

return basics;