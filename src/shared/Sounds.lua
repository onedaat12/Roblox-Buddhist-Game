-- The Bodhi Path: music and sound effects.
--
-- HOW TO ADD A SOUND
--   1. In Roblox Studio open the Toolbox, choose the Audio tab, and find a sound you like.
--   2. Right-click it and choose "Copy Asset ID".
--   3. Replace the 0 on the matching line below with that number.
-- A line left at 0 is simply silent (music keeps playing the previous step's track).

local Sounds = {}

Sounds.MusicVolume = 0.4
Sounds.EffectVolume = 0.7

----------------------------------------------------------------------
-- MUSIC: one looping track for each of the 28 steps of the journey.
----------------------------------------------------------------------
Sounds.Music = {
	{ step = "arrive", id = 88321898452519 }, --  1  Arrival: calm, welcoming, morning
	{ step = "bell", id = 0 }, --  2  The Temple Bell: very quiet, so the bell stands out
	{ step = "breath", id = 0 }, --  3  The First Breath: still, slow meditation
	{ step = "alms", id = 0 }, --  4  The Alms Round: light, warm village life
	{ step = "store", id = 0 }, --  5  The Merit Store: friendly bazaar
	{ step = "sights", id = 0 }, --  6  The Four Sights: thoughtful, bittersweet
	{ step = "cross", id = 0 }, --  7  The Great Departure: night journey, resolve
	{ step = "channa", id = 0 }, --  8  Channa's Farewell: tender parting
	{ step = "hair", id = 0 }, --  9  The Wanderer's Robe: solemn turning point
	{ step = "scouts", id = 0 }, -- 10  Shadows on the Road: uneasy, light tension
	{ step = "alara", id = 0 }, -- 11  The First Teacher: deep forest calm
	{ step = "uddaka", id = 0 }, -- 12  The Second Teacher: deeper, more spacious
	{ step = "doubt", id = 0 }, -- 13  The Seventh Army: unsettled, shifting
	{ step = "ascetics", id = 0 }, -- 14  The Five Companions: dry, sparse, austere
	{ step = "austerity", id = 0 }, -- 15  Six Years of Austerity: harsh, weary
	{ step = "sujata", id = 0 }, -- 16  Sujata's Offering: gentle relief, kindness
	{ step = "eat", id = 0 }, -- 17  The Middle Way: uplifting, balanced
	{ step = "bowl", id = 0 }, -- 18  The Golden Bowl: wonder, flowing water
	{ step = "sotthiya", id = 0 }, -- 19  The Grass-Cutter: simple, earthy
	{ step = "kusa", id = 0 }, -- 20  Eight Handfuls of Grass: quiet anticipation
	{ step = "daughters", id = 0 }, -- 21  The Daughters of Mara: hypnotic, then dangerous
	{ step = "armies", id = 0 }, -- 22  The Ten Armies: battle drums
	{ step = "mara", id = 0 }, -- 23  Mara: the biggest, darkest track
	{ step = "seat", id = 0 }, -- 24  The Seat of Awakening: hushed, sacred
	{ step = "watch1", id = 0 }, -- 25  The First Watch: night, vast, slow
	{ step = "watch2", id = 0 }, -- 26  The Second Watch: wider, deeper
	{ step = "watch3", id = 0 }, -- 27  The Third Watch: rising, luminous
	{ step = "awake", id = 0 }, -- 28  Awakened: joyful peace
}

----------------------------------------------------------------------
-- SOUND EFFECTS: short sounds that play once when something happens.
----------------------------------------------------------------------
Sounds.Effects = {
	bell = 0, -- the great temple bell is rung (deep bell or gong)
	wheel = 0, -- a prayer wheel is spun (soft whirr or small chime)
	strike = 0, -- your palm or staff swings (whoosh)
	hit = 0, -- a strike lands on a shadow (soft thud)
	beads = 0, -- a mala bead of light is sent (light shimmer or ping)
	metta = 0, -- loving-kindness radiates (warm swell or chord)
	bowl = 0, -- the singing bowl (a long singing-bowl tone)
	meditate = 0, -- you sit down to meditate (a single soft chime)
	petals = 0, -- a shadow is dispelled into petals (gentle sparkle)
	hurt = 0, -- your Calm is struck (dull low hit)
	overwhelm = 0, -- your Calm runs out (low fading tone)
	merit = 0, -- you earn merit (small bright chime)
	quest = 0, -- a new step of the journey begins (short gong or fanfare)
	pickup = 0, -- you pick something up: leaf, lotus, kusa (soft pluck)
	talk = 0, -- someone begins to speak (soft page-turn or blip)
	buy = 0, -- you buy something or put on a robe (cloth or coin sound)
	pray = 0, -- you pray at a shrine (small bell)
	storm = 0, -- Mara sends a storm (thunder crack)
	quake = 0, -- the earth answers as your witness (deep rumble)
	awaken = 0, -- the moment of awakening (long shimmering rise)
}

return Sounds
