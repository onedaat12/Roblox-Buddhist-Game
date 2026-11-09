# The Bodhi Path

A Roblox adventure that follows the road Siddhartha Gautama walked to become the Buddha.
You are a seeker who sets out from the temple at Kapilavastu, crosses two rivers, studies
with the forest teachers, endures the austerities of Uruvela, faces Mara's ten armies and
Mara himself, and finally sits beneath the Bodhi tree.

Built for Roblox Studio. All code is Luau. Works alone or with other players on the same server.

## Open and play it

1. Double-click **`BodhiPath.rbxlx`**. It opens in Roblox Studio.
2. Press **Play** (F5). The world builds itself in a second or two and you arrive in the temple courtyard.

Nothing has to be placed by hand: the scripts build the whole world when the game starts.

## Publish it to Roblox

1. In Studio: **File > Publish to Roblox As...**, choose a name, and create the experience.
2. **Home > Game Settings > Security**: turn on **Enable Studio Access to API Services**
   (this lets progress save while you test in Studio; published servers save without it).
3. **Game Settings > Avatar**: set Avatar Type to **R15**.
4. **Game Settings > Permissions**: set the experience to **Public** when you are ready for others to play.

## How to play

| | Keyboard | Phone / tablet |
|---|---|---|
| Strike (palm, then staff) | F or left click | Strike button |
| Mala (bead of light) | R | Mala button |
| Metta (loving-kindness) | Q | Metta button |
| Singing bowl | G | Bowl button |
| Meditate | M | Meditate button |
| Talk, pray, pick up | E | tap the prompt |
| Bag / Eightfold Path | B / P | buttons, top left |

- **Calm** is your health. When it runs out you are "overwhelmed" and return to the last shrine you prayed at. Meditating restores it quickly.
- **Merit** is the only currency. You earn it from the journey, from dispelling Mara's soldiers, from prayer wheels, bells and offerings.
- Spend merit in the two shops, on robes of the different Buddhist traditions, and on the eight steps of the Noble Eightfold Path (bought in order at any shrine; each one makes you stronger).
- A golden diamond on screen always points to your next goal.
- There are 28 steps in the journey, 20 hidden Bodhi leaves (each with a teaching), 10 shrines, 10 kinds of enemy, three mini-bosses and the encounter with Mara.

## What is in this folder

| Path | What it is |
|---|---|
| `BodhiPath.rbxlx` | The game, ready to open in Roblox Studio |
| `src/shared/Config.lua` | Numbers and lists: zones, items, prices, robes, enemies. **Change the game's balance here.** |
| `src/shared/Story.lua` | Every person, every line of dialogue, every step of the journey, every teaching |
| `src/server/` | Server scripts: world building, enemies, Mara, shops, saving |
| `src/client/` | What the player sees: the HUD, windows, effects |
| `docs/STORY_NOTES.md` | Where each part of the story comes from, and where the game takes liberties |
| `tools/` | Helper programs (not part of the game) |

## Changing the game

Edit the files in `src/`, then rebuild the place file:

```bash
node tools/build.js
```

Then reopen `BodhiPath.rbxlx` in Studio. (If you use [Rojo](https://rojo.space), `default.project.json` describes the same layout, so `rojo serve` also works.)

Two checks are included. They need Node.js and one `npm install` inside `tools/`:

```bash
node tools/check.js
```

checks every script for syntax errors and misspelled names, and

```bash
node tools/sim.js path/to/API-Dump.json
```

runs a simulated playthrough of the entire journey outside Roblox, against the real Roblox
API description (export it from Studio with `RobloxStudioBeta.exe -API API-Dump.json`).

## Things to add in Studio later

- **Music and sound.** The game is silent for now. Sounds must be picked from the Creator Store inside Studio.
- **A game icon and thumbnails** for the Roblox page.
- **Robux purchases** (for example selling a robe as a Game Pass). Everything is currently earned in play.
