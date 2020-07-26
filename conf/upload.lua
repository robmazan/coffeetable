local session = require 'resty.session'.open()
local upload = require 'resty.upload'
local cjson = require 'cjson'
local resty_md5 = require 'resty.md5'

-- ngx.say(cjson.encode(session.data))
-- ngx.exit(ngx.HTTP_OK)
if not session.data or not session.data.id_token then
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

local username = session.data.id_token.preferred_username

-- TODO: pass media root path, create username directory if not exists
--       get tempname, save file, read exif, rename file, create DB rec

local chunk_size = 4096
local form = upload:new(chunk_size)
if not form then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local md5 = resty_md5:new()
local file
local meta = {
    original_name = '',
    mime_type = ''
}
while true do
    local typ, res, err = form:read()

    if not typ then
            ngx.say("failed to read: ", err)
            return
    end

    if typ == "header" then
        local header_name = res[1]
        local header_value = res[2]

        if header_name == 'Content-Type' then
            meta.mime_type = header_value
        end

        if header_name == 'Content-Disposition' then
            local filename = string.match(header_value, 'filename="([^"]+)"')
            meta.original_name = filename
        end
        
    --     local file_name = my_get_file_name(res)
    --     if file_name then
    --         file = io.open(file_name, "w+")
    --         if not file then
    --             ngx.say("failed to open file ", file_name)
    --             return
    --         end
    --     end

        elseif typ == "body" then
            ngx.say(cjson.encode(meta))

    --     if file then
    --         file:write(res)
    --         md5:update(res)
        -- end

    elseif typ == "part_end" then
    --     file:close()
    --     file = nil
    --     local md5_sum = md5:final()
    --     md5:reset()
    --     my_save_sha1_sum(md5_sum)

    elseif typ == "eof" then
        break

    -- else
    --     -- do nothing
    end
end

