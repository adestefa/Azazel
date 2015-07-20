--[[ 
 ==================================--
  Azazel by CoreLogic 2015
 =================================--
  
	Evil Angel ~ Azazel [LUA] v0.9

	Inspired by the mutant from X-Men First Class Movie.
	
	Sebastian Shaw is dead and Eric is on vacation with Emma in the Bahammas sipping Mi-tys by the beach. 
	
	Azazel never had the stomach for laying around in the sun. Now addicted to Red Bull, he is board and wants some action.
	
	You are in control of one of the most lethal mutants, Azazel, the Red Angel. 
	
    Although you never see him (he is too fast for that) you will see the results ;-)	

	Press 'L' to summon Azazel. Have fun! 

    Video of Real Azazel: https://www.youtube.com/watch?v=F5pcqKBy1H4&feature=youtu.be&t=20   
	  
   
	This code is free to use and share, but please give credit and use in good will. (CoreLogic http://www.developer-me.com/forums/member.php?action=profile&uid=29)
  
	Github: https://github.com/adestefa/Azazel.git	
  
	Installation:
	 1. Install Script Hook https://www.gta5-mods.com/tools/script-hook-v 
	 2. Install the LUA script plugin for Scripthook https://www.gta5-mods.com/tools/lua-plugin-for-script-hook-v 
	 3. Download the flatsMiniGame file
	 4. Put the <b>Azazel.lua</b> file in your <install dir>\Grand Theft Auto V\scripts\addins folder. 
	 5. Text will appear above the mini-map when installed correctly
 
 -------------------------------
 version 0.9 7/17/2015
  - base version  
]]--
local Azazel = {};
-- ============================== --
--  Main configuration settings
-- ============================== --
Azazel.settings = {};
Azazel.settings["key_wait_time"] = 310;      -- key press delay before event firing again
Azazel.settings["dialog_cooldown"] = 1050;   -- time to show dialog msg on screen
Azazel.settings["height_increment"] = 50;    -- the higher value, the faster they rise
-- ============================== --
--     Run-time Global members
-- ============================== --
Azazel.data = {};
Azazel.data["seenPeds"] = {};                -- all peds seen and lifted by Azazel
Azazel.data["setup"] = false;				 -- did we set up the player yet?
-- ===================================== --
--  Each element in this table is
--  a switch that when on will be shown
--  as msg on screen when set true
--  and not shown when false.
-- ===================================== --
Azazel.toggle = {};
Azazel.toggle["dialog"] = true;               -- dialog message
Azazel.toggle["drop_attack"] = false;         -- main lift and drop attack
-- ======================================= --
--  Each element in this table is a timer
--   which often is associated with a 
--   'toggle' element. 
-- ======================================= --
Azazel.timer = {};
Azazel.timer["dialog"] = 0;                   -- timer to track dialog msg time onscreen
--Azazel.timer["drop_attack"] = 0;		      -- timer to track length of time attack is active
-- ============================== --
--     draw text to screen
-- ============================== --
function Azazel.draw_text(text, x, y, scale)
	UI.SET_TEXT_FONT(0);
	UI.SET_TEXT_SCALE(scale, scale);
	UI.SET_TEXT_COLOUR(255, 255, 255, 255);
	UI.SET_TEXT_WRAP(0.0, 1.0);
	UI.SET_TEXT_CENTRE(false);
	UI.SET_TEXT_DROPSHADOW(2, 2, 0, 0, 0);
	UI.SET_TEXT_EDGE(1, 0, 0, 0, 205);
	UI._SET_TEXT_ENTRY("STRING");
	UI._ADD_TEXT_COMPONENT_STRING(text);
	UI._DRAW_TEXT(y, x);
end
-- ============================== --
-- extra message display area
-- ============================== --
function Azazel.displayHitText(txt)
	Azazel.draw_text(txt, 0.5, 0.0005, 0.3);
end
-- ============================== --
-- play a sound 
-- (where do we find a 
--    list of game sound hashes??)
-- =============================== --
function Azazel.playSound()
	AUDIO.PLAY_SOUND_FRONTEND(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true);
end
-- =================================== --
--  Dynamically Toggle UI msg stage
-- =================================== --
function Azazel.switch(toggle)
 	if Azazel.toggle[toggle] then
		Azazel.toggle[toggle] = false;
	else
		Azazel.toggle[toggle] = true;
	end
end
-- =============================== --
--   Show toggle msgs to screen
-- =============================== --
function Azazel.showDisplayStack()
	
	-- ============= --
	--  Info dialog
	-- ============= --
	if (Azazel.toggle["dialog"]) then
		if (Azazel.timer["dialog"] < Azazel.settings["dialog_cooldown"]) then
			Azazel.draw_text(" Azazel", 0.45, 0.00005, 0.4);
			Azazel.draw_text(" The red mutant is back!\n\n He is now super fast\n thanks to Red Bull his\n new fav drink!", 0.5, 0.00005, 0.3);
			Azazel.draw_text(" Press 'L' to call Azazel\n and target close peds.\n", 0.63, 0.00005, 0.3);	
			Azazel.draw_text("  by CoreLogic 2015", 0.7, 0.000005, 0.24);			
			Azazel.timer["dialog"] = Azazel.timer["dialog"] + 1;
		else
			Azazel.toggle["dialog"] = false;
			Azazel.timer["dialog"] = 0;
		end
	end
	
	-- ===================== --
	--   Drop attack toggle
	-- ===================== --
	if(Azazel.toggle['drop_attack']) then
		Azazel.force();
		Azazel.draw_text(" - attacking... -", 0.97, 0.7, 0.3);
		Azazel.toggle["drop_attack"] = false;
	end
end
-- ============================== --
--  		Initialize
-- ============================== --
function Azazel.set()
	local player = PLAYER.PLAYER_PED_ID(); 
	local skin_hash = GAMEPLAY.GET_HASH_KEY("a_f_y_hipster_02");
	STREAMING.REQUEST_MODEL(skin_hash);
	PLAYER.SET_PLAYER_MODEL(player, GAMEPLAY.GET_HASH_KEY("a_f_y_hipster_02"));
	ENTITY.SET_ENTITY_COORDS(player, 1204.983, -2541.552, 37.900, true, true, true, true);
	ENTITY.SET_ENTITY_MAX_SPEED(player, 500);
	ENTITY.SET_ENTITY_INVINCIBLE(player, true);
	ENTITY.SET_ENTITY_HEALTH(player, 200);
	PLAYER.CLEAR_PLAYER_WANTED_LEVEL(player);
	ENTITY.SET_ENTITY_INVINCIBLE(player, false);
	PED.SET_PED_ARMOUR(player, 100);
	Azazel.data["setup"] = true; -- remember if we set the player up
end
-- ================================= --
--   Returns if we lifted this Ped
-- ================================= --
function Azazel.isNewPed(ped) 
	for i=1,#Azazel.data["seenPeds"] do
	local dead = PED._IS_PED_DEAD(Azazel.data["seenPeds"][i], true);
		--if(thisPedHealth > 0) then
		if(not dead) then
			if(Azazel.data["seenPeds"][i] == ped) then
			return false;
			end  
		end
	end
	return true;
end
-- ================================== --
-- Give Azazel a new target to lift
-- ================================== --
function Azazel.newTarget(ped)
	if (Azazel.isNewPed(ped)) then
		table.insert(Azazel.data["seenPeds"],ped);
		return false;
	else
		return true;
	end   
end
-- ======================================= --
-- print Ped data to console for debugging
-- ======================================= --
function Azazel.printPedData()
	for i=1,#Azazel.data["seenPeds"] do
	  print(i,Azazel.data["seenPeds"][i]);
	end
	Azazel.displayHitText("Ped data printed to console");
end
-- ======================================= --
--  You hear a thud, wonder long enough
--  to not realize he has grabbed you and
--  you too are now dangling over your doom
--  below. With a red smile, he lets go.
-- ======================================= --
function Azazel.force()
	local playerPed = PLAYER.PLAYER_PED_ID();
	local PedTab,PedCount = PED.GET_PED_NEARBY_PEDS(playerPed, 1, -1);
	thisPedCount = PedCount;
	for k,p in ipairs(PedTab)do 
		if(p == playerPed)then
		else
			-- target this ped (if not already dead)
			if (Azazel.newTarget(p)) then
				Azazel.playSound();
				--Azazel.playSound();
				-- simply find current ped location
				local coord=ENTITY.GET_ENTITY_COORDS(p,true)
				-- offset z-axis by incrementing palue
				local dz= coord.z + Azazel.settings["height_increment"];
				-- lift ped up and set some other configs
				ENTITY.SET_ENTITY_COORDS(p, coord.x, coord.y, dz, true, true, true, true);
				PED.SET_PED_TO_RAGDOLL(p, 6, 20, 20, true, true, true);
				PED.SET_PED_RAGDOLL_ON_COLLISION(p,true);
				PED.SET_PED_RAGDOLL_FORCE_FALL(p);	
				wait(500);					
			else
				-- do nothing /not targeting
			end
		end		
	end
end
-- =========================== --
--          Do the work!
-- =========================== --
function Azazel.tick()
	local playerPed = PLAYER.PLAYER_PED_ID();
	Azazel.showDisplayStack();
	-- =========================== --
	--  Initialize
	-- =========================== --
	if (not Azazel.data["setup"]) then
		Azazel.set();
	end	
	-- =========================== --
	--    Info about mod 'I'
	-- =========================== --
	if(get_key_pressed(73)) then 	
		Azazel.switch("dialog");
		wait(Azazel.settings["key_wait_time"]);
	end	
	-- ============================= --
	--  Azazel force 'L'
	-- ============================= --
	if(get_key_pressed(76)) then
		Azazel.switch("drop_attack");
		wait(20);
		--wait(Azazel.settings["key_wait_time"]);
	else -- not lifting
	-- ============================= --
	--  simple display UI
	-- ============================= --
		Azazel.draw_text(" [L] Azazel (v0.9)", 0.97, 0.7, 0.3);
	end		
	-- ============================== --
	--  display all toggled messages
	-- ============================== --
	
end
function Azazel.unload()
end
return Azazel;