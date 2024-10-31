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

local mover;
function basics.fly(t, speed, noVelo, useMover)
	if (not t) then
		maid.fly = nil;
		if (mover) then mover:Destroy(); mover = nil; end;

		local root = lplr.Character and lplr.Character.PrimaryPart;
		if (root) then
			root.AssemblyLinearVelocity *= Vector3.zero;
			root.AssemblyAngularVelocity *= Vector3.zero;
		end;

		return;
	end;

	local vertical = 0;

	maid.fly = runService.Heartbeat:Connect(function(dt)
		local root = lplr.Character and lplr.Character.PrimaryPart;
		if (not root) then return; end;

		local hum = lplr.Character:FindFirstChildOfClass('Humanoid');
		if (not hum) then return; end;

		if (inputService:IsKeyDown(Enum.KeyCode.Space)) then
			vertical = 1;
		elseif (inputService:IsKeyDown(Enum.KeyCode.LeftControl)) then
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
			mover = mover or Instance.new('BodyVelocity');
			mover.MaxForce = Vector3.one * math.huge;
			mover.Velocity = Vector3.new(moveDir.X, vertical, moveDir.Z) * speed * dt;
			mover.Parent = root;
		end;

		root.CFrame += Vector3.new(moveDir.X, vertical, moveDir.Z) * speed * dt;
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
		if (oldBrightness) then lighting.Ambient = oldBrightness; end;
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

return basics;