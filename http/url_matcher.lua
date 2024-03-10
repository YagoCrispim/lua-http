--- @class LHttpUrlMatcher 
local UrlMatcher = {}
UrlMatcher.__index = UrlMatcher

function UrlMatcher._split_url(url)
    local parts = {}
    for part in url:gmatch("([^/]+)") do
        table.insert(parts, part)
    end
    return parts
end

function UrlMatcher:_remove_query_params(url)
    local res = url:match("([^?]+)")
    return res
end

function UrlMatcher:_get_url_handler(method, url, handlers)
    local handlers_by_method = handlers[method]
    if not handlers_by_method then
        return nil
    end
    local possible_handlers = {}
    local urlParts = self._split_url(url)

    for route, handler in pairs(handlers_by_method) do
        local route_parts = self._split_url(handler.url)
        if #route_parts == #urlParts then
            local match = true
            for i, part in ipairs(route_parts) do
                if part:sub(1, 1) == "{" then
                    possible_handlers[route] = handler.handler
                elseif part ~= urlParts[i] then
                    match = false
                    break
                end
            end
            if match then
                possible_handlers = { url = handler.url, handler = handler.handler }
            end
        end
    end
    return possible_handlers
end

function UrlMatcher:_get_url_params(url, route)
    local req_url = url:match("([^?]+)")
    local url_parts = self._split_url(req_url)

    local route_url = route.url:match("([^?]+)")
    local route_parts = self._split_url(route_url)
    local params = {}
    for i, part in ipairs(route_parts) do
        if part:sub(1, 1) == "{" then
            local param_name = part:sub(2, -2)
            params[param_name] = url_parts[i]
        end
    end
    return params
end

function UrlMatcher:_get_query_params(url)
    local query = url:match("?(.+)")
    if not query then
        return {}
    end
    local params = {}
    for pair in query:gmatch("([^&]+)") do
        local key, value = pair:match("([^=]+)=([^=]+)")
        params[key] = value
    end
    return params
end

function UrlMatcher:get_handler(url, method, routes)
    method = method:upper()
    local handler = self:_get_url_handler(method, url, routes)

    if not handler or not handler.handler then
        return nil
    end

    local url_params = self:_get_url_params(url, handler)
    local query_params = self:_get_query_params(url)

    return {
        handler = handler.handler,
        params = url_params,
        queries = query_params
    }
end

return UrlMatcher
