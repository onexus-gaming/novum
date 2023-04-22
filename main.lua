-- novum core v0.1.0
-- ONEXUS, 2023
-- Keeping this notice in your game is recommended.

local game = {
    scenes = {
        menu = require "scenes.menu"
    },
    currentScene = "menu",
    title = "Novum Core Game"
}

-- table.foreach(game.scenes, print)

if #game.scenes == {} then
    error('No scene loaded.')
end
if not game.scenes.menu then
    error('No menu found.')
end

function game:discoverScene(name)
    print(name)
    game.scenes[name] = require("scenes." .. name)
    return game.scenes[name]
end

function game:moveScene(name)
    game.currentScene = name
end

function love.load()
    for k, v in pairs(game.scenes) do
        if v.load then
            v:load()
        end
    end
end

function love.update(dt)
    local scene = game.scenes[game.currentScene]
    if scene.update then
        scene:update(game, dt)
    end
end

function love.draw()
    local scene = game.scenes[game.currentScene]
    if scene.draw then
        scene:draw(game)
    end
end

return game