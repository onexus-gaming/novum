-- novum core v0.1.0
-- ONEXUS, 2023
-- Keeping this notice in your game is recommended.

local game = {
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

    -- handlers
    toasts = require "novum.toasts",

    -- overlays
    overlays = {
        handlers = {
            fps = require "novum.overlays.fps"
        },
        fps = false,
    },

    title = "Novum Core Game"
}

-- table.foreach(game.scenes, print)

if #game.scenes == {} then
    error('No scene loaded.')
end
if not game.scenes.initial then
    error('No initial scene found.')
end

function game:discoverScene(name)
    -- print(name)
    game.scenes[name] = require("scenes." .. name)
    return game.scenes[name]
end

function game:discoverTransition(name)
    -- print(name)
    game.transitions[name] = require("transitions." .. name)
    return game.transitions[name]
end

function game:switchSceneInstant(name)
    game.currentScene = name
end

function game:switchSceneByTransition(name, transition, duration)
    game.currentSceneTransition = {
        handler = game.transitions[transition],
        start = love.timer.getTime(),
        duration = duration or 1,
        from = game.currentScene,
        to = name
    }

    game.currentSceneTransition.handler:pre(game, game.scenes[game.currentSceneTransition.from], game.scenes[game.currentSceneTransition.to])
end

function love.load()
    for k, v in pairs(game.scenes) do
        if v.load then
            v:load()
        end
    end
end

function love.keypressed(key)
    local scene = game.scenes[game.currentScene]
    if scene.keypressed then
        scene:keypressed(game, key)
    end
end

function love.keyreleased(key)
    local scene = game.scenes[game.currentScene]
    if scene.keyreleased then
        scene:keyreleased(game, key)
    end
end

function love.update(dt)
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
            game:switchSceneInstant(game.currentSceneTransition.to)
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
    -- if transition is inactive
    if not game.currentSceneTransition.handler then
        local scene = game.scenes[game.currentScene]
        if scene.draw then
            scene:draw(game)
        end
    else
        local endTime = game.currentSceneTransition.start + game.currentSceneTransition.duration
        local position = 1 - (endTime - love.timer.getTime())/game.currentSceneTransition.duration
        game.currentSceneTransition.handler:draw(game, position, game.scenes[game.currentSceneTransition.from], game.scenes[game.currentSceneTransition.to])
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
end

return game