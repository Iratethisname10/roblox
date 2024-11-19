local inputService = game:GetService('UserInputService');
local inputManager = game:GetService('VirtualInputManager');
local chatService = game:GetService('TextChatService');
local players = game:GetService('Players');
local coreUi = game:GetService('CoreGui');

local lplr = players.LocalPlayer;

local junk = workspace.Junk;

local speed;
local tackle;

do
	local function add(class, props)
		props = props or {};
		if (not class) then return; end;

		local inst = Instance.new(class);
		for p, v in next, props do
			inst[p] = v;
		end;

		return inst;
	end;

	local mainUi = add('ScreenGui', {
		Name = '',
		Parent = coreUi
	});

	local adMain = add('Frame', {
		Name = '',
		Parent = mainUi,
		BackgroundColor3 = Color3.fromRGB(66, 66, 66),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0.599304259, 0, 0.133744851, 0),
		Size = UDim2.new(0, 364, 0, 102)
	});

	add('TextLabel', {
		Name = '',
		Parent = adMain,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1.000,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(-5.03037029e-07, 0, 0, 0),
		Size = UDim2.new(0, 363, 0, 50),
		Font = Enum.Font.FredokaOne,
		Text = 'paid version has full anticheat bypass and other insane features',
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		TextSize = 14.000,
		TextWrapped = true
	});

	add('TextLabel', {
		Name = '',
		Parent = adMain,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1.000,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(-5.03037029e-07, 0, 0.549019635, 0),
		Selectable = true,
		Size = UDim2.new(0, 363, 0, 52),
		Font = Enum.Font.FredokaOne,
		Text = 'https://discord.gg/Gxg42Eshpy',
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		TextSize = 14.000,
		TextWrapped = true
	});

	add('Frame', {
		Name = '',
		Parent = adMain,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(-1.67679005e-07, 0, 0.549019635, 0),
		Size = UDim2.new(0, 364, 0, 6)
	});

	local dcInv = add('TextButton', {
		Name = '',
		Parent = adMain,
		BackgroundColor3 = Color3.fromRGB(66, 66, 66),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0.56868118, 0, 1, 0),
		Size = UDim2.new(0, 157, 0, 42),
		Font = Enum.Font.FredokaOne,
		Text = 'copy to clipboard',
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		TextSize = 14.000,
		TextWrapped = true
	});

	local bindMain = add('Frame', {
		Name = '',
		Parent = mainUi,
		BackgroundColor3 = Color3.fromRGB(66, 66, 66),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0.0727388188, 0, 0.240054861, 0),
		Size = UDim2.new(0, 132, 0, 115)
	});

	tackle = add('TextLabel', {
		Name = '',
		Parent = bindMain,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1.000,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 132, 0, 46),
		Font = Enum.Font.FredokaOne,
		Text = '[E] Tackle Aura - off',
		TextColor3 = Color3.fromRGB(255, 0, 0),
		TextSize = 16.000,
		TextWrapped = true
	});

	speed = add('TextLabel', {
		Name = '',
		Parent = bindMain,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1.000,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.400000006, 0),
		Size = UDim2.new(0, 132, 0, 46),
		Font = Enum.Font.FredokaOne,
		Text = '[R] Speed - off',
		TextColor3 = Color3.fromRGB(255, 0, 0),
		TextSize = 16.000,
		TextWrapped = true
	});

	local function onClick()
		return setclipboard('https://discord.gg/Gxg42Eshpy');
	end;

	dcInv.MouseButton1Click:Connect(onClick);
	dcInv.MouseButton2Click:Connect(onClick);
end;

do
	local speedOn = false;
	local tackleOn = false;

	local function onInputBegan(input, gpe)
		if (gpe) then return; end;

		if (input.KeyCode == Enum.KeyCode.R) then
			speedOn = true;
			speed.TextColor3 = Color3.fromRGB(0, 255, 0);
		elseif (input.KeyCode == Enum.KeyCode.E) then
			tackleOn = true;
			tackle.TextColor3 = Color3.fromRGB(0, 255, 0);
		end
	end;

	local function onInputEnded(input, gpe)
		if (gpe) then return; end;

		if (input.KeyCode == Enum.KeyCode.R) then
			speedOn = false;
			speed.TextColor3 = Color3.fromRGB(255, 0, 0);
		elseif (input.KeyCode == Enum.KeyCode.E) then
			tackleOn = false;
			tackle.TextColor3 = Color3.fromRGB(255, 0, 0);
		end
	end;

	inputService.InputBegan:Connect(onInputBegan);
	inputService.InputEnded:Connect(onInputEnded);

	task.spawn(function()
		while (true) do
			if (not speedOn) then task.wait(); continue; end;

			local hum = lplr.Character:FindFirstChildOfClass('Humanoid');
			if (not hum) then task.wait(); continue; end;

			hum.WalkSpeed = 50;
			task.wait(0.5);
			hum.WalkSpeed = 16;
			task.wait(0.8);
		end;
	end);

	task.spawn(function()
		while (true) do
			if (not tackleOn) then task.wait(); continue; end;

			local ball = junk:FindFirstChild('Football');
			if (not ball) then task.wait(); continue; end;

			local root = lplr.Character and lplr.Character.PrimaryPart;
			if (not root) then task.wait(); continue; end;

			local ballPos = ball.CFrame.Position;
			local rootPos = root.CFrame.Position;

			if ((ballPos - rootPos).Magnitude > 15) then task.wait(); continue; end;

			local dir = Vector3.new(ballPos.X - rootPos.X, 0, ballPos.Z - rootPos.Z).Unit;
			root.CFrame = CFrame.new(rootPos, rootPos + dir);

			if (inputService:GetFocusedTextBox()) then task.wait(); continue; end;

			inputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game);
			task.wait();
			inputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game);

			task.wait();
		end;
	end);

	task.spawn(function()
		while (true) do
			local channel = chatService.ChatInputBarConfiguration.TargetTextChannel;
			channel:SendAsync('GET SCRIPT - g g / G x g 4 2 E s h p y');
			task.wait(9 + math.random(0, 10));
		end;
	end);
end;