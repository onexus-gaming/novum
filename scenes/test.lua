local Test = {
    text = "placeholder123",
    y = 0,

    update = function(self, game, dt)
        self.y = self.y + dt
    end,

    draw = function(self, game)
        love.graphics.print(self.text, love.graphics.getWidth()/2-love.graphics.getFont():getWidth(self.text)/2, love.graphics.getHeight()/2-love.graphics.getFont():getHeight()/2+(math.sin(self.y)*50))
    end
}

return Test