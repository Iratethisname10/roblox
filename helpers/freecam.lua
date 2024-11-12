local function getScript(url)
	if (type(url) ~= 'string') then return warn('getscript failed 1'); end;

	local baseUrl = 'https://raw.githubusercontent.com/Iratethisname10/roblox/refs/heads/main/helpers/';
	local suc, res = pcall(function() return game:HttpGet(string.format('%s%s.lua', baseUrl, url)); end);
	if (not suc or table.find({'404: Not Found', '400: Invalid Request'}, res)) then return warn('getscript failed 2'); end;

	local fun, err = loadstring(res, url);
	if (not fun) then return warn('getscript syntax err', err); end;

	return fun();
end;

local cloneref = cloneref or function(inst) return inst; end;
local inputService = cloneref(game:GetService('UserInputService'));
local actionService = cloneref(game:GetService('ContextActionService'));
local httpService = cloneref(game:GetService('HttpService'));
local runService = cloneref(game:GetService('RunService'));

local Maid = getScript('maid');

local maid = Maid.new();
local cam = workspace.CurrentCamera;

---@diagnostic disable-next-line: undefined-global
local flags = library.flags;

local spring = {};
local playerState = {};
local input = {};

local contextPrioHigh = Enum.ContextActionPriority.High.Value;
local mousePanEnum = Enum.UserInputType.MouseMovement;

local keyboardID = httpService:GenerateGUID(false);
local mousePanID = httpService:GenerateGUID(false);

do -- spring
	spring.__index = spring;

	function spring.new(frequency, position)
		local self = setmetatable({}, spring);

		self.f = frequency;
		self.p = position;
		self.v = position * 0;

		return self;
	end;

	function spring:Update(deltaTime, goal)
		local f = self.f * 2 * math.pi;
		local p0 = self.p;
		local v0 = self.v;

		local offset = goal - p0;
		local decay = math.exp(-f * deltaTime);

		local p1 = goal + (v0 * deltaTime - offset * (f * deltaTime + 1)) * decay;
		local v1 = (f * deltaTime * (offset * f - v0) + v0) * decay;

		self.p = p1;
		self.v = v1;

		return p1;
	end;

	function spring:Reset(position)
		self.p = position;
		self.v = position * 0;
	end;
end;

do -- playerState
	playerState.__index = playerState;

	function playerState.new()
		local self = setmetatable({}, playerState);

		self._oldCameraFieldOfView = cam.FieldOfView;
		cam.FieldOfView = 70;

		self._oldCameraType = cam.CameraType;
		cam.CameraType = Enum.CameraType.Custom;

		self._oldCameraCFrame = cam.CFrame;
		self._oldCameraFocus = cam.Focus;

		self._oldMouseIconEnabled = inputService.MouseIconEnabled;
		inputService.MouseIconEnabled = true;

		self._oldMouseBehavior = inputService.MouseBehavior;
		inputService.MouseBehavior = Enum.MouseBehavior.Default;

		return self;
	end;

	function playerState:Destroy()
		cam.FieldOfView = self._oldCameraFieldOfView;
		self._oldCameraFieldOfView = nil;

		cam.CameraType = self._oldCameraType;
		self._oldCameraType = nil;

		cam.CFrame = self._oldCameraCFrame;
		self._oldCameraCFrame = nil;

		cam.Focus = self._oldCameraFocus;
		self._oldCameraFocus = nil;

		inputService.MouseIconEnabled = self._oldMouseIconEnabled;
		self._oldMouseIconEnabled = nil;

		inputService.MouseBehavior = self._oldMouseBehavior;
		self._oldMouseBehavior = nil;
	end;
end;

do -- input
	local mouse = {Delta = Vector2.new()};
	local keyboard = {
		W = 0,
		A = 0,
		S = 0,
		D = 0,
		E = 0,
		Q = 0,
		Up = 0,
		Down = 0,
		LeftShift = 0
	};

	local PAN_MOUSE_SPEED = Vector2.new(3, 3) * (math.pi / 64);
	local NAV_ADJ_SPEED = 0.75;

	local navSpeed = 1;

	function input.vel(deltaTime)
		navSpeed = math.clamp(navSpeed + deltaTime * (keyboard.Up - keyboard.Down) * NAV_ADJ_SPEED, 0.01, 4);

		local localKeyboard = Vector3.new(keyboard.D - keyboard.A, keyboard.E - keyboard.Q, keyboard.S - keyboard.W) * (Vector3.one * flags.freecamSpeed);
		local shifting = inputService:IsKeyDown(Enum.KeyCode.LeftShift);

		return (localKeyboard) * (navSpeed * (shifting and flags.freecamShiftMult or 1));
	end;

	function input.pan()
		local localMouse = mouse.Delta * PAN_MOUSE_SPEED;
		mouse.Delta = Vector2.new();

		return localMouse;
	end;

	local function _keypress(_, state, object)
		keyboard[object.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0;
		return Enum.ContextActionResult.Sink;
	end

	local function _mousePan(_, _, object)
		local delta = object.Delta;
		mouse.Delta = Vector2.new(-delta.y, -delta.x);
		return Enum.ContextActionResult.Sink;
	end

	local function _zero(tab)
		for k, x in tab do
			tab[k] = x * 0;
		end;
	end;

	function input.start()
		actionService:BindActionAtPriority(keyboardID, _keypress, false, contextPrioHigh, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.E, Enum.KeyCode.Q, Enum.KeyCode.Up, Enum.KeyCode.Down);
		actionService:BindActionAtPriority(mousePanID, _mousePan, false, contextPrioHigh, mousePanEnum);
	end;

	function input.stop()
		navSpeed = 1;

		_zero(mouse);
		_zero(keyboard);

		actionService:UnbindAction(keyboardID);
		actionService:UnbindAction(mousePanID);
	end;
end;

local cameraFov;
local function getFocusDistance(cframe)
	local znear = 0.1;
	local viewport = cam.ViewportSize;
	local projy = 2 * math.tan(cameraFov / 2);
	local projx = viewport.X / viewport.Y * projy;
	local fx = cam.RightVector;
	local fy = cam.UpVector;
	local fz = cam.LookVector;

	local minVect = Vector3.zero;
	local minDist = 512;

	for x = 0, 1, 0.5 do
		for y = 0, 1, 0.5 do
			local cx = (x - 0.5) * projx;
			local cy = (y - 0.5) * projy;
			local offset = fx * cx - fy * cy + fz;
			local origin = cframe.Position + offset * znear;
			local res = workspace:Raycast(origin, offset.unit * minDist);
			res = res and res.Position;

			local dist = (res - origin).magnitude;
			if (minDist > dist) then
				minDist = dist;
				minVect = offset.unit;
			end;
		end;
	end;

	return fz:Dot(minVect) * minDist;
end;

local cameraPos = Vector3.zero;
local cameraRot = Vector2.new();
local velSpring = spring.new(5, Vector3.zero);
local panSpring = spring.new(5, Vector2.new());

return function(t)
	if (not t) then
		input.stop();
		maid.freecam = nil;
		playerState:Destroy();
		return;
	end;

	local cameraCFrame = cam.CFrame;
	local pitch, yaw = cameraCFrame:ToEulerAnglesYXZ();

	cameraRot = Vector2.new(pitch, yaw);
	cameraPos = cameraCFrame.Position;
	cameraFov = cam.FieldOfView;

	velSpring:Reset(Vector3.zero);
	panSpring:Reset(Vector2.new());

	playerState.new();
	maid.freecam = runService.RenderStepped:Connect(function(deltaTime)
		local vel = velSpring:Update(deltaTime, input.vel(deltaTime));
		local pan = panSpring:Update(deltaTime, input.pan());
		local zoomFactor = math.sqrt(math.tan(math.rad(70 / 2)) / math.tan(math.rad(cameraFov / 2)));

		cameraRot += pan * Vector2.new(0.75, 1) * 8 * (deltaTime / zoomFactor);
		cameraRot = Vector2.new(math.clamp(cameraRot.X, -math.rad(90), math.rad(90)), cameraRot.Y % (2 * math.pi));

		---@diagnostic disable-next-line: redefined-local
		local cameraCFrame = CFrame.new(cameraPos) * CFrame.fromOrientation(cameraRot.X, cameraRot.Y, 0) * CFrame.new(vel * Vector3.new(1, 1, 1) * 64 * deltaTime);
		cameraPos = cameraCFrame.Position;

		cam.CFrame = cameraCFrame;
		cam.Focus = cameraCFrame * CFrame.new(0, 0, -getFocusDistance(cameraCFrame));
		cam.FieldOfView = cameraFov;
	end);

	input.start();
end;