-- === 第2章 变量与基本类型 ===

--[[
  本章目标：
  1. 掌握Lua的5种基本类型：nil, boolean, number, string, table
  2. 理解动态类型的原理
  3. 掌握变量命名规则和注释写法
  4. 理解类型转换规则

  核心问题：
  Q1: 为什么Lua不需要声明类型？
  Q2: 数字和字符串能直接相加吗？
  Q3: nil和false的区别是什么？
  4. 深入: 动态类型原理/NaN/inf
]]

-- ============================
-- Q1: 为什么Lua不需要声明类型？
-- ============================

-- Lua是动态类型语言，变量类型由值决定，不是由变量声明决定

local age = 25          -- age现在是number类型
print(type(age))       -- "number"
print(age)

age = "twenty five"    -- age现在是string类型
print(type(age))       -- "string"
print(age)

age = true              -- age现在是boolean类型
print(type(age))       -- "boolean"
print(age)

-- 对比静态类型语言(如C/Java)：
-- int age = 25;        -- 必须声明类型
-- age = "twenty";      -- 编译错误！

-- Lua的变量可以随时改变类型，这是动态类型的核心特征

-- ============================
-- Q2: 数字和字符串能直接相加吗？
-- ============================

-- 答案：不能直接相加，会报错
-- local sum = "5" + 3  -- 这行会报错！

-- 必须显式转换
local sum1 = tonumber("5") + 3   -- 字符串转数字，再相加 = 8
local sum2 = "5" .. 3            -- 字符串拼接 = "53"（..是拼接操作符）
local sum3 = tostring(5) .. tostring(3) -- 都转字符串再拼接 = "53"

print("tonumber +:", sum1)       -- 8
print("concat ..:", sum2)        -- 53
print("tostring:", sum3)         -- 53

-- 自动类型转换规则：
-- 算术运算符(+,-,*,/,^,%)：自动把字符串转数字（如果字符串是有效数字）
local autoConvert = "10" + "20"  -- Lua会尝试转换，成功后 = 30
print("auto convert:", autoConvert) -- 30

-- 但"hello" + 5 会失败，因为"hello"不是有效数字
-- local fail = "hello" + 5  -- 报错：attempt to add two strings (number expected)

-- ============================
-- Q3: nil和false的区别是什么？
-- ============================

-- nil表示"没有值"，是一种特殊类型
-- false表示"假"，是boolean类型的值

local a = nil
local b = false
local c = 0            -- 0是true！Lua中只有nil和false是假值
local d = ""           -- 空字符串也是true

print("nil is", type(a))
print("false is", type(b))
print("0 is", type(c), "and truthy:", c ~= nil and c ~= false)
print("'' is", type(d), "and truthy:", d ~= nil and d ~= false)

-- if条件判断：
if a then
    print("a is truthy")   -- 不会执行
else
    print("a is falsy (nil)")  -- 执行
end

if b then
    print("b is truthy")   -- 不会执行
else
    print("b is falsy (false)")  -- 执行
end

if c then
    print("c is truthy (0 is truthy!)")  -- 执行！因为0不是nil也不是false
end

-- table中删除元素用nil
local arr = {1, 2, 3, 4, 5}
print("before:", #arr)
arr[3] = nil         -- 删除第3个元素
print("after:", #arr) -- 长度变成4

-- ============================
-- 深入: 动态类型原理
-- ============================

-- Lua动态类型的核心：每个值都携带自己的类型信息
-- 变量名只是值的引用（类似指针）

-- type()函数返回值的类型字符串
print(type(nil))      -- "nil"
print(type(true))    -- "boolean"
print(type(42))      -- "number"
print(type(3.14))   -- "number"
print(type("hello")) -- "string"
print(type({}))      -- "table"
print(type(print))   -- "function"
print(type(io.stdout)) -- "userdata"

-- 数字的特殊值：NaN和Inf
local nan = 0 / 0
local inf = 1 / 0
local neg_inf = -1 / 0

print("0/0 =", nan)        -- nan
print("1/0 =", inf)       -- inf
print("-1/0 =", neg_inf)  -- -inf

-- NaN的特性：NaN不等于任何值，包括自己
print("nan == nan:", nan == nan)  -- false！

-- 可以用math.type()检测
print("math.type(nan):", math.type(nan))           -- "nan"
print("math.type(inf):", math.type(inf))         -- "inf"
print("math.type(42):", math.type(42))           -- "integer"
print("math.type(3.14):", math.type(3.14))       -- "float"

-- ============================
-- 示例：完整可运行脚本
-- ============================

-- 类型检测函数
local function printType(var, name)
    name = name or "value"
    print(string.format("%s type: %s, value: %s", name, type(var), tostring(var)))
end

local variables = {
    {name = "nil_val", value = nil},
    {name = "bool_false", value = false},
    {name = "bool_true", value = true},
    {name = "integer", value = 42},
    {name = "float", value = 3.14159},
    {name = "string", value = "Hello Lua"},
    {name = "empty_string", value = ""},
    {name = "zero", value = 0},
    {name = "table", value = {1, 2, 3}},
    {name = "function", value = function() end}
}

for _, v in ipairs(variables) do
    printType(v.value, v.name)
end

-- 安全的类型转换函数
local function safeToNumber(val)
    if type(val) == "number" then
        return val, true
    end
    if type(val) == "string" then
        local n = tonumber(val)
        if n then
            return n, true
        end
    end
    return nil, false
end

print("\n--- 安全类型转换 ---")
local n, ok = safeToNumber("42.5")
print("safeToNumber('42.5'):", n, "success:", ok)

n, ok = safeToNumber("not a number")
print("safeToNumber('not a number'):", n, "success:", ok)

n, ok = safeToNumber(100)
print("safeToNumber(100):", n, "success:", ok)

print("\n=== 第2章结束 ===")
