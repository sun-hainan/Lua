-- === 第15章 协程 ===

--[[
  本章目标：
  1. 掌握coroutine.create/resume/yield
  2. 理解生产者消费者模式
  3. 区分协程和线程
  4. 理解协程状态

  核心问题：
  Q1: 协程为什么轻量？
  Q2: yield能暂停在哪？
  Q3: 线程和协程的区别？
  深入: 对称/非对称协程/调度器
]]

-- ============================
-- Q1: 协程为什么轻量？
-- ============================

-- 协程是用户态线程，由Lua运行时管理，不涉及操作系统调度
-- 切换协程只是保存/恢复少量的寄存器状态
-- 创建协程的开销远小于创建系统线程

local function demoCoroutine()
    print("--- 协程基础 ---")
    
    -- 创建协程：co是一个thread对象
    local co = coroutine.create(function()
        print("协程开始执行")
        coroutine.yield()  -- 暂停，返回主调者
        print("协程继续执行")
        return "协程结束"
    end)
    
    print("协程状态:", coroutine.status(co))  -- suspended
    
    -- resume启动协程
    print("\n第一次resume:")
    local ok, result = coroutine.resume(co)
    print("resume返回: ok=", ok, "result=", result)
    print("协程状态:", coroutine.status(co))  -- suspended
    
    -- 第二次resume
    print("\n第二次resume:")
    ok, result = coroutine.resume(co)
    print("resume返回: ok=", ok, "result=", result)
    print("协程状态:", coroutine.status(co))  -- dead
end

demoCoroutine()

-- ============================
-- Q2: yield能暂停在哪？
-- ============================

-- yield可以暂停在：
-- 1. 函数中间
-- 2. 嵌套函数中（yield会一直传递到最外层的resume）
-- 3. 被其他协程调用的函数中

local function nestedYield()
    print("  nestedYield开始")
    coroutine.yield("暂停信号")
    print("  nestedYield继续")
end

local function outerFunc()
    print("outerFunc开始")
    nestedYield()
    print("outerFunc继续")
end

print("\n--- yield嵌套示例 ---")
local co = coroutine.create(outerFunc)

print("第一次resume:")
local ok, msg = coroutine.resume(co)
print("  resume返回:", ok, msg)

print("第二次resume:")
ok, msg = coroutine.resume(co)
print("  resume返回:", ok, msg)

-- ============================
-- Q3: 线程和协程的区别？
-- ============================

-- 线程（系统线程）：
-- - 由操作系统调度
-- - 并行执行（多核利用）
-- - 切换开销大（内核态）
-- - 共享进程的内存空间，需要同步

-- 协程：
-- - 由应用程序调度（用户态）
-- - 协作式执行（非抢占）
-- - 切换开销小（用户态）
-- - 内存独立（但可共享数据）
-- - 单线程模型，无法利用多核

-- 协程适合的场景：
-- 1. 异步IO（事件驱动）
-- 2. 状态机
-- 3. 生产者-消费者模式

-- ============================
-- 示例：生产者消费者模式
-- ============================

local function producer()
    return coroutine.create(function(items)
        for i, item in ipairs(items) do
            coroutine.yield(item)  -- 生产一个item
        end
        return "done"  -- 生产完成
    end)
end

local function consumer(prod)
    local total = 0
    local count = 0
    while true do
        local ok, item = coroutine.resume(prod)
        if not ok then
            print("消费完成，共消费" .. count .. "个，总和=" .. total)
            break
        end
        total = total + item
        count = count + 1
        print("消费: " .. item)
    end
end

print("\n--- 生产者消费者 ---")
local prod = producer({10, 20, 30, 40, 50})
consumer(prod)

-- ============================
-- 深入：非对称协程
-- ============================

-- Lua的协程是非对称的（asymmetric）：
-- - resume：启动/恢复协程
-- - yield：挂起协程
-- 两者不对称，需要显式调用

-- 对称协程（一些语言有）：
-- - 所有协程等价
-- - 只有一个yield操作，参数是目标协程
-- - 协程可以直接切换到另一个协程

-- Lua的协程模型称为"半对称（semi-coroutine）"
-- 或"优先化协程（first-class coroutine）"

-- ============================
-- 示例：协程实现迭代器
-- ============================

local function rangeProducer(from, to)
    coroutine.yield(from)
    for i = from + 1, to do
        coroutine.yield(i)
    end
end

local function myRange(from, to)
    return coroutine.wrap(function()
        rangeProducer(from, to)
    end)
end

print("\n--- 协程迭代器 ---")
for i in myRange(1, 5) do
    print("  ", i)
end

-- 对比普通迭代器
local function myIpairs(arr)
    local i = 0
    return function()
        i = i + 1
        if i <= #arr then
            return i, arr[i]
        end
    end
end

local arr = {10, 20, 30}
print("\nmyIpairs:")
for i, v in myIpairs(arr) do
    print("  ", i, v)
end

-- ============================
-- 协程状态
-- ============================

print("\n--- 协程状态 ---")
-- coroutine.status(co)返回：
-- "running" - 正在运行（只能对当前协程调用）
-- "suspended" - 暂停
-- "normal" - 在另一个协程内运行
-- "dead" - 已结束

local co = coroutine.create(function()
    print("协程内部，状态:", coroutine.status(coroutine.running()))
    coroutine.yield()
    print("协程继续")
end)

print("创建后状态:", coroutine.status(co))
coroutine.resume(co)
print("yield后状态:", coroutine.status(co))
coroutine.resume(co)
print("结束后状态:", coroutine.status(co))

-- is_dead / is_yieldable (Lua 5.3+)
print("\nis_dead:", coroutine.isdead(co))
print("is_yieldable:", coroutine.isyiable(co))

print("\n=== 第15章结束 ===")
