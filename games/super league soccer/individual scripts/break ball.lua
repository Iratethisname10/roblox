-- // you have to have possession of the ball
-- // too lazy to make it grab the ball lol
-- // this just puts the ball 100 studs under the map

local repoStore = game:GetService('ReplicatedStorage');

local knit = require(repoStore.Packages.Knit);
local matchController = knit.GetController('MatchController');

local ball = matchController:GetComponent('Football');
if (not ball) then return; end;

local possessedBall = ball:GetPossessedFootball();
if (not possessedBall) then return; end;

local ballComponent = ball:GetFootballComponent(possessedBall);
if (not ballComponent) then return; end;

possessedBall:SetAttribute('State', 'Released');
ballComponent:Shoot(Vector3.new(0, -100, 0), Vector3.zero);