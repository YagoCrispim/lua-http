local socket = require 'socket'
local json = require 'http.json'
local url_matcher = require 'http.url_matcher'

---@class LHttp
local Http = {
    server = {},
    backlog = 5,
    port = 3001,
    handlers = {
        GET = {},
        POST = {},
        PUT = {},
        DELETE = {},
        PATCH = {},
    },
}
Http.__index = Http

function Http:start(config)
    local pid = assert(io.popen("echo $PPID", "r"))
    local pid_number = pid:read("*a")
    pid:close()

    if config then
        self.port = config.port
        self.backlog = config.queue_size
    end

    self.server = assert(socket.tcp())
    assert(self.server:bind("*", self.port))
    self.server:listen(self.backlog)

    local ip, port = self.server:getsockname()
    print('Port: ' .. self.port .. " || PID: " .. pid_number)

    while 1 do
        local client, err = self.server:accept()
        if client then
            local req, client_err = client:receive()

            if not client_err then
                local method, url = req:match("([A-Z]+) ([^ ]+) HTTP/1.1")
                local r = self:_get_handler(url, method)

                if not r or not r.handler then
                    client:send(self:_get_response_status(404))
                    client:close()
                    return
                end

                local headers = self:_get_headers(client)
                local body = self:_get_body(headers, client)

                local result = r.handler(r.params, r.queries, headers, body)

                local code = result.status
                if not code then
                    code = 200
                end

                if result.result then
                    client:send(self:_get_response_status(code) .. result.result)
                else
                    local res = self:_get_response_status(code)
                    client:send(res)
                end
            end
            client:close()
        else
            print("Error happened while getting the connection.\nError: " .. err)
            client:close()
        end
    end
end

function Http:register_handler(method, url, handler)
    table.insert(self.handlers[string.upper(method)], { url = url, handler = handler })
end

function Http:_get_response_status(code)
    local base_response = 'HTTP/1.0 '
    local response = {
        [200] = base_response .. '200 OK\n\n',
        [201] = base_response .. '201 Created\n\n',
        [204] = base_response .. '204 No Content\n\n',
        [400] = base_response .. '400 Bad Request\n\n',
        [401] = base_response .. '401 Unauthorized\n\n',
        [403] = base_response .. '403 Forbidden\n\n',
        [404] = base_response .. '404 Not Found\n\n',
        [422] = base_response .. '422 Unprocessable Entity\n\n',
        [500] = base_response .. '500 Internal Server Error\n\n',
    }
    return response[code]
end

function Http:_get_handler(requestUrl, method)
    local result = url_matcher:get_handler(requestUrl, method, self.handlers)
    if not result then
        return nil
    end
    return result
end

function Http:_get_headers(client)
    local headers = ""
    while true do
        local line = client:receive()
        headers = headers .. line .. "\n"
        if line == "" then
            break
        end
    end

    local headers_table = {}
    for line in headers:gmatch("([^\n]+)") do
        local key, value = line:match("([^:]+): (.+)")
        headers_table[key] = value
    end
    return headers_table
end

function Http:_get_body(headers, client)
    local content_length = headers['Content-Length'] or headers['content-length']
    if not content_length then
        return nil
    end

    local length = tonumber(content_length)

    if length == 0 then
        return nil
    end

    local content = client:receive(length)

    local body = nil
    local content_type = headers['Content-Type'] or headers['content-type']

    if content_type == 'application/json' then
        body = json.decode(content)
    end

    return body
end

return Http
