local libraryLoadAt = tick();

local function getIcons()
	local url = 'https://raw.githubusercontent.com/Iratethisname10/roblox/refs/heads/main/store/orion-icons.json';
	local suc, res = pcall(function() return game:HttpGet(url); end);
	if (not suc or table.find({'404: Not Found', '400: Invalid Request'}, res)) then return warn('getscript failed 2'); end;

	return res;
end;

local cloneref = cloneref or function(inst) return inst; end;

local inputService = cloneref(game:GetService('UserInputService'));
local tweenService = cloneref(game:GetService('TweenService'));
local runService = cloneref(game:GetService('RunService'));
local httpService = cloneref(game:GetService('HttpService'));
local players = cloneref(game:GetService('Players'));
local coreUi = cloneref(game:GetService('CoreGui'));

local localPlayer = players.LocalPlayer;
local localMouse = localPlayer:GetMouse();

local library = {
	elements = {},
	themeObjects = {},
	connections = {},
	title = 'vocat\'s script | __vocat on discord',
	flags = {},
	themes = {
		default = {
			Main = Color3.fromRGB(25, 25, 25),
			Second = Color3.fromRGB(32, 32, 32),
			Stroke = Color3.fromRGB(60, 60, 60),
			Divider = Color3.fromRGB(60, 60, 60),
			Text = Color3.fromRGB(240, 240, 240),
			TextDark = Color3.fromRGB(150, 150, 150)
		}
	},
	selectedTheme = 'default',
	active = true
};

local function decode(data)
	local suc, res = pcall(httpService.JSONDecode, httpService, data);
	if (not suc) then
		repeat
			suc, res = pcall(httpService.JSONDecode, httpService, data);
			task.wait();
		until suc;
	end;

	return res;
end;

local icons = decode(getIcons());

local function getIcon(name)
	if (not icons[name]) then return; end;
	return icons[name];
end;

local baseUi = Instance.new('ScreenGui')
baseUi.Name = 'Orion'
baseUi.Parent = gethui and gethui() or coreUi;

local function addConnection(signal, func)
	if (not library.active) then return; end;

	local listener = signal:Connect(func);
	table.insert(library.connections, listener);

	return listener;
end;

task.spawn(function()
	while (library.active) do
		task.wait();
	end;

	for _, v in next, library.connections do
		v:Disconnect()
	end
end)

local function allowDrag(point, ui)
	local doing, dInput, mPos, fPos = false, false, false, false;
	local tInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);

	point.InputBegan:Connect(function(input)
		if (input.UserInputType ~= Enum.UserInputType.MouseButton1) then return; end;
		doing, mPos, fPos = true, input.Position, ui.Position;

		input.Changed:Connect(function()
			if (input.UserInputState ~= Enum.UserInputState.End) then return; end;
			doing = false;
		end);
	end);

	point.InputChanged:Connect(function(input)
		if (input.UserInputType ~= Enum.UserInputType.MouseMovement) then return; end;
		dInput = input;
	end);

	inputService.InputChanged:Connect(function(input)
		if (input ~= dInput or not doing) then return; end;
		local delta = input.Position - mPos;

		tweenService:Create(ui, tInfo, {
			Position = UDim2.new(fPos.X.Scale, fPos.X.Offset + delta.X, fPos.Y.Scale, fPos.Y.Offset + delta.Y)
		}):Play();
	end);
end;

local function create(name, props, children)
	local inst = Instance.new(name);

	for i, v in next, props or {} do
		inst[i] = v;
	end;

	for _, v in next, children or {} do
		v.Parent = inst;
	end;

	return inst;
end;

local function createElement(name, func)
	library.elements[name] = function(...)
		return func(...);
	end;
end;

local function makeElement(name, ...)
	local NewElement = library.elements[name](...);
	return NewElement;
end;

local function setProps(element, props)
	for i, v in next, props do
		element[i] = v;
	end;

	return element;
end;

local function setChildren(element, children)
	for _, v in next, children do
		v.Parent = element;
	end;

	return element;
end;

local function round(number, factor)
	local result = math.floor(number / factor + (math.sign(number) * 0.5)) * factor;
	if (result < 0) then result += factor; end;

	return result;
end;

local function returnProp(obj)
	if (obj:IsA('Frame') or obj:IsA('TextButton')) then
		return 'BackgroundColor3';
	end;

	if (obj:IsA('ScrollingFrame')) then
		return 'ScrollBarImageColor3';
	end;

	if (obj:IsA('UIStroke')) then
		return 'Color';
	end;

	if (obj:IsA('TextLabel') or obj:IsA('TextBox')) then
		return 'TextColor3';
	end;

	if (obj:IsA('ImageLabel') or obj:IsA('ImageButton')) then
		return 'ImageColor3';
	end;
end;

local function addThemeObject(obj, kind)
	if (not library.themeObjects[kind]) then
		library.themeObjects[kind] = {};
	end;

	table.insert(library.themeObjects[kind], obj);
	obj[returnProp(obj)] = library.themes[library.selectedTheme][kind];

	return obj;
end;

local function toCamelCase(text)
	return string.lower(text):gsub('%s(.)', string.upper);
end;

local whitelistedMouse = { Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3 };
local blacklistedKeys = { Enum.KeyCode.Unknown, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right, Enum.KeyCode.Slash, Enum.KeyCode.Tab, Enum.KeyCode.Backspace, Enum.KeyCode.Escape };

local function checkKey(t, k)
	for _, v in next, t do
		if (v ~= k) then continue; end;
		return true;
	end;
end;

createElement('Corner', function(scale, offset)
	return create('UICorner', {
		CornerRadius = UDim.new(scale or 0, offset or 10)
	});
end);

createElement('Stroke', function(color, thickness)
	return create('UIStroke', {
		Color = color or Color3.fromRGB(255, 255, 255),
		Thickness = thickness or 1
	});
end);

createElement('List', function(scale, offset)
	return create('UIListLayout', {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(scale or 0, offset or 0)
	});
end);

createElement('Padding', function(bottom, left, right, top)
	return create('UIPadding', {
		PaddingBottom = UDim.new(0, bottom or 4),
		PaddingLeft = UDim.new(0, left or 4),
		PaddingRight = UDim.new(0, right or 4),
		PaddingTop = UDim.new(0, top or 4)
	});
end);

createElement('TFrame', function()
	return create('Frame', {
		BackgroundTransparency = 1
	});
end);

createElement('Frame', function(color)
	return create('Frame', {
		BackgroundColor3 = color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	});
end);

createElement('RoundFrame', function(color, scale, offset)
	return create('Frame', {
		BackgroundColor3 = color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	}, {
		create('UICorner', {
			CornerRadius = UDim.new(scale, offset)
		})
	});
end);

createElement('Button', function()
	return create('TextButton', {
		Text = '',
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	});
end);

createElement('ScrollFrame', function(color, width)
	return create('ScrollingFrame', {
		BackgroundTransparency = 1,
		MidImage = 'rbxassetid://7445543667',
		BottomImage = 'rbxassetid://7445543667',
		TopImage = 'rbxassetid://7445543667',
		ScrollBarImageColor3 = color,
		BorderSizePixel = 0,
		ScrollBarThickness = width,
		CanvasSize = UDim2.new(0, 0, 0, 0)
	});
end);

createElement('Image', function(imageId)
	local imageLabel = create('ImageLabel', {
		Image = imageId,
		BackgroundTransparency = 1
	});

	if (getIcon(imageId)) then
		imageLabel.Image = getIcon(imageId);
	end;

	return imageLabel;
end);

createElement('ImageButton', function(imageId)
	return create('ImageButton', {
		Image = imageId,
		BackgroundTransparency = 1
	});
end);

createElement('Label', function(text, textSize, transparency)
	return create('TextLabel', {
		Text = text or '',
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = transparency or 0,
		TextSize = textSize or 15,
		Font = Enum.Font.Gotham,
		RichText = true,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left
	});
end);

local notifHolder = setProps(setChildren(makeElement('TFrame'), {
	setProps(makeElement('List'), {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 5)
	})
}), {
	Position = UDim2.new(1, -25, 1, -25),
	Size = UDim2.new(0, 300, 1, -25),
	AnchorPoint = Vector2.new(1, 1),
	Parent = baseUi
});

function library:SendNotif(option)
	task.spawn(function()
		option = typeof(option) == 'table' and option or {};
		option.title = tostring(option.title);
		option.text = tostring(option.text);
		option.icon = typeof(option.icon) == 'string' and option.icon or typeof(option.icon) == 'number' and 'rbxassetid://' .. tostring(option.icon) or 'rbxassetid://4384403532';
		option.duration = typeof(option.duration) == 'number' and option.duration or 15;

		local notifParent = setProps(makeElement('TFrame'), {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = notifHolder
		})

		local notifFrame = setChildren(setProps(makeElement('RoundFrame', Color3.fromRGB(25, 25, 25), 0, 10), {
			Parent = notifParent,
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(1, -55, 0, 0),
			BackgroundTransparency = 0,
			AutomaticSize = Enum.AutomaticSize.Y
		}), {
			makeElement('Stroke', Color3.fromRGB(93, 93, 93), 1.2),
			makeElement('Padding', 12, 12, 12, 12),
			setProps(makeElement('Image', option.icon), {
				Size = UDim2.new(0, 20, 0, 20),
				ImageColor3 = Color3.fromRGB(240, 240, 240),
				Name = 'Icon'
			}),
			setProps(makeElement('Label', option.title, 15), {
				Size = UDim2.new(1, -30, 0, 20),
				Position = UDim2.new(0, 30, 0, 0),
				Font = Enum.Font.GothamBold,
				Name = 'Title'
			}),
			setProps(makeElement('Label', option.text, 14), {
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 25),
				Font = Enum.Font.GothamSemibold,
				Name = 'Content',
				AutomaticSize = Enum.AutomaticSize.Y,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextWrapped = true
			})
		});

		tweenService:Create(notifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play();
		task.wait(option.duration - 0.88);

		tweenService:Create(notifFrame.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play();
		tweenService:Create(notifFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play();
		task.wait(0.3);

		tweenService:Create(notifFrame.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 0.9}):Play();
		tweenService:Create(notifFrame.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play();
		tweenService:Create(notifFrame.Content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play();
		task.wait(0.05);

		notifFrame:TweenPosition(UDim2.new(1, 20, 0, 0), 'In', 'Quint', 0.8, true);
		task.wait(1.35);

		notifFrame:Destroy();
	end);
end;

function library:Destroy()
	self.active = false;
	baseUi:Destroy();
end;

function library:Start()
	local Minimized = false;

	local tabHolder = addThemeObject(setChildren(setProps(makeElement('ScrollFrame', Color3.fromRGB(255, 255, 255), 4), {
		Size = UDim2.new(1, 0, 1, -50)
	}), {
		makeElement('List'),
		makeElement('Padding', 8, 0, 0, 8)
	}), 'Divider');

	addConnection(tabHolder.UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'), function()
		tabHolder.CanvasSize = UDim2.new(0, 0, 0, tabHolder.UIListLayout.AbsoluteContentSize.Y + 16);
	end);

	local closeBtn = setChildren(setProps(makeElement('Button'), {
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1
	}), {
		addThemeObject(setProps(makeElement('Image', 'rbxassetid://7072725342'), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18)
		}), 'Text')
	});

	local minimizeBtn = setChildren(setProps(makeElement('Button'), {
		Size = UDim2.new(0.5, 0, 1, 0),
		BackgroundTransparency = 1
	}), {
		addThemeObject(setProps(makeElement('Image', 'rbxassetid://7072719338'), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18),
			Name = 'Ico'
		}), 'Text')
	});

	local dragPoint = setProps(makeElement('TFrame'), {
		Size = UDim2.new(1, 0, 0, 50)
	});

	local windowStuff = addThemeObject(setChildren(setProps(makeElement('RoundFrame', Color3.fromRGB(255, 255, 255), 0, 10), {
		Size = UDim2.new(0, 150, 1, -50),
		Position = UDim2.new(0, 0, 0, 50)
	}), {
		addThemeObject(setProps(makeElement('Frame'), {
			Size = UDim2.new(1, 0, 0, 10),
			Position = UDim2.new(0, 0, 0, 0)
		}), 'Second'),
		addThemeObject(setProps(makeElement('Frame'), {
			Size = UDim2.new(0, 10, 1, 0),
			Position = UDim2.new(1, -10, 0, 0)
		}), 'Second'),
		addThemeObject(setProps(makeElement('Frame'), {
			Size = UDim2.new(0, 1, 1, 0),
			Position = UDim2.new(1, -1, 0, 0)
		}), 'Stroke'),
		tabHolder,
		setChildren(setProps(makeElement('TFrame'), {
			Size = UDim2.new(1, 0, 0, 50),
			Position = UDim2.new(0, 0, 1, -50)
		}), {
			addThemeObject(setProps(makeElement('Frame'), {
				Size = UDim2.new(1, 0, 0, 1)
			}), 'Stroke'),
			addThemeObject(setChildren(setProps(makeElement('Frame'), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 32, 0, 32),
				Position = UDim2.new(0, 10, 0.5, 0)
			}), {
				setProps(makeElement('Image', 'https://www.roblox.com/headshot-thumbnail/image?userId=1&width=420&height=420&format=png'), {
					Size = UDim2.new(1, 0, 1, 0)
				}),
				addThemeObject(setProps(makeElement('Image', 'rbxassetid://4031889928'), {
					Size = UDim2.new(1, 0, 1, 0),
				}), 'Second'),
				makeElement('Corner', 1)
			}), 'Divider'),
			setChildren(setProps(makeElement('TFrame'), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 32, 0, 32),
				Position = UDim2.new(0, 10, 0.5, 0)
			}), {
				addThemeObject(makeElement('Stroke'), 'Stroke'),
				makeElement('Corner', 1)
			}),
			addThemeObject(setProps(makeElement('Label', 'Cheese Cake', 14), {
				Size = UDim2.new(1, -60, 0, 13),
				Position = UDim2.new(0, 50, 0, 19),
				Font = Enum.Font.GothamBold,
				ClipsDescendants = true
			}), 'Text')
		}),
	}), 'Second');

	local windowName = addThemeObject(setProps(makeElement('Label', library.title, 14), {
		Size = UDim2.new(1, -30, 2, 0),
		Position = UDim2.new(0, 25, 0, -24),
		Font = Enum.Font.GothamBlack,
		TextSize = 20
	}), 'Text');

	local windowTopbarLine = addThemeObject(setProps(makeElement('Frame'), {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1)
	}), 'Stroke');

	local mainWindow = addThemeObject(setChildren(setProps(makeElement('RoundFrame', Color3.fromRGB(255, 255, 255), 0, 10), {
		Parent = baseUi,
		Position = UDim2.new(0.5, -307, 0.5, -172),
		Size = UDim2.new(0, 615, 0, 344),
		ClipsDescendants = true
	}), {
		setChildren(setProps(makeElement('TFrame'), {
			Size = UDim2.new(1, 0, 0, 50),
			Name = 'TopBar'
		}), {
			windowName,
			windowTopbarLine,
			addThemeObject(setChildren(setProps(makeElement('RoundFrame', Color3.fromRGB(255, 255, 255), 0, 7), {
				Size = UDim2.new(0, 70, 0, 30),
				Position = UDim2.new(1, -90, 0, 10)
			}), {
				addThemeObject(makeElement('Stroke'), 'Stroke'),
				addThemeObject(setProps(makeElement('Frame'), {
					Size = UDim2.new(0, 1, 1, 0),
					Position = UDim2.new(0.5, 0, 0, 0)
				}), 'Stroke'),
				closeBtn,
				minimizeBtn
			}), 'Second'),
		}),
		dragPoint,
		windowStuff
	}), 'Main');

	allowDrag(dragPoint, mainWindow);

	addConnection(closeBtn.MouseButton1Up, function()
		mainWindow.Visible = false
		library:SendNotif({
			title = 'Interface Hidden',
			text = 'Tap RightShift to reopen the interface',
			duration = 5
		});
	end);

	addConnection(inputService.InputBegan, function(Input)
		if (Input.KeyCode ~= Enum.KeyCode.RightShift) then return; end;
		mainWindow.Visible = not mainWindow.Visible;
	end);

	addConnection(minimizeBtn.MouseButton1Up, function()
		if (Minimized) then
			tweenService:Create(mainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 615, 0, 344)}):Play();
			minimizeBtn.Ico.Image = 'rbxassetid://7072719338';
			task.wait(.02);

			mainWindow.ClipsDescendants = false;
			windowStuff.Visible = true;
			windowTopbarLine.Visible = true;
		else
			mainWindow.ClipsDescendants = true;
			windowTopbarLine.Visible = false;
			minimizeBtn.Ico.Image = 'rbxassetid://7072720870';

			tweenService:Create(mainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, windowName.TextBounds.X + 140, 0, 50)}):Play();
			task.wait(0.1);
			
			windowStuff.Visible = false;
		end;

		Minimized = not Minimized;
	end);

	local tab = {}
	function tab:AddTab(title, icon)
		local tabFrame = setChildren(setProps(makeElement('Button'), {
			Size = UDim2.new(1, 0, 0, 30),
			Parent = tabHolder
		}), {
			addThemeObject(setProps(makeElement('Image', ''), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 18, 0, 18),
				Position = UDim2.new(0, 10, 0.5, 0),
				ImageTransparency = 0.4,
				Name = 'Ico'
			}), 'Text'),
			addThemeObject(setProps(makeElement('Label', tostring(title), 14), {
				Size = UDim2.new(1, -35, 1, 0),
				Position = UDim2.new(0, 35, 0, 0),
				Font = Enum.Font.GothamSemibold,
				TextTransparency = 0.4,
				Name = 'Title'
			}), 'Text')
		});

		if (getIcon(icon)) then tabFrame.Ico.Image = getIcon(icon); end;

		local container = addThemeObject(setChildren(setProps(makeElement('ScrollFrame', Color3.fromRGB(255, 255, 255), 5), {
			Size = UDim2.new(1, -150, 1, -50),
			Position = UDim2.new(0, 150, 0, 50),
			Parent = mainWindow,
			Visible = false,
			Name = 'ItemContainer'
		}), {
			makeElement('List', 0, 6),
			makeElement('Padding', 15, 10, 10, 15)
		}), 'Divider');

		addConnection(container.UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'), function()
			container.CanvasSize = UDim2.new(0, 0, 0, container.UIListLayout.AbsoluteContentSize.Y + 30)
		end)

		tabFrame.Ico.ImageTransparency = 0;
		tabFrame.Title.TextTransparency = 0;
		tabFrame.Title.Font = Enum.Font.GothamBlack;
		container.Visible = true;

		addConnection(tabFrame.MouseButton1Click, function()
			for _, Tab in next, tabHolder:GetChildren() do
				if (not Tab:IsA('TextButton')) then continue; end;

				Tab.Title.Font = Enum.Font.GothamSemibold;
				tweenService:Create(Tab.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0.4}):Play();
				tweenService:Create(Tab.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play();
			end;

			for _, ItemContainer in next, mainWindow:GetChildren() do
				if (ItemContainer.Name ~= 'ItemContainer') then continue; end;
				ItemContainer.Visible = false;
			end;

			tweenService:Create(tabFrame.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play();
			tweenService:Create(tabFrame.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play();
			tabFrame.Title.Font = Enum.Font.GothamBlack;
			container.Visible = true;
		end);

		local function getElements(parent)
			local element = {}

			function element:AddLabel(text)
				local labelFrame = addThemeObject(setChildren(setProps(makeElement('RoundFrame', Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 0.7,
					Parent = parent
				}), {
					addThemeObject(setProps(makeElement('Label', text, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = 'Content'
					}), 'Text'),
					addThemeObject(makeElement('Stroke'), 'Stroke')
				}), 'Second');

				local label = {};
				function label:Set(newText)
					labelFrame.Content.Text = newText;
				end;

				return label;
			end;

			function element:AddParagraph(text, content)
				local paragraphFrame = addThemeObject(setChildren(setProps(makeElement('RoundFrame', Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 0.7,
					Parent = parent
				}), {
					addThemeObject(setProps(makeElement('Label', text, 15), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 10),
						Font = Enum.Font.GothamBold,
						Name = 'Title'
					}), 'Text'),
					addThemeObject(setProps(makeElement('Label', '', 13), {
						Size = UDim2.new(1, -24, 0, 0),
						Position = UDim2.new(0, 12, 0, 26),
						Font = Enum.Font.GothamSemibold,
						Name = 'Content',
						TextWrapped = true
					}), 'TextDark'),
					addThemeObject(makeElement('Stroke'), 'Stroke')
				}), 'Second');

				addConnection(paragraphFrame.Content:GetPropertyChangedSignal('Text'), function()
					paragraphFrame.Content.Size = UDim2.new(1, -24, 0, paragraphFrame.Content.TextBounds.Y);
					paragraphFrame.Size = UDim2.new(1, 0, 0, paragraphFrame.Content.TextBounds.Y + 35);
				end);

				paragraphFrame.Content.Text = content;

				local paragraph = {};
				function paragraph:Set(newText)
					paragraphFrame.Content.Text = newText;
				end;

				return paragraph;
			end;

			function element:AddButton(option)
				option = typeof(option) == 'table' and option or {};
				option.text = tostring(option.text);
				option.callback = typeof(option.callback) == 'function' and option.callback or function() end;
				option.icon = typeof(option.icon) == 'string' and option.icon or typeof(option.icon) == 'number' and 'rbxassetid://' .. tostring(option.icon) or 'rbxassetid://4384403532';

				local tInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);

				local click = setProps(makeElement('Button'), {
					Size = UDim2.new(1, 0, 1, 0)
				});

				local buttonFrame = addThemeObject(setChildren(setProps(makeElement('RoundFrame', Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 33),
					Parent = parent
				}), {
					addThemeObject(setProps(makeElement('Label', option.text, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = 'Content'
					}), 'Text'),
					addThemeObject(setProps(makeElement('Image', option.icon), {
						Size = UDim2.new(0, 20, 0, 20),
						Position = UDim2.new(1, -30, 0, 7),
					}), 'TextDark'),
					addThemeObject(makeElement('Stroke'), 'Stroke'),
					click
				}), 'Second');

				addConnection(click.MouseEnter, function()
					tweenService:Create(buttonFrame, tInfo, {BackgroundColor3 = Color3.fromRGB(library.themes[library.selectedTheme].Second.R * 255 + 3, library.themes[library.selectedTheme].Second.G * 255 + 3, library.themes[library.selectedTheme].Second.B * 255 + 3)}):Play();
				end);

				addConnection(click.MouseLeave, function()
					tweenService:Create(buttonFrame, tInfo, {BackgroundColor3 = library.themes[library.selectedTheme].Second}):Play()
				end);

				addConnection(click.MouseButton1Up, function()
					tweenService:Create(buttonFrame, tInfo, {BackgroundColor3 = Color3.fromRGB(library.themes[library.selectedTheme].Second.R * 255 + 3, library.themes[library.selectedTheme].Second.G * 255 + 3, library.themes[library.selectedTheme].Second.B * 255 + 3)}):Play();
					task.spawn(option.callback);
				end);

				addConnection(click.MouseButton1Down, function()
					tweenService:Create(buttonFrame, tInfo, {BackgroundColor3 = Color3.fromRGB(library.themes[library.selectedTheme].Second.R * 255 + 6, library.themes[library.selectedTheme].Second.G * 255 + 6, library.themes[library.selectedTheme].Second.B * 255 + 6)}):Play();
				end);

				local button = {};
				function button:Set(newText)
					buttonFrame.Content.Text = newText;
				end;

				return button;
			end;

			function element:AddToggle(option)
				option = typeof(option) == 'table' and option or {};
				option.text = tostring(option.text);
				option.state = typeof(option.state) == 'boolean' and option.state or false;
				option.callback = typeof(option.callback) == 'function' and option.callback or function() end;
				option.color = typeof(option.color) == 'Color3' and option.color or Color3.fromRGB(9, 99, 195);
				option.flag = toCamelCase(option.flag or option.text);

				local toggle = {val = option.state};
				local tInfoS = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);
				local tInfoM = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);

				local click = setProps(makeElement('Button'), {
					Size = UDim2.new(1, 0, 1, 0)
				});

				local toggleBox = setChildren(setProps(makeElement('RoundFrame', option.color, 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -24, 0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0.5)
				}), {
					setProps(makeElement('Stroke'), {
						Color = option.color,
						Name = 'Stroke',
						Transparency = 0.5
					}),
					setProps(makeElement('Image', 'rbxassetid://3944680095'), {
						Size = UDim2.new(0, 20, 0, 20),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0.5, 0, 0.5, 0),
						ImageColor3 = Color3.fromRGB(255, 255, 255),
						Name = 'Ico'
					}),
				});

				local toggleFrame = addThemeObject(setChildren(setProps(makeElement('RoundFrame', Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = parent
				}), {
					addThemeObject(setProps(makeElement('Label', option.text, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = 'Content'
					}), 'Text'),
					addThemeObject(makeElement('Stroke'), 'Stroke'),
					toggleBox,
					click
				}), 'Second');

				function toggle:Set(newVal)
					toggle.val = newVal;

					tweenService:Create(toggleBox, tInfoS, {BackgroundColor3 = toggle.val and option.color or library.themes.Default.Divider}):Play();
					tweenService:Create(toggleBox.Stroke, tInfoS, {Color = toggle.val and option.color or library.themes.Default.Stroke}):Play();
					tweenService:Create(toggleBox.Ico, tInfoS, {ImageTransparency = toggle.val and 0 or 1, Size = toggle.val and UDim2.new(0, 20, 0, 20) or UDim2.new(0, 8, 0, 8)}):Play();

					option.callback(toggle.val);
				end;

				toggle:Set(toggle.val);

				addConnection(click.MouseEnter, function()
					tweenService:Create(toggleFrame, tInfoM, {BackgroundColor3 = Color3.fromRGB(library.themes[library.selectedTheme].Second.R * 255 + 3, library.themes[library.selectedTheme].Second.G * 255 + 3, library.themes[library.selectedTheme].Second.B * 255 + 3)}):Play();
				end);

				addConnection(click.MouseLeave, function()
					tweenService:Create(toggleFrame, tInfoM, {BackgroundColor3 = library.themes[library.selectedTheme].Second}):Play();
				end);

				addConnection(click.MouseButton1Up, function()
					tweenService:Create(toggleFrame, tInfoM, {BackgroundColor3 = Color3.fromRGB(library.themes[library.selectedTheme].Second.R * 255 + 3, library.themes[library.selectedTheme].Second.G * 255 + 3, library.themes[library.selectedTheme].Second.B * 255 + 3)}):Play();
					toggle:Set(not toggle.val);
				end);

				addConnection(click.MouseButton1Down, function()
					tweenService:Create(toggleFrame, tInfoM, {BackgroundColor3 = Color3.fromRGB(library.themes[library.selectedTheme].Second.R * 255 + 6, library.themes[library.selectedTheme].Second.G * 255 + 6, library.themes[library.selectedTheme].Second.B * 255 + 6)}):Play();
				end);

				library.flags[option.flag] = toggle;
				return toggle;
			end;

			function element:AddSlider(option)
				option = typeof(option) == 'table' and option or {};
				option.text = tostring(option.text);
				option.min = typeof(option.min) == 'number' and option.min or 0;
				option.max = typeof(option.max) == 'number' and option.max or 0;
				option.float = typeof(option.value) == 'number' and option.float or 1;
				option.value = option.min < 0 and 0 or math.clamp(typeof(option.value) == 'number' and option.value or option.min, option.min, option.max);
				option.callback = typeof(option.callback) == 'function' and option.callback or function() end;
				option.suffix = option.suffix and tostring(option.suffix) or '';
				option.color = typeof(option.color) == 'Color3' and option.color or Color3.fromRGB(9, 99, 195);
				option.flag = toCamelCase(option.flag or option.text);

				local slider = {val = option.value};
				local dragging = false;

				local sliderDrag = setChildren(setProps(makeElement('RoundFrame', option.color, 0, 5), {
					Size = UDim2.new(0, 0, 1, 0),
					BackgroundTransparency = 0.3,
					ClipsDescendants = true
				}), {
					addThemeObject(setProps(makeElement('Label', 'value', 13), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 6),
						Font = Enum.Font.GothamBold,
						Name = 'Value',
						TextTransparency = 0
					}), 'Text')
				});

				local sliderBar = setChildren(setProps(makeElement('RoundFrame', option.color, 0, 5), {
					Size = UDim2.new(1, -24, 0, 26),
					Position = UDim2.new(0, 12, 0, 30),
					BackgroundTransparency = 0.9
				}), {
					setProps(makeElement('Stroke'), {
						Color = option.color
					}),
					addThemeObject(setProps(makeElement('Label', 'value', 13), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 6),
						Font = Enum.Font.GothamBold,
						Name = 'Value',
						TextTransparency = 0.8
					}), 'Text'),
					sliderDrag
				});

				addThemeObject(setChildren(setProps(makeElement('RoundFrame', Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(1, 0, 0, 65),
					Parent = parent
				}), {
					addThemeObject(setProps(makeElement('Label', option.text, 15), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 10),
						Font = Enum.Font.GothamBold,
						Name = 'Content'
					}), 'Text'),
					addThemeObject(makeElement('Stroke'), 'Stroke'),
					sliderBar
				}), 'Second');

				sliderBar.InputBegan:Connect(function(input)
					if (input.UserInputType ~= Enum.UserInputType.MouseButton1) then return; end;
					dragging = true;
				end);
				sliderBar.InputEnded:Connect(function(input) 
					if (input.UserInputType ~= Enum.UserInputType.MouseButton1) then return; end;
					dragging = false;
				end);

				inputService.InputChanged:Connect(function(Input)
					if (not dragging or Input.UserInputType ~= Enum.UserInputType.MouseMovement) then return; end;
					local SizeScale = math.clamp((Input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1);
					slider:Set(option.min + ((option.max - option.min) * SizeScale));
				end);

				function slider:Set(newVal)
					slider.val = math.clamp(round(newVal, option.float), option.min, option.max);
					tweenService:Create(sliderDrag, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromScale((slider.val - option.min) / (option.max - option.min), 1)}):Play();
					sliderBar.Value.Text = tostring(slider.val) .. ' ' .. option.suffix;
					sliderDrag.Value.Text = tostring(slider.val) .. ' ' .. option.suffix;
					option.callback(slider.val);
				end;

				slider:Set(slider.val);

				library.flags[option.flag] = slider;
				return slider;
			end;

			function element:AddList(option)
				option = typeof(option) == 'table' and option or {};
				option.text = tostring(option.text);
				option.values = typeof(option.values) == 'table' and option.values or {};
				option.value = tostring(option.value or option.values[1] or '');
				option.callback = typeof(option.callback) == 'function' and option.callback or function() end;
				option.flag = toCamelCase(option.flag or option.text);

				local dropdown = {val = option.value, values = option.values, buttons = {}, toggled = false, type = 'dropdown'};
				local tInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);

				if (not table.find(dropdown.values, dropdown.val)) then
					dropdown.val = '...';
				end;

				local dropdownList = makeElement('List');

				local dropdownContainer = addThemeObject(setProps(setChildren(makeElement('ScrollFrame', Color3.fromRGB(40, 40, 40), 4), {
					dropdownList
				}), {
					Parent = parent,
					Position = UDim2.new(0, 0, 0, 38),
					Size = UDim2.new(1, 0, 1, -38),
					ClipsDescendants = true
				}), 'Divider');

				local click = setProps(makeElement('Button'), {
					Size = UDim2.new(1, 0, 1, 0)
				});

				local dropdownFrame = addThemeObject(setChildren(setProps(makeElement('RoundFrame', Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = parent,
					ClipsDescendants = true
				}), {
					dropdownContainer,
					setProps(setChildren(makeElement('TFrame'), {
						addThemeObject(setProps(makeElement('Label', option.text, 15), {
							Size = UDim2.new(1, -12, 1, 0),
							Position = UDim2.new(0, 12, 0, 0),
							Font = Enum.Font.GothamBold,
							Name = 'Content'
						}), 'Text'),
						addThemeObject(setProps(makeElement('Image', 'rbxassetid://7072706796'), {
							Size = UDim2.new(0, 20, 0, 20),
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(1, -30, 0.5, 0),
							ImageColor3 = Color3.fromRGB(240, 240, 240),
							Name = 'Ico'
						}), 'TextDark'),
						addThemeObject(setProps(makeElement('Label', 'Selected', 13), {
							Size = UDim2.new(1, -40, 1, 0),
							Font = Enum.Font.Gotham,
							Name = 'Selected',
							TextXAlignment = Enum.TextXAlignment.Right
						}), 'TextDark'),
						addThemeObject(setProps(makeElement('Frame'), {
							Size = UDim2.new(1, 0, 0, 1),
							Position = UDim2.new(0, 0, 1, -1),
							Name = 'Line',
							Visible = false
						}), 'Stroke'),
						click
					}), {
						Size = UDim2.new(1, 0, 0, 38),
						ClipsDescendants = true,
						Name = 'F'
					}),
					addThemeObject(makeElement('Stroke'), 'Stroke'),
					makeElement('Corner')
				}), 'Second');

				addConnection(dropdownList:GetPropertyChangedSignal('AbsoluteContentSize'), function()
					dropdownContainer.CanvasSize = UDim2.new(0, 0, 0, dropdownList.AbsoluteContentSize.Y);
				end);

				local function addValues(values)
					for _, v in next, values do
						local optionBtn = addThemeObject(setProps(setChildren(makeElement('Button', Color3.fromRGB(40, 40, 40)), {
							makeElement('Corner', 0, 6),
							addThemeObject(setProps(makeElement('Label', v, 13, 0.4), {
								Position = UDim2.new(0, 8, 0, 0),
								Size = UDim2.new(1, -8, 1, 0),
								Name = 'Title'
							}), 'Text')
						}), {
							Parent = dropdownContainer,
							Size = UDim2.new(1, 0, 0, 28),
							BackgroundTransparency = 1,
							ClipsDescendants = true
						}), 'Divider');

						addConnection(optionBtn.MouseButton1Click, function()
							dropdown:Set(v);
						end);

						dropdown.buttons[v] = optionBtn;
					end;
				end;

				function dropdown:Refresh(Options, delete)
					if (delete) then
						for _,v in next, dropdown.buttons do
							v:Destroy();
						end;

						table.clear(dropdown.values);
						table.clear(dropdown.buttons);
					end;

					dropdown.values = Options;
					addValues(dropdown.values);
				end;

				function dropdown:Set(newVal)
					if (not table.find(dropdown.values, newVal)) then
						dropdown.val = '...';
						dropdownFrame.F.Selected.Text = dropdown.val;
						for _, v in pairs(dropdown.buttons) do
							tweenService:Create(v, tInfo, {BackgroundTransparency = 1}):Play();
							tweenService:Create(v.Title, tInfo, {TextTransparency = 0.4}):Play();
						end;

						return;
					end;

					dropdown.val = newVal;
					dropdownFrame.F.Selected.Text = dropdown.val;

					for _, v in pairs(dropdown.buttons) do
						tweenService:Create(v, tInfo, {BackgroundTransparency = 1}):Play();
						tweenService:Create(v.Title, tInfo, {TextTransparency = 0.4}):Play();
					end;

					tweenService:Create(dropdown.buttons[newVal], tInfo, {BackgroundTransparency = 0}):Play();
					tweenService:Create(dropdown.buttons[newVal].Title, tInfo, {TextTransparency = 0}):Play();

					return option.callback(dropdown.val);
				end;

				addConnection(click.MouseButton1Click, function()
					dropdown.toggled = not dropdown.toggled;
					dropdownFrame.F.Line.Visible = dropdown.toggled;
					tweenService:Create(dropdownFrame.F.Ico, tInfo, {Rotation = dropdown.toggled and 180 or 0}):Play();

					if (#dropdown.values > 5) then
						tweenService:Create(dropdownFrame, tInfo, {Size = dropdown.toggled and UDim2.new(1, 0, 0, 38 + (5 * 28)) or UDim2.new(1, 0, 0, 38)}):Play();
					else
						tweenService:Create(dropdownFrame, tInfo, {Size = dropdown.toggled and UDim2.new(1, 0, 0, dropdownList.AbsoluteContentSize.Y + 38) or UDim2.new(1, 0, 0, 38)}):Play();
					end;
				end);

				dropdown:Refresh(dropdown.values, false);
				dropdown:Set(dropdown.val);

				library.flags[option.flag] = dropdown;
				return dropdown;
			end;

			function element:AddBind(option)
				option = typeof(option) == 'table' and option or {};
				option.text = tostring(option.text);
				option.value = typeof(option.value) == 'number' and option.value or Enum.KeyCode.Unknown;
				option.hold = typeof(option.hold) == 'boolean' and option.hold or false;
				option.callback = typeof(option.callback) == 'function' and option.callback or function() end;
				option.flag = toCamelCase(option.flag or option.text);

				local bind = {val = nil, binding = false, type = 'bind'};
				local tInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);
				local holding = false;

				local click = setProps(makeElement('Button'), {
					Size = UDim2.new(1, 0, 1, 0)
				});

				local bindBox = addThemeObject(setChildren(setProps(makeElement('RoundFrame', Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {
					addThemeObject(makeElement('Stroke'), 'Stroke'),
					addThemeObject(setProps(makeElement('Label', option.text, 14), {
						Size = UDim2.new(1, 0, 1, 0),
						Font = Enum.Font.GothamBold,
						TextXAlignment = Enum.TextXAlignment.Center,
						Name = 'Value'
					}), 'Text')
				}), 'Main');

				local bindFrame = addThemeObject(setChildren(setProps(makeElement('RoundFrame', Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = parent
				}), {
					addThemeObject(setProps(makeElement('Label', option.text, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = 'Content'
					}), 'Text'),
					addThemeObject(makeElement('Stroke'), 'Stroke'),
					bindBox,
					click
				}), 'Second');

				addConnection(bindBox.Value:GetPropertyChangedSignal('Text'), function()
					tweenService:Create(bindBox, tInfo, {Size = UDim2.new(0, bindBox.Value.TextBounds.X + 16, 0, 24)}):Play();
				end);

				addConnection(click.InputEnded, function(input)
					if (input.UserInputType ~= Enum.UserInputType.MouseButton1) then return; end;
					if (bind.binding) then return; end;
					bind.binding = true;
					bindBox.Value.Text = '';
				end)

				addConnection(inputService.InputBegan, function(input)
					if (inputService:GetFocusedTextBox()) then return; end;
					if ((input.KeyCode.Name == bind.val or input.UserInputType.Name == bind.val) and not bind.binding) then
						if (option.hold) then
							holding = true;
							option.callback(holding);
						else
							option.callback();
						end;
					elseif (bind.binding) then
						local Key;
						pcall(function()
							if (not checkKey(blacklistedKeys, input.KeyCode)) then
								Key = input.KeyCode;
							end;
						end);
						pcall(function()
							if (checkKey(whitelistedMouse, input.UserInputType) and not Key) then
								Key = input.UserInputType;
							end;
						end);

						Key = Key or bind.val;
						bind:Set(Key);
					end;
				end);

				addConnection(inputService.InputEnded, function(input)
					if (input.KeyCode.Name ~= bind.val or input.UserInputType.Name ~= bind.val) then return; end;
					if (option.hold and holding) then
						holding = false;
						option.callback(holding);
					end;
				end);

				addConnection(click.MouseEnter, function()
					tweenService:Create(bindFrame, tInfo, {BackgroundColor3 = Color3.fromRGB(library.themes[library.selectedTheme].Second.R * 255 + 3, library.themes[library.selectedTheme].Second.G * 255 + 3, library.themes[library.selectedTheme].Second.B * 255 + 3)}):Play();
				end);

				addConnection(click.MouseLeave, function()
					tweenService:Create(bindFrame, tInfo, {BackgroundColor3 = library.themes[library.selectedTheme].Second}):Play();
				end);

				addConnection(click.MouseButton1Up, function()
					tweenService:Create(bindFrame, tInfo, {BackgroundColor3 = Color3.fromRGB(library.themes[library.selectedTheme].Second.R * 255 + 3, library.themes[library.selectedTheme].Second.G * 255 + 3, library.themes[library.selectedTheme].Second.B * 255 + 3)}):Play();
				end);

				addConnection(click.MouseButton1Down, function()
					tweenService:Create(bindFrame, tInfo, {BackgroundColor3 = Color3.fromRGB(library.themes[library.selectedTheme].Second.R * 255 + 6, library.themes[library.selectedTheme].Second.G * 255 + 6, library.themes[library.selectedTheme].Second.B * 255 + 6)}):Play();
				end);

				function bind:Set(newKey)
					bind.binding = false;
					bind.val = newKey or bind.val;
					bind.val = bind.val.Name or bind.val;
					bindBox.Value.Text = bind.val;
				end;

				bind:Set(option.value);

				library.flags[option.flag] = bind;
				return bind;
			end;

			function element:AddBox(option)
				option = typeof(option) == 'table' and option or {};
				option.text = tostring(option.text);
				option.value = tostring(option.value or '');
				option.ghost = typeof(option.ghost) == 'boolean' and option.ghost or false;
				option.callback = typeof(option.callback) == 'function' and option.callback or function() end;

				local tInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);

				local click = setProps(makeElement('Button'), {
					Size = UDim2.new(1, 0, 1, 0)
				});

				local textboxActual = addThemeObject(create('TextBox', {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					PlaceholderColor3 = Color3.fromRGB(210,210,210),
					PlaceholderText = 'Input',
					Font = Enum.Font.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextSize = 14,
					ClearTextOnFocus = false
				}), 'Text');

				local textContainer = addThemeObject(setChildren(setProps(makeElement('RoundFrame', Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {
					addThemeObject(makeElement('Stroke'), 'Stroke'),
					textboxActual
				}), 'Main');

				local textboxFrame = addThemeObject(setChildren(setProps(makeElement('RoundFrame', Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = parent
				}), {
					addThemeObject(setProps(makeElement('Label', option.text, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = 'Content'
					}), 'Text'),
					addThemeObject(makeElement('Stroke'), 'Stroke'),
					textContainer,
					click
				}), 'Second');

				addConnection(textboxActual:GetPropertyChangedSignal('Text'), function()
					tweenService:Create(textContainer, tInfo, {Size = UDim2.new(0, textboxActual.TextBounds.X + 16, 0, 24)}):Play();
				end);

				addConnection(textboxActual.FocusLost, function()
					option.callback(textboxActual.Text);
					if (option.ghost) then textboxActual.Text = ''; end;
				end);

				textboxActual.Text = option.value;

				addConnection(click.MouseEnter, function()
					tweenService:Create(textboxFrame, tInfo, {BackgroundColor3 = Color3.fromRGB(library.themes[library.selectedTheme].Second.R * 255 + 3, library.themes[library.selectedTheme].Second.G * 255 + 3, library.themes[library.selectedTheme].Second.B * 255 + 3)}):Play();
				end);

				addConnection(click.MouseLeave, function()
					tweenService:Create(textboxFrame, tInfo, {BackgroundColor3 = library.themes[library.selectedTheme].Second}):Play();
				end);

				addConnection(click.MouseButton1Up, function()
					tweenService:Create(textboxFrame, tInfo, {BackgroundColor3 = Color3.fromRGB(library.themes[library.selectedTheme].Second.R * 255 + 3, library.themes[library.selectedTheme].Second.G * 255 + 3, library.themes[library.selectedTheme].Second.B * 255 + 3)}):Play();
					textboxActual:CaptureFocus()
				end);

				addConnection(click.MouseButton1Down, function()
					tweenService:Create(textboxFrame, tInfo, {BackgroundColor3 = Color3.fromRGB(library.themes[library.selectedTheme].Second.R * 255 + 6, library.themes[library.selectedTheme].Second.G * 255 + 6, library.themes[library.selectedTheme].Second.B * 255 + 6)}):Play();
				end);
			end;

			function element:AddColor(option)
				option = typeof(option) == 'table' and option or {};
				option.text = tostring(option.text);
				option.color = typeof(option.color) == 'table' and Color3.new(option.color[1], option.color[2], option.color[3]) or option.color or Color3.new(1, 1, 1);
				option.callback = typeof(option.callback) == 'function' and option.callback or function() end;
				option.flag = toCamelCase(option.flag or option.text);

				local colorH, solorS, colorV = 1, 1, 1;
				local colorpicker = {val = option.color, toggled = false, type = 'colorpicker'};

				local colorSelection = create('ImageLabel', {
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(select(3, Color3.ToHSV(colorpicker.val))),
					ScaleType = Enum.ScaleType.Fit,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = 'http://www.roblox.com/asset/?id=4805639000'
				});

				local hueSelection = create('ImageLabel', {
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0.5, 0, 1 - select(1, Color3.ToHSV(colorpicker.val))),
					ScaleType = Enum.ScaleType.Fit,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = 'http://www.roblox.com/asset/?id=4805639000'
				});

				local color = create('ImageLabel', {
					Size = UDim2.new(1, -25, 1, 0),
					Visible = false,
					Image = 'rbxassetid://4155801252'
				}, {
					create('UICorner', {CornerRadius = UDim.new(0, 5)}),
					colorSelection
				});

				local hue = create('Frame', {
					Size = UDim2.new(0, 20, 1, 0),
					Position = UDim2.new(1, -20, 0, 0),
					Visible = false
				}, {
					create('UIGradient', {Rotation = 270, Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 4)), ColorSequenceKeypoint.new(0.20, Color3.fromRGB(234, 255, 0)), ColorSequenceKeypoint.new(0.40, Color3.fromRGB(21, 255, 0)), ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 17, 255)), ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 0, 251)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 4))},}),
					create('UICorner', {CornerRadius = UDim.new(0, 5)}),
					hueSelection
				});

				local colorpickerContainer = create('Frame', {
					Position = UDim2.new(0, 0, 0, 32),
					Size = UDim2.new(1, 0, 1, -32),
					BackgroundTransparency = 1,
					ClipsDescendants = true
				}, {
					hue,
					color,
					create('UIPadding', {
						PaddingLeft = UDim.new(0, 35),
						PaddingRight = UDim.new(0, 35),
						PaddingBottom = UDim.new(0, 10),
						PaddingTop = UDim.new(0, 17)
					})
				});

				local click = setProps(makeElement('Button'), {
					Size = UDim2.new(1, 0, 1, 0)
				});

				local colorpickerBox = addThemeObject(setChildren(setProps(makeElement('RoundFrame', Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {
					addThemeObject(makeElement('Stroke'), 'Stroke')
				}), 'Main');

				local colorpickerFrame = addThemeObject(setChildren(setProps(makeElement('RoundFrame', Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = parent
				}), {
					setProps(setChildren(makeElement('TFrame'), {
						addThemeObject(setProps(makeElement('Label', option.Name, 15), {
							Size = UDim2.new(1, -12, 1, 0),
							Position = UDim2.new(0, 12, 0, 0),
							Font = Enum.Font.GothamBold,
							Name = 'Content'
						}), 'Text'),
						colorpickerBox,
						click,
						addThemeObject(setProps(makeElement('Frame'), {
							Size = UDim2.new(1, 0, 0, 1),
							Position = UDim2.new(0, 0, 1, -1),
							Name = 'Line',
							Visible = false
						}), 'Stroke'), 
					}), {
						Size = UDim2.new(1, 0, 0, 38),
						ClipsDescendants = true,
						Name = 'F'
					}),
					colorpickerContainer,
					addThemeObject(makeElement('Stroke'), 'Stroke'),
				}), 'Second');

				addConnection(click.MouseButton1Click, function()
					colorpicker.toggled = not colorpicker.toggled;

					tweenService:Create(colorpickerFrame,TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = colorpicker.toggled and UDim2.new(1, 0, 0, 148) or UDim2.new(1, 0, 0, 38)}):Play();

					color.Visible = colorpicker.toggled;
					hue.Visible = colorpicker.toggled;
					colorpickerFrame.F.Line.Visible = colorpicker.toggled;
				end);

				local function UpdateColorPicker()
					colorpickerBox.BackgroundColor3 = Color3.fromHSV(colorH, solorS, colorV);
					color.BackgroundColor3 = Color3.fromHSV(colorH, 1, 1);

					colorpicker:Set(colorpickerBox.BackgroundColor3);
					option.callback(colorpickerBox.BackgroundColor3);
				end;

				colorH = 1 - (math.clamp(hueSelection.AbsolutePosition.Y - hue.AbsolutePosition.Y, 0, hue.AbsoluteSize.Y) / hue.AbsoluteSize.Y);
				solorS = (math.clamp(colorSelection.AbsolutePosition.X - color.AbsolutePosition.X, 0, color.AbsoluteSize.X) / color.AbsoluteSize.X);
				colorV = 1 - (math.clamp(colorSelection.AbsolutePosition.Y - color.AbsolutePosition.Y, 0, color.AbsoluteSize.Y) / color.AbsoluteSize.Y);

				local ColorInput, HueInput;

				addConnection(color.InputBegan, function(input)
					if (input.UserInputType ~= Enum.UserInputType.MouseButton1) then return; end;
					if (ColorInput) then ColorInput:Disconnect(); end;

					ColorInput = addConnection(runService.RenderStepped, function()
						local ColorX = (math.clamp(localMouse.X - color.AbsolutePosition.X, 0, color.AbsoluteSize.X) / color.AbsoluteSize.X);
						local ColorY = (math.clamp(localMouse.Y - color.AbsolutePosition.Y, 0, color.AbsoluteSize.Y) / color.AbsoluteSize.Y);

						colorSelection.Position = UDim2.new(ColorX, 0, ColorY, 0);
						solorS = ColorX;
						colorV = 1 - ColorY;

						UpdateColorPicker();
					end);
				end);

				addConnection(color.InputEnded, function(input)
					if (input.UserInputType ~= Enum.UserInputType.MouseButton1) then return; end;
					if (ColorInput) then ColorInput:Disconnect(); end;
				end);

				addConnection(hue.InputBegan, function(input)
					if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return; end;
					if (HueInput) then HueInput:Disconnect(); end;

					HueInput = addConnection(runService.RenderStepped, function()
						local HueY = (math.clamp(localMouse.Y - hue.AbsolutePosition.Y, 0, hue.AbsoluteSize.Y) / hue.AbsoluteSize.Y)

						hueSelection.Position = UDim2.new(0.5, 0, HueY, 0)
						colorH = 1 - HueY

						UpdateColorPicker();
					end);
				end);

				addConnection(hue.InputEnded, function(input)
					if (input.UserInputType ~= Enum.UserInputType.MouseButton1) then return; end;
					if (HueInput) then HueInput:Disconnect(); end;
				end);

				function colorpicker:Set(newVal)
					colorpicker.val = newVal;
					colorpickerBox.BackgroundColor3 = colorpicker.val;
					option.callback(colorpicker.val);
				end;

				colorpicker:Set(colorpicker.val);

				library.flags[option.flag] = colorpicker;
				return colorpicker;
			end;

			return element;
		end;

		local element = {};

		function element:AddSection(name)
			local sectionFrame = setChildren(setProps(makeElement('TFrame'), {
				Size = UDim2.new(1, 0, 0, 26),
				Parent = container
			}), {
				addThemeObject(setProps(makeElement('Label', tostring(name), 14), {
					Size = UDim2.new(1, -12, 0, 16),
					Position = UDim2.new(0, 0, 0, 3),
					Font = Enum.Font.GothamSemibold
				}), 'TextDark'),
				setChildren(setProps(makeElement('TFrame'), {
					AnchorPoint = Vector2.new(0, 0),
					Size = UDim2.new(1, 0, 1, -24),
					Position = UDim2.new(0, 0, 0, 23),
					Name = 'Holder'
				}), {
					makeElement('List', 0, 6)
				}),
			});

			addConnection(sectionFrame.Holder.UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'), function()
				sectionFrame.Size = UDim2.new(1, 0, 0, sectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 31)
				sectionFrame.Holder.Size = UDim2.new(1, 0, 0, sectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y)
			end);

			local SectionFunction = {};
			for i, v in next, getElements(sectionFrame.Holder) do
				SectionFunction[i] = v;
			end;

			return SectionFunction;
		end;

		for i, v in next, getElements(container) do
			element[i] = v;
		end;

		return element;
	end;

	return tab;
end;

warn(string.format('[Library] Loaded in %.02f seconds', tick() - libraryLoadAt));

getgenv().library = library;

return library;