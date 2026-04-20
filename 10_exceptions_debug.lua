-- ============================================================
-- 模块十：异常处理与调试
-- 异常分类/自定义/断点/日志
-- ============================================================

-- 【问题1】Lua 的错误处理机制是什么？
--
-- Lua 错误处理：
--   - error(message, level)：抛出错误
--   - assert(condition, message)：断言
--   - pcall(func, ...)：保护调用（Protected Call）
--   - xpcall(func, errhandler)：带错误处理器的保护调用
--
-- 与 Rust 的区别：
--   - Rust 有类型化的 Result，Lua 错误是普通值
--   - Rust 区分可恢复/不可恢复，Lua 用 error 和 pcall

local function error_handling()
    -- error
    local function divide(a, b)
        if b == 0 then
            error("division by zero", 2)  -- level=2 表示调用者级别
        end
        return a / b
    end

    -- pcall（保护调用）
    local success, result = pcall(function()
        return divide(10, 0)
    end)

    if not success then
        print("caught error:", result)
    end

    -- assert
    local function get_element(arr, i)
        assert(i > 0, "index must be positive")
        assert(i <= #arr, "index out of bounds")
        return arr[i]
    end

    local arr = {1, 2, 3}
    local ok, err = pcall(function()
        return get_element(arr, 10)
    end)
    if not ok then
        print("assert failed:", err)
    end
end

error_handling()

-- 【问题2】Lua 的错误类型和错误值如何设计？
--
-- Lua 没有类型化错误，所有错误都是普通值
-- 约定：错误描述用字符串，失败结果用 nil + 错误消息

local function error_design()
    -- 约定：返回 nil + 错误消息
    local function try_parse(s)
        local n = tonumber(s)
        if n then
            return n, nil  -- 成功：值 + nil
        else
            return nil, "not a number"  -- 失败：nil + 错误
        end
    end

    local ok, err = try_parse("123")
    print("parse '123':", ok, err)

    ok, err = try_parse("abc")
    print("parse 'abc':", ok, err)

    -- 复杂的错误对象
    local function custom_error(code, message)
        return {
            code = code,
            message = message,
            __tostring = function(self)
                return string.format("[%d] %s", self.code, self.message)
            end
        }
    end

    local err_obj = custom_error(404, "Not Found")
    print("custom error:", tostring(err_obj))
end

error_design()

-- 【问题3】Lua 如何调试？print 调试 vs debug 库？
--
-- 调试方法：
--   1. print 调试（简单直接）
--   2. debug 库（强大但慢）
--   3. 断言（防御性编程）
--   4. 日志模块

local function debug_demo()
    -- print 调试
    local function debug_print(...)
        local args = {...}
        for i, v in ipairs(args) do
            print(string.format("[DEBUG] %s", tostring(v)))
        end
    end

    debug_print("variable x =", 42)

    -- debug 库基本用法
    -- debug.getinfo(func) 获取函数信息
    -- debug.getlocal(level, local) 获取局部变量
    -- debug.setlocal(level, local, value) 设置局部变量
    -- debug.traceback() 获取调用栈

    -- traceback
    local function deep_function(n)
        if n <= 0 then
            print(debug.traceback("stack traceback"))
            return
        end
        deep_function(n - 1)
    end

    deep_function(3)

    -- 获取函数信息
    local function my_func() end
    local info = debug.getinfo(my_func)
    print("function info:",
        "name:", info.name,
        "source:", info.source,
        "linedefined:", info.linedefined)
end

debug_demo()

-- 【问题4】Lua 的日志系统如何实现？
--
-- 简单日志：
--   print("[INFO] message")
--   io.stderr:write("[ERROR] message\n")
--
-- 格式化日志：
--   - 时间戳
--   - 日志级别
--   - 输出到文件

local function logging_demo()
    -- 简单日志级别
    local LOG = {
        DEBUG = 1,
        INFO = 2,
        WARN = 3,
        ERROR = 4,
    }

    local current_level = LOG.DEBUG

    local function log(level, message)
        if level < current_level then return end

        local level_name = {
            [LOG.DEBUG] = "DEBUG",
            [LOG.INFO] = "INFO",
            [LOG.WARN] = "WARN",
            [LOG.ERROR] = "ERROR",
        }

        local timestamp = os.date("%Y-%m-%d %H:%M:%S")
        local line = string.format("[%s] [%s] %s\n",
            timestamp, level_name[level], message)

        -- 输出到 stderr
        io.stderr:write(line)

        -- 可选：写入文件
        -- local file = io.open("app.log", "a")
        -- file:write(line)
        -- file:close()
    end

    log(LOG.DEBUG, "debug message")
    log(LOG.INFO, "info message")
    log(LOG.WARN, "warning message")
    log(LOG.ERROR, "error message")
end

logging_demo()

-- 【问题5】Lua 的单元测试框架如何使用？
--
-- 常用测试框架：
--   - busted（BDD 风格）
--   - luaunit
--
-- 基本断言：
--   - assert(condition)
--   - assert_equal(expected, actual)
--   - assert_not_equal(...)
--   - assert_nil(value)
--   - assert_true(value)
--   - assert_false(value)

local function unit_test_demo()
    -- 手写简单测试
    local function assert(condition, message)
        if not condition then
            error("Assertion failed: " .. (message or ""))
        end
    end

    local function assert_equal(expected, actual, msg)
        if expected ~= actual then
            error(string.format("Expected %s but got %s%s",
                tostring(expected), tostring(actual),
                msg and ": " .. msg or ""))
        end
    end

    -- 测试示例
    local function test_basic()
        local function add(a, b) return a + b end

        assert_equal(5, add(2, 3), "basic addition")
        assert_equal(0, add(-1, 1), "negative numbers")
        print("basic tests passed")
    end

    test_basic()
end

unit_test_demo()

-- 【问题6】Lua 的性能测量如何实现？
--
-- os.clock() 返回 CPU 时间
-- os.time() 返回日历时间
-- 多次测量取平均

local function profiling_demo()
    -- CPU 时间测量
    local function measure_cpu(func, ...)
        local start = os.clock()
        func(...)
        local elapsed = os.clock() - start
        return elapsed
    end

    -- 测量循环性能
    local function benchmark(name, func, iterations)
        iterations = iterations or 1000000
        local start = os.clock()
        for i = 1, iterations do
            func(i)
        end
        local elapsed = os.clock() - start
        local per_op = (elapsed / iterations) * 1e6  -- 微秒
        print(string.format("%s: %.2f sec for %d iterations (%.3f us/op)",
            name, elapsed, iterations, per_op))
    end

    -- 示例
    benchmark("table insert", function(i)
        local t = {}
        table.insert(t, i)
    end)

    benchmark("table index", function(i)
        local t = {100}
        local v = t[1]
    end)
end

profiling_demo()

-- 【问题7】Lua 如何检查内存泄漏？
--
-- collectgarbage() 强制垃圾回收
-- debug.getregistry() 查看注册表
-- 弱表帮助避免循环引用

local function memory_leak_demo()
    -- 强制 GC
    print("memory stats:")
    collectgarbage("collect")
    print("count:", collectgarbage("count"))
    print("step:", collectgarbage("step"))

    -- 内存泄漏例子
    local leaks = {}
    local function create_leak()
        -- 每次调用都添加，导致内存持续增长
        table.insert(leaks, {"data", os.time()})
    end

    -- 如果不清理，leaks 表会一直增长
    -- 在生产代码中要注意及时清理

    -- 清理
    leaks = nil
    collectgarbage("collect")

    -- 弱表检测泄漏
    local leak_detector = setmetatable({}, {__mode = "v"})
    leak_detector[{}] = "some data"
    print("weak table size:", #leak_detector)  -- 被 GC 了
end

memory_leak_demo()

-- ============================================================
-- 【对比】Rust vs Lua vs Python 异常
-- ============================================================
-- Rust:
--   - panic! 用于不可恢复错误
--   - Result<T, E> 用于可恢复错误
--   - Option<T> 用于可能不存在的值
--   - ? 运算符早期返回

-- Lua:
--   - error() 抛出错误
--   - pcall/xpcall 捕获错误
--   - 没有类型化的错误，所有错误都是普通值
--   - nil 表示空值

-- Python:
--   - try/except/finally 处理异常
--   - raise 抛出异常
--   - 有 else 子句
--   - Exception 类支持继承

function compare_exceptions()
    print("=== 五语言异常处理对比 ===")

    -- Lua: error()/pcall/xpcall，无类型化错误
    -- Python: try/except/raise
    -- Rust: panic!/Result/Option，? 运算符早期返回
    -- Go: panic/recover 配合 defer，无类型化异常
    -- C++: throw/try/catch，noexcept 指定不抛异常
end

-- ============================================================
-- 【练习题】
-- ============================================================
-- 1. 实现一个 try-catch 模拟函数：try_catch(try_fn, catch_fn)，用 pcall 实现
-- 2. 实现一个带日志级别的日志系统（DEBUG/INFO/WARN/ERROR），支持输出到文件
-- 3. 编写完整的测试用例验证冒泡排序的正确性（各种边界情况）
-- 4. 用 os.clock() 实现一个性能测量工具 measure(func, iterations)，返回执行时间
-- 5. 用 debug.getinfo 打印一个函数的定义行号、源文件、参数信息

-- ============================================================
-- 总结
-- ============================================================
-- | 功能       | Lua 实现                                    |
-- |-----------|-------------------------------------------|
-- | 抛出错误   | error(message, level)                     |
-- | 断言       | assert(condition, message)                |
-- | 保护调用   | pcall(func, ...)                          |
-- | 错误处理器 | xpcall(func, errhandler)                  |
-- | 调试       | debug 库、print 语句                       |
-- | GC         | collectgarbage()                          |

local function main()
    print("=== 模块十：异常处理与调试 ===")

    error_handling()
    error_design()
    debug_demo()
    logging_demo()
    unit_test_demo()
    profiling_demo()
    memory_leak_demo()
    compare_exceptions()

    print("\n✅ 所有示例运行成功！")
end

main()