-- loadstring:
-- loadstring(game:HttpGet('https://raw.githubusercontent.com/Iratethisname10/roblox/refs/heads/main/misc/ui%20test.lua'))()

local library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Iratethisname10/roblox/refs/heads/main/ui/uwuware.lua'))();

local main = library:AddTab('Main');
local visuals = library:AddTab('Visuals');

local main1, main2 = main:AddColumn(), main:AddColumn();
local visuals1, visuals2 = visuals:AddColumn(), visuals:AddColumn();

do
	local character = main1:AddSection('character');
	local combat = main2:AddSection('combat');

	local esp = visuals1:AddSection('esp');
	local misc = visuals2:AddSection('other elements');

	do -- character
		character:AddToggle({
			text = 'fly'
		});

		character:AddSlider({
			text = 'fly speed',
			textpos = 2,
			min = 10,
			max = 100
		});

		character:AddToggle({
			text = 'invis'
		}):AddBind({
			flag = 'invis bind',
			callback = function()
				library.options.invis:SetState(not library.flags.invis);
			end
		});

		character:AddToggle({
			text = 'noclip'
		}):AddBind({
			flag = 'noclip bind',
			callback = function()
				library.options.noclip:SetState(not library.flags.noclip);
			end
		});

		character:AddToggle({
			text = 'godmode'
		}):AddBind({
			flag = 'godmode bind',
			callback = function()
				library.options.godmode:SetState(not library.flags.godmode);
			end
		});
	end;

	do -- combat
		combat:AddToggle({
			text = 'silent aim'
		});

		combat:AddSlider({
			text = 'fov',
			min = 10,
			max = 500
		});

		combat:AddSlider({
			text = 'hit chance',
			min = 10,
			max = 100,
			value = 80
		});

		combat:AddToggle({
			text = 'wall check'
		})
	end;

	do -- esp
		esp:AddToggle({
			text = 'enabled'
		}):AddColor({
			flag = 'esp color'
		});

		esp:AddToggle({
			text = 'tracers'
		});

		esp:AddToggle({
			text = 'boxes'
		});

		esp:AddToggle({
			text = 'health'
		});
	end;

	do -- misc
		misc:AddBox({
			text = 'text box'
		});

		misc:AddList({
			text = 'normal list',
			values = {'1', '2', '3', '4'},
		});

		misc:AddList({
			text = 'player list',
			playerOnly = true,
			values = {'1', '2', '3', '4'}
		});

		misc:AddList({
			text = 'multi list',
			multiselect = true,
			values = {'1', '2', '3', '4'}
		});
	end;
end;

library:Init();
