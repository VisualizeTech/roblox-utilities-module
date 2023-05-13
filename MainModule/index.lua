--[[
$$\    $$\ $$\                               $$\ $$\                     
$$ |   $$ |\__|                              $$ |\__|                    
$$ |   $$ |$$\  $$$$$$$\ $$\   $$\  $$$$$$\  $$ |$$\ $$$$$$$$\  $$$$$$\  
\$$\  $$  |$$ |$$  _____|$$ |  $$ | \____$$\ $$ |$$ |\____$$  |$$  __$$\ 
 \$$\$$  / $$ |\$$$$$$\  $$ |  $$ | $$$$$$$ |$$ |$$ |  $$$$ _/ $$$$$$$$ |
  \$$$  /  $$ | \____$$\ $$ |  $$ |$$  __$$ |$$ |$$ | $$  _/   $$   ____|
   \$  /   $$ |$$$$$$$  |\$$$$$$  |\$$$$$$$ |$$ |$$ |$$$$$$$$\ \$$$$$$$\ 
    \_/    \__|\_______/  \______/  \_______|\__|\__|\________| \_______|
    
This package is free software; you can redistribute it and/or modify it under
the license CC BY-NC 4.0.

You do not have to give me credit, it would be nice though :). You can also use this in your commercial
proyects. The reason I chose the CC BY-NC 4.0 license is because I will not allow it to be reselled as it
is, however, you can use it in commercial proyects whose main purpose is not to resell or take advantage of
this module directly.
]]--

local module = {
	self = script,
	module = script.Parent,

	paths = {},

	cache = { --Table where temporary/background values are stored.
		["append-load"] = {}, --COMING SOON
		["on-load"] = {}, --COMING SOON
		jobs = {}
	},

	version = "0.0.0",

	ready = false,
	loaded = false,

	settings = {}
};

function module:RemoveSelf(...)
	local arguments = {...}; if(self == arguments[1]) then table.remove(arguments, 1) end;
	return arguments;
end

module.AddRemoveSelf = function(...)
	local tables = module:RemoveSelf(...);

	for _, t in ipairs(tables) do
		assert(type(t) == "table", "Error at (AddRemoveSelf)\nExpected positional argument 1 to be a table\nGot '" .. typeof(t) .. "' instead.");

		function t:RemoveSelf(...)
			local arguments = {...};

			local r = function() table.remove(arguments, 1) end; --Shortcut

			if(self == arguments[1]) then
				r();
			elseif(type(arguments[1]) == "table") then
				local m = getmetatable(arguments[1]);
				if(m and type(m.objects) == "table") then --Is it a proxy?
					local m2 = getmetatable(self);

					if(table.find(m.objects, self)) then
						r();
					elseif(m2 and type(m2.objects) == "table") then

						for _, t in pairs(m2.objects) do
							if(table.find(m.objects, t)) then
								r();
								break
							end
						end
					end
				end
			end

			local clone = {...};
			setmetatable(arguments, { -- Allows for the original arguments to still be accesible through the
				--									__arguments key, we do not set it just in case someone loops through
				--									the table and gets an undesired key
				__index = function(self,k)
					if(k == "__arguments" or k == "__args") then return clone
					else return rawget(self,k) end;
				end
			});

			return arguments;
		end
	end
end; module.addRemoveSelf = module.AddRemoveSelf; module.addremoveself = module.AddRemoveSelf;




--[[
  _____      _   _         
 |  __ \    | | | |        
 | |__) |_ _| |_| |__  ___ 
 |  ___/ _` | __| '_ \/ __|
 | |  | (_| | |_| | | \__ \
 |_|   \__,_|\__|_| |_|___/
                           
]]--

local pathInterpreter = function(path : string, action : string, value : any)
	path = string.gsub(path, "//", "/");
	local segments = string.split(path, "/");
	if(segments[1] == "") then table.remove(segments, 1) end;

	if(action == "create") then
		local t = module;
		for i,k in pairs(segments) do
			if(not t.paths) then t.paths = {} end;
			if(not t.paths[k]) then t.paths[k] = {paths = {}} end;

			if(i == #segments) then
				t.paths[k] = value;
				return value;
			else t = t.paths[k] end;
		end
	elseif(action == "get") then
		local t = module;
		for i,k in pairs(segments) do
			if(not t.paths) then t.paths = {};
			elseif(not t.paths[k]) then return end;

			t = t.paths[k];
		end

		return t;
	elseif(action == "fix") then
		value = string.gsub(value, "//", "/");
		local segments2 = string.split(value, "/");
		if(segments2[1] == "") then table.remove(segments2, 1) end;

		local t2 = module;
		for i,k in pairs(segments2) do
			if(not t2.paths) then t2.paths = {};
			elseif(not t2.paths[k]) then return end;

			if(i ~= #segments2) then t2 = t2.paths[k] end;
		end

		local t = module;
		for i,k in pairs(segments) do
			if(not t.paths) then t.paths = {};
			elseif(not t.paths[k]) then return end;

			if(i == #segments) then
				t2.path = t.paths[k];
				return t;
			else t = t.paths[k] end;
		end
	end
end

module.CreatePath = function(path : string | {}, location : Instance): Instance | {[number] : {any}}
	if(type(path) == "table") then
		local results = {};

		for _, path in ipairs(path) do
			table.insert(results, pathInterpreter(path, "create", {
				path = location,
				paths = {}
			}));
		end

		return results;
	else
		return pathInterpreter(path, "create", {
			path = location,
			paths = {}
		});
	end
end

module.GetPath = function(path : string): Instance
	local result = pathInterpreter(path, "get");
	assert(result, "An error has occurred in the Utility's anchor module. An exception was thrown at the 'index' module, more specifically in the function 'GetPath':\nerror at (GetJob), could not find path '" .. tostring(path) .. "'.")

	if(type(result.path) == "string") then
		result.path = pathInterpreter(result.path, "fix", path).path;
	end

	return result.path;
end

setmetatable(module, {
	__call = function(self, path: string): Instance
		return module.GetPath(path);
	end
});

module.CreatePath("/module", script.Parent);
module.CreatePath("/settings", module"module":WaitForChild("Settings"));
module.CreatePath("/assets", module"module":WaitForChild("Assets"));

module.CreatePath({"/datatypes", "/assets/datatypes"}, module"assets":WaitForChild("Datatypes"));
module.CreatePath({"/libraries", "/assets/libraries"}, module"assets":WaitForChild("Libraries"));
module.CreatePath({"/modules", "/assets/modules"}, module"assets":WaitForChild("Modules"));

module.CreatePath("/primordial", module"module":WaitForChild("Primordial"));
module.CreatePath("/primordial/services", module"/primordial":WaitForChild("Services"));

module.CreatePath({"/cron", "/cron.lua"}, module"/primordial/services":WaitForChild("cron.lua"));
module.CreatePath("/types", module"/primordial":WaitForChild("types.d.lua")); --Ignore, just keeping this
--here if roblox ever improves type-checking (since right now Roblox can't typecheck through 2 or more
--functions)




--[[
   _____      _   _   _                 
  / ____|    | | | | (_)                
 | (___   ___| |_| |_ _ _ __   __ _ ___ 
  \___ \ / _ \ __| __| | '_ \ / _` / __|
  ____) |  __/ |_| |_| | | | | (_| \__ \
 |_____/ \___|\__|\__|_|_| |_|\__, |___/
                               __/ |    
                              |___/     
]]

for _, s in pairs(module"settings":GetChildren()) do
	module.settings[s:GetAttribute("Name")] = require(s);
end

module.RequireSetting = function(name : string, update : boolean?)
	assert(type(name) == "string", "Error at (GetSetting)\nExpected positional argument 1 to be a string\nGot '" .. typeof(name) .. "' instead.");

	for _, s in pairs(module"settings":GetChildren()) do
		if(s == name) then
			local result = require(s);
			if(update) then module.settings[s:GetAttribute("Name")] = result end;
			return result
		end
	end
end

module.GetSetting = function(name : string)
	assert(type(name) == "string", "Error at (GetSetting)\nExpected positional argument 1 to be a string\nGot '" .. typeof(name) .. "' instead.");

	return module.settings[name];
end

--[[
   _____                 
  / ____|                
 | |     _ __ ___  _ __  
 | |    | '__/ _ \| '_ \ 
 | |____| | | (_) | | | |
  \_____|_|  \___/|_| |_|
                         
]]--
module.cron = require(module"cron")(module);

--[[
   ___         _        
  / __|__ _ __| |_  ___ 
 | (__/ _` / _| ' \/ -_)
  \___\__,_\__|_||_\___|
  
]]--

local cacheGroupFrom = function(job : any, main : boolean)
	local setting = module.GetSetting("cache");
	if(not setting.CACHE) then return "void" end;

	if(setting.HOOK) then
		return setting.HOOK(module, job, main);
	end

	if(main) then
		return setting.PRIMARY_CACHE;
	end

	if(module.loaded) then return setting.ROOT_CACHE;
	elseif(module.ready) then
		return setting.INTERNAL_CACHE;
	end
end

do --Create all the group caches
	local setting = module.GetSetting("cache");
	module.cron.CreateCacheGroup(setting.INTERNAL_CACHE);
	module.cron.CreateCacheGroup(setting.ROOT_CACHE);
	module.cron.CreateCacheGroup(setting.PRIMARY_CACHE);
end

--[[
   ___              
  / __|_ _ ___ _ _  
 | (__| '_/ _ \ ' \ 
  \___|_| \___/_||_|
                    
]]--

--Why cache the jobs? Well, it's common for the jobs to be looped through, if there wasn't any cache then
--every loop would need a new table which is resource consuming. It's better to cache them all.
module.ReloadJobs = function(...): {[number] : {}}
	module.cache.jobs = module.cron.CreateJobs();

	return module.cache.jobs;
end
module.ReloadJobs();

module.ReloadJob = function(identifier : string, filter)
	filter = filter or {"id", "name"};

	for i, job in ipairs(module.cache.jobs) do
		if((job.identifier == identifier and table.find(filter, "id")) or (job.name == identifier and table.find(filter,  "name"))) then
			module.cache.jobs[i] = module.cron.CreateJob(job.module);
		end
	end

	return module;
end; module.reloadJob = module.ReloadJob; module.reloadjob = module.ReloadJob;

do -- This is a monster, and I am sorry that you got to see this. So for now I am putting it inside a do
	--loop to hide it from everyone else :D

	module.Require = function(name : string, version : number?, async : boolean?, callstack : any?)		
		assert(type(name) == "string", "Error at (Require)\nExpected positional argument 1 to be a string\nGot '" .. typeof(name) .. "' instead.");


		local main = false; --Determines whether this is being called by runtime or by the module.
		--		e.g: The library "anchor.lua" requires "table.lua", so if you require "anchor.lua" then		
		--		"anchor.lua" would be main and "table.lua" wouldn't be main. But if you require "table.lua" then
		--		it will become main.

		--		'version' - Modules send their contents by bits, you can either get a specific version of a module
		--		or wait for it's completion

		--		'async' - Some modules might take a long time to load, so if you wish to run more stuff meanwhile
		--		you can use that.

		--		'callstack' - Callstacks are useful to segregate a given cache group until the entire callstack
		--		finishes, this is necessary for situations where there is no cache.



		--		If this was called without a callstack, or the parent process had no callstack, then this means it
		--		is a main call which should spawn another group.	
		if(not callstack) then
			callstack = math.random(1,10000); --The id of the entire callstack

			main = true;
		end

		--		What group should the process be at or go to? This determines where the module should look for
		--		another module.
		local group = cacheGroupFrom(main, true);

		local result = module.cron.GetCache(name, "process", group) or module.cron.GetCache(name, "process", callstack);
		--		Checks if the module already exists

		local ret = function(...) --Simplifying so I don't need to write this condition multiple times

			--			'ret' means return, all the functions (except async) already have this so it doesn't need to be
			--			repeated all the time.

			if(main == true and module.cron.cache[callstack]) then
				module.cron.TransposeCacheGroup(callstack, group); --Transposing cache means changing it's
				--				name, we do this at the end so it merges with the main branch
			end

			return ...;

		end

		local syncReturn = function():any

			local thread = coroutine.running();
			local done = false;

			result.listen(function(steps, totalSteps)
				if(not version and steps == totalSteps or version and version <= steps) then
					done = true;
					coroutine.resume(thread);
				end

				if(version and version > totalSteps and steps == totalSteps) then warn("Version mismatch on (Require) for asset " .. tostring(name) .. ", the expected version is bigger than the expected final version, this could result in an infinite yield.") end;
			end);

			if(not result.ended and not result.running) then
				task.spawn(function() result() end);
			end

			if(not done and not result.ended) then coroutine.yield(thread) end;

			return ret(result.job.value);
		end

		local asyncReturn = function():((any) -> ()) -> ()	
			return ret(function(caller)
				result.listen(function(steps, totalSteps)
					if(not version and steps == totalSteps or version and version <= steps) then							
						module.cron.TransposeCacheGroup(callstack, group);

						caller(result.job.value);
					end

					if(version and version > totalSteps and steps == totalSteps) then warn("Version mismatch on (Require) for asset " .. tostring(name) .. ", the expected version is bigger than the expected final version, this could result in an infinite yield.") end;
				end);

				if(not result.ended and not result.running) then
					task.spawn(function() result() end);
				end
			end);
		end

		if(result) then --Does a cache already exist?			
			if(not version and result.steps == result.totalsteps or version and version <= result.steps) then
				return ret(result.job.value) --Already above the necessary version
			else
				if(async) then --This returns a caller that will call a function when the necessary version is present
					return asyncReturn();
				else --This waits for the necessary version, and then returns
					return syncReturn();
				end
			end
		else --Was the module never required?			
			do
				local _, err = pcall(function()
					if(main) then
						module.cron.CreateCacheGroup(callstack);
					end

					result = module.cron.CreateProcess(module.cron.GetJob(module.cache.jobs, name), callstack);
				end);

				if(err) then --Does the module not exist?
					warn("An error occured when calling a function:", err);
					error("An error has occurred in the Utility's main index. An exception was thrown at the 'index' module, more specifically in the function 'Require':\nerror at (Require), could not find asset with name '" .. tostring(name) .. "' in the job's array.\nThis is probably due to you misspelling the name or searching for an asset that does not exist.");
				end
			end

			module.cron.Cache({ --Create a new cache for this module
				type = "process",
				identifier = result.identifier,
				value = result
			}, callstack or group); module:ReloadJob(name);
			--NOTE: If 'callstack' and the 'group' variable is nil, then the table won't be cached.

			if(async) then
				return asyncReturn();
			else
				return syncReturn();
			end
		end
	end
end



--[[
  _____        _        _                         
 |  __ \      | |      | |                        
 | |  | | __ _| |_ __ _| |_ _   _ _ __   ___  ___ 
 | |  | |/ _` | __/ _` | __| | | | '_ \ / _ \/ __|
 | |__| | (_| | || (_| | |_| |_| | |_) |  __/\__ \
 |_____/ \__,_|\__\__,_|\__|\__, | .__/ \___||___/
                             __/ | |              
                            |___/|_|              
]]--

module.GetDatatypes = function(...)
	local t = {};
	for _, job in ipairs(module.cache.jobs) do
		if(job.module.Parent:GetAttribute("Identifier") == "3A73B94F-4FBC-46C0-AD8B-FB4EC6B776D2") then
			t[job.identifier] = job;
		end
	end

	return t;
end

module.GetDatatype = function(value : any)
	local _type = typeof(value);
	if(_type == type(value)) then return end; --To stop things like 'table', 'string', 'number' from
	--	being confused with roblox datatypes

	local datatype;
	pcall(function()
		datatype = module.Require(_type);
	end);

	return datatype;
end




--[[
  ______           _ 
 |  ____|         | |
 | |__   _ __   __| |
 |  __| | '_ \ / _` |
 | |____| | | | (_| |
 |______|_| |_|\__,_|
                     
]]--

return module;