-- novum core v0.2.0
-- ONEXUS, 2023
-- Keeping this notice in your game is recommended.

function table.contains(t, element)
    for k, v in pairs(t) do
        if v == element then return true end
    end
    return false
end

function table.length(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

local game = {
    versioning = {
        novum = "0.2.0",
        game = "0.0.0",
    },

    -- scene system
    scenes = {
        initial = require "scenes.initial"
    },
    currentScene = "initial",
    transitions = {},
    currentSceneTransition = {
        handler = nil,
        start = 0,
        duration = 0,
        from = "",
        to = ""
    },
    
    -- callback handlers
    callbackHandlers = {},
    knownCallbacks = {'load', 'keypressed', 'keyreleased', 'textinput', 'touchpressed', 'touchreleased', 'touchmoved', 'update', 'draw', 'drawOverlay'},

    -- handlers
    toasts = require "novum.toasts",
    gameConfig = require "novum.gameConfig",
    keyBinds = require "novum.keys",

    -- modules
    timer = require "novum.timer",
    autoImport = require "novum.autoImport",
    reactiveBGM = require "novum.reactiveBGM",

    -- overlays
    overlays = {
        handlers = {
            fps = require "novum.overlays.fps",
            multitouch = require "novum.overlays.multitouch"
        },
        fps = false,
        multitouch = false
    },

    startPrint = false, -- print info on startup

    title = "Novum Core Game"
}

-- table.foreach(game.scenes, print)

if #game.scenes == {} then
    error('No scene loaded.')
end
if not game.scenes.initial then
    error('No initial scene found.')
end

function game:dynamicTitle()
    love.window.setTitle(self.title .. '(' .. self.versioning.game .. ')')
end

function game:discoverScene(name)
    -- print(name)
    game.scenes[name] = require("scenes." .. name)
    return game.scenes[name]
end

function game:discoverAllScenes()
    local sceneList = love.filesystem.getDirectoryItems("scenes")
    for i, v in ipairs(sceneList) do
        if(string.sub(v, 1) ~= "_" and string.sub(v, -4) == ".lua") then -- ignore metascenes
			self:discoverScene(string.sub(v,1,-5))
		end
    end
end

function game:discoverTransition(name)
    -- print(name)
    game.transitions[name] = require("transitions." .. name)
    return game.transitions[name]
end

function game:discoverAllTransitions()
    local transitionList = love.filesystem.getDirectoryItems("transitions")
    for i, v in ipairs(transitionList) do
        if(string.sub(v, 1) ~= "_" and string.sub(v, -4) == ".lua") then -- ignore metascenes
			self:discoverTransition(string.sub(v,1,-5))
		end
    end
end

function game:switchSceneInstant(name, data)
    game.currentScene = name
    local scene = game.scenes[game.currentScene]
    if scene.opened then
        scene:opened(game, data)
    end
end

function game:switchSceneByTransition(name, transition, duration, data)
    game.currentSceneTransition = {
        handler = game.transitions[transition],
        data = data,
        start = love.timer.getTime(),
        duration = duration or 1,
        from = game.currentScene,
        to = name
    }

    game.currentSceneTransition.handler:pre(game, game.scenes[game.currentSceneTransition.from], game.scenes[game.currentSceneTransition.to])
end

function game.isMobile()
    local osString = love.system.getOS()
    return osString == 'Android' or osString == 'iOS'
end

function game:mobileFullscreen()
    if self.isMobile() then
        love.window.setFullscreen(true)
    end
end

function game:hookCallback(eventName, callback) -- run game-wide code after callbacks
    if self.callbackHandlers[eventName] == nil then
        self.callbackHandlers[eventName] = {}
    end
    -- if the specified callback doesn't exist, show a gentle toast so as to prevent the game dev from ripping their hair apart because their piece of code never gets executed
    -- trust me, i've gone through this a lot, i know how it is
    if not table.contains(self.knownCallbacks, eventName) then
        self.toasts:post('warn', 'novum:hookCallback: callback "'..eventName..'" doesn\'t exist.')
    end
    table.insert(self.callbackHandlers[eventName], callback)
end

function love.load()
    if game.startPrint then
        print("novum core v"..game.versioning.novum)
        print("running game "..game.title.." v"..game.versioning.game)
        print("discovered:")
        print(table.length(game.scenes), "scene(s)")
        print(table.length(game.transitions), "transition(s)")
        print("configuration:")
        print(table.length(game.gameConfig.config), "option(s)")
        print(table.length(game.keyBinds.keys), "custom action(s) (keyboard)")
    end

    if game.callbackHandlers.load then
        for k, v in pairs(game.callbackHandlers.load) do
            v(game)
        end
    end
    for k, v in pairs(game.scenes) do
        if v.load then
            v:load(game)
        end
    end
end

function love.keypressed(key)
    local scene = game.scenes[game.currentScene]
    if game.callbackHandlers.keypressed then
        for k, v in pairs(game.callbackHandlers.keypressed) do
            v(game, key)
        end
    end
    if scene.keypressed then
        scene:keypressed(game, key)
    end
end

function love.keyreleased(key)
    local scene = game.scenes[game.currentScene]
    if game.callbackHandlers.keyreleased then
        for k, v in pairs(game.callbackHandlers.keyreleased) do
            v(game, key)
        end
    end
    if scene.keyreleased then
        scene:keyreleased(game, key)
    end
end

function love.textinput(text)
    local scene = game.scenes[game.currentScene]
    if game.callbackHandlers.textinput then
        for k, v in pairs(game.callbackHandlers.textinput) do
            v(game, text)
        end
    end
    if scene.textinput then
        scene:textinput(game, text)
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    local scene = game.scenes[game.currentScene]
    if game.callbackHandlers.touchpressed then
        for k, v in pairs(game.callbackHandlers.touchpressed) do
            v(game, id, x, y, dx, dy, pressure)
        end
    end
    if scene.touchpressed then
        scene:touchpressed(game, id, x, y, dx, dy, pressure)
    end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    local scene = game.scenes[game.currentScene]
    if game.callbackHandlers.touchreleased then
        for k, v in pairs(game.callbackHandlers.touchreleased) do
            v(game, id, x, y, dx, dy, pressure)
        end
    end
    if scene.touchreleased then
        scene:touchreleased(game, id, x, y, dx, dy, pressure)
    end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    local scene = game.scenes[game.currentScene]
    if game.callbackHandlers.touchmoved then
        for k, v in pairs(game.callbackHandlers.touchmoved) do
            v(game, id, x, y, dx, dy, pressure)
        end
    end
    if scene.touchmoved then
        scene:touchmoved(game, id, x, y, dx, dy, pressure)
    end
end

function love.update(dt)
    if game.callbackHandlers.update then
        for k, v in pairs(game.callbackHandlers.update) do
            v(game, dt)
        end
    end

    -- if transition is inactive
    if not game.currentSceneTransition.handler then
        local scene = game.scenes[game.currentScene]
        if scene.update then
            scene:update(game, dt)
        end
    else
        local endTime = game.currentSceneTransition.start + game.currentSceneTransition.duration
        if love.timer.getTime() >= endTime then
            game.currentSceneTransition.handler = nil
            game:switchSceneInstant(game.currentSceneTransition.to, game.currentSceneTransition.data)
        end
    end

    -- overlay management
    for k, v in pairs(game.overlays.handlers) do
        if game.overlays[k] and v.update then
            v:update(game, dt)
        end
    end

    -- toast management
    game.toasts:clean(5)
end

function love.draw()
    if game.callbackHandlers.draw then
        for k, v in pairs(game.callbackHandlers.draw) do
            v(game)
        end
    end

    -- if transition is inactive
    if not game.currentSceneTransition.handler then
        local scene = game.scenes[game.currentScene]
        if scene.draw then
            scene:draw(game)
        end
    else
        local endTime = game.currentSceneTransition.start + game.currentSceneTransition.duration
        local position = 1 - (endTime - love.timer.getTime())/game.currentSceneTransition.duration
        game.currentSceneTransition.handler:draw(game, position, game.scenes[game.currentSceneTransition.from], game.scenes[game.currentSceneTransition.to], game.currentSceneTransition.data)
    end

    -- overlay management
    for k, v in pairs(game.overlays.handlers) do
        if game.overlays[k] and v.draw then
            v:draw(game)
        end
    end

    -- toast management
    local y = 5
    for i, v in ipairs(game.toasts.toasts) do
        local toast = game.toasts.toasts[i]
        y = y + game.toasts:renderSingle(toast, 5, 5, y) + 5
    end

    if game.callbackHandlers.drawOverlay then
        for k, v in pairs(game.callbackHandlers.drawOverlay) do
            v(game)
        end
    end
end

game:switchSceneInstant('initial')

return game