# novum

 Simple easy-to-use game core for LÖVE (LOVE2D)

 note: this repository **ISN'T** runnable.

## usage

place the contents of this repository (excluding the `scenes` folder, they are dummy scenes to get you started) into `novum/` in your game folder

then, in `main.lua` initialize novum by doing:

```lua
local novum = require "novum"
```

or

```lua
novum = require "novum"
```

## what does novum do

novum provides:

* a scene management system
* a transition system to switch between scenes with animations
* a toast system to display messages
* an overlay system for debugging purposes
* a keybinding system
* a game config system
* a state-based reactive background music system (queue audio tracks based on in-game events)

novum is entirely configurable: every module of the framework can be customized (this is particularly useful if you need to integrate novum components with your game's visuals).

read the wiki for more info
