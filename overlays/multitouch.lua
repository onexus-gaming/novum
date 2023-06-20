local MultitouchOverlay = {
    draw = function(self, game)
        local touches = love.touch.getTouches()

        for i, id in ipairs(touches) do
            local x, y = love.touch.getPosition(id)
            love.graphics.circle("fill", x, y, 20)
        end
    end
}

return MultitouchOverlay