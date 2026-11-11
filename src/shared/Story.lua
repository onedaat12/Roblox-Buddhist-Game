-- The Bodhi Path: the story.
-- People to meet, the steps of the journey, and the teachings written on the Bodhi leaves.
--
-- The journey follows the traditional account of how Siddhartha Gautama became the Buddha
-- (mainly the Pali Canon and the Jataka Nidanakatha): the Four Sights, the Great Departure
-- across the River Anoma, the two teachers, six years of austerity at Uruvela, Sujata's
-- offering, the golden bowl on the Neranjara, Sotthiya's kusa grass, Mara's assault, the
-- earth as witness, and the three watches of the night beneath the Bodhi tree.
--
-- Where the old sources differ, a note says so (see docs/STORY_NOTES.md).

local Story = {}

----------------------------------------------------------------------
-- People. "look" picks an outfit in the server's Rig module.
-- "lines" are what they say when they have nothing special to tell you.
----------------------------------------------------------------------
Story.NPCs = {
	-- Kapilavastu: the home temple and the village
	{ id = "abbot", name = "The Venerable Abbot", look = "abbot", x = -40, z = 6, face = { x = 0, z = 0 },
		lines = {
			"Walk gently, seeker. The path is long, but every step of it is already the path.",
			"When the mind is troubled, sit. When it is calm, sit. Either way, sit.",
		} },
	{ id = "bell_monk", name = "Brother Tissa", look = "monk", x = 20, z = -44, face = { x = 0, z = 0 },
		lines = {
			"A temple bell is rung one hundred and eight times at the turning of the year, once for each trouble of the heart.",
			"Listen to the bell until the sound is gone. Then listen to what is left.",
		} },
	{ id = "pond_nun", name = "Sister Khema", look = "nun", x = 40, z = -74, face = { x = 52, z = -92 },
		lines = {
			"The lotus grows in mud and opens above the water without a stain. That is why we love it.",
			"If you find a lotus, offer it at a shrine. Giving is the first step of the path.",
		} },
	{ id = "wheel_novice", name = "Novice Sona", look = "novice", x = 30, z = 36, face = { x = 40, z = 44 },
		lines = {
			"Spin the prayer wheels clockwise! Each turn sends good wishes out to everyone.",
			"I am saving my merit for a saffron robe. Sister Visakha sews them in the village.",
		} },
	{ id = "merchant", name = "Upali the Shopkeeper", look = "merchant", x = 160, z = 66, face = { x = 160, z = 40 }, shop = "village",
		lines = { "Tea, incense, lamps for the shrine. Take what helps you on the road." } },
	{ id = "tailor", name = "Visakha the Robe-Maker", look = "villager_f", x = 204, z = -66, face = { x = 204, z = -40 }, robes = true,
		lines = { "A robe is only cloth, friend. But it reminds the one who wears it what they have set out to do." } },
	{ id = "garland", name = "Sumana the Garland-Maker", look = "villager_m", x = 4, z = -109, face = { x = 4, z = -90 }, shop = "garden",
		lines = { "Flowers fade by evening. That is why they are worth offering." } },
	{ id = "alms1", name = "Farmer Gopal", look = "farmer", x = 150, z = -13, face = { x = 150, z = 0 }, alms = true,
		lines = { "The rains were kind this year. There is enough rice to share." } },
	{ id = "alms2", name = "Grandmother Amba", look = "elder_f", x = 180, z = 13, face = { x = 180, z = 0 }, alms = true,
		lines = { "I have fed monks at this door for fifty years. It has never once made me poorer." } },
	{ id = "alms3", name = "Dasa the Potter", look = "villager_m", x = 214, z = -13, face = { x = 214, z = 0 }, alms = true,
		lines = { "I made the bowls the monks carry. Clay, water, fire, and patience." } },
	{ id = "alms4", name = "Little Mira", look = "child", x = 234, z = 14, face = { x = 234, z = 0 }, alms = true,
		lines = { "Mother says giving makes your heart bigger. I want a very big heart." } },

	-- The Road of the Four Sights
	{ id = "old_man", name = "An Old Man", look = "elder_m", x = 332, z = 20, face = { x = 332, z = 0 },
		lines = { "I was young once, and strong. I did not believe this day would come to me. It comes to everyone." } },
	{ id = "sick_man", name = "A Sick Man", look = "sick", x = 412, z = -24, face = { x = 412, z = 0 },
		lines = { "The fever comes and goes. Be glad of your health while you have it, traveller." } },
	{ id = "mourner", name = "A Mourner", look = "mourner", x = 497, z = 28, face = { x = 505, z = 40 },
		lines = { "He was my father. Yesterday he laughed with us. All who are born must also pass away." } },
	{ id = "ascetic", name = "A Wandering Ascetic", look = "ascetic", x = 577, z = -20, face = { x = 577, z = 0 },
		lines = { "I own a bowl and a robe, and I sleep beneath the trees. I have never been so free." } },

	-- The River Anoma
	{ id = "fisherman", name = "A River Fisherman", look = "farmer", x = 690, z = 44, face = { x = 725, z = 44 },
		lines = { "The Anoma is shallow at the stones. They say a prince once crossed here in a single leap of his horse." } },
	{ id = "channa", name = "Channa the Charioteer", look = "channa", x = 784, z = 14, face = { x = 760, z = 0 },
		lines = { "I carried the news back to the palace once. I will carry it again if I must." } },

	-- The Forest of the Teachers
	{ id = "alara", name = "Alara Kalama", look = "sage", x = 940, z = 78, face = { x = 940, z = 40 },
		lines = { "Let go of form. Let go of space. Let go even of the one who lets go." } },
	{ id = "alara_student", name = "A Student of Alara", look = "ascetic", x = 928, z = 70, face = { x = 940, z = 78 },
		lines = { "The teacher once sat by the road while five hundred carts rolled past. He neither saw nor heard them." } },
	{ id = "uddaka", name = "Uddaka Ramaputta", look = "sage2", x = 1110, z = -78, face = { x = 1110, z = -40 },
		lines = { "Beyond nothingness there is a place so fine that one cannot say perception is there, or that it is not." } },

	-- Uruvela
	{ id = "kondanna", name = "Kondanna", look = "ascetic", x = 1322, z = -44, face = { x = 1322, z = 0 },
		lines = { "We eat little and sleep less. If the body is the chain, we will wear the chain away." } },
	{ id = "bhaddiya", name = "Bhaddiya", look = "ascetic", x = 1310, z = -56, face = { x = 1322, z = -52 },
		lines = { "Six years we have practised here beside the Neranjara." } },
	{ id = "vappa", name = "Vappa", look = "ascetic", x = 1332, z = -58, face = { x = 1322, z = -52 },
		lines = { "A single grain of rice a day. A single sesame seed. So we train." } },
	{ id = "mahanama", name = "Mahanama", look = "ascetic", x = 1318, z = -66, face = { x = 1322, z = -52 },
		lines = { "Do not disturb the fire. It is the only warmth we allow ourselves." } },
	{ id = "assaji", name = "Assaji", look = "ascetic", x = 1336, z = -46, face = { x = 1322, z = -52 },
		lines = { "Walk calmly and the mind follows. That much I have learned." } },

	-- Senani and the Neranjara
	{ id = "sujata", name = "Sujata", look = "sujata", x = 1700, z = 40, face = { x = 1700, z = 0 },
		lines = { "May your wishes be fulfilled, as mine have been." } },
	{ id = "punna", name = "Punna", look = "villager_f", x = 1710, z = 46, face = { x = 1700, z = 40 },
		lines = { "I came at dawn to sweep beneath the banyan, and there he sat, shining. I ran to tell my mistress." } },
	{ id = "trader", name = "Bhallika the Trader", look = "merchant", x = 1644, z = -64, face = { x = 1644, z = -40 }, shop = "senani",
		lines = { "My caravan stops here for the season. See what the road has brought." } },
	{ id = "herdsman", name = "A Herdsman", look = "farmer", x = 1752, z = 80, face = { x = 1740, z = 60 },
		lines = { "Sujata's cattle give the richest milk in Senani. She fed the milk of a thousand cows to five hundred, and theirs to fewer still, until it was sweet as honey." } },
	{ id = "sotthiya", name = "Sotthiya the Grass-Cutter", look = "farmer", x = 1946, z = 24, face = { x = 1920, z = 0 },
		lines = { "Kusa grass. Soft to sit on, and sharp enough to cut a careless hand. Hold it wisely." } },
	{ id = "pond_elder", name = "An Old Villager", look = "elder_m", x = 1986, z = -84, face = { x = 2000, z = -96 },
		lines = {
			"This is Mucalinda's pool. They say that in the weeks after the awakening a great storm came, and the naga king rose from the water, coiled seven times around the Buddha, and spread his hood above him for seven days.",
		} },
}

-- A few people who simply walk about, so the villages feel lived in.
Story.Wanderers = {
	{ name = "Villager", look = "villager_m", x = 170, z = -4, radius = 34 },
	{ name = "Villager", look = "villager_f", x = 205, z = 6, radius = 34 },
	{ name = "Monk", look = "monk", x = -10, z = 20, radius = 40 },
	{ name = "Monk", look = "monk", x = 30, z = -20, radius = 40 },
	{ name = "Novice", look = "novice", x = 0, z = 50, radius = 30 },
	{ name = "Farmer", look = "farmer", x = 310, z = 60, radius = 26 },
	{ name = "Pilgrim", look = "villager_m", x = 540, z = 6, radius = 30 },
	{ name = "Villager", look = "villager_f", x = 1670, z = 8, radius = 36 },
	{ name = "Villager", look = "villager_m", x = 1740, z = -10, radius = 36 },
	{ name = "Child", look = "child", x = 1690, z = -20, radius = 30 },
}

----------------------------------------------------------------------
-- The journey, step by step.
-- Objective kinds:
--   talk      speak with a person (target = NPC id)
--   interact  use something in the world (target = interaction id)
--   alms      receive alms from villagers
--   meditate  meditate at a place for "count" seconds (target = spot id)
--   reach     arrive somewhere (target = area id)
--   dispel    overcome enemies (target = enemy type, or a group such as "host")
--   collect   gather things (target = kind)
--   use       use an item (target = item id)
--   boss      answer Mara
----------------------------------------------------------------------
Story.Quests = {
	{
		id = "arrive", title = "Arrival",
		intro = "You have come to the temple at Kapilavastu to walk the road the Buddha walked.",
		objectives = {
			{ kind = "talk", target = "abbot", text = "Speak with the Venerable Abbot", lines = {
				{ "The Venerable Abbot", "Welcome, seeker. Long ago a prince named Siddhartha left this city in search of an end to suffering. He found it beneath a tree at Bodh Gaya." },
				{ "The Venerable Abbot", "Every seeker walks that same road: past age, sickness and death, across the rivers, through Mara's armies, to the foot of the Bodhi tree." },
				{ "The Venerable Abbot", "Begin as we all begin. Ring the temple bell, and let the whole valley know that someone has set out." },
			} },
		},
		reward = { merit = 10 },
	},
	{
		id = "bell", title = "The Temple Bell",
		intro = "The great bell hangs in the courtyard, south of where you arrived.",
		objectives = {
			{ kind = "interact", target = "temple_bell", text = "Ring the temple bell" },
		},
		reward = { merit = 15 },
		outro = {
			{ "", "The bell sounds across the valley. Somewhere far to the east, something old and watchful turns its head." },
		},
	},
	{
		id = "breath", title = "The First Breath",
		intro = "North of the courtyard is the meditation hall. Sit there and follow your breath. (Press M, or the Meditate button.)",
		objectives = {
			{ kind = "meditate", target = "village_hall", count = 10, text = "Meditate in the meditation hall" },
		},
		reward = { merit = 15 },
		outro = {
			{ "", "Breathing in, you know you are breathing in. Breathing out, you know you are breathing out. Whenever your Calm runs low, you can always return to this." },
		},
	},
	{
		id = "alms", title = "The Alms Round",
		intro = "A monk does not buy food or grow it. Each morning the village shares what it has. Cross the stream to the village. Four villagers wait by their doors beside the road: follow the golden marker to each one, walk up close, and choose \"Hold out your bowl\" (press E, or tap the button that appears). They will put food in it.",
		objectives = {
			{ kind = "alms", target = "alms", count = 4, text = "Receive alms from four villagers" },
		},
		grant = { items = { alms_bowl = 1 } },
		reward = { merit = 30 },
	},
	{
		id = "store", title = "The Merit Store",
		intro = "Kind acts earn merit. Upali keeps a store in the village where merit can be exchanged for what a traveller needs.",
		objectives = {
			{ kind = "talk", target = "merchant", text = "Visit Upali at the Merit Store", lines = {
				{ "Upali the Shopkeeper", "Ah, the new seeker. You will want tea for the road and a lamp for the shrines. Pay in merit; I have no use for coins." },
				{ "Upali the Shopkeeper", "And if robes are what you are after, Visakha sews them across the road. Every tradition, every colour." },
			} },
		},
		reward = { merit = 25 },
	},
	{
		id = "sights", title = "The Four Sights",
		intro = "Prince Siddhartha rode out from the palace four times. What he saw on the road changed him. Go east through the gate and see what he saw.",
		objectives = {
			{ kind = "talk", target = "old_man", text = "Meet the old man", lines = {
				{ "An Old Man", "Do not stare, young one. This bent back was straight once. These hands could draw a bow." },
				{ "", "The first sight: old age. The prince asked his charioteer, 'Will this happen to me also?' Channa answered, 'To you, and to everyone.'" },
			} },
			{ kind = "talk", target = "sick_man", text = "Meet the sick man", lines = {
				{ "A Sick Man", "Water... thank you. Three days the fever has held me. No one is so strong that sickness cannot find them." },
				{ "", "The second sight: sickness. Health, like youth, is only lent to us." },
			} },
			{ kind = "talk", target = "mourner", text = "Come upon the funeral", lines = {
				{ "A Mourner", "We carry my father to the river. Walk with us a little way, if you will." },
				{ "", "The third sight: death. The prince went home in silence and could find no joy in the palace." },
			} },
			{ kind = "talk", target = "ascetic", text = "Meet the wandering ascetic", lines = {
				{ "A Wandering Ascetic", "You look troubled. I was too. Then I gave up my house and went looking for what does not grow old, fall sick, or die." },
				{ "", "The fourth sight: a wanderer, calm in the midst of it all. Seeing him, the prince knew what he had to do." },
			} },
		},
		reward = { merit = 50 },
		outro = {
			{ "", "That night, at the age of twenty-nine, Siddhartha looked once at his sleeping wife and newborn son, and rode out through the city gate on his horse Kanthaka, with Channa beside him." },
		},
	},
	{
		id = "cross", title = "The Great Departure",
		intro = "They rode through the night to the River Anoma. Cross it, as he did.",
		objectives = {
			{ kind = "reach", target = "anoma_far", text = "Cross the River Anoma" },
		},
		reward = { merit = 20 },
	},
	{
		id = "channa", title = "Channa's Farewell",
		intro = "Channa the charioteer waits on the far bank with the horse Kanthaka.",
		objectives = {
			{ kind = "talk", target = "channa", text = "Speak with Channa", lines = {
				{ "Channa the Charioteer", "Here the prince dismounted and gave me his jewels to take home. I begged to stay with him. He would not allow it." },
				{ "Channa the Charioteer", "Kanthaka looked back until he could see his master no more. They say the good horse died of grief, and was reborn among the gods." },
				{ "Channa the Charioteer", "The road beyond is not safe. Take this staff. It is no weapon, but it will steady your step and turn aside what comes at you." },
			} },
		},
		reward = { merit = 20, ability = "staff" },
	},
	{
		id = "hair", title = "The Wanderer's Robe",
		intro = "By the flat rock on the bank the prince drew his sword, cut off his long hair, and put on the robe of a wanderer.",
		objectives = {
			{ kind = "interact", target = "hair_rock", text = "Leave your old life at the rock" },
		},
		reward = { merit = 30, robe = "renunciant" },
		outro = {
			{ "", "He cast his hair into the air and exchanged his silks for a simple robe. From this moment he owned nothing." },
			{ "", "You have received the Rag-Robe of the Wanderer. (Open Robes to wear it.)" },
		},
	},
	{
		id = "scouts", title = "Shadows on the Road",
		intro = "Mara, lord of all that binds the heart, has noticed you. His scouts are in the forest: the grey shapes of Discontent.",
		objectives = {
			{ kind = "dispel", target = "discontent", count = 6, text = "Dispel the shadows of Discontent" },
		},
		reward = { merit = 40 },
		outro = {
			{ "", "Nothing is destroyed. When a shadow is met with a steady mind it falls apart into petals, as Mara's weapons turned to flowers before they could touch the Buddha." },
		},
	},
	{
		id = "alara", title = "The First Teacher",
		intro = "Siddhartha sought out the greatest meditation teachers of his day. The first was Alara Kalama, whose hermitage lies north of the forest road.",
		objectives = {
			{ kind = "talk", target = "alara", text = "Speak with Alara Kalama", lines = {
				{ "Alara Kalama", "I teach the attainment of the sphere of nothingness. Sit with us, and see how far the mind can go." },
				{ "Alara Kalama", "Take this mala. Let each bead be one breath, and send your steadiness where it is needed." },
			} },
			{ kind = "meditate", target = "alara", count = 14, text = "Meditate at Alara's hermitage" },
		},
		reward = { merit = 40, ability = "beads" },
		outro = {
			{ "", "Siddhartha quickly mastered all that Alara knew, and Alara offered to share the leadership of his community. But the sphere of nothingness was not the end of suffering. He thanked his teacher and walked on." },
		},
	},
	{
		id = "uddaka", title = "The Second Teacher",
		intro = "Deeper in the forest, south of the road, Uddaka Ramaputta teaches a still subtler attainment.",
		objectives = {
			{ kind = "talk", target = "uddaka", text = "Speak with Uddaka Ramaputta", lines = {
				{ "Uddaka Ramaputta", "My father Rama reached the sphere of neither-perception-nor-non-perception. Few can follow. Sit, and we shall see." },
			} },
			{ kind = "meditate", target = "uddaka", count = 14, text = "Meditate at Uddaka's hermitage" },
		},
		reward = { merit = 40, maxCalm = 20 },
		outro = {
			{ "", "This too he mastered, and this too he found was not the goal: when the meditation ended, the troubles of the heart returned. Uddaka offered him the whole community. He declined, and walked on alone." },
		},
	},
	{
		id = "doubt", title = "The Seventh Army",
		intro = "Having left both teachers, a seeker meets Doubt. It never stays where you look for it.",
		objectives = {
			{ kind = "dispel", target = "doubt", count = 5, text = "Dispel the shadows of Doubt" },
		},
		reward = { merit = 45 },
	},
	{
		id = "ascetics", title = "The Five Companions",
		intro = "At Uruvela, by the Neranjara river, five ascetics practise the hardest disciplines known. Their camp is south of the road.",
		objectives = {
			{ kind = "talk", target = "kondanna", text = "Speak with Kondanna", lines = {
				{ "Kondanna", "I was one of the eight brahmins who read the signs at the prince's birth. I alone said he would surely become a Buddha. So I came here to wait for him." },
				{ "Kondanna", "We believe the body must be worn down until the spirit is free. Stay. Fast with us. Face what comes." },
			} },
		},
		reward = { merit = 30 },
	},
	{
		id = "austerity", title = "Six Years of Austerity",
		intro = "For six years Siddhartha starved himself until he could feel his spine through his belly. Face what he faced, then sit in the cave to the north.",
		objectives = {
			{ kind = "dispel", target = "hunger", count = 6, text = "Endure Hunger and Thirst" },
			{ kind = "dispel", target = "sloth", count = 3, text = "Overcome Sloth and Torpor" },
			{ kind = "meditate", target = "cave", count = 16, text = "Meditate in the cave" },
		},
		reward = { merit = 70 },
		outro = {
			{ "", "At the edge of death he remembered a day in childhood: sitting in the shade of a rose-apple tree while his father ploughed, his mind had settled, easy and clear, all by itself." },
			{ "", "'Could that be the way?' he thought. 'But this wasted body cannot follow it. I will eat.' This was the discovery of the Middle Way, between indulgence and self-torment." },
		},
	},
	{
		id = "sujata", title = "Sujata's Offering",
		intro = "East of Uruvela is the village of Senani. A woman named Sujata is carrying an offering to the banyan tree.",
		objectives = {
			{ kind = "talk", target = "sujata", text = "Meet Sujata beneath the banyan", lines = {
				{ "Sujata", "I vowed to make an offering at this tree if I should bear a son, and I have. My maid said the spirit of the tree itself was sitting here, shining." },
				{ "Sujata", "But you are no spirit; you are thin as a reed. Please, take this: rice boiled in the richest milk, in a bowl of gold." },
				{ "Sujata", "May your wishes be fulfilled, as mine have been." },
			} },
		},
		reward = { merit = 30, items = { milk_rice = 1, golden_bowl = 1 } },
	},
	{
		id = "eat", title = "The Middle Way",
		intro = "Eat Sujata's milk-rice. (Open your Bag and use it.)",
		objectives = {
			{ kind = "use", target = "milk_rice", text = "Eat the milk-rice" },
		},
		reward = { merit = 30, maxCalm = 30, ability = "metta" },
		outro = {
			{ "", "Strength returns. The five ascetics, seeing him eat, said, 'Gotama has given up the struggle,' and left him in disgust." },
			{ "", "Moved by Sujata's kindness, you have learned Metta: loving-kindness, radiated in every direction." },
		},
	},
	{
		id = "bowl", title = "The Golden Bowl",
		intro = "He carried the empty bowl down to the Neranjara and made a vow. Go down the steps to the river.",
		objectives = {
			{ kind = "interact", target = "bowl_river", text = "Set the golden bowl upon the river" },
		},
		reward = { merit = 40 },
		outro = {
			{ "", "'If I am to awaken today, let this bowl go upstream.' He set it on the water. It glided against the current, swift as a horse, then sank to the palace of the naga king below." },
		},
	},
	{
		id = "sotthiya", title = "The Grass-Cutter",
		intro = "Cross the Neranjara. On the far bank the grass-cutter Sotthiya is at his work.",
		objectives = {
			{ kind = "talk", target = "sotthiya", text = "Speak with Sotthiya", lines = {
				{ "Sotthiya the Grass-Cutter", "Going to the great tree, are you? Then you will want something to sit on. The ground there is hard." },
				{ "Sotthiya the Grass-Cutter", "I gave the Bodhisatta eight handfuls of kusa. Gather eight for yourself; the best of it grows along this bank." },
			} },
		},
		reward = { merit = 25 },
	},
	{
		id = "kusa", title = "Eight Handfuls of Grass",
		intro = "Gather eight handfuls of kusa grass along the east bank of the Neranjara.",
		objectives = {
			{ kind = "collect", target = "kusa", count = 8, text = "Gather kusa grass" },
		},
		reward = { merit = 50 },
	},
	{
		id = "daughters", title = "The Daughters of Mara",
		intro = "The land darkens ahead. Mara sends his three daughters first: Tanha, Arati and Raga. Craving, Aversion and Passion.",
		objectives = {
			{ kind = "dispel", target = "tanha", count = 1, text = "Remain unmoved by Tanha" },
			{ kind = "dispel", target = "arati", count = 1, text = "Remain unmoved by Arati" },
			{ kind = "dispel", target = "raga", count = 1, text = "Remain unmoved by Raga" },
		},
		reward = { merit = 120 },
		outro = {
			{ "", "They tried every guise and were no more able to move him than a feather can cut stone. (In the Pali texts they come after the awakening; other tellings place them before it. Either way, they fail.)" },
		},
	},
	{
		id = "armies", title = "The Ten Armies",
		intro = "'Sensual desire is your first army; the second is discontent; the third is hunger and thirst; the fourth is craving...' Mara's host stands between you and the tree.",
		objectives = {
			{ kind = "dispel", target = "host", count = 15, text = "Break through Mara's host" },
		},
		reward = { merit = 120 },
	},
	{
		id = "mara", title = "Mara",
		intro = "Mara himself waits at the end of the field, mounted on the great elephant Girimekhala. Enter the ring of fires.",
		objectives = {
			{ kind = "boss", target = "mara", text = "Answer Mara" },
		},
		reward = { merit = 250 },
		outro = {
			{ "", "Mara cried, 'That seat is mine! My army is my witness. Who is yours?' The Bodhisatta reached down with his right hand and touched the earth." },
			{ "", "And the earth roared, 'I am his witness.' Girimekhala fell to his knees. The ten armies scattered to the ends of the world." },
		},
	},
	{
		id = "seat", title = "The Seat of Awakening",
		intro = "The way to the Bodhi tree is open. Spread your kusa grass on the stone seat on the eastern side of the tree.",
		objectives = {
			{ kind = "interact", target = "vajrasana", text = "Spread the kusa grass at the foot of the tree" },
		},
		reward = { merit = 60 },
		outro = {
			{ "", "He sat facing east and made his vow: 'Let only skin, sinew and bone remain; let the flesh and blood dry up in my body. I will not rise from this seat until I have awakened.'" },
		},
	},
	{
		id = "watch1", title = "The First Watch of the Night",
		intro = "Sit on the seat and meditate.",
		objectives = {
			{ kind = "meditate", target = "bodhi_seat", count = 20, text = "Meditate beneath the Bodhi tree" },
		},
		reward = { merit = 60 },
		outro = {
			{ "", "In the first watch of the night his mind turned to the past, and he remembered his former lives: one birth, two, a hundred, a hundred thousand, through the rising and falling of whole worlds." },
		},
	},
	{
		id = "watch2", title = "The Second Watch of the Night",
		intro = "Remain seated. Meditate on.",
		objectives = {
			{ kind = "meditate", target = "bodhi_seat", count = 20, text = "Meditate beneath the Bodhi tree" },
		},
		reward = { merit = 60 },
		outro = {
			{ "", "In the second watch he saw beings everywhere passing away and being reborn, high and low, happy and wretched, each according to their own actions." },
		},
	},
	{
		id = "watch3", title = "The Third Watch of the Night",
		intro = "The night is almost over. Meditate on.",
		objectives = {
			{ kind = "meditate", target = "bodhi_seat", count = 20, text = "Meditate beneath the Bodhi tree" },
		},
		reward = { merit = 300, robe = "golden" },
		outro = {
			{ "", "In the third watch he saw it whole: this is suffering; this is its cause; this is its end; this is the path that leads to its end." },
			{ "", "As the morning star rose, ignorance was destroyed and knowledge arose. 'Birth is ended. The holy life has been lived. What had to be done is done.'" },
			{ "", "'House-builder, you are seen. You shall not build this house again.' So Siddhartha Gautama became the Buddha, the Awakened One." },
		},
	},
	{
		id = "awake", title = "Awakened",
		intro = "You have walked the whole of the Bodhi Path. Stay as long as you like: find every Bodhi leaf, complete the Eightfold Path, and help other seekers answer Mara.",
		objectives = {},
		final = true,
	},
}

Story.QuestIndex = {}
for i, q in ipairs(Story.Quests) do
	Story.QuestIndex[q.id] = i
end

----------------------------------------------------------------------
-- Teachings on the Bodhi leaves. These are short paraphrases, with the
-- traditional source of each.
----------------------------------------------------------------------
Story.Teachings = {
	{ text = "Mind comes first. Speak or act with a clear mind, and happiness follows like a shadow that never leaves.", source = "Dhammapada 2" },
	{ text = "Hatred is never ended by hatred. By non-hatred alone is it ended. This is an ancient law.", source = "Dhammapada 5" },
	{ text = "Better than a thousand hollow words is one word that brings peace.", source = "Dhammapada 100" },
	{ text = "You yourself must make the effort. The Buddhas only point the way.", source = "Dhammapada 276" },
	{ text = "Drop by drop the water pot is filled. So the wise fill themselves with good, little by little.", source = "Dhammapada 122" },
	{ text = "As a solid rock is not shaken by the wind, the wise are not moved by praise or blame.", source = "Dhammapada 81" },
	{ text = "One may conquer a thousand men a thousand times in battle. The greatest victor conquers only one: oneself.", source = "Dhammapada 103" },
	{ text = "All tremble at violence; life is dear to all. Seeing yourself in others, do not harm, and do not cause harm.", source = "Dhammapada 130" },
	{ text = "Health is the greatest gift, contentment the greatest wealth, trust the best of kin, Nibbana the highest happiness.", source = "Dhammapada 204" },
	{ text = "There is no fire like passion, no grip like hatred, no net like delusion, no river like craving.", source = "Dhammapada 251" },
	{ text = "To avoid all harm, to cultivate the good, and to purify the mind: this is the teaching of the Buddhas.", source = "Dhammapada 183" },
	{ text = "The scent of flowers does not travel against the wind. The fragrance of the good spreads in every direction.", source = "Dhammapada 54" },
	{ text = "Do not dwell on the faults of others, on what they did or left undone. Look to your own doing.", source = "Dhammapada 50" },
	{ text = "As rain cannot break into a well-roofed house, craving cannot break into a well-trained mind.", source = "Dhammapada 14" },
	{ text = "Conquer anger with calm, meanness with giving, and falsehood with truth.", source = "Dhammapada 223" },
	{ text = "A fool who knows they are a fool is, in that at least, wise.", source = "Dhammapada 63" },
	{ text = "Irrigators guide water, fletchers straighten arrows, carpenters shape wood. The wise shape themselves.", source = "Dhammapada 80" },
	{ text = "As a lotus is born in the water and grows in the water, yet rises above it unstained, so the awakened one lives in the world.", source = "Anguttara Nikaya 4.36" },
	{ text = "All conditioned things pass away. Strive on with heedfulness.", source = "The Buddha's last words, Digha Nikaya 16" },
	{ text = "May all beings be happy and safe. May their hearts be at ease.", source = "Metta Sutta, Sutta Nipata 1.8" },
}

-- Short words shown when a player's Calm runs out.
Story.OverwhelmLines = {
	"The mind was swept away. Begin again; the breath is still here.",
	"Even the Bodhisatta wavered. Return to the shrine and gather yourself.",
	"Falling is part of the path. So is getting up.",
}

return Story
