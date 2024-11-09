-- reactive BGM component
local reactiveBGM = {}

local function direction(a, b)
        if a < b then return  1
    elseif a > b then return -1
    else              return  0 end
end

setmetatable(reactiveBGM, {
    __call = function(_, ...)
        return reactiveBGM.new(...)
    end
})

local mt = {
    __index = reactiveBGM
}

function reactiveBGM.new(musicTable)
    local targetState = {}
    for k, v in pairs(musicTable) do
        targetState[k] = v.state

        v.audio = love.audio.newSource(v.path, 'stream')
        v.audio:setLooping(true)
        v.audio:setVolume(v.state)
    end

    local res = {
        music = musicTable,
        targetState = targetState,
        changeSpeed = 1,
    }
    return setmetatable(res, mt)
end

function reactiveBGM:play()
    for k, v in pairs(self.music) do
        if v.audio:isPlaying() then
            v.audio:stop()
        end

        v.audio:play()
    end
end

function reactiveBGM:isPlaying()
    for k, v in pairs(self.music) do
        if v.audio:isStopped() then
            return false
        end
    end
    
    return true
end

function reactiveBGM:sync()
    local latestTime = 0
    for k, v in pairs(self.music) do
        local t = v.audio:tell()
        if t > latestTime then
            latestTime = t
        end
    end

    for k, v in pairs(self.music) do
        v.audio:seek(latestTime)
    end
end

function reactiveBGM:pause()
    for k, v in pairs(self.music) do
        v.audio:pause()
    end
end

function reactiveBGM:stop()
    for k, v in pairs(self.music) do
        v.audio:stop()
    end
end

function reactiveBGM:update(dt)
    for k, v in pairs(self.music) do
        if v.state ~= self.targetState[k] then
            local d = direction(v.state, self.targetState[k])
            v.state = v.state + d * self.changeSpeed * dt
            if math.abs(self.targetState[k] - v.state) <= 0.01 then
                v.state = self.targetState[k]
            end
        end

        v.audio:setVolume(v.state)
    end
end

function reactiveBGM:tell()
    local latestTime = 0
    for k, v in pairs(self.music) do
        local t = v.audio:tell()
        if t > latestTime then
            latestTime = t
        end
    end

    return latestTime
end

function reactiveBGM:getDuration()
    local longestDuration = 0
    for k, v in pairs(self.music) do
        local t = v.audio:getDuration()
        if t > longestDuration then
            longestDuration = t
        end
    end
    
    return longestDuration
end

return reactiveBGM