local opts = {
    redirect_uri = "/index.html",
    discovery = ngx.var.oidc_discovery_url,
    client_id = ngx.var.oidc_client_id,
    client_secret = ngx.var.oidc_client_secret,
    scope = "openid email profile",
    logout_path = "/logout",
    redirect_after_logout_uri = "/",
    renew_access_token_on_expiry = true,
    session_contents = {id_token=true, user=true, access_token=true}
}

local res, err = require("resty.openidc").authenticate(opts)

if err then
    ngx.status = 500
    ngx.say(res)
    ngx.say(err)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end