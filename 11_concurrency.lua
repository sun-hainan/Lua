-- ============================================================
-- 模块十一：并发编程
-- 线程/锁/同步/线程池/死锁
-- ============================================================

-- 【问题1】Lua 的协程（Coroutine）是什么？与线程的区别？
--
-- 协程：轻量级并发，协作式多任务
-- 与线程的区别：
--   - 线程：抢占式多任务（OS 调度）
--   - 协程：协作式多任务（主动让出）
--   - 协程只占用单个线程，无切换开销
--
-- 核心函数：
--   - coroutine.create(f)：创建协程
--   - coroutine.resume(co)：启动/恢复协程
--   - coroutine.yield()：挂起协程
--   - coroutine.status(co)：检查状态

local function coroutine_basics()
    -- 创建协程
    local co = coroutine.create(function(a, b)
        print("coroutine started:", a, b)
        local r = coroutine.yield("yielded value")  -- 挂起
        print("coroutine resumed with:", r)
        return "final return"
    end)

    print("status (suspended):", coroutine.status(co))

    -- 启动协程
    local ok, first_yield = coroutine.resume(co, 10, 20)
    print("resume result:", ok, first_yield)

    print("status (suspended after yield):", coroutine.status(co))

    -- 恢复协程（传入 yield 的返回值）
    ok, return_val = coroutine.resume(co, "resume value")
    print("resume result:", ok, return_val)

    print("status (dead):", coroutine.status(co))
end

coroutine_basics()

-- 【问题2】Lua 协程的生产者-消费者模式如何实现？
--
-- 协程天然适合生产者-消费者：
--   - 生产者：产生数据，yield
--   - 消费者：处理数据，resume

local function producer_consumer()
    -- 生产者（生成数据）
    local function producer(max)
        return coroutine.create(function()
            for i = 1, max do
                coroutine.yield(i)  -- 产生一个值
            end
        end)
    end

    -- 消费者（处理数据）
    local function consumer(prod)
        while true do
            local ok, value = coroutine.resume(prod)
            if not ok then break end  -- 生产者结束
            if value > 5 then break end  -- 处理到5停止
            print("consumed:", value)
        end
    end

    local p = producer(10)
    consumer(p)
end

producer_consumer()

-- 【问题3】Lua 的迭代器与协程如何结合？
--
-- 协程实现生成器（类似 Python 的 yield）
-- 每次 resume 产生一个值

local function coroutine_iterator()
    -- 用协程实现迭代器
    local function my_range(from, to)
        coroutine.yield(from)
        if from < to then
            my_range(from + 1, to)  -- 递归调用（尾调用）
        end
    end

    local function range(from, to)
        return coroutine.create(function()
            local function iterate(current, to)
                if current > to then return end
                coroutine.yield(current)
                iterate(current + 1, to)  -- 尾调用
            end
            iterate(from, to)
        end)
    end

    -- 使用迭代器
    for i in function()
        local co = range(1, 5)
        return coroutine.resume, co, nil
    end do
        print("iteration:", i)
    end

    -- 更简洁的方式：包装函数
    local function all_values(...)
        local args = {...}
        local index = 0
        return function()
            index = index + 1
            if index > #args then return nil end
            return args[index]
        end
    end

    for v in all_values(1, 2, 3, 4, 5) do
        print("value:", v)
    end
end

coroutine_iterator()

-- 【问题4】Lua 的多线程支持如何？（实际是协程）
--
-- 注意：标准 Lua 没有真正的多线程
-- 解决方案：
--   - 协程（单线程内的协作式多任务）
--   - LuaJIT 的 FFI 调用 pthread（需要 C 库）
--   - OpenResty 的 nginx worker（每个 worker 一个 Lua VM）
--
-- 协程 vs 线程：
--   - 协程：单线程，无竞态条件，无锁
--   - 线程：真并行，需要锁保护共享数据

local function threading_note()
    print("Lua 标准库不提供多线程支持")
    print("协程是协作式多任务，不是抢占式")
    print()
    print("实际方案：")
    print("  1. LuaJIT + FFI + pthread（真正的多线程）")
    print("  2. OpenResty（nginx 多 worker）")
    print("  3. LÖVE 游戏引擎（子线程）")
    print()
    print("对于大多数场景，协程足够")
end

threading_note()

-- 【问题5】Lua 协程如何模拟异步操作？
--
-- 异步操作包装成协程：
--   - 发起异步操作，yield 挂起
--   - 回调完成时，resume 恢复
--
-- 场景：模拟同步风格的异步代码

local function async_simulation()
    -- 模拟异步操作
    local function async_read(callback)
        -- 模拟延迟后调用回调
        local fake_data = "file content"
        callback(fake_data)
    end

    -- 用协程包装
    local function read_async(co, filename)
        async_read(function(data)
            coroutine.resume(co, data)
        end)
        return coroutine.yield()  -- 挂起，等待回调
    end

    local function async_main()
        local co = coroutine.create(function()
            local data = read_async(coroutine.running(), "test.txt")
            print("async result:", data)
        end)

        coroutine.resume(co)
    end

    print("async simulation with coroutine")
end

async_simulation()

-- 【问题6】Lua 的管道和过滤器模式如何实现？
--
-- 管道模式：用协程实现数据流
-- 过滤器模式：数据经过多个处理步骤

local function pipeline_pattern()
    -- 生成器（数据源）
    local function generate_numbers(n)
        return coroutine.create(function()
            for i = 1, n do
                coroutine.yield(i)
            end
        end)
    end

    -- 过滤器（处理数据）
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

    -- 消费者（收集结果）
    local function collect(co)
        local result = {}
        while true do
            local ok, val = coroutine.resume(co)
            if not ok then break end
            table.insert(result, val)
        end
        return result
    end

    -- 构建管道
    local nums = generate_numbers(10)
    local evens = filter(nums, function(n) return n % 2 == 0 end)
    local result = collect(evens)

    print("even numbers 1-10:", table.concat(result, ", "))
end

pipeline_pattern()

-- 【问题7】Lua 的状态机如何用协程实现？
--
-- 协程本身就是一个状态机：
--   - yield 切换状态
--   - resume 恢复执行
--
-- 场景：游戏 AI、解析器、状态转换

local function state_machine()
    local function state_machine_demo()
        local state = coroutine.create(function()
            while true do
                print("State: IDLE")
                coroutine.yield()

                print("State: LOADING")
                coroutine.yield()

                print("State: PROCESSING")
                coroutine.yield()

                print("State: COMPLETE")
                return  -- 结束状态机
            end
        end)

        return function()
            local ok, err = coroutine.resume(state)
            if not ok then
                print("state machine error:", err)
            end
            return coroutine.status(state) ~= "dead"
        end
    end

    local step = state_machine_demo()
    while step() do
        -- 模拟外部触发
        print("(external trigger)")
    end
end

state_machine()

-- 【问题8】Lua 协程的局限性和适用场景是什么？
--
-- 局限：
--   - 单线程，不能利用多核
--   - 一个协程阻塞，整个程序阻塞
--   - 没有内置的 sleep，需要手写
--
-- 适用场景：
--   - 迭代器/生成器
--   - 异步操作模拟
--   - 状态机
--   - 生产者-消费者

local function coroutine_limitations()
    print("协程局限：")
    print("  1. 单线程，无法利用多核 CPU")
    print("  2. 阻塞调用会阻塞整个程序")
    print("  3. 没有内置时间延迟")
    print()
    print("适合场景：")
    print("  1. 迭代器和生成器")
    print("  2. 状态机")
    print("  3. 异步编程（模拟）")
    print("  4. 生产者-消费者")
    print()
    print("不适合场景：")
    print("  1. CPU 密集型计算（应该用多进程）")
    print("  2. 真正的并行需求")
end

coroutine_limitations()

-- ============================================================
-- 【对比】Rust vs Lua vs Python 并发
-- ============================================================
-- Rust:
--   - std::thread 创建线程
--   - Arc<Mutex<T>> 共享数据
--   - mpsc channel 消息传递
--   - 编译时借用检查保证线程安全

-- Lua:
--   - 协程（Coroutine）是唯一并发机制
--   - 协作式多任务，单线程
--   - FFI + pthread 可实现真正多线程

-- Python:
--   - threading 模块（受 GIL 限制）
--   - multiprocessing 模块（绕过 GIL）
--   - asyncio（协程 + 事件循环）

function compare_concurrency()
    print("=== 三语言并发对比 ===")

    -- Rust: 真正的多线程，类型系统保证安全
    -- Lua: 协程是协作式，单线程
    -- Python: 有真正的线程（受 GIL 限制）

    print("Lua: coroutine is single-threaded cooperative multitasking")
    print("Python: asyncio + await for async, threading for real threads")
end

-- ============================================================
-- 练习题
-- ============================================================
-- 1. 用协程实现一个斐波那契数列生成器
-- 2. 用协程实现一个状态机（处理 HTTP 请求）
-- 3. 比较协程和线程的优缺点

-- ============================================================
-- 总结
-- ============================================================
-- | 特性       | Lua 实现                                    |
-- |-----------|-------------------------------------------|
-- | 创建协程   | coroutine.create(func)                     |
-- | 启动       | coroutine.resume(co, ...)                 |
-- | 挂起       | coroutine.yield(...)                       |
-- | 状态查询   | coroutine.status(co)                       |
-- | 当前协程   | coroutine.running()                        |
-- | 多线程     | Lua 标准库不支持，需要 FFI                 |

local function main()
    print("=== 模块十一：并发编程 ===")

    coroutine_basics()
    producer_consumer()
    coroutine_iterator()
    threading_note()
    async_simulation()
    pipeline_pattern()
    state_machine()
    coroutine_limitations()
    compare_concurrency()

    print("\n✅ 所有示例运行成功！")
end

main()