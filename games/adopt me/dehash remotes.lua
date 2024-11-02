local router;

for _, v in next, getgc(true) do
	if (type(v) ~= 'table') then continue; end;

	if (rawget(v, 'get_remote_from_cache')) then
		router = v;
	end;
end;

local remotes = debug.getupvalue(router.get_remote_from_cache, 1);

for k, v in next, remotes do
	v.Name = k;
end;
