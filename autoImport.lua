function loadAll(sourceType, sourceFolder)
    local files = love.filesystem.getDirectoryItems(sourceFolder)
    local sources = {}

    if files then
        for i, v in ipairs(files) do
            local info = love.filesystem.getInfo(sourceFolder..'/'..v)
            local extensionless = v:match("(.+)%..+$")

            if info.type == 'directory' or info.type == 'symlink' then
                sources[extensionless] = loadAll(sourceType, sourceFolder..'/'..v)

            elseif sourceType == 'image' then
                sources[extensionless] = love.graphics.newImage(sourceFolder..'/'..v)

            elseif sourceType == 'audio' then
                local slug = string.sub(v, 1, 4)
                if slug == 'str-' then
                    sources[extensionless] = love.audio.newSource(sourceFolder..'/'..string.sub(v, 5, #v), 'stream')
                elseif slug == 'sta-' then
                    sources[extensionless] = love.audio.newSource(sourceFolder..'/'..string.sub(v, 5, #v), 'static')
                else
                    error("unexpected slug (expected 'str-' (streaming) or 'sta-' (static))", 2)
                end

            else
                error("unexpected source type (expected 'image' or 'audio')", 2)
            end
        end
    end

    return sources
end

return loadAll