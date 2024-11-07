-- loadstring:
-- loadstring(game:HttpGet('https://raw.githubusercontent.com/Iratethisname10/roblox/refs/heads/main/universal/aimbot.lua'))()


local function getScript(url)
	if (type(url) ~= 'string') then return warn('getscript failed 1'); end;

	local baseUrl = 'https://raw.githubusercontent.com/Iratethisname10/roblox/refs/heads/main/';
	local suc, res = pcall(function() return game:HttpGet(string.format('%s%s.lua', baseUrl, url)); end);
	if (not suc or table.find({'404: Not Found', '400: Invalid Request'}, res)) then return warn('getscript failed 2'); end;

	local fun, err = loadstring(res, url);
	if (not fun) then return warn('getscript syntax err', err); end;

	return fun();
end;

local library = getScript('ui/uwuware');
library.gameName = 'aimbot';

local main = library:AddTab('aimbot and esp and other stuff');
local main1, main2 = main:AddColumn(), main:AddColumn();

local cloneref = cloneref or function(inst) return inst; end;
local inputService = cloneref(game:GetService('UserInputService'));
local players = cloneref(game:GetService('Players'));
local runService = cloneref(game:GetService('RunService'));

local fakeCam = cloneref(Instance.new('Camera'));

local clonefunc = clonefunction or function(func) return func; end;
local getPlayers = clonefunc(players.GetPlayers);
local getMouseLocation = clonefunc(inputService.GetMouseLocation);
local findFirstChild = clonefunc(game.FindFirstChild);
local findFirstChildClass = clonefunc(game.FindFirstChildOfClass);
local worldToViewportPoint = clonefunc(fakeCam.WorldToViewportPoint);
local getPartsObscuringTarget = clonefunc(fakeCam.GetPartsObscuringTarget);
local isDescendantOf = clonefunc(fakeCam.IsDescendantOf);

local Maid = getScript('helpers/maid');
local PlayerESP = getScript('helpers/esp');
local ToastNotif = getScript('helpers/notifs');

local lplr = players.LocalPlayer;
local mouse = clonefunc(lplr.GetMouse)(lplr);
local cam = workspace.CurrentCamera;

local maid = Maid.new();
local funcs = {};

do -- helper funcs
	function funcs.closeToMouse()
		local player, distance = nil, library.flags.aimbotFov;

		for _, v in next, getPlayers(players) do
			if (v == lplr) then continue; end;

			local char = v.Character;
			if (not char) then continue; end;

			local hum = findFirstChildClass(char, 'Humanoid');
			if (not hum) then continue; end;

			local targetPart = findFirstChild(char, library.flags.aimbotPart);
			if (not targetPart) then continue; end;

			if (library.flags.aimbotWall and funcs.behindWall(v, targetPart)) then continue; end;
			if (library.flags.aimbotTeam and funcs.isTeam(v)) then continue; end;
			if (library.flags.aimbotAlive and hum.Health <= 0) then continue; end;

			local vector, inViewport = worldToViewportPoint(cam, targetPart.CFrame.Position);
			local magnitude = (getMouseLocation(inputService) - Vector2.new(vector.X, vector.Y)).Magnitude;

			if (magnitude <= distance and inViewport) then
				distance = magnitude;
				player = v;
			end;
		end;

		return player;
	end;

	function funcs.closeToCharacter()
		local player, distance = nil, library.flags.aimbotFov;

		local root = lplr.Character and lplr.Character.PrimaryPart;
		if (not root) then return {Character = nil}; end;

		for _, v in next, getPlayers(players) do
			if (v == lplr) then continue; end;

			local char = v.Character;
			if (not char) then continue; end;

			local hum = findFirstChildClass(char, 'Humanoid');
			if (not hum) then continue; end;

			local targetPart = findFirstChild(char, library.flags.aimbotPart);
			if (not targetPart) then continue; end;

			if (library.flags.aimbotWall and funcs.behindWall(v, targetPart)) then continue; end;
			if (library.flags.aimbotTeam and funcs.isTeam(v)) then continue; end;
			if (library.flags.aimbotAlive and hum.Health <= 0) then continue; end;

			local magnitude = (root.CFrame.Position - targetPart.CFrame.Position).Magnitude;
			if (magnitude <= distance) then
				distance = magnitude;
				player = v;
			end;
		end;

		return player;
	end;

	function funcs.isTeam(player)
		local myTeam, thierTeam = lplr.Team, player.Team;

		if (not myTeam or not thierTeam) then
			return;
		end;

		return myTeam == thierTeam;
	end;

	function funcs.behindWall(player, part)
		return #getPartsObscuringTarget(cam, {part.CFrame.Position}, player.Character:GetDescendants()) > 0
	end;
end;

do -- esp
	local playerList = {};

	local function onPlayerAdded(player)
		if (player == lplr) then return; end;
		local espDonePlayer = PlayerESP.new(player);

		library.unloadMaid[player] = function()
			table.remove(playerList, table.find(playerList, espDonePlayer));
			espDonePlayer:Destroy();
		end;

		table.insert(playerList, espDonePlayer);
	end;

	local function onPlayerRemoving(player)
		library.unloadMaid[player] = nil;
	end;

	library.OnLoad:Connect(function()
		players.PlayerAdded:Connect(onPlayerAdded);
		players.PlayerRemoving:Connect(onPlayerRemoving);

		for _, player in getPlayers(players) do
			task.spawn(onPlayerAdded, player);
		end;
	end);

	function funcs.toggleRainbowEsp(flag)
		return function(t)
			if (not t) then
				maid['rainbow'.. flag] = nil;
				return;
			end;

			maid['rainbow'.. flag] = runService.RenderStepped:Connect(function()
				library.options[flag]:SetColor(library.chromaColor, false, true);
			end);
		end;
	end;

	function funcs.updateESP(t)
		if (not t) then
			maid.updateEsp = nil
			for _, v in playerList do
				v:Hide();
			end;

			return;
		end;

		local lastUpdateAt = 0;

		maid.updateEsp = runService.RenderStepped:Connect(function()
			if (tick() - lastUpdateAt < 0.01) then return; end;
			lastUpdateAt = tick();

			for _, v in playerList do
				v:Update();
			end;
		end);
	end;

	function funcs.updateESPFont(val)
		val = Drawing.Fonts[val];
		for _, v in playerList do
			v:SetFont(val);
		end;
	end;

	function funcs.updateESPTextSize(val)
		for _, v in playerList do
			v:SetTextSize(val)
		end
	end;

	library.flags.maxEspDistance = math.huge;
end;

do -- aimbot
	function funcs.updateAimbot(t)
		if (maid.circle) then
			maid.circle.Visible = t;
		end;

		if (not t) then
			maid.aimbot = nil;
			return;
		end;

		maid.aimbot = runService.RenderStepped:Connect(function()
			if (maid.circle) then
				maid.circle.Radius = library.flags.aimbotFov;
				maid.circle.Color = library.flags.aimbotCircleColor;
				maid.circle.Position = getMouseLocation(inputService);
			end;

			local target = funcs[library.flags.aimbotSortMode == 'Mouse' and 'closeToMouse' or 'closeToCharacter']();
			target = target and target.Character;
			if (not target) then return; end;

			local targetPart = target[library.flags.aimbotPart];

			cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, targetPart.CFrame.Position), 1 / library.flags.aimbotSpeed);
		end);
	end;

	function funcs.updateAimbotFov(val)
		if (val == 1000) then
			val = math.huge;
		end;

		library.flags.aimbotFov = val;
	end;

	function funcs.updateAimbotSortMode(val)
		if (not maid.circle) then return; end;

		maid.circle.Visible = val == 'Mouse';
	end;

	function funcs.updateAimbotCircle(t)
		if (not t) then
			if (maid.circle) then maid.circle:Destroy(); maid.circle = nil; end;
			return;
		end;

		maid.circle = Drawing.new('Circle');

		maid.circle.Visible = library.flags.aimbot and library.flags.aimbotSortMode == 'Mouse';
		maid.circle.Filled = false;
		maid.circle.NumSides = 200;
		maid.circle.Transparency = 1;
		maid.circle.Thickness = 1.7;
		maid.circle.ZIndex = 4;
	end;
end;

do -- triggerbot
	function funcs.updateTriggerbot(t)
		if (not t) then
			maid.triggerbot = nil;
			return;
		end;

		maid.triggerbot = runService.RenderStepped:Connect(function()
			if (not lplr.Character) then return; end;

			local rayParams = RaycastParams.new();
			rayParams.FilterDescendantsInstances = {lplr.Character, cam};

			local ray = workspace:Raycast(cam.CFrame.Position, mouse.UnitRay.Direction * 10000, rayParams);
			if (not ray or not ray.Instance) then return; end;

			for _, v in next, getPlayers(players) do
				if (library.flags.triggerbotTeam and funcs.isTeam(v)) then continue; end;
				if (not v.Character) then continue; end;
				if (not isDescendantOf(ray.Instance, v.Character)) then continue; end;

				mouse1click();
			end;
		end);
	end
end;

do -- extra
	do -- backtrack
		local roots = {};

		function funcs.backtrack(t)
			if (not t) then
				maid.backtrack = nil;

				for _, v in next, roots do
					if (not v or not v.Anchored) then continue; end;
					v.Anchored = false;
				end;

				return;
			end;

			task.delay(library.flags.backtrackTimeout, function()
				if (not library.flags.backtrack) then return; end;

				library.options.backtrack:SetState(false);
				ToastNotif.new({text = 'Backtrack disabled', duration = 2});
			end);

			maid.backtrack = runService.Heartbeat:Connect(function()
				for _, v in next, getPlayers(players) do
					if (v == lplr) then continue; end;

					local root = v.Character and v.Character.PrimaryPart;
					if (not root) then continue; end;

					table.insert(roots, root);
					root.Anchored = true;
				end;
			end);
		end;
	end;
end;

do -- ui
	local aimbot = main1:AddSection('Aimbot');
	local triggerbot = main1:AddSection('Triggerbot');
	local extra = main1:AddSection('Extra');

	local esp = main2:AddSection('Player ESP');

	do -- aimbot
		aimbot:AddToggle({
			text = 'Enabled',
			flag = 'aimbot',
			callback = funcs.updateAimbot
		}):AddBind({
			flag = 'aimbot bind',
			callback = function()
				library.options.aimbot:SetState(not library.flags.aimbot);
			end;
		});

		aimbot:AddDivider();

		aimbot:AddSlider({
			text = 'Field Of View',
			flag = 'aimbot fov',
			min = 50,
			max = 1000,
			callback = funcs.updateAimbotFov
		});

		aimbot:AddSlider({
			text = 'Lock Smoothing',
			flag = 'aimbot speed',
			min = 1,
			max = 10,
			float = 0.1
		});

		aimbot:AddList({
			text = 'Aim Part',
			flag = 'aimbot part',
			values = {'Head', 'HumanoidRootPart'}
		});

		aimbot:AddList({
			text = 'Sort Method',
			flag = 'aimbot sort mode',
			values = {'Mouse', 'Character'},
			callback = funcs.updateAimbotSortMode
		});

		aimbot:AddToggle({
			text = 'Wall Check',
			flag = 'aimbot wall'
		});

		aimbot:AddToggle({
			text = 'Team Check',
			flag = 'aimbot team'
		});

		aimbot:AddToggle({
			text = 'Alive Check',
			flag = 'aimbot alive'
		});

		aimbot:AddToggle({
			text = 'Draw Circle',
			flag = 'aimbot cicle',
			callback = funcs.updateAimbotCircle
		}):AddColor({
			flag = 'aimbot circle color'
		});
	end;

	do -- triggerbot
		triggerbot:AddToggle({
			text = 'Enabled',
			flag = 'triggerbot',
			callback = funcs.updateTriggerbot
		}):AddBind({
			flag = 'triggerbot bind',
			callback = function()
				library.options.triggerbot:SetState(not library.flags.triggerbot);
			end
		});

		triggerbot:AddDivider();

		triggerbot:AddSlider({
			text = 'Click Delay',
			flag = 'triggerbot delay',
			min = 0,
			max = 1,
			float = 0.001
		});

		triggerbot:AddToggle({
			text = 'Team Check',
			flag = 'triggerbot team'
		});
	end;

	do -- esp
		esp:AddToggle({
			text = 'Enabled',
			flag = 'esp',
			callback = funcs.updateESP
		}):AddBind({
			flag = 'aimbot esp',
			callback = function()
				library.options.esp:SetState(not library.flags.esp);
			end;
		});

		esp:AddDivider();

		esp:AddList({
			text = 'Esp Font',
			values = {'UI', 'System', 'Plex', 'Monospace'},
			callback = funcs.updateESPFont
		});

		esp:AddSlider({
			text = 'Text Size',
			max = 100,
			min = 16,
			callback = funcs.updateESPTextSize
		});

		esp:AddDivider();

		esp:AddToggle({
			text = 'Render Tracers'
		});

		esp:AddToggle({
			text = 'Render Boxes'
		});

		esp:AddToggle({
			text = 'Render Health Bar'
		}):AddColor({
			flag = 'health bar low',
			tip = 'health bar color when low health',
			color = Color3.fromRGB(255, 0, 0)
		}):AddColor({
			flag = 'health bar high',
			tip = 'health bar color when full health',
			color = Color3.fromRGB(0, 255, 0)
		});

		esp:AddDivider();

		esp:AddToggle({
			text = 'Display Name',
			state = true
		});

		esp:AddToggle({
			text = 'Display Distance'
		});

		esp:AddToggle({
			text = 'Display Health'
		});

		esp:AddDivider();

		esp:AddToggle({
			text = 'Render Team Members',
			state = true
		});

		esp:AddToggle({
			text = 'Use Float Health',
			tip = 'shows the players health as a percentage'
		});

		esp:AddToggle({
			text = 'Unlock Tracers'
		});

		esp:AddDivider()

		esp:AddToggle({
			text = 'Rainbow Enemy Color',
			callback = funcs.toggleRainbowEsp('enemyColor')
		});

		esp:AddToggle({
			text = 'Rainbow Ally Color',
			callback = funcs.toggleRainbowEsp('allyColor')
		});

		esp:AddColor({
			text = 'Ally Color',
			color = Color3.fromRGB(0, 255, 0)
		});

		esp:AddColor({
			text = 'Enemy Color',
			color = Color3.fromRGB(255, 0, 0)
		});

		esp:AddToggle({
			text = 'Use Team Color',
			state = true
		});
	end;

	do -- extra
		extra:AddToggle({
			text = 'Backtrack',
			callback = funcs.backtrack
		}):AddBind({
			flag = 'backtrack bind',
			callback = function()
				library.options.backtrack:SetState(not library.flags.backtrack);
			end
		});

		extra:AddSlider({
			text = 'Backtrack Timeout',
			min = 0,
			max = 5,
			float = 0.01
		});
	end;
end;

library.unloadMaid:GiveTask(fakeCam);

library:Init();