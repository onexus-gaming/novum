# novum-core

 Simple easy-to-use game core for LÖVE (LOVE2D)

 note: this repository **ISN'T** runnable.

## usage

place the contents of this repository (excluding the `scenes` folder, they are dummy scenes to get you started) into `novum/` in your game folder

then, in `main.lua` initialize novum by doing:

```lua
local novum = require "novum.main"
```

or

```lua
novum = require "novum.main"
```

## what does novum do

novum provides:

* a scene management system
* a transition system to switch between scenes with animations
* a toast system to display messages
* an overlay system for debugging purposes

read the wiki for more info
