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

local KeyBindingsHandler = {
    file = "keys.binser",

    keys = {},

    validate = function(self)
        for k, v in pairs(self.keys) do
            if not type(v) == 'table' then
                return false
            end
            for i, w in ipairs(v) do
                if not type(w) == 'string' then
                    return false
                end
            end
        end
        return true
    end,

    initialize = function(self, defaults)
        if love.filesystem.getInfo(self.file) then -- configuration exists
            local contents, size = love.filesystem.read(self.file)
            local results, len = binser.deserialize(contents)
            self.keys = deepCopy(results[1])
            if not self:validate() then
                error('keybinds must be tables of strings', 2)
            end
        else -- generate config
            self.keys = deepCopy(defaults)
            if not self:validate() then
                error('keybinds must be tables of strings', 2)
            end
            local success, message = love.filesystem.write(self.file, binser.serialize(defaults))
            if not success then
                error(message, 2)
            end
        end
    end,

    save = function(self)
        if not self:validate() then
            error('keybinds must be tables of strings', 2)
        end
        local success, message = love.filesystem.write(self.file, binser.serialize(self.keys))
        if not success then
            error(message, 2)
        end
    end,

    getAssociatedAction = function(self, key)
        for k, v in pairs(self.keys) do
            for i, w in ipairs(v) do
                if w == key then
                    return k
                end
            end
        end
        return nil
    end,

    isActionDown = function(self, action)
        for i, v in ipairs(self.keys[action]) do
            if love.keyboard.isDown(v) then
                return true
            end
        end
        return false
    end
}

return KeyBindingsHandler