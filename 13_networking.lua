-- ============================================================
-- 模块十三：网络编程
-- TCP/UDP/Socket/HTTP
-- ============================================================

-- 注意：标准 Lua 没有内置 socket，需要 luasocket 库
-- 以下示例展示概念，运行时需要安装 luasocket

-- 【问题1】Lua 的 socket 库如何安装和使用？
--
-- 安装：luarocks install luasocket
-- 使用：local socket = require("socket")

local function socket_basics()
    print("=== Socket 示例（需要 luasocket 库）===")
    print()

    --[[
    local socket = require("socket")

    -- TCP 客户端
    local tcp = socket.try(socket.connect("localhost", 80))
    socket.try(tcp:send("GET / HTTP/1.0\r\n\r\n"))
    local response = tcp:receive("*a")
    tcp:close()
    print(response)
    ]]

    print("luasocket 基本用法：")
    print("  local socket = require('socket')")
    print("  local tcp = socket.connect('host', port)")
    print("  local udp = socket.udp()")
end

socket_basics()

-- 【问题2】Lua 的 TCP 通信如何实现？
--
-- luasocket TCP 操作：
--   - socket.connect(host, port)：创建 TCP 连接
--   - sock:send(data)：发送数据
--   - sock:receive("*a")：接收所有数据
--   - sock:close()：关闭连接

local function tcp_demo()
    print("=== TCP 通信示例 ===")
    print()

    --[[ 实际运行需要 luasocket
    -- TCP 服务器
    local server = assert(socket.bind("*", 8080))
    server:settimeout(5)  -- 5秒超时

    local client = server:accept()
    if client then
        client:settimeout(10)
        local line = client:receive("*l")  -- 读取一行
        print("received:", line)
        client:send("Hello from server\n")
        client:close()
    end

    server:close()
    ]]

    print("TCP 服务器模式：")
    print("  server = socket.bind('*', port)")
    print("  client = server:accept()")
    print("  client:send() / client:receive()")
    print()
    print("TCP 客户端模式：")
    print("  tcp = socket.connect('host', port)")
    print("  tcp:send(data)")
    print("  response = tcp:receive('*a')")
end

tcp_demo()

-- 【问题3】Lua 的 UDP 通信如何实现？
--
-- UDP：无连接、不可靠、快速
-- 适合：DNS 查询、实时游戏

local function udp_demo()
    print("=== UDP 通信示例 ===")
    print()

    --[[
    -- UDP 套接字
    local udp = assert(socket.udp())
    udp:setpeername("localhost", 8080)

    -- 发送
    udp:send("hello")
    -- 接收
    local data, ip, port = udp:receivefrom()
    print("from", ip, ":", port, "=>", data)
    ]]

    print("UDP 模式：")
    print("  udp = socket.udp()")
    print("  udp:setpeername('host', port)")
    print("  udp:send(data)")
    print("  data, ip, port = udp:receivefrom()")
end

udp_demo()

-- 【问题4】Lua 的 HTTP 请求如何发送？
--
-- luasocket 提供 socket.http
-- 支持 GET/POST 等 HTTP 方法

local function http_demo()
    print("=== HTTP 请求示例 ===")
    print()

    --[[
    local http = require("socket.http")
    local ltn12 = require("socket.ltn12")

    -- GET 请求
    local response, status = http.request("http://example.com/")
    print("status:", status)
    print("response length:", #response)

    -- 带参数的 GET
    local response = http.request("http://example.com?key=value")

    -- POST 请求
    local request_body = "key1=value1&key2=value2"
    local response, status, headers = http.request{
        url = "http://example.com/post",
        method = "POST",
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
            ["Content-Length"] = #request_body,
        },
        source = ltn12.source.string(request_body),
        sink = ltn12.sink.table(response_body),
    }
    ]]

    print("socket.http 用法：")
    print("  local http = require('socket.http')")
    print("  local response, status = http.request('http://url')")
    print()
    print("POST 请求需要 ltn12 源/接收器")
end

http_demo()

-- 【问题5】Lua 的同步 vs 异步网络操作如何选择？
--
-- luasocket 是同步（阻塞）IO
-- 异步需要使用 lua-nginx（LÖVE 等）
--
-- 同步问题：
--   - 阻塞直到完成
--   - 长时间操作会卡住主线程
--
-- 异步方案：
--   - OpenResty（nginx + Lua）
--   - LÖVE 游戏引擎
--   - 自定义事件循环

local function sync_vs_async()
    print("=== 同步 vs 异步 ===")
    print()
    print("luasocket: 同步（阻塞）IO")
    print("  - 适合短操作")
    print("  - 长操作会卡住")
    print()
    print("异步方案：")
    print("  1. OpenResty（nginx worker）")
    print("  2. LÖVE 游戏引擎")
    print("  3. 自定义事件循环 + 协程")
    print()
    print("协程 + socket 模拟异步：")
    print("  - yield 挂起等待")
    print("  - receive/send 完成时 resume")
end

sync_vs_async()

-- 【问题6】Lua 的 URL 解析如何实现？
--
-- socket.url 提供 URL 解析
-- 解析协议、主机、端口、路径等

local function url_parsing()
    print("=== URL 解析示例 ===")
    print()

    --[[
    local url = require("socket.url")

    -- 解析 URL
    local parsed = url.parse("http://user:pass@example.com:8080/path?query=value")
    print("scheme:", parsed.scheme)
    print("host:", parsed.host)
    print("port:", parsed.port)
    print("path:", parsed.path)
    print("query:", parsed.query)
    print("user:", parsed.user)
    print("password:", parsed.password)

    -- 构造 URL
    local built = url.build(parsed)
    print("built URL:", built)

    -- 百分号编码
    local encoded = url.escape("hello world & 符号")
    print("encoded:", encoded)
    local decoded = url.unescape(encoded)
    print("decoded:", decoded)
    ]]

    print("socket.url 用法：")
    print("  url.parse('http://host:port/path')")
    print("  url.build(parsed_table)")
    print("  url.escape(str)")
    print("  url.unescape(str)")
end

url_parsing()

-- 【问题7】Lua 的 SMTP 邮件发送如何实现？
--
-- socket.smtp 发送邮件
-- 支持纯文本邮件

local function smtp_demo()
    print("=== SMTP 邮件示例 ===")
    print()

    --[[
    local smtp = require("socket.smtp")
    local mime = require("socket.mime")

    local from = "sender@example.com"
    local to = "receiver@example.com"
    local msg = {
        headers = {
            ["From"] = from,
            ["To"] = to,
            ["Subject"] = "Test email",
        },
        body = "Hello from Lua!",
    }

    local r, e = smtp.send{
        from = from,
        recipient = to,
        source = smtp.message(msg),
        server = "smtp.example.com",
    }
    ]]

    print("socket.smtp 用法：")
    print("  smtp.send{from, recipient, source, server}")
    print("  需要 MIME 库处理编码")
end

smtp_demo()

-- ============================================================
-- 【对比】Rust vs Lua vs Python 网络
-- ============================================================
-- Rust:
--   - 标准库提供 TcpListener/TcpStream/UdpSocket
--   - 异步需要 tokio/async-std

-- Lua:
--   - luasocket 提供 TCP/UDP/HTTP/SMTP
--   - 同步 IO，有异步方案

-- Python:
--   - socket 标准库支持 TCP/UDP
--   - urllib/requests 提供 HTTP
--   - asyncio 提供异步网络

function compare_networking()
    print("=== 三语言网络对比 ===")

    print()
    print("| 特性       | Rust              | Lua               | Python           |")
    print("|------------|-------------------|-------------------|------------------|")
    print("| TCP        | 标准库            | luasocket         | socket.stdlib    |")
    print("| UDP        | 标准库            | luasocket         | socket.stdlib    |")
    print("| HTTP       | reqwest           | luasocket.http    | requests         |")
    print("| 异步       | tokio             | OpenResty/协程    | asyncio          |")
end

-- ============================================================
-- 练习题
-- ============================================================
-- 1. 用 luasocket 实现一个 echo 服务器
-- 2. 实现一个 HTTP 客户端（带错误处理）
-- 3. 比较同步和异步 IO 的适用场景

-- ============================================================
-- 总结
-- ============================================================
-- | 功能       | Lua 实现                                    |
-- |-----------|-------------------------------------------|
-- | TCP       | luasocket（同步）                          |
-- | UDP       | luasocket                                  |
-- | HTTP      | socket.http / socket.http                  |
-- | URL       | socket.url                                 |
-- | SMTP      | socket.smtp                                |
-- | 异步      | 协程 + 自定义事件循环                       |

local function main()
    print("=== 模块十三：网络编程 ===")

    socket_basics()
    tcp_demo()
    udp_demo()
    http_demo()
    sync_vs_async()
    url_parsing()
    smtp_demo()
    compare_networking()

    print("\n✅ 所有示例运行成功！")
end

main()