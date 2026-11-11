-- The Bodhi Path: shared settings and world data.
-- Everything here is plain data so that the server and the client agree on it.
-- Positions are written as {x = ..., z = ...}; the ground is at height 0 and the
-- journey runs along the X axis, from the home temple (x = 0) to the Bodhi tree.

local Config = {}

Config.Title = "The Bodhi Path"
Config.DataStoreName = "BodhiPath_v1"
Config.HalfWidth = 150 -- playable distance either side of the road
Config.WorldStart = -220
Config.WorldEnd = 2860

----------------------------------------------------------------------
-- Zones (in travel order)
----------------------------------------------------------------------
Config.Zones = {
	{ id = "village", name = "Kapilavastu", sub = "Where every journey begins", x0 = -220, x1 = 260, light = "morning", ground = "Grass" },
	{ id = "road", name = "Road of the Four Sights", sub = "Age, sickness, death, and one who is at peace", x0 = 260, x1 = 620, light = "day", ground = "Grass" },
	{ id = "anoma", name = "River Anoma", sub = "The Great Departure", x0 = 620, x1 = 830, light = "day", ground = "Grass" },
	{ id = "forest", name = "Forest of the Teachers", sub = "Among the sal trees", x0 = 830, x1 = 1220, light = "forest", ground = "LeafyGrass" },
	{ id = "uruvela", name = "Uruvela", sub = "The grove of austerities", x0 = 1220, x1 = 1580, light = "harsh", ground = "Ground" },
	{ id = "senani", name = "Senani and the Neranjara", sub = "Sujata's village by the river", x0 = 1580, x1 = 2040, light = "golden", ground = "Grass" },
	{ id = "mara", name = "Mara's Field", sub = "The ten armies gather", x0 = 2040, x1 = 2560, light = "storm", ground = "Basalt" },
	{ id = "bodhgaya", name = "Bodh Gaya", sub = "The Seat of Awakening", x0 = 2560, x1 = 2860, light = "night", ground = "Grass" },
}

-- Gates between zones. A player may pass a gate once they have reached the named quest step.
Config.Gates = {
	{ id = "gate_road", x = 260, quest = "sights", hint = "Finish your duties at the temple first." },
	{ id = "gate_forest", x = 830, quest = "scouts", hint = "Take up the life of a wanderer before entering the forest." },
	{ id = "gate_uruvela", x = 1220, quest = "ascetics", hint = "Learn what the two teachers can teach before going on." },
	{ id = "gate_senani", x = 1580, quest = "sujata", hint = "The road to Senani opens when the austerities are done." },
	{ id = "gate_mara", x = 2040, quest = "daughters", hint = "Gather the kusa grass for your seat before facing Mara." },
	{ id = "gate_bodhi", x = 2560, quest = "seat", hint = "Mara bars the way. He must be answered first." },
}

----------------------------------------------------------------------
-- Important places
----------------------------------------------------------------------
-- Running water: every stream and river crosses the road from north to south at "x".
Config.Rivers = {
	{ x = 122, width = 12, depth = 6 },
	{ x = 456, width = 12, depth = 6 },
	{ x = 725, width = 48, depth = 10 }, -- the Anoma
	{ x = 1040, width = 12, depth = 6 },
	{ x = 1880, width = 72, depth = 10 }, -- the Neranjara
}

Config.Places = {
	spawn = { x = 0, z = 0 },
	temple = { x = -80, z = 0 },
	temple_bell = { x = 12, z = -52 },
	hall = { x = -20, z = 84 },
	wheels = { x = 40, z = 44 },
	lotus_pond = { x = 52, z = -92 },
	store = { x = 160, z = 58 },
	tailor = { x = 204, z = -58 },
	anoma_river = { x = 725, z = 0, width = 48 },
	hair_rock = { x = 802, z = -22 },
	alara = { x = 940, z = 88 },
	uddaka = { x = 1110, z = -88 },
	ascetic_camp = { x = 1320, z = -50 },
	cave = { x = 1420, z = 96 },
	sujata_tree = { x = 1700, z = 52 },
	store2 = { x = 1644, z = -56 },
	bowl_river = { x = 1840, z = 0 },
	neranjara = { x = 1880, z = 0, width = 72 },
	mucalinda = { x = 2000, z = -96 },
	arena = { x = 2470, z = 0, radius = 62 },
	mara = { x = 2522, z = 0 },
	tree = { x = 2740, z = 0 },
	seat = { x = 2752, z = 0 },
}

-- Shrines: checkpoints, places to pray, travel points.
Config.Shrines = {
	{ id = "village", name = "Temple Courtyard", x = 40, z = 12 },
	{ id = "road", name = "Wayside Shrine", x = 288, z = -22 },
	{ id = "anoma", name = "Anoma Bank", x = 650, z = -30 },
	{ id = "forest", name = "Forest Edge", x = 852, z = 14 },
	{ id = "uruvela", name = "Uruvela", x = 1246, z = 14 },
	{ id = "senani", name = "Senani Village", x = 1606, z = 14 },
	{ id = "neranjara", name = "Neranjara East Bank", x = 1950, z = -26 },
	{ id = "mara_edge", name = "Edge of Mara's Field", x = 2064, z = 14 },
	{ id = "mara_gate", name = "Before the Host", x = 2384, z = 14 },
	{ id = "bodhgaya", name = "Bodh Gaya", x = 2592, z = 14 },
	{ id = "garden", name = "Pilgrims' Garden", x = -2, z = -80 },
}

-- Places where meditating counts toward a quest.
Config.MeditationSpots = {
	{ id = "village_hall", x = -20, z = 84, radius = 24 },
	{ id = "alara", x = 940, z = 70, radius = 20 },
	{ id = "uddaka", x = 1110, z = -70, radius = 20 },
	{ id = "cave", x = 1420, z = 92, radius = 18 },
	{ id = "bodhi_seat", x = 2752, z = 0, radius = 14 },
}

-- Areas used by "reach this place" objectives.
Config.Areas = {
	anoma_far = { x = 780, z = 0, radius = 34 },
	neranjara_far = { x = 1945, z = 0, radius = 40 },
}

----------------------------------------------------------------------
-- Player basics
----------------------------------------------------------------------
Config.Player = {
	BaseCalm = 100,
	BaseSpeed = 16,
	PassiveRegen = 1.5, -- calm per second when not recently hurt
	MeditateRegen = 9, -- calm per second while meditating
	MeditateShield = 0.5, -- damage multiplier while meditating
	HurtRegenDelay = 5,
	OverwhelmGrace = 4,
}

-- Abilities. "key" is the keyboard key; every ability also has an on-screen button.
Config.Abilities = {
	strike = { name = "Strike", key = "F", cooldown = 0.45, range = 8, damage = 10, order = 1, hint = "Open palm, or your staff once you carry one." },
	beads = { name = "Mala", key = "R", cooldown = 1.2, range = 80, damage = 16, order = 2, hint = "Send a bead of light at the nearest shadow." },
	metta = { name = "Metta", key = "Q", cooldown = 14, range = 24, damage = 45, order = 3, hint = "Radiate loving-kindness in every direction." },
	bowl = { name = "Bowl", key = "G", cooldown = 18, range = 28, stun = 4, order = 4, hint = "The singing bowl stills every shadow that hears it." },
	meditate = { name = "Meditate", key = "M", cooldown = 0.5, order = 5, hint = "Sit and return to the breath. Calm returns quickly." },
}

-- What the Strike ability is done with. "palm" needs nothing; the others are items
-- held in the hand (chosen in the Bag). "hits" is how many shadows one swing can touch,
-- "all" reaches behind you as well, "swing" is how far the weapon sweeps (degrees).
-- "stun" holds a struck shadow still (seconds), "push" throws it back (studs),
-- "thrown" flies out and returns, "field" leaves a circle of light (seconds).
Config.Weapons = {
	palm = { name = "Open Palm", damage = 10, range = 8, cooldown = 0.45, hits = 3 },
	staff = { name = "Walking Staff", damage = 22, range = 11, cooldown = 0.45, hits = 3, swing = 115 },
	whisk = { name = "Fly Whisk", damage = 13, range = 10, cooldown = 0.28, hits = 5, all = true, swing = 140 },
	spade = { name = "Monk's Spade", damage = 44, range = 14, cooldown = 0.85, hits = 4, swing = 125 },
	wisdom_sword = { name = "Sword of Wisdom", damage = 36, range = 12, cooldown = 0.45, hits = 4, swing = 130 },
	conch = { name = "Conch Horn", damage = 16, range = 18, cooldown = 1, hits = 8, all = true, push = 12, stun = 0.5, ring = true },
	bell = { name = "Hand Bell", damage = 18, range = 12, cooldown = 0.7, hits = 3, all = true, swing = 80, stun = 0.5, ring = true },
	phurba = { name = "Phurba", damage = 30, range = 9, cooldown = 0.5, hits = 1, swing = 150, stun = 3 },
	chakra = { name = "Wheel of Light", damage = 24, range = 44, cooldown = 1.1, hits = 0, swing = 120, thrown = true },
	lantern = { name = "Paper Lantern", damage = 6, range = 14, cooldown = 6, hits = 0, field = 5 },
}

----------------------------------------------------------------------
-- The Noble Eightfold Path: upgrades bought in order with merit at any shrine.
----------------------------------------------------------------------
Config.Path = {
	{ id = "view", name = "Right View", pali = "Samma ditthi", cost = 60, text = "Seeing clearly. All merit you earn is increased by 20%." },
	{ id = "intention", name = "Right Intention", pali = "Samma sankappa", cost = 90, text = "Goodwill and harmlessness. Metta is 40% stronger." },
	{ id = "speech", name = "Right Speech", pali = "Samma vaca", cost = 120, text = "Truthful, kind words. Shopkeepers ask 15% less." },
	{ id = "action", name = "Right Action", pali = "Samma kammanta", cost = 160, text = "Acting without harm. Strikes are 30% stronger." },
	{ id = "livelihood", name = "Right Livelihood", pali = "Samma ajiva", cost = 200, text = "Living simply. Prayer wheels, bells and offerings give double merit." },
	{ id = "effort", name = "Right Effort", pali = "Samma vayama", cost = 250, text = "Steady energy. You walk faster." },
	{ id = "mindfulness", name = "Right Mindfulness", pali = "Samma sati", cost = 300, text = "Present and aware. Your Calm grows by 40." },
	{ id = "concentration", name = "Right Concentration", pali = "Samma samadhi", cost = 400, text = "A collected mind. Meditation restores Calm twice as fast." },
}

----------------------------------------------------------------------
-- Items. Everything a player can carry is something a Buddhist monastic or
-- pilgrim would recognise.
----------------------------------------------------------------------
Config.Items = {
	alms_bowl = { name = "Alms Bowl", desc = "One of a monk's eight requisites. Villagers place food in it.", keep = true, order = 1 },
	rice = { name = "Alms Rice", desc = "A simple meal, freely given. Restores 35 Calm.", use = "heal", amount = 35, order = 2 },
	tea = { name = "Butter Tea", desc = "Warming and steadying. Walk faster for 60 seconds.", use = "speed", amount = 6, duration = 60, order = 3 },
	incense = { name = "Incense", desc = "Light it and breathe. Calm returns faster for 60 seconds.", use = "regen", amount = 4, duration = 60, order = 4 },
	lamp = { name = "Butter Lamp", desc = "Offer it at a shrine to earn merit and a blessing of protection.", use = "offer", merit = 25, order = 5 },
	lotus = { name = "Lotus Flower", desc = "Rises clean from the mud. Offer it at a shrine to earn merit.", use = "offer", merit = 12, order = 6 },
	milk_rice = { name = "Sujata's Milk-Rice", desc = "Rice boiled in rich milk, offered in a golden bowl. Eat it to end the long fast.", use = "quest", order = 7 },
	golden_bowl = { name = "Golden Bowl", desc = "The bowl Sujata gave. It belongs to the river now.", keep = true, order = 8 },
	kusa = { name = "Kusa Grass", desc = "Sacred grass from the grass-cutter Sotthiya. Eight handfuls make the seat.", keep = true, order = 9 },
	singing_bowl = { name = "Singing Bowl", desc = "Its tone stills the mind. Unlocks the Bowl ability.", keep = true, unlock = "bowl", order = 10 },
	vajra = { name = "Vajra", desc = "The diamond thunderbolt: unbreakable resolve. Strikes are 25% stronger.", keep = true, order = 11 },
	wheel_charm = { name = "Dharma Wheel", desc = "Eight spokes for the Eightfold Path. Earn 10% more merit.", keep = true, order = 12 },
	long_mala = { name = "Mala of 108 Beads", desc = "A full mala. The Mala ability recovers twice as fast.", keep = true, order = 13 },
	prayer_flags = { name = "Prayer Flags", desc = "Blue, white, red, green and yellow. Colourful flags trail behind you.", keep = true, order = 14 },
	staff = { name = "Walking Staff", desc = "A ringed staff; the rings warn small creatures off the path. Reaches further and strikes harder than an open palm.", keep = true, use = "equip", order = 15 },
	whisk = { name = "Fly Whisk", desc = "A whisk for brushing insects away without harming them: a sign of sweeping troubles from the mind. Very quick, and reaches every shadow around you.", keep = true, use = "equip", order = 16 },
	spade = { name = "Monk's Spade", desc = "The crescent-bladed spade of the wandering monks of China, carried to clear the road and to bury the dead they found. Slow, heavy, and long.", keep = true, use = "equip", order = 17 },
	wisdom_sword = { name = "Sword of Wisdom", desc = "The flaming sword of Manjushri. It cuts through ignorance and harms no living thing. Earned by finding the Eight Auspicious Symbols.", keep = true, use = "equip", order = 18 },
	conch = { name = "Conch Horn", desc = "The white conch, whose deep note carries in every direction as the teaching does. One blast pushes back every shadow around you.", keep = true, use = "equip", order = 19 },
	bell = { name = "Hand Bell", desc = "The ritual bell, held with the vajra. Its clear sound stands for wisdom. Shadows that hear it stop for a moment.", keep = true, use = "equip", order = 20 },
	phurba = { name = "Phurba", desc = "The three-sided ritual peg of Tibet. It wounds nothing: it pins one obstacle in place so that it can be faced.", keep = true, use = "equip", order = 21 },
	chakra = { name = "Wheel of Light", desc = "A wheel of eight spokes. In the Deer Park the Buddha set the wheel of the Dharma turning. Thrown, it flies out and comes back. A gift of the animals of the old stories.", keep = true, use = "equip", order = 22 },
	lantern = { name = "Paper Lantern", desc = "A lantern for the dark road. Set down its light and shadows inside the circle grow slow and weak.", keep = true, use = "equip", order = 23 },

	-- Things that change only how you look (from the Garden Stall). "slot" items are
	-- worn one at a time; lantern colours are used for the sky lanterns you release.
	lantern_lotus = { name = "Lotus-Pink Lanterns", desc = "Your sky lanterns can glow the pink of a lotus at dawn.", keep = true, lanternColor = { 255, 150, 190 }, order = 30 },
	lantern_jade = { name = "Jade Lanterns", desc = "Your sky lanterns can glow a soft jade green.", keep = true, lanternColor = { 120, 220, 160 }, order = 31 },
	lantern_sky = { name = "Sky-Blue Lanterns", desc = "Your sky lanterns can glow the blue of a clear morning.", keep = true, lanternColor = { 130, 190, 255 }, order = 32 },
	lantern_gold = { name = "Golden Lanterns", desc = "Your sky lanterns can glow bright gold. A patron's gift.", keep = true, lanternColor = { 255, 215, 80 }, order = 33 },
	trail_petals = { name = "Trail of Petals", desc = "Flower petals drift down behind you as you walk.", keep = true, use = "wear", slot = "trail", order = 34 },
	trail_light = { name = "Path of Light", desc = "A soft ribbon of light follows your footsteps.", keep = true, use = "wear", slot = "trail", order = 35 },
	trail_gold = { name = "Golden Path", desc = "A wide ribbon of gold follows your footsteps. A patron's gift.", keep = true, use = "wear", slot = "trail", order = 36 },
	firefly = { name = "Firefly Companion", desc = "A firefly keeps you company and lights your way a little.", keep = true, use = "wear", slot = "companion", order = 37 },
	butterfly = { name = "Butterfly Companion", desc = "A butterfly rides at your shoulder.", keep = true, use = "wear", slot = "companion", order = 38 },
}

Config.Shops = {
	village = {
		name = "The Merit Store",
		keeper = "Upali the Shopkeeper",
		stock = {
			{ item = "rice", price = 8 },
			{ item = "tea", price = 15 },
			{ item = "incense", price = 15 },
			{ item = "lamp", price = 20 },
			{ item = "singing_bowl", price = 120, once = true },
			{ item = "whisk", price = 140, once = true },
			{ item = "conch", price = 180, once = true },
			{ item = "lantern", price = 200, once = true },
			{ item = "prayer_flags", price = 150, once = true },
			{ item = "wheel_charm", price = 200, once = true },
		},
	},
	senani = {
		name = "Senani Trading Post",
		keeper = "Bhallika the Trader",
		stock = {
			{ item = "rice", price = 8 },
			{ item = "tea", price = 15 },
			{ item = "incense", price = 15 },
			{ item = "lamp", price = 20 },
			{ item = "singing_bowl", price = 120, once = true },
			{ item = "long_mala", price = 250, once = true },
			{ item = "vajra", price = 300, once = true },
			{ item = "bell", price = 220, once = true },
			{ item = "phurba", price = 260, once = true },
			{ item = "spade", price = 320, once = true },
		},
	},
	garden = {
		name = "The Garden Stall",
		keeper = "Sumana the Garland-Maker",
		robux = true, -- the Robux items (Config.Robux) are listed at the bottom of this shop
		stock = {
			{ item = "tea", price = 15 },
			{ item = "lantern_lotus", price = 60, once = true },
			{ item = "lantern_jade", price = 60, once = true },
			{ item = "lantern_sky", price = 60, once = true },
			{ item = "trail_petals", price = 180, once = true },
			{ item = "firefly", price = 200, once = true },
			{ item = "trail_light", price = 240, once = true },
			{ item = "butterfly", price = 260, once = true },
		},
	},
}

----------------------------------------------------------------------
-- Things sold for Robux. They change only how things look, or are a gift to
-- everyone in the game. Nothing here makes the journey easier.
--
-- HOW TO SWITCH ONE ON
--   1. On create.roblox.com open the game, then Monetization.
--   2. Make a Pass (for "passes") or a Developer Product (for "products"), set its price.
--   3. Copy its ID number and put it below in place of the 0.
-- While the number is 0 the item shows as "Coming soon" and cannot be bought.
----------------------------------------------------------------------
Config.Robux = {
	passes = {
		{ id = "patron", passId = 0, name = "Patron of the Temple", desc = "A thank-you for supporting the game: the white-and-gold Robe of the Patron, the Golden Path trail, and Golden Lanterns.", robe = "patron", items = { "trail_gold", "lantern_gold" } },
	},
	products = {
		{ id = "flowers", productId = 0, name = "Offering of Flowers", desc = "Petals fall around every player in the game, with your name. It gives you nothing but the joy of giving. Can be offered again and again." },
	},
}

----------------------------------------------------------------------
-- Robes. Colours are {r, g, b}. "bare" leaves the right shoulder uncovered,
-- as in the Theravada way of wearing the robe.
----------------------------------------------------------------------
Config.Robes = {
	{ id = "own", name = "My Own Clothes", desc = "Wear your usual avatar.", price = 0, free = true },
	{ id = "novice", name = "Novice Whites", desc = "The plain white of one who has just arrived at the temple.", price = 0, free = true, main = { 236, 232, 222 }, sash = { 205, 200, 188 }, bare = false },
	{ id = "renunciant", name = "Rag-Robe of the Wanderer", desc = "Stitched from cast-off cloth and dyed with earth. Given at the River Anoma.", quest = true, main = { 163, 116, 62 }, sash = { 128, 88, 44 }, bare = true },
	{ id = "saffron", name = "Saffron Robe", desc = "The bright robe of the Theravada tradition of Sri Lanka and Southeast Asia.", price = 150, main = { 232, 136, 24 }, sash = { 205, 110, 14 }, bare = true },
	{ id = "forest", name = "Forest Ochre", desc = "The dark ochre of the forest monks, dyed with jackfruit wood.", price = 220, main = { 150, 92, 38 }, sash = { 118, 70, 28 }, bare = true },
	{ id = "maroon", name = "Maroon and Gold", desc = "The maroon robe and yellow shirt of the Tibetan tradition.", price = 280, main = { 122, 28, 40 }, sash = { 226, 170, 36 }, bare = false },
	{ id = "grey", name = "Grey Robe", desc = "The grey of the Chan and Seon monasteries of China and Korea.", price = 280, main = { 128, 130, 134 }, sash = { 92, 62, 44 }, bare = false },
	{ id = "black", name = "Black Robe", desc = "The black koromo of the Zen tradition of Japan.", price = 340, main = { 34, 34, 38 }, sash = { 110, 84, 50 }, bare = false },
	{ id = "pilgrim", name = "Pilgrim's Robe", desc = "For one who has found all twenty Bodhi leaves.", reward = true, main = { 70, 122, 78 }, sash = { 214, 178, 80 }, bare = true },
	{ id = "golden", name = "Robe of Awakening", desc = "For one who has sat beneath the Bodhi tree through the three watches of the night.", reward = true, main = { 244, 196, 70 }, sash = { 255, 232, 150 }, bare = true, glow = true },
	{ id = "patron", name = "Robe of the Patron", desc = "White edged with gold: the dress of the lay supporters who have kept the temples standing for two and a half thousand years. Comes with Patron of the Temple.", pass = "patron", main = { 248, 244, 232 }, sash = { 226, 178, 54 }, bare = false },
}

----------------------------------------------------------------------
-- Mara's ten armies (from the Padhana Sutta, Sutta Nipata 3.2), his three
-- daughters, and how each behaves. "special" is a behaviour handled by the server.
----------------------------------------------------------------------
Config.Enemies = {
	desire = { name = "Sensual Desire", pali = "Kama", army = 1, hp = 90, dmg = 9, speed = 13, range = 6, scale = 1.0, color = { 214, 80, 150 }, glow = { 255, 120, 200 }, merit = 7, special = "pull" },
	discontent = { name = "Discontent", pali = "Arati", army = 2, hp = 40, dmg = 6, speed = 15, range = 5, scale = 0.9, color = { 96, 104, 122 }, glow = { 150, 170, 210 }, merit = 4 },
	hunger = { name = "Hunger and Thirst", pali = "Khuppipasa", army = 3, hp = 70, dmg = 7, speed = 12, range = 5, scale = 0.95, color = { 150, 132, 96 }, glow = { 230, 200, 120 }, merit = 6, special = "drain" },
	craving = { name = "Craving", pali = "Tanha", army = 4, hp = 80, dmg = 9, speed = 18, range = 5, scale = 1.0, color = { 40, 110, 104 }, glow = { 60, 230, 200 }, merit = 7 },
	sloth = { name = "Sloth and Torpor", pali = "Thina-middha", army = 5, hp = 150, dmg = 10, speed = 8, range = 7, scale = 1.5, color = { 70, 82, 60 }, glow = { 140, 170, 110 }, merit = 9, special = "slow" },
	fear = { name = "Fear", pali = "Bhiru", army = 6, hp = 60, dmg = 18, speed = 20, range = 5, scale = 1.05, color = { 24, 22, 34 }, glow = { 230, 240, 255 }, merit = 8 },
	doubt = { name = "Doubt", pali = "Vicikiccha", army = 7, hp = 55, dmg = 8, speed = 13, range = 5, scale = 1.0, color = { 76, 60, 110 }, glow = { 170, 130, 255 }, merit = 6, special = "blink" },
	hypocrisy = { name = "Hypocrisy and Stubbornness", pali = "Makkha-thambha", army = 8, hp = 230, dmg = 12, speed = 10, range = 7, scale = 1.35, color = { 92, 92, 100 }, glow = { 200, 200, 215 }, merit = 12 },
	fame = { name = "Gain, Honour and Fame", pali = "Labha-siloka-sakkara", army = 9, hp = 110, dmg = 10, speed = 14, range = 6, scale = 1.1, color = { 178, 140, 40 }, glow = { 255, 220, 90 }, merit = 20, special = "steal" },
	pride = { name = "Self-Praise and Scorn", pali = "Attukkamsana", army = 10, hp = 270, dmg = 16, speed = 12, range = 8, scale = 1.75, color = { 120, 24, 30 }, glow = { 255, 80, 60 }, merit = 16 },

	tanha = { name = "Tanha, Daughter of Mara", pali = "Craving", daughter = true, hp = 650, dmg = 13, speed = 15, range = 7, scale = 1.25, color = { 60, 170, 160 }, glow = { 120, 255, 235 }, merit = 60, special = "pull" },
	arati = { name = "Arati, Daughter of Mara", pali = "Aversion", daughter = true, hp = 650, dmg = 15, speed = 16, range = 7, scale = 1.25, color = { 120, 130, 190 }, glow = { 170, 190, 255 }, merit = 60, special = "blink" },
	raga = { name = "Raga, Daughter of Mara", pali = "Passion", daughter = true, hp = 750, dmg = 14, speed = 15, range = 7, scale = 1.25, color = { 220, 70, 110 }, glow = { 255, 140, 170 }, merit = 60, special = "drain" },
}

-- Where the armies appear. "group" lets a quest count any soldier of Mara's host.
Config.Spawns = {
	-- Forest: discontent, then doubt
	{ id = "f1", type = "discontent", x = 900, z = -40, count = 3, radius = 22 },
	{ id = "f2", type = "discontent", x = 965, z = 26, count = 3, radius = 22 },
	{ id = "f3", type = "discontent", x = 1020, z = -52, count = 3, radius = 22 },
	{ id = "f4", type = "doubt", x = 1092, z = 30, count = 3, radius = 22 },
	{ id = "f5", type = "doubt", x = 1152, z = -8, count = 3, radius = 22 },
	{ id = "f6", type = "doubt", x = 1186, z = 56, count = 2, radius = 18 },
	-- Uruvela: hunger and thirst, sloth and torpor
	{ id = "u1", type = "hunger", x = 1300, z = 44, count = 3, radius = 22 },
	{ id = "u2", type = "hunger", x = 1384, z = -18, count = 3, radius = 22 },
	{ id = "u3", type = "hunger", x = 1474, z = 34, count = 2, radius = 20 },
	{ id = "u4", type = "sloth", x = 1444, z = -64, count = 2, radius = 20 },
	{ id = "u5", type = "sloth", x = 1524, z = 16, count = 2, radius = 20 },
	-- East bank of the Neranjara: craving
	{ id = "s1", type = "craving", x = 1966, z = 78, count = 3, radius = 20 },
	{ id = "s2", type = "craving", x = 2014, z = 24, count = 3, radius = 18 },
	-- Mara's Field: the rest of the host
	{ id = "m1", type = "desire", x = 2108, z = -44, count = 3, radius = 22, group = "host" },
	{ id = "m2", type = "fear", x = 2172, z = 8, count = 3, radius = 22, group = "host" },
	{ id = "m3", type = "hypocrisy", x = 2250, z = 44, count = 2, radius = 20, group = "host" },
	{ id = "m4", type = "fame", x = 2282, z = -30, count = 3, radius = 22, group = "host" },
	{ id = "m5", type = "pride", x = 2342, z = -62, count = 2, radius = 20, group = "host" },
	{ id = "m6", type = "fear", x = 2350, z = 26, count = 2, radius = 20, group = "host" },
	{ id = "m7", type = "doubt", x = 2196, z = -86, count = 2, radius = 18, group = "host" },
	-- The three daughters, each in her pavilion
	{ id = "d1", type = "tanha", x = 2132, z = 74, count = 1, radius = 6, respawn = 45 },
	{ id = "d2", type = "arati", x = 2216, z = -74, count = 1, radius = 6, respawn = 45 },
	{ id = "d3", type = "raga", x = 2302, z = 66, count = 1, radius = 6, respawn = 45 },
}

-- Mara himself (the fight at the arena).
Config.Boss = {
	hp = 1600,
	hpPerExtraPlayer = 800,
	hostToDispel = 10,
	stormSeconds = 5,
	resetAfter = 45,
}

-- The nine storms Mara sent (Jataka Nidanakatha). Each turned to flowers or
-- sandalwood powder before it could touch the one seated beneath the tree.
Config.Storms = {
	{ name = "a whirlwind", color = { 200, 210, 220 } },
	{ name = "a great rain", color = { 90, 140, 220 } },
	{ name = "a shower of rocks", color = { 120, 110, 100 } },
	{ name = "a shower of weapons", color = { 190, 190, 205 } },
	{ name = "a shower of burning coals", color = { 255, 110, 40 } },
	{ name = "a shower of hot ashes", color = { 170, 150, 140 } },
	{ name = "a shower of sand", color = { 220, 190, 120 } },
	{ name = "a shower of mud", color = { 100, 76, 52 } },
	{ name = "a great darkness", color = { 30, 20, 50 } },
}

----------------------------------------------------------------------
-- Things to find
----------------------------------------------------------------------
Config.Leaves = {
	{ x = -112, z = 100 }, { x = 70, z = -112 }, { x = -84, z = -11, y = 4.2 }, { x = 244, z = 112 },
	{ x = 362, z = -112 }, { x = 462, z = 122 }, { x = 584, z = 96 }, { x = 690, z = 122 },
	{ x = 806, z = -120 }, { x = 902, z = 122 }, { x = 1046, z = -124 }, { x = 1162, z = 112 },
	{ x = 1292, z = 122 }, { x = 1426, z = 102 }, { x = 1542, z = -120 }, { x = 1692, z = 122 },
	{ x = 1880, z = -122 }, { x = 2008, z = -112 }, { x = 2204, z = 122 }, { x = 2702, z = 112 },
}

Config.Kusa = {
	{ x = 1932, z = 60 }, { x = 1958, z = 104 }, { x = 1990, z = 62 }, { x = 2022, z = 96 },
	{ x = 1936, z = -70 }, { x = 1972, z = -52 }, { x = 2018, z = -44 }, { x = 2026, z = -118 },
}

Config.Lotus = {
	{ x = 46, z = -98 }, { x = 60, z = -86 }, { x = 54, z = -104 },
	{ x = 1994, z = -102 }, { x = 2006, z = -90 }, { x = 2008, z = -104 },
	{ x = 2656, z = 72 }, { x = 2666, z = 64 }, { x = 2658, z = -70 }, { x = 2668, z = -78 },
}

-- The Eight Auspicious Symbols (Ashtamangala), one hidden in each land.
-- Finding all eight earns the Sword of Wisdom.
Config.Symbols = {
	{ id = "vase", name = "The Treasure Vase", x = -170, z = -60, text = "The treasure vase is never emptied, however much is taken from it. It stands for the teaching, which is not used up by being shared." },
	{ id = "parasol", name = "The Parasol", x = 330, z = 120, text = "The parasol gives shade from the burning sun. It stands for shelter from suffering, offered to every being." },
	{ id = "fishes", name = "The Golden Fishes", x = 756, z = -112, text = "Two golden fishes swim wherever they wish and do not fear the water. They stand for moving freely and without fear through the ocean of this world." },
	{ id = "knot", name = "The Endless Knot", x = 1000, z = 120, text = "The endless knot has no beginning and no end. It stands for the way all things depend on one another, and for wisdom and compassion woven together." },
	{ id = "conch", name = "The White Conch", x = 1370, z = -122, text = "The white conch is blown like a horn and heard far away. It stands for the sound of the teaching, which wakes those who hear it." },
	{ id = "lotus", name = "The Lotus", x = 1780, z = -118, text = "The lotus roots in mud and opens clean above the water. It stands for a mind that grows pure in the middle of a troubled world." },
	{ id = "banner", name = "The Victory Banner", x = 2300, z = -120, text = "The victory banner is raised when a battle is won. It stands for victory over Mara: over craving, fear, pride and death." },
	{ id = "wheel", name = "The Dharma Wheel", x = 2790, z = 70, text = "The wheel has eight spokes for the Noble Eightfold Path. When the Buddha first taught, it is said he set the wheel turning." },
}

-- Animals of the Jataka tales, the stories of the Buddha's earlier lives.
-- Share a little alms rice with each one to hear its story.
Config.Animals = {
	{ id = "hare", kind = "hare", name = "The Hare", x = 410, z = 62, yaw = 40, source = "Sasa Jataka, no. 316", text = "Long ago the Buddha-to-be was born as a hare. A hungry traveller came by, and the hare had no food to give, so he offered himself and leapt into the traveller's fire. The fire did not burn him. The traveller was the god Sakka, who drew the hare's shape on the moon so that his gift would be remembered." },
	{ id = "deer", kind = "deer", name = "The Banyan Deer", x = 520, z = -90, yaw = 200, source = "Nigrodhamiga Jataka, no. 12", text = "Long ago the Buddha-to-be was born as a golden deer, king of his herd. When a mother deer was to be sent to the king's kitchen, he lay down on the block in her place. The king was so moved that he spared the deer, and then every creature in his land." },
	{ id = "monkey", kind = "monkey", name = "The Monkey King", x = 770, z = 100, yaw = 250, source = "Mahakapi Jataka, no. 407", text = "Long ago the Buddha-to-be was born as a king of monkeys. When archers surrounded his troop, he stretched his own body across the river as a bridge, and every monkey crossed to safety over his back. The human king who saw it learned what a ruler is for." },
	{ id = "quail", kind = "quail", name = "The Young Quail", x = 1280, z = -100, yaw = 120, source = "Vattaka Jataka, no. 35", text = "Long ago the Buddha-to-be was born as a baby quail, too young to fly. A forest fire came and his parents fled. He had nothing left but the truth, so he spoke it: 'I have wings that cannot fly and feet that cannot walk.' At his true words the fire turned back." },
	{ id = "elephant", kind = "elephant", name = "The Six-Tusked Elephant", x = 1806, z = 112, yaw = 160, source = "Chaddanta Jataka, no. 514", text = "Long ago the Buddha-to-be was born as Chaddanta, a great white elephant king. A hunter wounded him for his tusks. Chaddanta felt no anger. He forgave the hunter and gave the tusks himself." },
	{ id = "goose", kind = "goose", name = "The Golden Goose", x = 1830, z = -80, yaw = 300, source = "Suvannahamsa Jataka, no. 136", text = "Long ago the Buddha-to-be was born as a goose with feathers of gold. He gave his poor family one feather at a time, and they lived well. Then greed made them pluck him bare, and every stolen feather turned plain and white." },
}

return Config
