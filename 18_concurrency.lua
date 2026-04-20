-- === 第18章 并发与异步 ===

--[[
  本章目标：
  1. 理解多线程（llthreads/luajit threads）
  2. 理解非阻塞IO/select
  3. 理解事件循环概念
  4. 了解copas/socket.http异步

  核心问题：
  Q1: Lua线程安全吗？
  Q2: 为什么单线程更高效？
  Q3: 异步的本质是什么？
  深入: 事件驱动/回调地狱/Promise模式
]]

-- ============================
-- Q1: Lua线程安全吗？
-- ============================

-- Lua的核心库（基本类型、操作）不是线程安全的
-- 但单个Lua状态机（Lua_State）是线程隔离的

-- Lua的并发模型：
-- 1. 多协程 - 单线程协作式
-- 2. 多状态机 - 每个状态机独立
-- 3. OS线程 + LuaJIT FFI - 可以真正并行

-- llthreads示例（需要库）：
--[[
local llthreads = require("llthreads")
local thr = llthreads.new(function(a, b)
    local result = a + b
    return result
end, 10, 20)

thr:start()
local ok, result = thr:join()
print("线程结果:", result)
]]

-- ============================
-- Q2: 为什么单线程更高效？
-- ============================

-- 单线程 + 事件驱动（Event Loop）的优势：
-- 1. 无锁开销 - 不需要同步机制
-- 2. 上下文切换少 - 协程切换比线程切换快100倍
-- 3. 内存共享简单 - 避免复杂的状态管理

-- 单线程模型适合IO密集型：
-- - Web服务器（处理大量连接但计算少）
-- - 数据库驱动
-- - 游戏服务器（帧同步）

-- 缺点：计算密集型无法利用多核

-- ============================
-- Q3: 异步的本质是什么？
-- ============================

-- 同步：等待操作完成才继续
-- 异步：发起操作，不等待，继续执行，之后处理结果

-- 示例：同步vs异步
--[[
-- 同步
local data = http.request("http://example.com")  -- 阻塞等待
print(data)

-- 异步（非阻塞）
http.request("http://example.com", function(err, data)
    -- 回调函数在请求完成后执行
    print(data)
end)
print("不等待，立即执行")  -- 这行先执行
]]

-- ============================
-- 示例：事件循环模拟
-- ============================

local EventLoop = {}
EventLoop.__index = EventLoop

function EventLoop.new()
    return setmetatable({
        tasks = {},
        running = false
    }, EventLoop)
end

function EventLoop.schedule(self, delay, func, ...)
    -- 延迟执行的任务
    local task = {
        func = func,
        args = {...},
        executeAt = os.time() + (delay or 0),
        recurring = false
    }
    table.insert(self.tasks, task)
    return task
end

function EventLoop.scheduleRepeating(self, interval, func, ...)
    local task = {
        func = func,
        args = {...},
        interval = interval,
        executeAt = os.time() + interval,
        recurring = true
    }
    table.insert(self.tasks, task)
    return task
end

function EventLoop.run(self, duration)
    self.running = true
    local endTime = os.time() + (duration or 10)
    
    while self.running and os.time() < endTime do
        local now = os.time()
        local newTasks = {}
        local i = 1
        
        while i <= #self.tasks do
            local task = self.tasks[i]
            
            if task.executeAt <= now then
                -- 执行任务
                local ok, err = pcall(function()
                    task.func(table.unpack(task.args))
                end)
                
                if not ok then
                    print("任务错误:", err)
                end
                
                if task.recurring then
                    task.executeAt = now + task.interval
                    table.insert(newTasks, task)
                end
                
                table.remove(self.tasks, i)
            else
                i = i + 1
            end
        end
        
        -- 添加新任务
        for _, t in ipairs(newTasks) do
            table.insert(self.tasks, t)
        end
        
        -- 模拟事件循环的空转
        -- 真实环境会用 socket.select 或 epoll
    end
end

function EventLoop.stop(self)
    self.running = false
end

print("\n--- 事件循环示例 ---")
local loop = EventLoop.new()

loop:scheduleRepeating(1, function()
    print("每秒执行一次")
end)

loop:schedule(5, function()
    print("5秒后执行一次")
    loop:stop()
end)

loop:run(6)

-- ============================
-- 深入: 回调地狱/Promise模式
-- ============================

-- 回调地狱示例（嵌套回调）：
--[[
asyncOperation1(function(err, result1)
    if err then handleError(err) return end
    
    asyncOperation2(result1, function(err, result2)
        if err then handleError(err) return end
        
        asyncOperation3(result2, function(err, result3)
            if err then handleError(err) return end
            
            doSomething(result3)
        end)
    end)
end)
]]

-- Promise模式（链式调用）：
--[[
Promise.new(function(resolve, reject)
    asyncOperation1(resolve)
end)
:then(function(result1)
    return Promise2.new(resolve, reject)
end)
:then(function(result2)
    return Promise3.new(resolve, reject)
end)
:catch(function(err)
    handleError(err)
end)
]]

-- 协程简化异步：
--[[
local function asyncTask()
    local result1 = yield(promise1)
    local result2 = yield(promise2)
    local result3 = yield(promise3)
    return result3
end
]]

print("\n--- Promise模式示例 ---")

local Promise = {}
Promise.__index = Promise

function Promise.new(executor)
    return setmetatable({
        state = "pending",  -- pending, fulfilled, rejected
        value = nil,
        callbacks = {}
    }, Promise)
end

function Promise.resolve(value)
    return Promise.new(function(resolve)
        resolve(value)
    end)
end

function Promise.reject(reason)
    return Promise.new(function(_, reject)
        reject(reason)
    end)
end

function Promise:then(onFulfilled, onRejected)
    local self = self
    return Promise.new(function(resolve, reject)
        local function handle(callback, value)
            local ok, result = pcall(callback, value)
            if ok then
                resolve(result)
            else
                reject(result)
            end
        end
        
        if self.state == "fulfilled" then
            if onFulfilled then
                handle(onFulfilled, self.value)
            else
                resolve(self.value)
            end
        elseif self.state == "rejected" then
            if onRejected then
                handle(onRejected, self.value)
            else
                reject(self.value)
            end
        else
            table.insert(self.callbacks, {
                onFulfilled = onFulfilled,
                onRejected = onRejected,
                resolve = resolve,
                reject = reject
            })
        end
    end)
end

function Promise:catch(onRejected)
    return self:then(nil, onRejected)
end

print("\n=== 第18章结束 ===")
