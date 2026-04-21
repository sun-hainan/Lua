-- ============================================================
-- 模块十七：信息分发与事件系统
-- 观察者/EventEmitter/信号槽/消息队列/中间件
-- ============================================================

-- 【问题1】Lua 的观察者模式（Observer Pattern）如何实现？
--
-- 观察者模式：主题维护观察者列表，状态变化时通知
-- 发布-订阅（pub/sub）是变体

local function observer_pattern()
    -- 观察者接口
    local Observer = {
        update = function(self, event) end,
    }

    -- 具体观察者
    local Logger = setmetatable({}, {__index = Observer})
    function Logger:update(event)
        print("[LOG]", event.message, "at", event.timestamp)
    end

    local EmailNotifier = setmetatable({}, {__index = Observer})
    function EmailNotifier:update(event)
        print("[EMAIL] Would send:", event.message)
    end

    -- 主题
    local EventSubject = {}
    function EventSubject:new()
        return setmetatable({
            observers = {},
        }, {__index = self})
    end

    function EventSubject:subscribe(observer)
        table.insert(self.observers, observer)
    end

    function EventSubject:unsubscribe(index)
        table.remove(self.observers, index)
    end

    function EventSubject:notify(event)
        for _, observer in ipairs(self.observers) do
            observer:update(event)
        end
    end

    function EventSubject:publish(message)
        local event = {
            message = message,
            timestamp = os.date("%H:%M:%S"),
        }
        self:notify(event)
    end

    -- 使用
    local subject = EventSubject:new()
    subject:subscribe(Logger)
    subject:subscribe(EmailNotifier)

    subject:publish("User logged in")
    subject:publish("Order placed")
end

observer_pattern()

-- 【问题2】Lua 的 EventEmitter（事件发射器）如何实现？
--
-- 类似 Node.js 的事件系统
-- 支持任意事件类型、多个监听器

local function event_emitter()
    local EventEmitter = {}

    function EventEmitter:new()
        return setmetatable({
            listeners = {},
        }, {__index = self})
    end

    function EventEmitter:on(event, handler)
        if not self.listeners[event] then
            self.listeners[event] = {}
        end
        table.insert(self.listeners[event], handler)
    end

    function EventEmitter:once(event, handler)
        local wrapped = function(...)
            handler(...)
            self:remove_listener(event, wrapped)
        end
        self:on(event, wrapped)
    end

    function EventEmitter:emit(event, ...)
        if self.listeners[event] then
            for _, handler in ipairs(self.listeners[event]) do
                handler(...)
            end
        end
    end

    function EventEmitter:remove_listener(event, handler)
        if self.listeners[event] then
            for i, h in ipairs(self.listeners[event]) do
                if h == handler then
                    table.remove(self.listeners[event], i)
                    break
                end
            end
        end
    end

    function EventEmitter:remove_all(event)
        self.listeners[event] = nil
    end

    -- 使用
    local emitter = EventEmitter:new()

    emitter:on("data", function(data)
        print("handler1 got:", data)
    end)

    emitter:on("data", function(data)
        print("handler2 got:", data)
    end)

    emitter:emit("data", "hello world")

    emitter:once("single", function()
        print("This fires only once")
    end)
    emitter:emit("single")
    emitter:emit("single")  -- 不触发
end

event_emitter()

-- 【问题3】Lua 的信号槽（Signal/Slot）机制是什么？
--
-- 信号槽：类似 Qt 的信号与槽
-- 信号发射时自动调用连接的槽函数

local function signal_slot()
    print("=== 信号槽机制 ===")
    print()

    print("在 Lua 中实现：")
    print("  - Signal 类：存储槽函数")
    print("  - connect() 连接槽")
    print("  - disconnect() 断开")
    print("  - emit() 发射信号")

    -- 信号类实现
    local Signal = {}
    function Signal:new()
        return setmetatable({
            slots = {},
        }, {__index = self})
    end

    function Signal:connect(slot)
        table.insert(self.slots, slot)
    end

    function Signal:disconnect(slot)
        for i, s in ipairs(self.slots) do
            if s == slot then
                table.remove(self.slots, i)
                break
            end
        end
    end

    function Signal:emit(...)
        for _, slot in ipairs(self.slots) do
            slot(...)
        end
    end

    -- 使用
    local clicked = Signal:new()

    local function on_click()
        print("button clicked!")
    end

    clicked:connect(on_click)
    clicked:emit()
end

signal_slot()

-- 【问题4】Lua 的消息队列如何实现？
--
-- 消息队列：生产者-消费者模式
-- 队列操作：enqueue/dequeue
-- 可以用协程实现异步处理

local function message_queue()
    -- 简单队列
    local function create_queue()
        return {
            data = {},
            head = 1,
        }
    end

    local function enqueue(q, item)
        table.insert(q.data, item)
    end

    local function dequeue(q)
        if q.head > #q.data then
            return nil
        end
        local item = q.data[q.head]
        q.head = q.head + 1
        return item
    end

    local function is_empty(q)
        return q.head > #q.data
    end

    -- 生产者
    local function producer(q, items)
        for _, item in ipairs(items) do
            enqueue(q, item)
            print("produced:", item)
        end
    end

    -- 消费者
    local function consumer(q)
        while true do
            local item = dequeue(q)
            if item == nil then
                break
            end
            print("consumed:", item)
        end
    end

    local q = create_queue()
    producer(q, {"task1", "task2", "task3"})
    consumer(q)

    -- 带优先级的队列
    print()
    print("Priority Queue:")
    local function create_priority_queue()
        return {}
    end

    local function pq_enqueue(q, priority, item)
        table.insert(q, {priority = priority, item = item})
        -- 按优先级排序（简单插入排序）
        for i = #q, 2, -1 do
            if q[i].priority < q[i-1].priority then
                q[i], q[i-1] = q[i-1], q[i]
            end
        end
    end

    local function pq_dequeue(q)
        return table.remove(q, 1)
    end

    local pq = create_priority_queue()
    pq_enqueue(pq, 3, "low priority")
    pq_enqueue(pq, 1, "high priority")
    pq_enqueue(pq, 2, "medium priority")

    while #pq > 0 do
        local item = pq_dequeue(pq)
        print(item.priority, item.item)
    end
end

message_queue()

-- 【问题5】Lua 的中间件（Middleware）模式是什么？
--
-- 中间件：链式处理请求
-- 每个处理器可以修改、传递或终止请求
--
-- 场景：Web 框架（如 OpenResty）

local function middleware_pattern()
    print("=== 中间件模式 ===")
    print()

    print("中间件链：")
    print("Request → Logger → Auth → Handler")
    print("                  ↓")
    print("               拒绝")
    print()

    -- 中间件实现
    local function create_pipeline()
        local middlewares = {}
        return {
            use = function(self, mw)
                table.insert(middlewares, mw)
            end,
            execute = function(self, context, final_handler)
                local function run(index)
                    if index > #middlewares then
                        return final_handler(context)
                    end
                    local mw = middlewares[index]
                    mw(context, function()
                        return run(index + 1)
                    end)
                end
                return run(1)
            end,
        }
    end

    -- 创建中间件
    local function logger_middleware(ctx, next)
        print("LOG: before")
        next()
        print("LOG: after")
    end

    local function auth_middleware(ctx, next)
        if ctx.authenticated then
            print("AUTH: ok")
            next()
        else
            print("AUTH: denied")
        end
    end

    local function handler(ctx)
        print("HANDLER: processing", ctx.path)
    end

    -- 使用
    local pipeline = create_pipeline()
    pipeline:use(logger_middleware)
    pipeline:use(auth_middleware)

    print("--- request with auth ---")
    pipeline:execute({path = "/api", authenticated = true}, handler)

    print()
    print("--- request without auth ---")
    pipeline:execute({path = "/api", authenticated = false}, handler)
end

middleware_pattern()

-- 【问题6】Lua 的 Actor 模型如何实现？
--
-- Actor：独立执行单元，消息驱动
-- 每个 Actor 有自己的状态，通过消息通信
-- Lua 中可以用协程模拟

local function actor_model()
    print("=== Actor 模型示例 ===")
    print()

    -- Actor 实现
    local function create_actor(behavior)
        local mailbox = {}
        local running = true

        local actor = {
            send = function(self, msg)
                table.insert(mailbox, msg)
            end,
            run = function(self)
                while running do
                    if #mailbox > 0 then
                        local msg = table.remove(mailbox, 1)
                        if msg == "STOP" then
                            running = false
                        else
                            behavior(msg)
                        end
                    end
                end
            end,
        }

        return actor
    end

    -- 创建 Actor
    local counter_actor = create_actor(function(msg)
        if msg.type == "increment" then
            counter_actor.state = (counter_actor.state or 0) + 1
            print("count:", counter_actor.state)
        elseif msg.type == "get" then
            print("current count:", counter_actor.state or 0)
        end
    end)

    -- 发送消息
    counter_actor:send({type = "increment"})
    counter_actor:send({type = "increment"})
    counter_actor:send({type = "get"})
    counter_actor:send({type = "increment"})
    counter_actor:send({type = "get"})
end

actor_model()

-- 【问题7】Lua 的响应式编程（Reactive）如何实现？
--
-- 响应式：数据流 + 声明式转换
-- 用协程实现生成器/流

local function reactive_stream()
    print("=== 响应式流示例 ===")
    print()

    -- 简单生成器（类似 Python 的 generator）
    local function range(from, to)
        return coroutine.create(function()
            for i = from, to do
                coroutine.yield(i)
            end
        end)
    end

    -- 映射
    local function map(co, func)
        return coroutine.create(function()
            while true do
                local ok, val = coroutine.resume(co)
                if not ok then break end
                coroutine.yield(func(val))
            end
        end)
    end

    -- 过滤
    local function filter(co, predicate)
        return coroutine.create(function()
            while true do
                local ok, val = coroutine.resume(co)
                if not ok then break end
                if predicate(val) then
                    coroutine.yield(val)
                end
            end
        end)
    end

    -- 收集
    local function collect(co)
        local result = {}
        while true do
            local ok, val = coroutine.resume(co)
            if not ok then break end
            table.insert(result, val)
        end
        return result
    end

    -- 使用
    local numbers = range(1, 10)
    local evens = filter(numbers, function(n) return n % 2 == 0 end)
    local doubled = map(evens, function(n) return n * 2 end)
    local result = collect(doubled)

    print("evens doubled:", table.concat(result, ", "))
end

reactive_stream()

-- 【问题8】Lua 的事件总线（Event Bus）如何实现？
--
-- 事件总线：中心化的发布-订阅
-- 所有组件可以注册监听事件

local function event_bus()
    -- 事件总线实现
    local EventBus = {}

    function EventBus:new()
        return setmetatable({
            subscribers = {},
        }, {__index = self})
    end

    function EventBus:subscribe(event_type, handler)
        if not self.subscribers[event_type] then
            self.subscribers[event_type] = {}
        end
        table.insert(self.subscribers[event_type], handler)
    end

    function EventBus:publish(event_type, data)
        if self.subscribers[event_type] then
            for _, handler in ipairs(self.subscribers[event_type]) do
                handler(data)
            end
        end
    end

    -- 使用
    local bus = EventBus:new()

    bus:subscribe("user.logged_in", function(data)
        print("Analytics: user", data.user_id, "logged in")
    end)

    bus:subscribe("order.placed", function(data)
        print("Shipping: prepare order", data.order_id)
    end)

    bus:publish("user.logged_in", {user_id = 123})
    bus:publish("order.placed", {order_id = 456})
end

event_bus()

-- ============================================================
-- 【对比】Lua vs Python vs Rust vs Go vs C++ 事件系统
-- ============================================================
-- Rust:
--   - 观察者：trait + Box<dyn Observer>
--   - EventEmitter：HashMap<String, Vec<Box<dyn Fn>>>

-- Lua:
--   - 表 + 函数实现事件系统
--   - 协程实现异步流

-- Python:
--   - asyncio：异步流
--   - blinker：信号/事件

function compare_event_systems()
    print("=== 五语言事件系统对比 ===")
    print()
    print("| 特性          | Rust       | Python        | Lua           | Go             | C++             |")
    print("|---------------|------------|---------------|---------------|----------------|-----------------|")
    print("| 发布-订阅     | 自定义     | blinker       | table 模拟   | 自定义         | 观察者模式手写 |")
    print("| 信号/槽       | 无原生     | 无原生        | 无原生       | 无原生         | Qt 信号槽      |")
    print("| 异步流        | futures    | asyncio       | 协程         | channels       | boost::asio     |")
    print("| Actor 模型    | actix      | thespian      | 自定义       | -              | -               |")
end

-- ============================================================
-- 【练习题】
-- ============================================================
-- 1. 实现一个带 once 功能的事件发射器：once(event, handler) 只触发一次后自动移除
-- 2. 实现一个线程安全的 EventBus，支持 subscribe/unsubscribe/publish，内部用协程队列
-- 3. 用协程实现一个 channel（通道）：create_channel(buffer_size)，支持 send 和 receive 操作
-- 4. 实现一个带中间件的 HTTP 请求处理管道，包含日志、认证、限流三个中间件
-- 5. 用 Actor 模型实现一个简单的银行转账系统，支持 deposit/withdraw/transfer 操作

-- ============================================================
-- 总结
-- ============================================================
-- | 模式       | Lua 实现                                    |
-- |-----------|-------------------------------------------|
-- | 观察者     | 表 + 函数列表                              |
-- | EventEmitter | 表 + 事件映射                          |
-- | 信号槽     | 表 + 连接/断开方法                        |
-- | 消息队列   | 表（数组）+ enqueue/dequeue              |
-- | 中间件     | 函数链 + next 回调                        |
-- | Actor      | 表 + 邮箱队列 + 行为函数                   |
-- | 事件总线   | 中心化订阅表                               |

local function main()
    print("=== 模块十七：信息分发与事件系统 ===")

    observer_pattern()
    event_emitter()
    signal_slot()
    message_queue()
    middleware_pattern()
    actor_model()
    reactive_stream()
    event_bus()
    compare_event_systems()

    print("\n✅ 所有示例运行成功！")
end

main()