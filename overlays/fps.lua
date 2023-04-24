local FPSOverlay = {
    fps = 0,
    fpsFont = love.graphics.newFont(14),

    update = function(self, game, dt)
        self.fps = love.timer.getFPS()
    end,

    draw = function(self, game)
        local text = self.fps .. ' FPS'
        local width = self.fpsFont:getWidth(text) + 10
        local height = self.fpsFont:getHeight() + 10

        -- keeping original colour and font
        r, g, b, a = love.graphics.getColor()
        font = love.graphics.getFont()

        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle('fill', love.graphics.getWidth() - width, love.graphics.getHeight() - height, width, height)

        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(self.fpsFont)
        love.graphics.print(text, love.graphics.getWidth() - width + 5, love.graphics.getHeight() - height + 5)
    end
}

return FPSOverlay