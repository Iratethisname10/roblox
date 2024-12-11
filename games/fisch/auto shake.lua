local players = game:GetService('Players');
local uiService = game:GetService('GuiService');
local inputManager = game:GetService('VirtualInputManager');

local playerUi = players.LocalPlayer.PlayerGui;

_G.autoshake = true;

repeat
	local shakeUi = playerUi:FindFirstChild('shakeui');
	if (not shakeUi) then task.wait(); continue; end;

	local buttonArea = shakeUi:FindFirstChild('safezone');
	if (not buttonArea) then task.wait(); continue; end;

	local button = buttonArea:FindFirstChild('button');
	if (not button) then task.wait(); continue; end;

	uiService.SelectedObject = button;
	inputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game);
	task.wait();
	inputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game);

	task.wait(0.5);
until _G.autoshake == false;