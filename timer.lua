-- state timer component
local timer = {}

setmetatable(timer, {
    __call = function(_, ...)
        return timer.new(...)
    end
})

local mt = {
    __index = timer
}

function timer.new(initial, maximum)
    local res = {
        initial = initial,
        current = initial,
        maximum = maximum,
    }
    return setmetatable(res, mt)
end

function timer:expired()
    return self.current >= self.maximum
end

function timer:update(dt)
    self.current = math.min(self.current + dt, self.maximum)
    return self.current
end

function timer:reset(initial)
    initial = initial or self.initial
    self.current = initial
    return initial
end

function timer:progress(initial)
    local time = self.maximum - self.initial
    local currentTime = self.current - self.initial
    return currentTime/time
end

return timer