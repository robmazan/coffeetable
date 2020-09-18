local cjson = require('cjson')
local upload_service = {}

function upload_service.read_exif(filename)
    local handle = io.popen('exiftool -struct -b -j -d "%Y-%m-%d %H:%M:%S" -c "%.15f" '..filename)
    local output = handle:read("*a")
    handle.close()
    return cjson.decode(output)[1]
end

return upload_service
