local json = require 'http.json'
local socket = require 'http.socket-bind'

---@class LHttpApp
local App = {
    app = socket,
    config = {
        port = 3210,
        queue_size = 10,
    },
}
App.__index = App

function App:start()
    self.app:start(self.config)
end

function App:set_config(newConfig)
    self.config = newConfig
end

function App:handler(method, url, handler)
    self.app:register_handler(method, url, function(params, queries, headers, body)
        local context = self:_get_request_context(params, queries, headers, body)

        local result = handler(context)
        if result and type(result) == 'table' then
            result = json.encode(result)
        end

        if result and type(result) == 'boolean' then
            result = tostring(result)
        end

        context.res.result = result
        return context.res
    end)
end

function App:_get_request_context(params, queries, headers, body)
    return {
        req = {
            headers = headers,
            body = body,
            params = params or {},
            queries = queries or {},
        },
        res = {
            status = nil,
        },
    }
end

function App:_handler_result_string_convert(result)
    if type(result) == 'string' then
        return result
    end

    if type(result) == 'table' then
        return table.concat(result, ', ')
    end

    return tostring(result)
end

return App
