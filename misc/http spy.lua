-- // logs: HttpGet, HttpGetAsync, HttpPost, HttpPostAsync, GetObjects
-- // loadstring(game:HttpGet('https://raw.githubusercontent.com/Iratethisname10/roblox/refs/heads/main/misc/http%spy.lua'))()

-- // inspired from:
-- // https://github.com/NotDSF/HttpSpy

local clonefunc = clonefunction or function(f) return f; end;

local callingMethod = clonefunc(getnamecallmethod);
local cClosure = clonefunc(newcclosure);
local hookMethod = clonefunc(hookmetamethod);

local blockRequests = false;

local toLog = {
	HttpGet = true,
	HttpGetAsync = true,
	HttpPost = true,
	HttpPostAsync = true,
	GetObjects = true,
};

local function printf(text, ...)
	return print('[http spy]', string.format(text, ...));
end;

local oldNamecall;
oldNamecall = hookMethod(game, '__namecall', cClosure(function(self, ...)
	local method = callingMethod();

	if (toLog[method]) then
		printf('%s - %s', method, ...);
	end;

	if (blockRequests) then
		printf('blocked');
		return task.wait(9e99);
	end;

	return oldNamecall(self, ...);
end));