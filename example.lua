local app = require 'http.app'
local json = require 'http.json'

app:handler('get', '/', function()
    return 'Hello, world!'
end)

app:handler('get', '/json/{param}', function(ctx)
    local param = ctx.req.params['param']
    return { status = 'success', param = param }
end)

--[[
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"username":"xyz","password":"xyz"}' \
  http://localhost:3000/body
]]
app:handler('post', '/body', function(ctxt)
    local body = ctxt.req.body
    local headers = ctxt.req.headers

    print(json.encode(body))
    print('---')
    print(json.encode(headers))

    return 'ok'
end)

app:set_config({
    port = 3000,
    queue_size = 100
})
app:start()
