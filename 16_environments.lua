-- === 第16章 环境与全局变量 ===

--[[
  本章目标：
  1. 理解_G全局表
  2. 掌握setfenv改变环境
  3. 理解rawget/rawset
  4. 理解局部变量的优势

  核心问题：
  Q1: _G是什么？
  Q2: 全局变量为什么慢？
  Q3: 怎么隔离环境？
  深入: 环境查找链/编译时局部变量优化
]]

-- ============================
-- Q1: _G是什么？
-- ============================

-- _G是一个table，包含所有全局变量
-- 当访问一个全局变量x时，实际是访问_G.x

print("--- _G全局表 ---")
print("_G类型:", type(_G))
print("_G._G == _G:", _G._G == _G)

-- 全局变量存储在_G中
_G.myGlobal = 42
print("myGlobal:", myGlobal)  -- 直接访问
print("_G.myGlobal:", _G.myGlobal)  -- 通过_G访问

-- 遍历所有全局变量
print("\n所有全局变量:")
local count = 0
for k, v in pairs(_G) do
    count = count + 1
    if count <= 10 then
        print("  " .. k .. ":", type(v))
    end
end
print("  ... 共", count, "个")

-- ============================
-- Q2: 全局变量为什么慢？
-- ============================

-- 访问全局变量的查找链：
-- 1. 编译器首先检查是否有局部变量
-- 2. 如果没有，生成代码访问_G

-- 局部变量在寄存器或栈上，O(1)访问
-- 全局变量需要查表，O(1)但有额外的hash查找开销

local function testGlobal()
    -- 局部变量访问更快
    local localVar = 0
    for i = 1, 1000000 do
        localVar = localVar + 1
    end
    return localVar
end

local function testGlobalSlow()
    -- 全局变量访问更慢
    _G.globalCounter = 0
    for i = 1, 1000000 do
        _G.globalCounter = _G.globalCounter + 1
    end
    return _G.globalCounter
end

print("\n--- 性能对比（省略执行） ---")
-- print("局部变量:", testGlobal())
-- print("全局变量:", testGlobalSlow())

-- ============================
-- Q3: 怎么隔离环境？
-- ============================

-- 每个函数有自己的环境（_ENV）
-- 可以用setfenv改变函数的环境

print("\n--- 环境隔离 ---")

-- 默认主chunk的环境是_G
print("主chunk _G:", _G)

-- 创建隔离的环境
local function createIsolatedEnv()
    local env = {
        print = print,  -- 保留print
        math = math,
        pairs = pairs,
        ipairs = ipairs,
        table = table,
        string = string,
        type = type,
        tostring = tostring,
        tonumber = tonumber,
        -- 危险的函数不导入
        -- os = nil,
        -- io = nil,
    }
    setmetatable(env, {
        __index = _G,  -- 访问真实全局变量
        __newindex = function(t, k, v)
            error("Cannot set global: " .. k)
        end
    })
    return env
end

local code = [[
    print("在隔离环境中运行")
    x = 10  -- 会报错，因为__newindex被拦截
    return 42
]]

local env = createIsolatedEnv()
local func = loadstring(code)
if func then
    setfenv(func, env)
    local ok, result = pcall(func)
    print("执行结果: ok=", ok, "result=", result)
end

-- ============================
-- rawget/rawset
-- ============================

-- rawget(table, key)：不触发元方法，直接获取
-- rawset(table, key, value)：不触发元方法，直接设置

local t = setmetatable({a = 1}, {
    __index = function(t, k)
        print("__index被调用")
        return "default"
    end
})

print("\n--- rawget/rawset ---")
print("普通访问t.a:", t.a)  -- 触发__index
print("rawget(t, 'a'):", rawget(t, 'a'))  -- 不触发__index

rawset(t, "b", 2)
print("rawset后t.b:", t.b)  -- t.b存在

rawset(t, "a", 100)
print("rawset后t.a:", rawget(t, 'a'))  -- 不触发__index

-- ============================
-- 深入: 环境查找链/编译时局部变量优化
-- ============================

-- Lua编译器的优化：
-- 1. 局部变量声明后，编译器知道它存在，不再查_G
-- 2. 多次访问同一局部变量，会缓存到寄存器

-- 环境查找链：
-- _ENV实际是编译时注入的隐式局部变量
-- 访问x相当于访问_ENV.x

-- 示例：理解_ENV
local env = {}
_G._ENV = env  -- 改变当前环境
_ENV.hello = "world"
print("_ENV.hello:", hello)  -- 实际是_ENV.hello

-- ============================
-- 示例：模块隔离
-- ============================

local function createModule(modname)
    local mod = {}
    local privateData = "私有数据"
    
    -- 模块环境
    local env = setmetatable({
        mod = mod,
        print = print,
    }, {
        __index = function(t, k)
            -- 优先查找模块内容
            if mod[k] ~= nil then
                return mod[k]
            end
            -- 然后查找全局
            return _G[k]
        end
    })
    
    function mod.publicFunc()
        return "公开函数"
    end
    
    return mod, env
end

print("\n--- 模块隔离示例 ---")
local MyModule, moduleEnv = createModule("MyModule")
print("MyModule.publicFunc():", MyModule.publicFunc())

print("\n=== 第16章结束 ===")
