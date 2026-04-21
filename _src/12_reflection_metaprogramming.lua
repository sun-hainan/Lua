-- ============================================================
-- 模块十二：反射与元编程
-- 动态创建/注解/动态代码执行
-- ============================================================

-- 【问题1】Lua 的运行时类型信息（RTTI）如何实现？
--
-- Lua 动态类型，所有值都有元信息
-- type() 返回值的类型名字符串
--
-- 元表（metatable）提供行为扩展

local function type_inspection()
    -- type() 函数
    print("type of 42:", type(42))
    print("type of 'hello':", type('hello'))
    print("type of nil:", type(nil))
    print("type of {}", type({}))
    print("type of function:", type(function() end))

    -- type 检查
    local function print_type(val)
        print(type(val), "=", val)
    end

    -- 多态函数
    local function process(val)
        local t = type(val)
        if t == "number" then
            print("processing number:", val * 2)
        elseif t == "string" then
            print("processing string:", val .. val)
        elseif t == "table" then
            print("processing table:", next(val) or "empty")
        elseif t == "function" then
            print("processing function:", val())
        else
            print("processing other:", t)
        end
    end

    process(42)
    process("hi")
    process({a = 1})
    process(function() return 100 end)
end

type_inspection()

-- 【问题2】Lua 的动态代码执行如何实现？
--
-- loadstring(s) / load(s)：编译字符串为函数
-- loadfile(f)：加载文件为函数
-- dostring(s)：等同于 loadstring(s)()
--
-- 注意：返回 (nil, error) 或 (func, err)

local function dynamic_code_exec()
    -- 执行字符串
    local chunk, err = loadstring("return 2 + 3")
    if chunk then
        print("result:", chunk())  -- 5
    else
        print("compile error:", err)
    end

    -- 执行表达式（不返回）
    loadstring("print('hello from string')")()

    -- 局部变量访问限制
    local env = {}
    loadstring("x = 10", nil, env)()
    print("env.x:", env.x)

    -- 带环境的代码
    local function sandbox()
        local env = {
            print = print,  -- 允许 print
            math = math,
            io = nil,       -- 禁止 io
        }
        setmetatable(env, {__index = _G})

        local chunk = loadstring("io = nil; print(math.random(10))", nil, env)
        if chunk then chunk() end
    end

    sandbox()

    -- loadfile
    -- local func = loadfile("script.lua")
    -- func()
end

dynamic_code_exec()

-- 【问题3】Lua 的 eval（求值器）如何实现？
--
-- eval：解析并执行字符串，返回结果
--
-- 简单实现：loadstring("return " .. expr)

local function eval_implementation()
    -- 简单 eval
    local function eval(expr)
        local chunk, err = loadstring("return " .. expr)
        if chunk then
            local ok, result = pcall(chunk)
            if ok then return result end
            error(result)
        else
            error(err)
        end
    end

    print("eval('2+3'):", eval("2+3"))
    print("eval('math.max(1,5,3):", eval("math.max(1,5,3)"))

    -- 更安全的 eval（限制范围）
    local function safe_eval(expr, allowed)
        local func, err = loadstring("return " .. expr)
        if not func then return nil, err end

        -- 使用受限环境
        local env = setmetatable({}, {__index = function(_, k)
            if allowed[k] then return _G[k] end
            return nil
        end})

        setfenv(func, env)

        local ok, result = pcall(func)
        if ok then return result end
        return nil, result
    end

    local result, err = safe_eval("print('hi')", {print = true})
    if err then print("blocked:", err) end
end

eval_implementation()

-- 【问题4】Lua 的元表（Metatable）如何实现反射？
--
-- 元表提供"拦截"操作的机制：
--   - __index：查找键
--   - __newindex：设置键
--   - __add, __mul 等运算符重载
--   - __tostring：字符串转换
--
-- 设置/获取元表：
--   - setmetatable(t, mt)
--   - getmetatable(t)

local function metatable_reflection()
    -- __index 拦截
    local function create_proxy(original)
        return setmetatable({}, {
            __index = function(self, key)
                print("accessing:", key)
                return original[key]
            end,
            __newindex = function(self, key, value)
                print("setting:", key, "=", value)
                original[key] = value
            end,
        })
    end

    local data = {a = 1, b = 2}
    local proxy = create_proxy(data)

    print("proxy.a:", proxy.a)
    proxy.c = 3
    print("proxy.c:", proxy.c)
    print("original:", data.a, data.b, data.c)

    -- __tostring
    local function create_display(obj)
        return setmetatable({}, {
            __tostring = function()
                local parts = {}
                for k, v in pairs(obj) do
                    table.insert(parts, tostring(k) .. "=" .. tostring(v))
                end
                return "{" .. table.concat(parts, ", ") .. "}"
            end,
            __index = obj,
        })
    end

    local display = create_display({x = 10, y = 20})
    print("display:", tostring(display))
end

metatable_reflection()

-- 【问题5】Lua 的动态方法分发如何实现？
--
-- 方法分派：
--   - 表中存储函数
--   - 根据条件调用不同函数
--
-- 类似命令模式

local function dynamic_dispatch()
    -- 命令表
    local commands = {
        ["add"] = function(a, b) return a + b end,
        ["sub"] = function(a, b) return a - b end,
        ["mul"] = function(a, b) return a * b end,
        ["div"] = function(a, b) return a / b end,
    }

    local function execute(cmd, a, b)
        local fn = commands[cmd]
        if fn then
            return fn(a, b)
        else
            error("unknown command: " .. tostring(cmd))
        end
    end

    print("add(10, 5):", execute("add", 10, 5))
    print("mul(10, 5):", execute("mul", 10, 5))

    -- 动态注册
    local registry = {}
    local function register(name, fn)
        registry[name] = fn
    end

    register("pow", function(a, b) return a ^ b end)
    print("pow(2, 8):", registry["pow"](2, 8))
end

dynamic_dispatch()

-- 【问题6】Lua 的闭包工厂如何实现元编程？
--
-- 闭包可以捕获外部变量，形成"记忆"
--
-- 工厂函数生成带状态的函数

local function closure_factory()
    -- 记忆化（memoize）
    local function memoize(fn)
        local cache = {}
        return function(...)
            local key = table.concat({...}, ",", 1, select("#", ...))
            if cache[key] == nil then
                cache[key] = fn(...)
            end
            return cache[key]
        end
    end

    -- 测试
    local function expensive(n)
        print("computing...")
        return n * 2
    end

    local fast = memoize(expensive)
    print(fast(5))  -- computing... 10
    print(fast(5))  -- 直接返回 10（缓存）

    -- 函数组合工厂
    local function compose(f, g)
        return function(...)
            return f(g(...))
        end
    end

    local double = function(x) return x * 2 end
    local increment = function(x) return x + 1 end

    local double_then_increment = compose(increment, double)
    print("double_then_increment(5):", double_then_increment(5))  -- 11

    local increment_then_double = compose(double, increment)
    print("increment_then_double(5):", increment_then_double(5))  -- 12
end

closure_factory()

-- 【问题7】Lua 的环境（_ENV）如何工作？
--
-- _ENV：当前环境，搜索全局变量的表
-- loadstring/chunk 的默认环境
--
-- _G：全局表（初始的 _ENV）
--
-- setfenv(func, env)：设置函数的_ENV
-- getfenv(func)：获取函数的_ENV

local function environment_demo()
    -- 沙箱：限制可用的全局变量
    local function create_sandbox()
        local env = {
            print = print,
            math = math,
            table = table,
            string = string,
            pairs = pairs,
            ipairs = ipairs,
            tostring = tostring,
            tonumber = tonumber,
        }
        setmetatable(env, {__index = _G})
        return env
    end

    local sandbox = create_sandbox()
    local code = [[
        print(math.random(100))
        io = nil  -- 尝试设置不允许的
        print(io)
    ]]

    local chunk = loadstring(code)
    if chunk then
        setfenv(chunk, sandbox)
        local ok, err = pcall(chunk)
        if not ok then print("sandbox error:", err) end
    end

    -- _ENV 在函数内
    local function show_env()
        print("_ENV type:", type(_ENV))
    end
    show_env()
end

environment_demo()

-- ============================================================
-- 【对比】Rust vs Lua vs Python 元编程
-- ============================================================
-- Rust:
--   - 反射能力有限（Any/TypeId）
--   - 强大的宏系统（编译时代码生成）
--   - proc_macro 实现编译器扩展

-- Lua:
--   - 完整反射：type(), getmetatable/setmetatable
--   - 动态执行：loadstring/load
--   - metatable 链实现行为修改
--   - 非常灵活的元编程能力

-- Python:
--   - 完整反射：type(), getattr, setattr
--   - 装饰器是元编程核心
--   - exec/eval 动态执行代码

function compare_metaprogramming()
    print("=== 五语言元编程对比 ===")

    -- Lua: 最强反射能力（动态语言本质），loadstring 可执行任意代码
    -- Python: 装饰器 + eval/exec + metaclasses
    -- Rust: 强大宏系统（编译时代码生成），proc_macro
    -- Go: 有限反射（reflect 包），无宏
    -- C++: 模板元编程（TMP），编译时计算

    print("Lua: loadstring + metatable = most dynamic")
    print("Rust: macro_rules! = most powerful compile-time")
end

-- ============================================================
-- 【练习题】
-- ============================================================
-- 1. 实现一个安全版本的 eval（限制只能执行数学运算：+ - * / ^），禁止访问全局变量
-- 2. 用元表实现一个只读表（read-only table），任何修改操作都会抛出错误
-- 3. 用闭包实现记忆化斐波那契，比较普通递归和记忆化递归的性能
-- 4. 用 metatable 的 __index 实现一个代理对象，每次访问属性时打印日志
-- 5. 实现一个简单的类系统：Class(name, fields)，返回一个可以用 : 调用方法的类

-- ============================================================
-- 总结
-- ============================================================
-- | 功能       | Lua 实现                                    |
-- |-----------|-------------------------------------------|
-- | 类型检查   | type(val)                                  |
-- | 元表设置   | setmetatable(t, mt)                        |
-- | 元表获取   | getmetatable(t)                            |
-- | 动态代码   | loadstring/dofile                          |
-- | 环境设置   | setfenv/getfenv                            |
-- | 闭包       | 函数捕获外部变量（upvalue）                 |

local function main()
    print("=== 模块十二：反射与元编程 ===")

    type_inspection()
    dynamic_code_exec()
    eval_implementation()
    metatable_reflection()
    dynamic_dispatch()
    closure_factory()
    environment_demo()
    compare_metaprogramming()

    print("\n✅ 所有示例运行成功！")
end

main()