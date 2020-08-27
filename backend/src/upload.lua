local session = require 'resty.session'.open()
local upload = require 'resty.upload'
local cjson = require 'cjson'
local resty_md5 = require 'resty.md5'

local function process_upload(filename, meta, md5_sum)
    local username = session.data.id_token.preferred_username
    local handle = io.popen('exiftool -struct -b -j -d "%Y-%m-%d %H:%M:%S" -c "%.15f" '..filename)
    local output = handle:read("*a")
    handle.close()
    ngx.say(output)
    ngx.exit(ngx.HTTP_OK)
end

if not session.data or not session.data.id_token then
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

-- TODO: pass media root path, create username directory if not exists
--       get tempname, save file, read exif, rename file, create DB rec

local chunk_size = 4096
local form = upload:new(chunk_size)
if not form then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local md5 = resty_md5:new()
local file
local filename
local meta = {
    original_name = '',
    mime_type = ''
}
while true do
    local typ, res, err = form:read()

    if not typ then
        ngx.log(ngx.ERR, "Failed to read uploaded file: ", err)
        ngx.say(cjson.encode({
            message = "File upload failed, cannot process upload"
        }))
        ngx.exit(ngx.ERROR)
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
        
        filename = os.tmpname()
        file = io.open(filename, "w+")
        if not file then
            ngx.log(ngx.err, "Error during upload: cannot create temp file")
            ngx.say(cjson.encode({
                message = "File upload failed, unable to create file on server"
            }))
            ngx.exit(ngx.ERROR)
        end

    elseif typ == "body" then
        if file then
            file:write(res)
            md5:update(res)
        end

    elseif typ == "part_end" then
        file:close()
        file = nil
        local md5_sum = md5:final()
        md5:reset()
        process_upload(filename, meta, md5_sum)

    elseif typ == "eof" then
        break

    end
end

