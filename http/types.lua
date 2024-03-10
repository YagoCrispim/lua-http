---@class LHttpServerConfig
---@field port number
---@field queue_size number

---@alias LHttpHandler
--- |fun(params: table, queries: table, headers: table, body: string | nil): any

---@class LHttp
---@field server table
---@field backlog number
---@field port number
---@field handlers table
---@field start fun(self: LHttp, config: LHttpServerConfig | nil)
---@field register_handler fun(self: LHttp, method: string, url: string, handler: LHttpHandler)
---@field _get_headers fun(self: LHttp, client: table): table
---@field _get_body fun(self: LHttp, headers: table, client: table): string | nil
---@field _get_handler fun(self: LHttp, requestUrl: string, method: string): LHttpUrlMatcherResult | nil
---@field _get_response_status fun(self: LHttp, code: number): string

--

---@class LHttpUrlMatcherResult
---@field handler LHttpHandler
---@field params table
---@field queries table

---@class LHttpUrlMatcher
---@field get_handler fun(self: LHttpUrlMatcher, url: string, method: string, routes: table): LHttpUrlMatcherResult | nil
---@field _split_url fun(url: string): table
---@field _remove_query_params fun(self: LHttpUrlMatcher, url: string): string
---@field _get_url_handler fun(self: LHttpUrlMatcher, method: string, url: string, handlers: table): table | nil
---@field _get_url_params fun(self: LHttpUrlMatcher, url: string, route: table): table
---@field _get_query_params fun(self: LHttpUrlMatcher, url: string): table

--

---@class LHttpAppReqContext
---@field req { headers: table, body: string, params: table, queries: table }
---@field res { status: number | nil, result: string }

---@alias LHttpAppReqHandler
--- | fun(ctxt: LHttpAppReqContext): any

---@class LHttpApp
---@field app LHttp
---@field config LHttpServerConfig
---@field start fun(self: LHttpApp)
---@field handler fun(self: LHttpApp, method: string, url: string, handler: LHttpAppReqHandler)
---@field set_config fun(self: LHttpApp, newConfig: table)
---@field _handler_result_string_convert fun(self: LHttpApp, result: any): string
---@field _get_request_context fun(self: LHttpApp, params: table, queries: table, headers: table, body: string | nil): LHttpAppReqContext
