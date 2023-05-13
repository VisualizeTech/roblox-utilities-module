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
                                                                                                                                                                                                                                                                                                                                            return {
	CACHE = true, --The cache module in general, if disabled this won't even load





--[[
  ___       _                          _    ___            _         
 |_ _| _ _ | |_  ___  _ _  _ _   __ _ | |  / __| __ _  __ | |_   ___ 
  | | | ' \|  _|/ -_)| '_|| ' \ / _` || | | (__ / _` |/ _|| ' \ / -_)
 |___||_||_|\__|\___||_|  |_||_|\__,_||_|  \___|\__,_|\__||_||_|\___|



The cache for this module divides into two halves. One half controls the cache before the module has loaded,
and the other half controls the cache after the module has loaded.

Internal Cache is the first half, and it controls the cache of the module before it has loaded. If you
disable this there will be no cache before the module has loaded.
]]
	INTERNAL_CACHE = "__main__", 

--[[
  ___            _      ___            _
 | _ \ ___  ___ | |_   / __| __ _  __ | |_   ___
 |   // _ \/ _ \|  _| | (__ / _` |/ _|| ' \ / -_)
 |_|_\\___/\___/ \__|  \___|\__,_|\__||_||_|\___|



The cache for this module divides into two halves. One half controls the cache before the module has loaded,
and the other half controls the cache after the module has loaded.

Root Cache is the second half, and it controls the cache of the module after it has loaded. If you disable
this there will be no cache both on the root and on the superficial aspects of the module.
]]
	ROOT_CACHE = "__main__",

--[[
  ___       _                            ___            _         
 | _ \ _ _ (_) _ __   __ _  _ _  _  _   / __| __ _  __ | |_   ___ 
 |  _/| '_|| || '  \ / _` || '_|| || | | (__ / _` |/ _|| ' \ / -_)
 |_|  |_|  |_||_|_|_|\__,_||_|   \_, |  \___|\__,_|\__||_||_|\___|
                                 |__/                


Primary Cache dictates whether or not the module should cache first-level mentions. That is to say, when a
module is required in the main script and not by another module (think of it as __main__ in python). Note
that this will only work if either Root Cache or Internal Cache is enabled.

If we assume module B is a dependency for module A then upon requiring module A it will require module B.
If disabled, instead of caching both B and A, the second-hand mentions will be the only ones to be cached
and shared among the module, and the cache will be skipped if it is required by a script.
]]
	PRIMARY_CACHE = "__main__",
	
--[[
  _    _             _    
 | |  | |           | |   
 | |__| | ___   ___ | | __
 |  __  |/ _ \ / _ \| |/ /
 | |  | | (_) | (_) |   < 
 |_|  |_|\___/ \___/|_|\_\



If you want to write your own cache code, you can use a hook to handle extra cache groups. A hook is a
function that will be called every time a cache group is needed.

Please note that this will override the cache behavior and might break or lag the module. Use moderately.                        
]]
	HOOK = nil
																																																																																				   }