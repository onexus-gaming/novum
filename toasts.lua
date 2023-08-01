local ToastHandler = {
    toasts = {
        --[[toast format:
        {
            type = "success" or "debug" or "info" or "warn" or "error",
            text = string,
            timePosted = number,
        }
        ]]
    },
    toastFont = love.graphics.newFont(14),

    post = function(self, type, text)
        table.insert(self.toasts, 1, {
            type = type,
            text = text,
            timePosted = love.timer.getTime(),
        })
    end,
    clean = function(self, decay)
        local i = 1
        while i <= #self.toasts do
            local toast = self.toasts[i]
            -- print(i, toast.type, toast.text, toast.timePosted)
            if love.timer.getTime() - toast.timePosted >= decay then
                table.remove(self.toasts, i)
            end
            i = i + 1
        end
    end,

    renderSingle = function(self, toast, decay, x, y)
        local barWidth = 5
        local toastWidth = self.toastFont:getWidth(toast.text) + 3*barWidth
        local toastHeight = self.toastFont:getHeight() + 2*barWidth

        local toastColours = {
            success = {0.3,   1, 0.3},
            debug = {0.6, 0.6, 0.6},
            info  = {0.5, 0.7, 0.9},
            warn  = {1,   0.7, 0.1},
            error = {1,   0.3, 0.3},
        }
        local colour = toastColours[toast.type]

        -- keeping original colour and font
        r, g, b, a = love.graphics.getColor()
        font = love.graphics.getFont()

        local toastAlpha = 1
        if love.timer.getTime() - toast.timePosted >= decay - 1 then
            local animRate = love.timer.getTime() - toast.timePosted - decay + 1
            toastAlpha = 1 - animRate
        end
        local toastAnimatedX = -toastWidth
        if love.timer.getTime() - toast.timePosted < 0.125 then
            toastAnimatedX = -toastWidth + (toastWidth+x)*(love.timer.getTime() - toast.timePosted)*8
        else
            toastAnimatedX = x
        end

        love.graphics.setFont(self.toastFont)
        love.graphics.setColor(0.2, 0.2, 0.2, toastAlpha)
        love.graphics.rectangle('fill', toastAnimatedX, y, toastWidth, toastHeight)

        love.graphics.setColor(colour[1], colour[2], colour[3], toastAlpha)
        love.graphics.rectangle('fill', toastAnimatedX, y, barWidth, toastHeight)
        love.graphics.rectangle('line', toastAnimatedX, y, toastWidth, toastHeight)
        
        love.graphics.setColor(1, 1, 1, toastAlpha)
        love.graphics.print(toast.text, toastAnimatedX + 2*barWidth, y + barWidth)

        -- restoring original colour and font
        love.graphics.setColor(r,g,b,a)
        love.graphics.setFont(font)

        return toastHeight*math.min((love.timer.getTime() - toast.timePosted)*8, 1) -- stacked rendering purposes
    end
}

return ToastHandler