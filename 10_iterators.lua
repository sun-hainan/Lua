-- === 第10章 迭代器与生成器 ===

--[[
  本章目标：
  1. 理解pairs/ipairs的内部原理
  2. 掌握自定义迭代器的实现
  3. 掌握泛型for循环的机制
  4. 理解闭包迭代器和next函数

  核心问题：
  Q1: 迭代器返回什么？
  Q2: 为什么要用闭包？
  Q3: next函数是什么？
  深入: 迭代器状态/永续性
]]

-- ============================
-- Q1: 迭代器返回什么？
-- ============================

-- 迭代器是生成一系列值的函数，每次调用返回两个值：key和value
-- 泛型for会自动处理迭代协议

-- pairs迭代器：遍历所有键值对
-- ipairs迭代器：遍历数组部分（整数索引，从1开始）

local arr = {10, 20, 30}

print("--- pairs vs ipairs ---")

-- pairs返回(key, value)，key遍历顺序不确定
for k, v in pairs(arr) do
    print("pairs:", k, v)
end

-- ipairs返回(index, value)，只在index连续且从1开始时工作
for i, v in ipairs(arr) do
    print("ipairs:", i, v)
end

-- ============================
-- Q2: 为什么要用闭包？
-- ============================

-- 迭代器需要保存状态，普通函数做不到
-- 闭包可以捕获外部变量（upvalue），保存状态

-- 错误做法：函数无法保存状态
local function countFunc()
    local count = 0
    return function()
        count = count + 1
        return count
    end
end

-- 正确做法：闭包迭代器
local function counter()
    local count = 0
    return function()
        count = count + 1
        if count <= 10 then
            return count, count * 10  -- 返回索引和值的平方
        end
        return nil  -- 迭代结束
    end
end

print("\n--- 闭包迭代器示例 ---")
local iter, state
local myCounter = counter()
for i, v in myCounter do
    print(i, v)
end

-- 自己实现一个迭代器类
local function rangeIter(state)
    local i = state[1]
    local max = state[2]
    i = i + 1
    if i > max then
        return nil
    end
    return i, i * i
end

local function range(start, stop)
    -- 返回：迭代器函数、状态初始化、初始状态
    return rangeIter, {start - 1}, start
end

print("\nrange迭代器:")
for i, v in range(1, 5) do
    print("  ", i, v)
end

-- ============================
-- Q3: next函数是什么？
-- ============================

-- next(table, [key]) 返回下一个键值对
-- next(t) 等价于pairs的开始

local dict = {a = 1, b = 2, c = 3}

print("\n--- next函数 ---")
-- 从nil开始，返回第一个键值对
local k, v = next(dict)
print("next(dict):", k, v)

-- 从a开始，返回下一个
k, v = next(dict, "a")
print("next(dict, 'a'):", k, v)

-- 遍历整个table
print("\n用next遍历:")
k = nil
repeat
    k, v = next(dict, k)
    if k then
        print("  ", k, v)
    end
until not k

-- 实现自己的pairs
local function myPairs(t)
    return next, t, nil
end

print("\nmyPairs遍历:")
for k, v in myPairs(dict) do
    print("  ", k, v)
end

-- ============================
-- 深入: 迭代器状态/永续性
-- ============================

-- 迭代器有两种：
-- 1. 有状态迭代器（闭包方式）：状态在upvalue中
-- 2. 无状态迭代器（函数+状态）：状态作为参数传递

-- 无状态迭代器的优点：可以多次并行遍历
-- 缺点：调用者不能保存迭代器中间状态

-- Lua的内置pairs/ipairs是无状态迭代器
--[[
pairs = function(t)
    return next, t, nil
end
]]

-- 有状态迭代器（如文件迭代器）：
--[[
function lines(file)
    return function()
        return file:read()
    end
end
]]

-- 无状态迭代器可以安全地在多个for循环中共享
local t = {1, 2, 3, 4, 5}
local iter1, state1, init1 = pairs(t)
local iter2, state2, init2 = pairs(t)

print("\n--- 多个并行迭代 ---")
-- 先迭代一部分
local k1, v1 = iter1(state1, init1)
print("iter1:", k1, v1)

-- 再迭代另一个（互不影响，因为状态独立）
local k2, v2 = iter2(state2, init2)
print("iter2:", k2, v2)

-- ============================
-- 示例：完整可运行脚本
-- ============================

-- 过滤器迭代器
local function filterIter(state)
    local t = state.t
    local pred = state.pred
    local i = state.i
    
    while i <= #t do
        if pred(t[i]) then
            state.i = i + 1
            return i, t[i]
        end
        i = i + 1
    end
    return nil
end

local function filter(t, pred)
    return filterIter, {t = t, pred = pred, i = 1}
end

print("\n--- 过滤迭代器 ---")
local nums = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
for i, v in filter(nums, function(x) return x % 2 == 0 end) do
    print("偶数:", v)
end

-- 组合迭代器（链式调用）
local function mapIter(state)
    local srcIter = state.srcIter
    local srcState = state.srcState
    local func = state.func
    
    local k, v = srcIter(srcState)
    if v ~= nil then
        return k, func(v)
    end
    return nil
end

local function map(iter, state, init, func)
    return mapIter, {srcIter = iter, srcState = state, init = init, func = func}
end

print("\n--- 链式迭代器 ---")
-- range(1,5)返回迭代器
for i, v in map(range(1, 5), {1}, 1, function(x) return x * x end) do
    print("平方:", v)
end

-- 实现无限迭代器（慎用）
local function infiniteRange()
    local i = 0
    return function()
        i = i + 1
        return i, i
    end
end

print("\n--- 无限迭代器（前5个）---")
local infIter = infiniteRange()
for _ = 1, 5 do
    local i, v = infIter()
    print("  ", i, v)
end

print("\n=== 第10章结束 ===")
