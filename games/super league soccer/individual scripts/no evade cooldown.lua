local repoStore = game:GetService('ReplicatedStorage');
local players = game:GetService('Players');
local inputService = game:GetService('UserInputService');

local knit = require(repoStore.Packages.Knit);
local animController = knit.GetController('AnimationController');
local actionService = knit.GetService('ActionService');

local lplr = players.LocalPlayer
local anim = lplr:GetAttribute('EquippedDribble') or 'The Marseille Turn';

local anims = repoStore.Assets.Items.Dribbles;

inputService.InputBegan:Connect(function(input, gpe)
	if (gpe) then return; end;
	if (input.KeyCode ~= Enum.KeyCode.Q) then return; end;

	actionService:PerformActionThenGet('EvadeActivated');
	animController:PlayAnimationFromPlayer(lplr, anims[anim], nil, nil, 1.38);
end);
