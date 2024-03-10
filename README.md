# Lua HTTP - WIP

This is a small and simple HTTP-server written in Lua and depends on the LuaSocket library.
The project is a work in progress.

## Installation

- Install LuaSocket library on your system.
    - LuaSocket documentation: https://lunarmodules.github.io/luasocket/index.html
- Clone the repository to your local machine.

## Usage
The server listens on port 3210 by default, but you can change this by modifying the "set_config" method.

## Example

```lua
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
```

## Contributing
Contributions are welcome! If you find any bugs or want to suggest new features, please open an issue or submit a pull request.

## License
This project is licensed under the MIT License. See the LICENSE file for details.
