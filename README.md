[![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](https://github.com/Hand-Lock/billy-boarding/blob/main/LICENSE)

# Billy Boarding: A Mode 13h Addon

*A resource pack for Minecraft 1.20.1 to 26.3 that turns small 3D blocks into flat sprites, which the **Mode 13h** shaderpack **billboards**.*

> **Designed as an addon for [Mode 13h: MS-DOSify!](https://modrinth.com/shader/mode-13h) 2.1.2 or newer.** Turn on *Billy Boarding* in its shader settings.
> Without the shaderpack you *can* still use the pack, but the blocks render as static **cross/hatch** sprites (like vanilla grass/flowers), because Mode 13h is what turns them to face you.

---

![A lit candle cake drawn as a flat sprite on a stone pedestal](https://cdn.modrinth.com/data/bTh8rCOa/images/e919a4f1a350da2ca0c69e7cf4e1c6c7633e29aa.png)

## 🧾 Why This Exists

Old DOS-era 3D games drew their props as **billboards**: flat pictures that always turn to face you. Mode 13h already does that for flowers, grass, torches and lanterns, but cakes, flower pots, anvils and bells stay chunky little 3D models.

**Billy Boarding** gives Mode 13h more to work with. It replaces the models of cakes, flower pots, anvils, bells, brewing stands, cactus, crops and fire with flat sprites, and the shader turns them to face the camera.

---

## ✨ Features

### 🎂 Cakes and candle cakes

* Every **bite stage** of the cake has its own sprite.
* **Candle cakes**, lit and unlit.

![A cake with a slice missing on a table in a brick dungeon](https://cdn.modrinth.com/data/bTh8rCOa/images/77d09cd3eaef47b71839da4a24f87b7866675940.png)

### 🪴 Flower pots

* The empty pot and **every potted plant**: 34 on 1.20.1, up to 39 on 26.3.
* The plant sits between the back and front of the pot, so it reads as *in* the pot from every side.
* The open **eyeblossom** keeps its glow.

![A potted dandelion and a potted mushroom on a brick wall](https://cdn.modrinth.com/data/bTh8rCOa/images/18b43dfe7dadba363e00b68bf4a7aceb419c63c5.png)

### 🔔 Bells

* **Standing** and **hanging** bells become billboards.
* **Wall-mounted** bells become flat plates on the wall, hanging from their stem.

![Standing, hanging and wall-mounted bells between cobblestone blocks](https://cdn.modrinth.com/data/bTh8rCOa/images/da0740dfc58007c4a3481615b55ddedd88d7ba54.png)

### ⚗️ Brewing stands

* The stand and **each bottle slot**: bottles appear and disappear as you fill it.

![A brewing stand with a potion bottle](https://cdn.modrinth.com/data/bTh8rCOa/images/479d5f83bb7e1d9b79d8a428d8c18daaaeeb089b.png)

### 🌾 Crops, cactus and fire

* **Wheat**, **carrots**, **potatoes**, **beetroots**, **nether wart** and **torchflower** crops.
* The **pitcher crop**: its leaves billboard over the 3D bulb.
* **Cactus**, **fire** and **soul fire**.

![Rows of billboarded carrots, beetroots, potatoes and wheat on farmland](https://cdn.modrinth.com/data/bTh8rCOa/images/1c6999e90fa4ffb5aea35e05f93ff61038c8a746.png)

### 🔨 Anvils

* Intact, chipped and damaged anvils, **flat in the inventory** too.

---

## 🪵 Resourcepack-friendly by design

* The sprites reuse the **vanilla item icons and textures** wherever they read well, so most blocks pick up the look of any texture pack you load **below** this one.
* New art only where no icon fits: cake bites, candle cakes, pot layers, brewing stand bottles, bell parts and anvils.

---

## ⚠️ Known compromises

* **Anvils** are placeholder silhouettes until their art lands.
* **Colored candle cakes** all show the plain candle for now.
* The **potted cactus** is a green square for now.
* On **Fabric without the shader**, cakes, anvils and bells show dark backgrounds around their sprites. Mode 13h cleans them up; Forge and NeoForge don't have the problem.
* Blocks **moved by pistons** stay static while they move.
* The **pale oak pot** stays vanilla on 1.21.2–1.21.3, where pale oak was experimental.

Coming as the art lands: candles, sea pickles, turtle eggs, the sniffer egg, the dragon egg, campfires, the heavy core and the dried ghast. Signs are left to [**Flatter Signs**](https://modrinth.com/mod/flatter-signs).

---

## 🧩 Compatibility

| Setup | Works? | Notes |
| :--- | :---: | :--- |
| **Minecraft 1.20.1** | ✅ | Tested in game |
| **Minecraft 1.21.1** | ✅ | Main target |
| **Minecraft 1.20.2 – 26.3** | ✅ | Best effort; one zip covers every version through overlays |
| **Mode 13h + Iris / Oculus** | ✅ | Billboards |
| **Vanilla or other shaders** | ✅* | *Static cross/hatch sprites, like vanilla flowers* |
| **Forge / NeoForge** | ✅ | Clean sprites with or without the shader |
| **Fabric** | ✅ | Needs Mode 13h for clean cakes, anvils and bells |

---

## ⚙️ Setup

1. Install [**Mode 13h**](https://modrinth.com/shader/mode-13h) with **Iris** or **Oculus**.
2. Turn on **Billy Boarding** in the shader settings.
3. Put this pack **above** the default resources (and above texture packs you want it to use) in the resource pack list.

---

## 🖇️ Credits

* **Models, blockstates & idea:** *HandLock_*
* **Textures:** *damikdevv*
* **Item icons the sprites are based on:** *Mojang*
* **Made for:** [Mode 13h: MS-DOSify!](https://modrinth.com/shader/mode-13h) shaderpack

## 📜 License

[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). You can share and adapt the pack, including in modpacks, as long as you credit the authors and share your changes under the same license.

## 🛠️ Development

See [`AGENTS.md`](https://github.com/Hand-Lock/billy-boarding/blob/main/AGENTS.md).

> *“The cake is a sprite.”*
