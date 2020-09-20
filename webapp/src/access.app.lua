local opts = {
    discovery = ngx.var.oidc_discovery_url,
}

local res, err = require("resty.openidc").bearer_jwt_verify(opts)

if err or not res then
    ngx.status = 403
    ngx.say(err and err or "no access_token provided")
    ngx.exit(ngx.HTTP_FORBIDDEN)
end

ngx.var.access_token = res
