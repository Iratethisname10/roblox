-- // loadstring:
-- // loadstring(game:HttpGet('https://raw.githubusercontent.com/Iratethisname10/roblox/refs/heads/main/games/cali%20shootout/main.lua'))()

-- // this is the first ever open-source cali shootout script
-- // that actually works well
-- // all features are made by me

-- // originally uploaded to the "Code" repo on 16/04/2024
-- // which was deleted on 30/10/2024

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
library.gameName = 'cali';

local main = library:AddTab('main');
local visual = library:AddTab('visual');

local main1, main2 = main:AddColumn(), main:AddColumn();
local visual1, visual2 = visual:AddColumn(), visual:AddColumn();

local inputService = game:GetService('UserInputService');
local inputManager = game:GetService('VirtualInputManager');
local players = game:GetService('Players');
local repoStore = game:GetService('ReplicatedStorage');
local runService = game:GetService('RunService');
local promptService = game:GetService('ProximityPromptService');

local Maid = getScript('helpers/maid');
local PlayerESP = getScript('helpers/esp');
local TextLogger = getScript('helpers/text%20logger');
local ToastNotif = getScript('helpers/notifs');
local basics = getScript('helpers/basics');

local lplr = players.LocalPlayer;
local cam = workspace.CurrentCamera;

local safeZones = workspace.SafeZones;
local carRobberys = workspace.CarRobberys;
local jobSystem = workspace['Job System'];

local remotes = repoStore.Remotes;
local modules = repoStore.Modules;

local weaponSettings = modules.WeaponSettings.Gun;
local gunEffects = repoStore.Miscs.GunVisualEffects.Common;

local blurModule = require(modules.CreateBlur);

local maid = Maid.new();
local funcs = {};

local cache = {};
local gunsList = {};

do -- fetch stuff
	for _, v in next, weaponSettings:GetChildren() do
		if (not v:IsA('Folder')) then continue; end;
		if (#v:GetDescendants() ~= 2) then continue; end;

		table.insert(gunsList, v.Name);
	end;
end;

do -- text logger
	local chatLogger = TextLogger.new({
		title = 'Chat Logger',
		preset = 'chatLogger',
		buttons = {'Copy Username', 'Copy User Id', 'Copy Text'}
	});

	local last, lastPlayer;
	local function onPlayerChatted(player, message)
		local timeText = DateTime.now():FormatLocalTime('H:mm:ss', 'en-us');
		local playerName = player.Name;

		if (message == last and playerName == lastPlayer) then return end;
		last, lastPlayer = message, playerName;

		message = ('[%s] [%s] %s'):format(timeText, playerName, message);

		chatLogger:AddText({
			text = message,
			player = player
		});
	end;

	chatLogger.OnPlayerChatted:Connect(onPlayerChatted);

	function funcs.chatLogger(toggle)
		chatLogger:SetVisible(toggle);
	end;
end;

do -- esp
	-- // override
	function PlayerESP:IsTeamMate() return false; end;

	-- // main
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

		for _, player in players:GetPlayers() do
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

	function funcs.enableESP(t)
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

do -- helper functions
	function funcs.getWeapon()
		local tool = lplr.Character and lplr.Character:FindFirstChildOfClass('Tool');
		if (not tool) then return nil; end;

		if (not table.find(gunsList, tool.Name)) then return nil; end;

		return tool;
	end;

	function funcs.isPointLoaded(pos, distance)
		local characters = {};
		for _, v in next, players:GetPlayers() do
			if (not v.Character) then continue; end;

			table.insert(characters, v.Character);
		end;

		local rayParams = RaycastParams.new();
		rayParams.RespectCanCollide = true;
		rayParams.FilterType = Enum.RaycastFilterType.Exclude;
		rayParams.FilterDescendantsInstances = {cam, lplr.Character, characters};

		local ray = workspace:Raycast(pos, Vector3.new(0, tonumber(distance) or -20, 0), rayParams);

		return ray and ray.Instance;
	end;

	function funcs.teleport(point)
		if (typeof(point) == 'Vector3') then point = CFrame.new(point); end;
		if (typeof(point) == 'Instance') then point = point.CFrame; end;

		local root = lplr.Character and lplr.Character:FindFirstChild('HumanoidRootPart');
		if (not root) then return; end;

		if (lplr.Character.Humanoid.SeatPart) then
			lplr.Character.Humanoid.Sit = false;
			runService.Heartbeat:Wait();
		end;

		local streamTask = task.spawn(function()
			while (true) do
				lplr:RequestStreamAroundAsync(point.Position);
				task.wait();
			end;
		end);

		task.delay(funcs.isPointLoaded(point.Position) and 0.3 or 0, function()
			root.CFrame = point;
			root.AssemblyLinearVelocity = Vector3.zero;
			root.AssemblyAngularVelocity = Vector3.zero;

			task.cancel(streamTask);
		end);
	end;
end;

do -- funcs
	function funcs.autoRun(t)
		if (not t) then
			maid.autoRun = nil
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

	function funcs.noclipFix(t)
		if (not t) then
			maid.noclipFix = nil;
			return;
		end;

		maid.noclipFix = runService.Heartbeat:Connect(function()
			local root = lplr.Character and lplr.Character.PrimaryPart;
			if (not root) then return; end;

			local velocity = root.AssemblyLinearVelocity;
			local floor = funcs.isPointLoaded(root.CFrame.Position, 5);

			if (velocity.Y < -100 and floor) then
				root.AssemblyLinearVelocity = Vector3.new(velocity.X, 0, velocity.Z);
			end;
		end);
	end;

	do -- godmode
		local part, oldCf, oldSize;
		function funcs.god(t)
			if (not t) then
				if (not part or not oldCf or not oldSize) then return; end;

				part.CFrame = oldCf;
				part.Size = oldSize;

				return;
			end;

			local streamTask = task.spawn(function()
				while (true) do
					lplr:RequestStreamAroundAsync(Vector3.new(-1635, 4, -93));
					task.wait();
				end;
			end);

			local cachedPart = cache.godPart;
			if (cachedPart) then
				part = cachedPart;
				task.wait(0.2);
			else
				repeat
					for _, v in safeZones:GetChildren() do
						if (not v:IsA('BasePart')) then continue; end;
						if (v.Name ~= 'safeZoneArea') then continue; end;

						part = v;
						break;
					end;
					task.wait();
				until part;
			end;

			oldSize = part.Size;
			oldCf = part.CFrame;
			task.cancel(streamTask);

			repeat
				local root = lplr.Character and lplr.Character.PrimaryPart;
				if (not root) then return; end;

				part.Size = Vector3.one * 2040;
				part.CFrame = root.CFrame;

				task.wait(3);
			until not library.flags.godMode;
		end;
	end;

	function funcs.noRagdoll()
		while (library.flags.antiRagdoll) do
			local ragdoll = lplr.PlayerGui and lplr.PlayerGui:FindFirstChild('ragdoll');
			if (not ragdoll) then task.wait(); continue; end;

			local events = ragdoll:FindFirstChild('events');
			if (not events) then task.wait(); continue; end;

			local remote = events:FindFirstChild('variableserver');
			if (not remote) then task.wait(); continue; end;

			remote:FireServer('ragdoll', false);
			task.wait();
		end;
	end;

	function funcs.autoKill(t)
		if (not t) then
			maid.autoKill = nil;
			return;
		end;

		maid.autoKill = runService.Heartbeat:Connect(function()
			for _, v in next, players:GetPlayers() do
				if (v == lplr) then continue; end;

				local root = v.Character and v.Character:FindFirstChild('HumanoidRootPart');
				if (not root) then continue; end;

				local hum = v.Character:FindFirstChildOfClass('Humanoid');
				if (not hum) then continue; end;

				local head = v.Character:FindFirstChild('Head');
				if (not head) then continue; end;

				local collision = head:FindFirstChild('HeadCollision');
				if (not collision) then continue; end;

				if (hum.Health > 100) then continue; end;

				local weapon = funcs.getWeapon();
				if (not weapon) then continue; end;

				remotes.InflictTarget:InvokeServer(unpack({
					[1] = 'Gun',
					[2] = weapon,
					[3] = require(weaponSettings[weapon.Name].Setting['1']),
					[4] = hum,
					[5] = root,
					[6] = collision,
					[7] = Vector3.one,
					[8] = {
						ChargeLevel = 0,
						ExplosionEffectFolder = gunEffects.ExplosionEffect,
						MuzzleFolder = gunEffects.MuzzleEffect,
						HitEffectFolder = gunEffects.HitEffect,
						GoreEffect = gunEffects.GoreEffect,
						BloodEffectFolder = gunEffects.BloodEffect
					},
					[9] = 0
				}));
			end;
		end);
	end;

	do -- gun mods
		local old = {};

		local function hook(prop, val)
			for _, v in next, gunsList do
				old[v] = old[v] or {};

				if (not old[v][prop]) then
					old[v][prop] = require(weaponSettings[v].Setting['1'])[prop];
				end;

				require(weaponSettings[v].Setting['1'])[prop] = val;
			end;
		end;

		local function unhook(prop)
			if (not next(old)) then return; end;

			for _, v in next, gunsList do
				if (not old[v] or not old[v][prop]) then continue; end;

				require(weaponSettings[v].Setting['1'])[prop] = old[v][prop];
				old[v][prop] = nil;
			end;
		end;

		_G.debugGunMods = function()
			for k, v in next, old do
				if (typeof(v) == 'table') then
					for k2, v2 in next, v do
						print(k2, v2);
					end;
				end;

				print(k, v);
			end;
		end;

		function funcs.modGuns(t)
			if (not t) then
				unhook('BaseDamage');
				unhook('AmmoCost');
				unhook('Spread');
				unhook('FireRate');
				unhook('Auto');
				unhook('CameraRecoilingEnabled');
				unhook('Recoil');
				unhook('Range');
				unhook('ZeroDamageDistance');
				unhook('FullDamageDistance');
				unhook('BulletShellEnabled');
				unhook('Knockback');
				return;
			end;

			hook('BaseDamage', 9e9); -- insta kill
			hook('AmmoCost', 0); -- inf ammo
			hook('Spread', 0); -- no spread
			hook('FireRate', 0.001); -- fast fire rate
			hook('Auto', true); -- always auto
			hook('CameraRecoilingEnabled', false); -- no cam recoil
			hook('Recoil', 0); -- no gun recoil
			hook('Range', 9e9); -- inf range
			hook('ZeroDamageDistance', 9e9); -- inf range
			hook('FullDamageDistance', 9e9); -- inf range
			hook('BulletShellEnabled', false); -- no bullet shells
			hook('Knockback', 9e9); -- kill people who dont have guns
		end;
	end;

	do -- auto rob cars
		local old;

		local function rob(car)
			local scripts = car:FindFirstChild('Scripts');
			if (not scripts) then return; end;

			local part = scripts:FindFirstChild('ProxPart');
			if (not part) then return; end;

			local prompt = part:FindFirstChild('ProximityPrompt');
			if (not prompt) then return; end;

			funcs.teleport(part);

			fireproximityprompt(prompt);
		end;

		function funcs.robCars()
			while (library.flags.autoRobCars) do
				local root = lplr.Character and lplr.Character.PrimaryPart;
				if (not root) then continue; end;

				if (not old) then old = root.CFrame; end;

				for _, v in carRobberys:GetChildren() do
					if (not library.flags.autoRobCars) then break; end;

					local window = v.Parts:FindFirstChild('Window');
					if (not window) then continue; end;

					if (window.Transparency == 1) then continue; end;

					funcs.teleport(v:GetPivot() * CFrame.new(0, 5, 0));
					rob(v);

					task.wait(1.5);
				end;

				if (old) then funcs.teleport(old); old = nil; end;
				task.wait();
			end;
		end;
	end;

	do -- wee farm
		local weed = {};
		weed.start = Vector3.new(-1986, 7, 177);
		weed.sell = Vector3.new(-2005, 3, 198);
		weed.found = {};

		function weed.get()
			for _, v in next, workspace:GetDescendants() do
				if (not v:IsA('ProximityPrompt')) then continue; end;
				if (not v.Parent:IsA('MeshPart')) then continue; end;
				if (v.Parent.Name ~= 'Grass') then continue; end;
				if (v.Parent.Transparency ~= 0) then continue; end;

				weed.found.found = true;
				weed.found.prompt = v;
				weed.found.part = v.Parent;
			end;
		end;

		function weed.clear()
			weed.found.found = false;
			weed.found.prompt = nil;
			weed.found.part = nil;
		end;

		function funcs.weedFarm()
			while (library.flags.weedFarm) do
				local root = lplr.Character and lplr.Character.PrimaryPart;
				if (not root) then continue; end;

				funcs.teleport(weed.start);
				weed.clear();

				repeat
					if (not library.flags.weedFarm) then break; end;

					weed.get();
					task.wait(2);
				until weed.found.found;

				funcs.teleport(weed.found.part);
				fireproximityprompt(weed.found.prompt);

				task.wait(0.15);

				while (lplr.Character:FindFirstChild('Grass') or lplr.Backpack:FindFirstChild('Grass')) do
					if (lplr.Backpack:FindFirstChild('Grass')) then
						lplr.Backpack.Grass.Parent = lplr.Character;
						runService.Heartbeat:Wait();
					end;

					funcs.teleport(weed.sell);

					task.delay(1, function()
						local transmitter = cache.weedTouchTransmitter;
						if (transmitter) then
							firetouchinterest(root, transmitter, 0);
							task.wait();
							firetouchinterest(root, transmitter, 1);
						else
							for _, v in next, workspace:GetDescendants() do
								if (not v:FindFirstChild('BoxPlay')) then continue; end;
								if (not v:FindFirstChild('Script')) then continue; end;
								if (not v:FindFirstChild('TouchInterest')) then continue; end;

								cache.weedTouchTransmitter = v;
								firetouchinterest(root, v, 0);
								task.wait();
								firetouchinterest(root, v, 1);
							end;
						end;
					end);

					task.wait();
				end;

				weed.clear();
				task.wait(3);
			end;
		end;
	end;

	do -- box farm
		local box = {};
		box.start = Vector3.new(-1941, 3, -49);
		box.sell = Vector3.new(-1925, 3, -22);

		function funcs.boxFarm()
			while (library.flags.boxFarm) do
				local root = lplr.Character and lplr.Character.PrimaryPart;
				if (not root) then continue; end;

				funcs.teleport(box.start);

				local boxPrompt = cache.boxPrompt;
				if (boxPrompt) then
					fireproximityprompt(boxPrompt);
				else
					for _, v in next, jobSystem:GetDescendants() do
						if (not v:IsA('ProximityPrompt')) then continue; end;
						if (v.ObjectText ~= '📦Deliver the crate to the truck') then continue; end;

						cache.boxPrompt = v;
						fireproximityprompt(v);
						break;
					end;
				end;

				task.wait(0.15);

				while (lplr.Character:FindFirstChild('BOX') or lplr.Backpack:FindFirstChild('BOX')) do
					if (lplr.Backpack:FindFirstChild('BOX')) then
						lplr.Backpack.BOX.Parent = lplr.Character;
						runService.Heartbeat:Wait();
					end;

					funcs.teleport(box.sell);

					task.delay(1, function()
						local transmitter = cache.boxTouchTransmitter;
						if (transmitter) then
							firetouchinterest(root, transmitter, 0);
							task.wait();
							firetouchinterest(root, transmitter, 1);
						else
							for _, v in next, jobSystem:GetDescendants() do
								if (not v:FindFirstChild('BoxPlay')) then continue; end;
								if (not v:FindFirstChild('Script')) then continue; end;
								if (not v:FindFirstChild('TouchInterest')) then continue; end;

								cache.boxTouchTransmitter = v;
								firetouchinterest(root, v, 0);
								task.wait();
								firetouchinterest(root, v, 1);
							end;
						end;
					end);

					task.wait();
				end;

				task.wait(3);
			end;
		end;
	end;

	function funcs.noDeathEffect()
		while (library.flags.noDeathEffect) do
			local damageUi = lplr.PlayerGui:FindFirstChild('Damage GUI');
			if (not damageUi) then continue; end;

			for _, v in next, damageUi:GetChildren() do
				if (not v:IsA('ImageLabel')) then continue; end;
				v.Visible = false;
			end;

			task.wait();
		end;
	end;

	function funcs.betterDeathEffect(t)
		lplr.PlayerGui['Damage GUI'].IgnoreGuiInset = t;
	end;

	do -- no gun blur
		local old = blurModule.Create;
		function funcs.noGunBlur(t)
			if (not t) then
				blurModule.Create = old;
				return;
			end;

			blurModule.Create = function() end;
		end;
	end;

	function funcs.instantPP(t)
		if (not t) then
			maid.instantInteract = nil;
			return;
		end;

		maid.instantInteract = promptService.PromptButtonHoldBegan:Connect(fireproximityprompt);
	end;

	do -- drop useless tools
		local function destroyTools()
			if (not lplr.Character) then return; end;

			local unnecessaryTools = { 'Phone', 'Mop', 'Laptop' };

			for _, v in next, lplr.Backpack:GetChildren() do
				if (not v:IsA('Tool')) then continue; end;
				if (not table.find(unnecessaryTools, v.Name)) then continue; end;

				v:Destroy();
			end;
			for _, v in next, lplr.Character:GetChildren() do
				if (not v:IsA('Tool')) then continue; end;
				if (not table.find(unnecessaryTools, v.Name)) then continue; end;

				v.Parent = workspace;
			end;
		end;

		function funcs.dropUselessTools()
			while (library.flags.dropUnnecessaryTools) do
				destroyTools()
				task.wait();
			end;
		end;
	end;

	function funcs.redeemCode()
		for _, v in next, lplr.CodesFolder:GetChildren() do
			if (not v:IsA('BoolValue')) then continue; end;
			if (v.Value) then continue; end;

			repoStore.codeEvent:FireServer(v.Name);

			ToastNotif.new({
				text = string.format('redeemed: %s', v.Name),
				duration = 5
			});

			task.wait();
		end;
	end;
end;

do -- ui
	local character = main1:AddSection('Character');
	local combat = main2:AddSection('Combat');
	local autofarm = main2:AddSection('Auto Farm');
	local extra = main2:AddSection('Extra');

	local esp = visual1:AddSection('ESP');
	local effects = visual2:AddSection('Effects');

	do -- character
		character:AddToggle({
			text = 'Speed',
			callback = function(t)
				basics.speed(t, library.flags.speedValue, true);
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
				basics.speed(library.flags.speed, val, true);
			end
		});

		character:AddToggle({
			text = 'Fly',
			callback = function(t)
				basics.fly(t, library.flags.flySpeedValue, true);
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
				basics.fly(library.flags.fly, val, true, true);
			end
		});

		character:AddToggle({
			text = 'Auto Sprint',
			callback = funcs.autoRun
		});

		character:AddToggle({
			text = 'Noclip',
			callback = function(t)
				basics.noclip(t, true);
				funcs.noclipFix(t);
			end
		}):AddBind({
			flag = 'noclip bind',
			callback = function()
				library.options.noclip:SetState(not library.flags.noclip);
			end
		});

		character:AddToggle({
			text = 'Inf Jump',
			callback = function(t)
				basics.infJump(t);
			end
		});

		character:AddToggle({
			text = 'God Mode',
			callback = funcs.god
		});

		character:AddToggle({
			text = 'Anti Ragdoll',
			callback = funcs.noRagdoll
		});
	end;

	do -- combat
		combat:AddToggle({
			text = 'Auto Kill',
			tip = 'this wont work with modded guns :(',
			callback = funcs.autoKill
		}):AddBind({
			flag = 'auto kill bind',
			callback = function()
				library.options.autoKill:SetState(not library.flags.autoKill);
			end
		});

		combat:AddToggle({
			text = 'Mod Guns',
			callback = funcs.modGuns
		}):AddBind({
			flag = 'mod guns bind',
			callback = function()
				library.options.modGuns:SetState(not library.flags.modGuns);
			end
		});
	end;

	do -- autofarm
		autofarm:AddToggle({
			text = 'Auto Rob Cars',
			callback = funcs.robCars
		});

		autofarm:AddToggle({
			text = 'Weed Farm',
			callback = funcs.weedFarm
		});

		autofarm:AddToggle({
			text = 'Box Farm',
			callback = funcs.boxFarm
		});
	end;

	do -- extra
		extra:AddToggle({
			text = 'Chat Logger',
			callback = funcs.chatLogger
		}):AddBind({
			flag = 'chat logger bind',
			callback = function()
				library.options.chatLogger:SetState(not library.flags.chatLogger);
			end
		});

		extra:AddToggle({
			text = 'Instant Interact',
			callback = funcs.instantPP
		});

		extra:AddToggle({
			text = 'Drop Unnecessary Tools',
			callback = funcs.dropUselessTools
		});

		extra:AddButton({
			text = 'Redeem All Codes',
			callback = funcs.redeemCode
		});
	end;

	do -- esp
		esp:AddToggle({
			text = 'Enabled',
			flag = 'toggle esp',
			callback = funcs.enableESP
		}):AddColor({
			flag = 'enemy Color',
			color = Color3.fromRGB(255, 0, 0)
		});

		esp:AddDivider();

		esp:AddList({
			text = 'Esp Font',
			values = {'UI', 'System', 'Plex', 'Monospace'},
			callback = funcs.updateESPFont
		});

		esp:AddSlider({
			text = 'Text Size',
			textpos = 2,
			max = 100,
			min = 16,
			callback = funcs.updateESPTextSize
		});

		esp:AddDivider();
		esp:AddToggle({text = 'Render Tracers'});
		esp:AddToggle({text = 'Render Boxes'});
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
		esp:AddToggle({text = 'Display Name', state = true});
		esp:AddToggle({text = 'Display Distance'});
		esp:AddToggle({text = 'Display Health'});

		esp:AddDivider();
		esp:AddToggle({text = 'Use Float Health', tip = 'shows the players health as a percentage'});
		esp:AddToggle({text = 'Unlock Tracers'});

		esp:AddDivider();
		esp:AddToggle({text = 'Rainbow', callback = funcs.toggleRainbowEsp('enemyColor')});
	end;

	do -- effects
		effects:AddToggle({
			text = 'Full Bright',
			callback = function()
				basics.fullBright(library.flags.fullBright);
			end
		});

		effects:AddToggle({
			text = 'No Death Effect',
			tip = 'removes the death screen',
			callback = funcs.noDeathEffect
		});

		effects:AddToggle({
			text = 'Better Death Effect',
			tip = 'makes the death cam better',
			callback = funcs.betterDeathEffect
		});

		effects:AddToggle({
			text = 'No Gun Blur',
			callback = funcs.noGunBlur
		});
	end;
end;

library:Init();