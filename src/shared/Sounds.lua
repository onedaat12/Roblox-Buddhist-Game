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
Sounds.WaterVolume = 0.6

----------------------------------------------------------------------
-- MUSIC: one looping track for each of the 28 steps of the journey.
----------------------------------------------------------------------
Sounds.Music = {
	{ step = "arrive", id = 100971756298760 }, --  1  Arrival: calm, welcoming, morning
	{ step = "bell", id = 93946537663928 }, --  2  The Temple Bell: very quiet, so the bell stands out
	{ step = "breath", id = 116130915379705 }, --  3  The First Breath: still, slow meditation
	{ step = "alms", id = 1839894836 }, --  4  The Alms Round: light, warm village life
	{ step = "store", id = 1840124474 }, --  5  The Merit Store: friendly bazaar
	{ step = "sights", id = 104515600700947 }, --  6  The Four Sights: thoughtful, bittersweet
	{ step = "cross", id = 1836376521 }, --  7  The Great Departure: night journey, resolve
	{ step = "channa", id = 1845724239 }, --  8  Channa's Farewell: tender parting
	{ step = "hair", id = 1842483589 }, --  9  The Wanderer's Robe: solemn turning point
	{ step = "scouts", id = 77103661048765 }, -- 10  Shadows on the Road: uneasy, light tension
	{ step = "alara", id = 135919250581860 }, -- 11  The First Teacher: deep forest calm
	{ step = "uddaka", id = 84936650613249 }, -- 12  The Second Teacher: deeper, more spacious
	{ step = "doubt", id = 1840843924 }, -- 13  The Seventh Army: unsettled, shifting
	{ step = "ascetics", id = 83850416265658 }, -- 14  The Five Companions: dry, sparse, austere
	{ step = "austerity", id = 76534453813986 }, -- 15  Six Years of Austerity: harsh, weary
	{ step = "sujata", id = 73080860156849 }, -- 16  Sujata's Offering: gentle relief, kindness
	{ step = "eat", id = 9046656223 }, -- 17  The Middle Way: uplifting, balanced
	{ step = "bowl", id = 140422396863468 }, -- 18  The Golden Bowl: wonder, flowing water
	{ step = "sotthiya", id = 111399415119885 }, -- 19  The Grass-Cutter: simple, earthy
	{ step = "kusa", id = 92428953268139 }, -- 20  Eight Handfuls of Grass: quiet anticipation
	{ step = "daughters", id = 9041786001 }, -- 21  The Daughters of Mara: hypnotic, then dangerous
	{ step = "armies", id = 84331969561132 }, -- 22  The Ten Armies: battle drums
	{ step = "mara", id = 9045721164 }, -- 23  Mara: the biggest, darkest track
	{ step = "seat", id = 126695140992161 }, -- 24  The Seat of Awakening: hushed, sacred
	{ step = "watch1", id = 82555754602814 }, -- 25  The First Watch: night, vast, slow
	{ step = "watch2", id = 110481782288601 }, -- 26  The Second Watch: wider, deeper
	{ step = "watch3", id = 1839251961 }, -- 27  The Third Watch: rising, luminous
	{ step = "awake", id = 96506107863425 }, -- 28  Awakened: joyful peace
}

----------------------------------------------------------------------
-- SOUND EFFECTS: short sounds that play once when something happens.
----------------------------------------------------------------------
Sounds.Effects = {
	bell = 106399723585350, -- the great temple bell is rung (deep bell or gong)
	wheel = 9120658280, -- a prayer wheel is spun (soft whirr or small chime)
	strike = 123890977510299, -- your palm or staff swings (whoosh)
	hit = 9113818671, -- a strike lands on a shadow (soft thud)
	beads = 6691605753, -- a mala bead of light is sent (light shimmer or ping)
	metta = 99384056183835, -- loving-kindness radiates (warm swell or chord)
	bowl = 138570431689848, -- the singing bowl (a long singing-bowl tone)
	meditate = 9116395089, -- you sit down to meditate (a single soft chime)
	petals = 110241936966089, -- a shadow is dispelled into petals (gentle sparkle)
	hurt = 9113486062, -- your Calm is struck (dull low hit)
	overwhelm = 107073250463751, -- your Calm runs out (low fading tone)
	merit = 1839901345, -- you earn merit (small bright chime)
	quest = 89056648074625, -- a new step of the journey begins (short gong or fanfare)
	pickup = 1008455422378, -- you pick something up: leaf, lotus, kusa (soft pluck)
	talk = 132723137731070, -- someone begins to speak (soft page-turn or blip)
	buy = 607662191, -- you buy something or put on a robe (cloth or coin sound)
	pray = 9113420607, -- you pray at a shrine (small bell)
	storm = 71511119515611, -- Mara sends a storm (thunder crack)
	quake = 9114220333, -- the earth answers as your witness (deep rumble)
	awaken = 121538758381608, -- the moment of awakening (long shimmering rise)
	splash = 142431247, -- you drop into deep water (a splash)
}

-- Effects that are too long: how many seconds to play before fading away gently.
-- (Any effect not listed here plays in full, up to 12 seconds.)
Sounds.EffectLength = {
	bowl = 6,
}

-- Effects where only the ending is wanted: play just the last so-many seconds.
Sounds.EffectTail = {
	merit = 2,
}

----------------------------------------------------------------------
-- SURROUNDINGS: looping sounds that grow louder as you come near something.
----------------------------------------------------------------------
Sounds.Ambient = {
	stream = 110597779584354, -- running water, heard near every stream and river and on the bridges
	wade = 78165223586115, -- walking through shallow water (sloshing footsteps)
	swim = 9125777696, -- swimming (strokes and splashes)
}

return Sounds
