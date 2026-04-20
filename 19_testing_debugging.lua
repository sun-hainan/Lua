-- === 第19章 测试与调试 ===

--[[
  本章目标：
  1. 理解busted框架（需要库）
  2. 掌握单元测试/集成测试
  3. 理解mock/stub
  4. 掌握debug库/debug.getinfo

  核心问题：
  Q1: 怎么测试私有函数？
  Q2: 断言是什么？
  Q3: mock有什么用？
  深入: 覆盖率/钩子函数
]]

-- ============================
-- Q1: 怎么测试私有函数？
-- ============================

-- Lua没有真正的私有函数，但可以用约定：
-- 1. 用local声明的函数只在当前chunk可见
-- 2. 测试文件和被测文件在同一环境

-- 技巧1：把私有函数也导出（不推荐但实用）
--[[
local M = {}
function M.publicFunc() end
function M._privateHelper() end  -- 以下划线开头表示私有但导出
return M
]]

-- 技巧2：测试时加载整个模块
--[[
-- test.lua
package.path = "./?.lua;" .. package.path
local mymodule = require("mymodule")
-- mymodule._privateHelper() 可以访问
]]

-- ============================
-- Q2: 断言是什么？
-- ============================

-- 断言：检查条件是否为真，不满足则报错

-- assert(condition, message)
-- 如果condition为false，抛出错误

local function divide(a, b)
    assert(b ~= 0, "除数不能为零")
    return a / b
end

print("\n--- 断言示例 ---")
print("divide(10, 2):", divide(10, 2))

-- 自定义断言函数
local function assertEqual(actual, expected, msg)
    msg = msg or string.format("期望 %s，实际 %s", tostring(expected), tostring(actual))
    assert(actual == expected, msg)
end

local function assertTrue(value, msg)
    msg = msg or "期望 truthy，实际 " .. tostring(value)
    assert(value, msg)
end

local function assertTableContains(tbl, key, value)
    assert(tbl[key] ~= nil, "table不包含键: " .. tostring(key))
    assertEqual(tbl[key], value, "table[" .. tostring(key) .. "]值不匹配")
end

print("断言测试通过")

-- ============================
-- Q3: mock有什么用？
-- ============================

-- mock（模拟对象）：替换真实对象，控制行为
-- 用于测试依赖外部资源的代码

-- 示例：mock网络请求
local HttpMocker = {}
HttpMocker.__index = HttpMocker

function HttpMocker.new()
    return setmetatable({
        responses = {}
    }, HttpMocker)
end

function HttpMocker:mock(url, response)
    self.responses[url] = response
end

function HttpMocker.request(url)
    local mocker = HttpMocker.new()
    return mocker.responses[url] or "default response"
end

print("\n--- Mock示例 ---")
local mocker = HttpMocker.new()
mocker:mock("http://test.com/api", '{"name": "Alice"}')
mocker:mock("http://test.com/error", nil, "Network Error")

print("mock请求:", HttpMocker.request("http://test.com/api"))

-- ============================
-- debug库
-- ============================

print("\n--- debug库示例 ---")

-- debug.getinfo获取函数信息
local function myFunc(a, b)
    return a + b
end

local info = debug.getinfo(myFunc)
print("函数名:", info.name)
print("函数类型:", info.what)
print("定义行:", info.linedefined)
print("源文件:", info.source)

-- 获取当前函数的调用者信息
local function callerInfo()
    local info = debug.getinfo(2)  -- 2表示调用者
    print("调用者信息:")
    print("  函数:", info.name or "(主chunk)")
    print("  行号:", info.currentline)
    print("  源:", info.source)
end

local function callee()
    callerInfo()
end

callee()

-- debug.traceback获取调用栈
print("\n--- 调试栈追踪 ---")
local function level3() error("模拟错误") end
local function level2() level3() end
local function level1() level2() end

local ok, err = pcall(level1)
print("错误信息:", err)
print("\ntraceback:")
print(debug.traceback())

-- ============================
-- 示例：简单测试框架
-- ============================

local TestFramework = {}
TestFramework.__index = TestFramework

function TestFramework.new(name)
    local tf = {
        name = name,
        passed = 0,
        failed = 0,
        tests = {}
    }
    return setmetatable(tf, TestFramework)
end

function TestFramework.test(self, name, func)
    table.insert(self.tests, {name = name, func = func})
end

function TestFramework.run(self)
    print(string.format("\n=== 测试套件: %s ===", self.name))
    for _, test in ipairs(self.tests) do
        local ok, err = pcall(test.func)
        if ok then
            print(string.format("  ✓ %s", test.name))
            self.passed = self.passed + 1
        else
            print(string.format("  ✗ %s: %s", test.name, tostring(err)))
            self.failed = self.failed + 1
        end
    end
    
    print(string.format("\n结果: %d passed, %d failed", self.passed, self.failed))
    return self.failed == 0
end

-- 使用示例
print("\n--- 测试框架示例 ---")

local tf = TestFramework.new("Math Utils")

tf:test("加法", function()
    local result = 1 + 2
    assertEqual(result, 3)
end)

tf:test("除法", function()
    local result = 10 / 2
    assertEqual(result, 5)
end)

tf:test("字符串拼接", function()
    local result = "Hello" .. " " .. "World"
    assertEqual(result, "Hello World")
end)

tf:test("会失败的测试", function()
    assertEqual(1 + 1, 3, "故意失败")
end)

tf:run()

-- ============================
-- 深入: 覆盖率/钩子函数
-- ============================

-- 覆盖率统计需要特殊工具，如luacov
--[[
luacov - 统计代码覆盖率
busted --coverage - busted测试覆盖率
]]

-- debug.sethook设置钩子函数
print("\n--- 钩子函数示例 ---")

local function hook(event, line)
    print(string.format("钩子触发: event=%s, line=%d", event, line))
end

-- 设置行钩子（每次执行一行时触发）
-- debug.sethook(hook, "l")

-- 设置调用钩子（每次函数调用/返回时触发）
-- debug.sethook(hook, "cr")

-- 设置执行计数钩子
-- debug.sethook(hook, "", 1000)  -- 每1000条指令触发一次

print("(钩子已设置但注释掉以避免输出)")

-- 关闭钩子
debug.sethook()

print("\n=== 第19章结束 ===")
