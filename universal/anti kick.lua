local cloneref = cloneref or function(inst) return inst; end;
local clonefunction = clonefunction or function(func) return func; end;

local players = cloneref(game:GetService('Players'));

local lplr = players.LocalPlayer;

local stringLower = clonefunction(string.lower);

local oldNamecall;
oldNamecall = hookmetamethod(game, '__namecall', function(self, ...)
	local method = getnamecallmethod();

	if (stringLower(method) == 'kick' and self == lplr) then
		return;
	end;

	return oldNamecall(self, ...);
end);