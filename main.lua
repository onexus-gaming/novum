-- novum core v0.1.0
-- ONEXUS, 2023
-- Keeping this notice in your game is recommended.

local game = {
    -- scene system
    scenes = {
        initial = require "scenes.initial"
    },
    currentScene = "initial",

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

function game:switchSceneInstant(name)
    game.currentScene = name
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
    local scene = game.scenes[game.currentScene]
    if scene.update then
        scene:update(game, dt)
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
    local scene = game.scenes[game.currentScene]
    if scene.draw then
        scene:draw(game)
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