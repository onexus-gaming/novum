local binser = require "novum.binser"

local function deepCopy(t)
    local ct = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            ct[k] = deepCopy(v)
        else
            ct[k] = v
        end
    end
    return ct
end

local GameConfigurationHandler = {
    file = "config.binser",

    config = {},

    initialize = function(self, defaults)
        if love.filesystem.getInfo(self.file) then -- configuration exists
            local contents, size = love.filesystem.read(self.file)
            local results, len = binser.deserialize(contents)
            self.config = deepCopy(results[1])
        else -- generate config
            local success, message = love.filesystem.write(self.file, binser.serialize(defaults))
            if not success then
                error(message, 2)
            end
            self.config = defaults
        end
    end,

    save = function(self)
        local success, message = love.filesystem.write(self.file, binser.serialize(self.config))
        if not success then
            error(message, 2)
        end
    end
}

return GameConfigurationHandler