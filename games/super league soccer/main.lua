-- // loadstring:
-- // loadstring(game:HttpGet('https://raw.githubusercontent.com/Iratethisname10/roblox/refs/heads/main/games/super%20league%20soccer/main.lua'))()

-- // this is the first ever open-source super league soccer
-- // that actually works well
-- // all features except for ball esp are made by me
-- // ball esp is from aztup hub's parkour script

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
library.gameName = 'sls';
library.fixSignal = true;

local main = library:AddTab('main');
local main1, main2 = main:AddColumn(), main:AddColumn();

local inputService = game:GetService('UserInputService');
local inputManager = game:GetService('VirtualInputManager');
local players = game:GetService('Players');
local repoStore = game:GetService('ReplicatedStorage');
local runService = game:GetService('RunService');
local chatService = game:GetService('TextChatService');

local Maid = getScript('helpers/maid');
local basics = getScript('helpers/basics');

local lplr = players.LocalPlayer;
local cam = workspace.CurrentCamera;

local junk = workspace.Junk;
local teams = workspace.Stadium.Teams;

local rng = Random.new(tick() / math.sqrt(2));

local sls;

local maid = Maid.new();
local funcs = {};

do -- stuff
	local controllers = lplr.PlayerScripts.Client.Controllers;
	local knit = require(repoStore.Packages.Knit);

	local actionService = knit.GetService('ActionService');
	local matchController = knit.GetController('MatchController');

	sls = {
		actionService = actionService,
		doAction = actionService.PerformAction,
		leapController = require(controllers.Action.Leap),
		matchController = matchController,
		staminaController = require(controllers.Stamina),
	};

	maid.ballAuraPart = Instance.new('Part');
	maid.ballAuraPart.Transparency = 0.75;
	maid.ballAuraPart.Anchored = true;
	maid.ballAuraPart.CanCollide = false;
	maid.ballAuraPart.CanTouch = false;
	maid.ballAuraPart.CFrame = CFrame.new(0, 9e9, 0);
	maid.ballAuraPart.Size = Vector3.one;
	maid.ballAuraPart.Shape = Enum.PartType.Ball;
	maid.ballAuraPart.CastShadow = false;
	maid.ballAuraPart.Material = Enum.Material.ForceField;
	maid.ballAuraPart.Color = Color3.fromRGB(255, 0, 0);
	maid.ballAuraPart.Parent = nil;

	library.unloadMaid:GiveTask(maid.ballAuraPart);

	library.unloadMaid:GiveTask(task.spawn(function()
		while (true) do
			if (not lplr:GetAttribute('TeamPosition')) then task.wait(); continue; end;

			local root = lplr.Character and lplr.Character.PrimaryPart;
			if (not root) then task.wait(); continue; end;

			local rootPos = root.CFrame.Position;
			if (rootPos.Y <= 55) then task.wait(); continue; end;

			root.CFrame = CFrame.new(rootPos.X, 45, rootPos.Z);

			runService.Heartbeat:Wait();
		end;
	end));
end;

do -- hooking
	local oldNamecall;
	local function onNamecall(self, ...)
		local method = getnamecallmethod();
		local caller = getcallingscript();

		if (method:lower() == 'kick' and tostring(caller):lower() == 'anticheat' and self == lplr) then
			return;
		end;

		return oldNamecall(self, ...);
	end;

	oldNamecall = hookmetamethod(game, '__namecall', onNamecall);

	local oldConsume = sls.staminaController.Consume;
	sls.staminaController.Consume = function(...)
		if (library.flags.infStamina) then return true; end;

		return oldConsume(...);
	end;
end;

do -- esp
	local BallESP = {};
	BallESP.__index = BallESP;
	BallESP.balls = {};

	function BallESP.new(inst)
		local self = setmetatable({}, BallESP);

		self.line = Drawing.new('Line');
		self.line.Transparency = 1;
		self.line.Color = library.flags.ballEspColor;

		self.ball = inst;
		table.insert(BallESP.balls, self);

		return self;
	end;

	function BallESP:Update()
		if (not library.flags.ballEsp) then
			return self:Hide();
		end;

		local vector, inViewport = cam:WorldToViewportPoint(self.ball.CFrame.Position);
		if (not inViewport) then
			return self:Hide();
		end;

		local screenPos = Vector2.new(vector.X, vector.Y);
		local vpSize = cam.ViewportSize;

		self.line.Color = library.flags.ballEspColor;
		self.line.From = Vector2.new(vpSize.X / 2, vpSize.Y);
		self.line.To = screenPos;
		self.line.Visible = true;
	end;

	function BallESP:Destroy()
		table.remove(self.balls, table.find(self.balls, self));

		self.line:Destroy();
		self.line = nil;
	end;

	function BallESP:Hide()
		self.line.Visible = false;
	end;

	local function onChildAdded(inst)
		if (inst.Name ~= 'Football') then return; end;

		local esp = BallESP.new(inst);
		inst.Destroying:Connect(function()
			esp:Destroy();
		end);
	end;

	for _, v in next, junk:GetChildren() do
		task.spawn(onChildAdded, v);
	end;

	junk.ChildAdded:Connect(onChildAdded);

	function funcs.ballESP()
		repeat
			for _, v in next, BallESP.balls do
				v:Update();
			end;

			runService.RenderStepped:Wait();
		until not library.flags.ballEsp;
	end;
end;

do -- helper funcs
	function funcs.getOpposingTeam()
		local team = lplr.Team;
		if (team == nil) then return; end;

		local pTeams = teams:GetChildren();
		if (#pTeams ~= 2) then return; end;

		for _, v in next, pTeams do
			if (v.Name ~= team.Name) then
				return v.Name;
			end;
		end;

		return nil;
	end;
end;

do -- funcs
	do -- chat spam
		local ads = {
			'GET SCRIPT - g g / G x g 4 2 E s h p y',
			'vocat best developer',
			'imagine not using vcs - g g / G x g 4 2 E s h p y',
			'vcs >>>>>>>> beast hub - g g / G x g 4 2 E s h p y',
			'vcs always winning',
			'maybe get vcs or something??? - g g / G x g 4 2 E s h p y',
			'vocat ALWAYS finds a way'
		};

		function funcs.chatSpam()
			local channel = chatService.ChatInputBarConfiguration.TargetTextChannel;

			while (library.flags.adfly) do
				channel:SendAsync(ads[rng:NextInteger(1, #ads)]);
				task.wait(library.flags.chatSpamDelay);
			end;
		end;
	end;

	-- // redo this
	function funcs.autoRun(t)
		if (not t) then
			maid.autoRun = nil
			inputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game);
			return;
		end;

		local moveKeys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D};
		local lastSent = 0;

		maid.autoRun = inputService.InputBegan:Connect(function(input, gpe)
			if (gpe or tick() - lastSent < 0.3) then return; end;

			if (table.find(moveKeys, input.KeyCode)) then
				lastSent = tick();
				inputManager:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game);
			end;
		end);
	end;

	function funcs.antiTackle()
		while (library.flags.antiTackle) do
			local ball = sls.matchController:GetComponent('Football');
			if (not ball or not ball:HasFootball()) then task.wait(); continue; end;

			sls.actionService:PerformActionThenGet('EvadeActivated');
			task.wait();
		end;
	end;

	function funcs.ballAura()
		while (library.flags.ballAura) do
			local root = lplr.Character and lplr.Character.PrimaryPart;
			if (not root) then task.wait(); continue; end;

			local ball = junk:FindFirstChild('Football');
			if (not ball) then task.wait(); continue; end;

			maid.ballAuraPart.Parent = cam;
			maid.ballAuraPart.CFrame = root.CFrame;
			maid.ballAuraPart.Size = Vector3.one * library.flags.ballAuraRange;

			local mag = (root.CFrame.Position - ball.CFrame.Position).Magnitude;
			if (mag > 20) then task.wait(); continue; end;

			if (ball:GetAttribute('State') ~= 'Released' or mag > library.flags.ballAuraRange) then  task.wait(); continue; end;

			sls.doAction:Fire('PickUpBall', ball, ball:GetAttribute('ReleaseId'));

			task.wait();
		end;

		maid.ballAuraPart.Parent = nil;
		maid.ballAuraPart.CFrame = CFrame.new(0, 9e9, 0);
		maid.ballAuraPart.Size = Vector3.one;
	end;

	function funcs.hitboxExpand()
		local goal, hitbox, interceptionHitbox;
		while (library.flags.hitboxExpander) do
			local opposingTeam = funcs.getOpposingTeam();
			if (not opposingTeam) then task.wait(); continue; end;

			local team = teams:FindFirstChild(opposingTeam);
			if (not team) then task.wait(); continue; end;

			goal = team:FindFirstChild('Goal');
			if (not goal) then task.wait(); continue; end;

			interceptionHitbox = goal:FindFirstChild('InterceptionHitbox');
			if (not interceptionHitbox) then task.wait(); continue; end;

			hitbox = goal:FindFirstChild('Hitbox');
			if (not hitbox) then task.wait(); continue; end;

			interceptionHitbox.Parent = nil;
			hitbox.Size = Vector3.one * library.flags.hitboxExpandSize;

			task.wait();
		end;

		if (not goal or not interceptionHitbox or not hitbox) then return; end;

		interceptionHitbox.Parent = goal;
		hitbox.Size = Vector3.new(31.327247619628906, 11.277809143066406, 8.289474487304688);
	end;

	function funcs.noDiveDelay(t)
		local func = debug.getupvalue(sls.leapController.BindActionToController, 7);
		debug.setconstant(func, 12, t and 0 or 0.71);
	end;

	function funcs.ballTP()
		local ball = junk:FindFirstChild('Football');
		if (not ball) then task.wait(); return; end;

		sls.doAction:Fire('PickUpBall', ball, ball:GetAttribute('ReleaseId'));
	end;

	function funcs.shootBall()
		local root = lplr.Character and lplr.Character.PrimaryPart;
		if (not root) then return; end;

		local ball = sls.matchController:GetComponent('Football');
		if (not ball) then return; end;

		local possessedBall = ball:GetPossessedFootball();
		if (not possessedBall) then return; end;

		local ballComponent = ball:GetFootballComponent(possessedBall);
		if (not ballComponent) then return; end;

		local force = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z) * 500;

		possessedBall:SetAttribute('State', 'Released');
		ballComponent:Shoot(root.CFrame.Position, force);
	end;

	function funcs.changeTeam()
		if (not lplr:GetAttribute('TeamPosition')) then return; end;

		lplr:SetAttribute('TeamPosition', library.flags.teamChooser);
	end;
end;

do -- ui
	local character = main1:AddSection('Character');
	local extra = main1:AddSection('Extra');
	local gameplay = main2:AddSection('Gameplay');
	local visual = main2:AddSection('Visual');

	do -- character
		character:AddToggle({
			text = 'Speed',
			callback = function(t)
				basics.speedVelo(t, library.flags.speedValue);
			end
		}):AddBind({
			flag = 'speed bind',
			callback = function()
				library.options.speed:SetState(not library.flags.speed);
			end
		});

		character:AddSlider({
			text = 'Speed Value',
			min = 20,
			max = 300,
			textpos = 2,
			callback = function(val)
				basics.speedVelo(library.flags.speed, val, true);
			end
		});

		character:AddToggle({
			text = 'Fly',
			callback = function(t)
				basics.flyVelo(t, library.flags.flySpeedValue);
			end
		}):AddBind({
			flag = 'fly bind',
			callback = function()
				library.options.fly:SetState(not library.flags.fly);
			end
		});

		character:AddSlider({
			text = 'Fly Speed Value',
			min = 20,
			max = 300,
			textpos = 2,
			callback = function(val)
				basics.flyVelo(library.flags.fly, val, true, true);
			end
		});

		character:AddToggle({
			text = 'Auto Sprint',
			callback = funcs.autoRun
		});

		character:AddToggle({
			text = 'Inf Jump',
			callback = function(t)
				basics.infJump(t);
			end
		});

		character:AddToggle({
			text = 'Inf Stamina',
			callback = funcs.infStamina
		});
	end;

	do -- extra
		extra:AddToggle({
			text = 'Adfly',
			tip = 'sends messages in the chat advertising this script',
			callback = funcs.chatSpam
		}):AddSlider({
			flag = 'chat spam delay',
			min = 1,
			max = 10
		});
	end;

	do -- gameplay
		gameplay:AddToggle({
			text = 'Anti Tackle',
			tip = 'makes it harder for people to tackle you',
			callback = funcs.antiTackle
		});

		gameplay:AddToggle({
			text = 'Ball Aura',
			tip = 'auto get the ball when its close to you',
			callback = funcs.ballAura
		}):AddSlider({
			text = 'range',
			flag = 'ball aura range',
			min = 10,
			max = 40,
			value = 20
		});

		gameplay:AddToggle({
			text = 'Hitbox Expander',
			tip = 'expands the hitbox of the opposing team\'s goal',
			callback = funcs.hitboxExpand
		}):AddSlider({
			text = 'expand size',
			flag = 'hitbox expand size',
			min = 50,
			max = 300,
			value = 200
		});

		gameplay:AddToggle({
			text = 'No Dive Delay',
			tip = 'removes the goal keeper dive delay',
			callback = funcs.noDiveDelay
		});

		gameplay:AddBind({
			text = 'Get Ball',
			tip = 'get the ball from anywhere on the map',
			callback = funcs.ballTP
		});

		gameplay:AddBind({
			text = 'shoot Ball',
			tip = 'shoots the ball at a higher velocity',
			callback = funcs.shootBall
		});

		gameplay:AddList({
			text = 'Team Chooser',
			tip = 'use the keybind to change your team',
			values = { 'GK', 'CF', 'LF', 'RF', 'CM', 'LB', 'RB' }
		}):AddBind({
			flag = 'team chooser bind',
			callback = funcs.changeTeam
		});
	end;

	do -- visual
		visual:AddToggle({
			text = 'Fov Changer',
			callback = function(t)
				basics.fovChanger(t, library.flags.fovValue);
			end
		}):AddSlider({
			flag = 'fov value',
			min = 40,
			max = 120,
			value = 120,
			callback = function(val)
				basics.fovChanger(library.flags.fovChanger, val);
			end
		});

		visual:AddToggle({
			text = 'Ball Esp',
			callback = funcs.ballESP
		}):AddColor({
			flag = 'ball esp color',
			color = Color3.fromRGB(255, 0, 0)
		});
	end;
end;

library:Init();