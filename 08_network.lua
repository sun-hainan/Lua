-- === 第8章 网络请求 ===

--[[
  本章目标：
  1. 理解socket.http的基本用法
  2. 理解LuaSocket库的组成
  3. 理解JSON解析（cjson）
  4. 理解简单HTTP请求的原理

  核心问题：
  Q1: TCP三次握手是什么？
  Q2: socket是什么？
  Q3: 为什么需要库来发HTTP请求？
  深入: HTTP协议/请求头/响应码
]]

-- ============================
-- Q1: TCP三次握手是什么？
-- ============================

-- TCP可靠连接的建立过程：
-- 1. 客户端发送SYN（同步请求）
-- 2. 服务器返回SYN-ACK（同步确认）
-- 3. 客户端发送ACK（确认）
-- 建立连接后开始传输数据

-- HTTP是应用层协议，基于TCP
-- HTTPS在TCP和HTTP之间加了一层SSL/TLS加密

-- LuaSocket的TCP socket帮助我们处理握手细节
-- 我们只需要关注发送和接收数据

-- ============================
-- Q2: socket是什么？
-- ============================

-- socket（套接字）：网络通信的端点
-- IP地址 + 端口号 唯一标识一个socket

-- 网络分层：
-- 应用层：HTTP, FTP, SMTP（我们写的代码）
-- 传输层：TCP, UDP（socket处理的）
-- 网络层：IP（路由器处理的）
-- 链路层：以太网（网卡处理的）

-- LuaSocket提供的socket类型：
-- socket.tcp()  创建TCP socket
-- socket.udp()  创建UDP socket
-- socket.http   HTTP客户端

-- 注意：以下代码需要LuaSocket库
-- luarocks install luasocket

-- 示例代码（需要库才能运行）：
--[[
local socket = require("socket")
local http = require("socket.http")

-- 简单GET请求
local response, status, headers = http.request("http://httpbin.org/get")
print("状态码:", status)
print("响应:", response)
]]

-- ============================
-- Q3: 为什么需要库来发HTTP请求？
-- ============================

-- HTTP协议很复杂，需要正确处理：
-- - 格式正确的请求行和请求头
-- - Chunked Transfer Encoding（分块传输）
-- - Keep-Alive（连接复用）
-- - 重定向处理
-- - Cookie管理

-- 用socket发送HTTP请求需要自己拼字符串
--[[
local tcp = socket.tcp()
tcp:connect("httpbin.org", 80)

local request = "GET /get HTTP/1.1\r\n" ..
    "Host: httpbin.org\r\n" ..
    "User-Agent: LuaSocket\r\n" ..
    "Connection: close\r\n" ..
    "\r\n"

tcp:send(request)

local response = ""
while true do
    local chunk, err = tcp:receive("*a")
    if not chunk then
        break
    end
    response = response .. chunk
end

tcp:close()
print("响应:", response)
]]

-- 用库就简单多了
--[[
local http = require("socket.http")
local response, status = http.request("http://httpbin.org/get")
]]

-- ============================
-- 深入: HTTP协议/请求头/响应码
-- ============================

-- HTTP请求格式：
-- 请求行：GET /path HTTP/1.1
-- 请求头：Header-Name: value
-- 空行
-- 请求体（可选，POST/PUT时）

-- HTTP响应格式：
-- 状态行：HTTP/1.1 200 OK
-- 响应头：Content-Type: application/json
-- 空行
-- 响应体

-- 常见状态码：
-- 200 OK - 成功
-- 301 Moved Permanently - 永久重定向
-- 302 Found - 临时重定向
-- 400 Bad Request - 请求语法错误
-- 401 Unauthorized - 需要认证
-- 403 Forbidden - 拒绝访问
-- 404 Not Found - 资源不存在
-- 500 Internal Server Error - 服务器内部错误
-- 502 Bad Gateway - 网关错误
-- 503 Service Unavailable - 服务不可用

-- 请求头示例：
-- Host: api.example.com
-- User-Agent: MyApp/1.0
-- Accept: application/json
-- Content-Type: application/json
-- Authorization: Bearer token
-- Content-Length: 123

-- ============================
-- 示例：模拟HTTP客户端
-- ============================

-- 简单的HTTP响应解析器
local function parseHttpResponse(response)
    local result = {
        statusLine = "",
        headers = {},
        body = ""
    }
    
    -- 按两个换行符分割header和body
    local headerEnd = response:find("\r\n\r\n")
    if not headerEnd then
        headerEnd = response:find("\n\n") or #response + 1
    end
    
    local headerSection
    if response:find("\r\n\r\n") then
        headerSection = response:sub(1, headerEnd - 1)
        result.body = response:sub(headerEnd + 4)
    else
        headerSection = response:sub(1, headerEnd - 1)
        result.body = response:sub(headerEnd + 2)
    end
    
    -- 解析状态行
    local firstLineEnd = headerSection:find("\n") or headerSection:find("\r")
    if firstLineEnd then
        result.statusLine = headerSection:sub(1, firstLineEnd - 1)
    end
    
    -- 解析headers
    for line in headerSection:gmatch("[^\r\n]+") do
        local key, value = line:match("^([%w%-]+):%s*(.+)$")
        if key then
            result.headers[key:lower()] = value
        end
    end
    
    -- 解析状态码
    result.status = tonumber(result.statusLine:match("HTTP/%d%.%d%s+(%d+)"))
    
    return result
end

-- 构建HTTP请求（模拟）
local function buildHttpRequest(method, path, host, headers, body)
    local request = string.format("%s %s HTTP/1.1\r\n", method, path)
    request = request .. string.format("Host: %s\r\n", host)
    
    if headers then
        for k, v in pairs(headers) do
            request = request .. string.format("%s: %s\r\n", k, v)
        end
    end
    
    if body then
        request = request .. string.format("Content-Length: %d\r\n", #body)
    end
    
    request = request .. "Connection: close\r\n"
    request = request .. "\r\n"
    
    if body then
        request = request .. body
    end
    
    return request
end

-- 模拟请求
print("--- HTTP请求构造演示 ---")
local request = buildHttpRequest("GET", "/api/users", "api.example.com", {
    Accept = "application/json",
    ["User-Agent"] = "LuaTutorial/1.0"
})
print("请求内容:")
print(request)

-- 模拟响应解析
local mockResponse = [[HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 45
Connection: close

{"users": [{"name": "Alice", "age": 25}]}]]

print("\n--- HTTP响应解析演示 ---")
local parsed = parseHttpResponse(mockResponse)
print("状态行:", parsed.statusLine)
print("状态码:", parsed.status)
print("Content-Type:", parsed.headers["content-type"])
print("响应体:", parsed.body)

-- JSON解析演示（LuaJSON或cjson）
--[[
local cjson = require("cjson")
local data = cjson.decode(parsed.body)
print(data.users[1].name)  -- "Alice"
]]

-- 自定义简单JSON解析（只支持简单对象）
local function simpleJsonDecode(json)
    -- 移除空白
    json = json:gsub("%s+", "")
    
    -- 解析对象
    if json:match("^{.+}=$") then
        local obj = {}
        local content = json:match("^%{(.+)}%$")
        for key, value in content:gmatch("(%w+):([^,]+)") do
            obj[key] = value:gsub('"', '')
        end
        return obj
    end
    
    return nil
end

print("\n简单JSON解析:")
print(simpleJsonDecode('{"name": "Alice", "age": 25}').name)

print("\n=== 第8章结束 ===")
