-- === 第14章 元编程 ===

--[[
  本章目标：
  1. 理解loadstring/dofile/load
  2. 理解setfenv/getfenv（改变环境）
  3. 实现沙盒（sandbox）
  4. 掌握字符串格式化

  核心问题：
  Q1: loadstring是什么？
  Q2: 为什么要沙盒？
  Q3: 动态执行的安全问题？
  深入: 代码生成/求值环境
]]

-- ============================
-- Q1: loadstring是什么？
-- ============================

-- loadstring把字符串当作代码执行
-- 返回编译后的函数，或报错

print("--- loadstring示例 ---")

local code = "return 1 + 2"
local func = loadstring(code)
print("loadstring结果:", func())  -- 3

-- 带参数的代码
local code2 = "local x = ...; return x * 2"
local times2 = loadstring(code2)
print("times2(21):", times2(21))  -- 42

-- 动态生成函数
local function makeAdder(n)
    local code = string.format("return function(x) return x + %d end", n)
    return loadstring(code)()
end

print("\n--- 动态生成函数 ---")
local add10 = makeAdder(10)
local add20 = makeAdder(20)
print("add10(5):", add10(5))   -- 15
print("add20(5):", add20(5))   -- 25

-- loadfile vs load vs dofile
-- dofile: 读取文件并执行
-- loadfile: 只编译，不执行
-- load: 从字符串加载，功能同loadstring（Lua 5.2+）

-- ============================
-- Q2: 为什么要沙盒？
-- ============================

-- loadstring可以执行任意代码，包括危险的代码
-- 沙盒限制了可执行的操作

-- 危险示例（不要执行！）
-- local dangerous = "os.execute('rm -rf /')"
-- loadstring(dangerous)()  -- 可能删除文件！

-- 沙盒策略：
-- 1. 禁用危险的函数（os.execute, io.popen等）
-- 2. 限制CPU和内存使用
-- 3. 限制文件访问

-- ============================
-- Q3: 动态执行的安全问题？
-- ============================

-- 安全问题：
-- 1. 注入攻击：用户输入被当作代码执行
-- 2. 资源耗尽：无限循环、无限内存
-- 3. 逃逸：突破沙盒限制

-- 注入示例：
-- local name = "aaa'; os.execute('malicious'); local a='"
-- local code = string.format("print('Hello, %s!')", name)
-- loadstring(code)()  -- 注入代码被执行！

-- ============================
-- 示例：实现沙盒
-- ============================

local function createSandbox()
    -- 安全的全局环境
    local safeEnv = {
        -- 基本数学函数
        math = math,
        -- 只读副本
        table = table,
        string = string,
        -- 安全的pairs/ipairs
        pairs = pairs,
        ipairs = ipairs,
        -- 类型函数
        type = type,
        tostring = tostring,
        tonumber = tonumber,
        -- 安全的基本函数
        assert = assert,
        error = error,
        pcall = pcall,
        -- print也安全
        print = print,
        -- _G指向安全环境（防止逃逸）
        _G = nil,  -- 设为nil防止访问真实_G
        -- 不允许的函数设为nil
        os = nil,
        io = nil,
        debug = nil,
        loadfile = nil,
        dofile = nil,
        loadstring = nil,
        load = nil,
    }
    
    -- 元表，让未定义的全局变量返回nil而不是报错
    setmetatable(safeEnv, {
        __index = function(_, k)
            return nil
        end,
        __newindex = function(_, k, v)
            error("Cannot modify sandbox environment")
        end
    })
    
    return safeEnv
end

local function runSandbox(code)
    local env = createSandbox()
    
    -- Lua 5.2+ 用_ENV
    local func, err = loadstring(code)
    if not func then
        return nil, err
    end
    
    setfenv(func, env)
    return pcall(func)
end

print("\n--- 沙盒执行 ---")

-- 安全代码
local ok, result = runSandbox("return 1 + 2")
print("安全代码: 1+2 =", result)

-- 危险代码（被阻止）
ok, result = runSandbox("os.execute('echo hacked')")
print("os.execute结果: ok=", ok, "result=", result)

-- 尝试访问真实_G
ok, result = runSandbox("return _G")
print("_G访问: ok=", ok, "result=", result)

-- ============================
-- 深入: 代码生成/求值环境
-- ============================

-- 词法闭包：Lua编译器生成的代码引用外部变量时，
-- 实际引用的是当前环境的变量

-- setfenv改变函数的环境
local function testEnv()
    local x = 10
    print("x in env:", x)  -- x是局部变量
end

local function testFenv()
    local env = {x = 20}
    setfenv(1, env)  -- 改变当前函数的环境
    print("x after setfenv:", x)  -- x现在是env.x
end

print("\n--- setfenv示例 ---")
testEnv()
testFenv()

-- getfenv获取当前环境
local function showEnv()
    local env = getfenv(1)
    print("当前函数环境:", env)
end
showEnv()

-- ============================
-- 字符串格式化
-- ============================

-- string.format格式化
print("\n--- string.format ---")
print(string.format("%s %d %.2f", "Hello", 42, 3.14159))
print(string.format("十六进制: 0x%X", 255))
print(string.format("二进制: %b", 5))
print(string.format("对齐: [%10s]", "right"))
print(string.format("对齐: [%-10s]", "left"))

-- %q格式化（安全引用字符串）
local unsafe = 'hello "world"'
print(string.format("%%q: %q", unsafe))

-- 自定义format函数
local function formatTable(t)
    local parts = {}
    for k, v in pairs(t) do
        table.insert(parts, string.format("%s=%s", k, tostring(v)))
    end
    return table.concat(parts, ", ")
end

local data = {name = "Alice", age = 25, active = true}
print("\nformatTable:", formatTable(data))

print("\n=== 第14章结束 ===")
