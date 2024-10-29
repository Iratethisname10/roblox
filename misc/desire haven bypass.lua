-- key system bypass for https://discord.gg/desirehaven
-- also fuck your key system ppl keep taking my key, make the bot send an empheal message

local scriptHash = '4057c3f0b7a85d5bc4f9dc41f21114b698dc5de20e02ace2bfa7a20f8655b5ed4ef4a1ef3c4d3717d8e57f27867e0308';

local players = game:GetService('Players');
local lplr = players.LocalPlayer;

for _, v in lplr.PlayerGui:GetDescendants() do
	if (not v:IsA('LocalScript')) then continue; end;

	if (getscripthash(v) == scriptHash) then;
		v.Parent:Destroy();
	end;
end;