-- novum core v0.1.0
-- ONEXUS, 2023
-- Keeping this notice in your game is recommended.

local game = {
    scenes = {
        menu = require "scenes.menu"
    },
    current_scene = "menu",
    title = "Novum Core Game"
}

table.foreach(game.scenes, print)

if #game.scenes == {} then
    error('No scene loaded.')
end
if not game.scenes.menu then
    error('No menu found.')
end

function love.update(dt)
    local scene = game.scenes[game.current_scene]
    if scene.update then
        scene.update(game, dt)
    end
end

function love.draw()
    local scene = game.scenes[game.current_scene]
    if scene.draw then
        scene.draw(game)
    end
end