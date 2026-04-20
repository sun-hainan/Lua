-- === 第4章 函数与代码复用 ===

--[[
  本章目标：
  1. 掌握function定义、参数传递、返回值
  2. 理解多返回值机制
  3. 理解变长参数...
  4. 理解命名参数（table实现）
  5. 理解尾调用优化

  核心问题：
  Q1: 为什么函数能返回多个值？
  Q2: ...是什么？怎么用？
  Q3: 尾调用快在哪里？
  Q4: 命名参数怎么实现？
  深入: 调用栈/尾递归消除
]]

-- ============================
-- Q1: 为什么函数能返回多个值？
-- ============================

-- Lua函数可以返回多个值，用逗号分隔
local function stats(data)
    local sum = 0
    local min = data[1]
    local max = data[1]
    
    for i = 1, #data do
        sum = sum + data[i]
        if data[i] < min then min = data[i] end
        if data[i] > max then max = data[i] end
    end
    
    local avg = sum / #data
    return sum, avg, min, max  -- 返回4个值
end

local data = {10, 20, 30, 40, 50}
local sum, avg, min, max = stats(data)
print("sum:", sum, "avg:", avg, "min:", min, "max:", max)

-- 多返回值的特殊用法：交换变量
local a, b = 10, 20
a, b = b, a  -- 交换
print("a:", a, "b:", b)

-- 多返回值用在函数调用中：最后一个位置
local function range()
    return 1, 2, 3
end
print(range())  -- 输出: 1 2 3

-- 如果多返回值不是用在最后一个位置，只取第一个
local x = range()  -- x = 1

-- 用括号包围可以强制只取第一个值
local y = (range())  -- y = 1

-- ============================
-- Q2: ...是什么？怎么用？
-- ============================

-- ...是变长参数，表示零个或多个参数
local function sumAll(...)
    local args = {...}  -- 把变长参数转成table
    local sum = 0
    for i = 1, #args do
        sum = sum + args[i]
    end
    return sum
end

print("\nsumAll(1,2,3):", sumAll(1, 2, 3))
print("sumAll(10,20):", sumAll(10, 20))
print("sumAll():", sumAll())

-- select函数处理变长参数
local function printArgs(...)
    for i = 1, select("#", ...) do  -- select("#")返回参数个数
        local arg = select(i, ...)  -- 获取第i个参数
        print("  arg" .. i .. ":", arg)
    end
end

print("\nprintArgs('a','b','c'):")
printArgs("a", "b", "c")

-- 变长参数解包
local function add(a, b)
    return a + b
end

local nums = {10, 20}
print("add(unpack(nums)):", add(table.unpack(nums)))

-- ============================
-- Q3: 尾调用快在哪里？
-- ============================

-- 尾调用：函数最后一步是调用另一个函数，不需要返回
-- 语法要求：调用必须是最后一个语句，不能有后续操作

-- 错误示例：不是尾调用（调用后还要加1）
local function factorialWrong(n)
    if n <= 1 then return 1 end
    return n * factorialWrong(n - 1)  -- *操作后还需要返回
end

-- 正确示例：尾调用（累积参数）
local function factorialRight(n, acc)
    acc = acc or 1
    if n <= 1 then return acc end
    return factorialRight(n - 1, n * acc)  -- 尾调用
end

print("\nfibonacci tail call:")
-- 尾递归版本
local function fibTail(n, a, b)
    a, b = a or 0, b or 1
    if n == 0 then return a end
    return fibTail(n - 1, b, a + b)
end

for i = 0, 10 do
    print("fib(" .. i .. "):", fibTail(i))
end

-- 尾调用优化原理：
-- 普通函数调用：调用func() → 创建新栈帧 → 执行 → 释放帧 → 返回
-- 尾调用：直接复用当前栈帧，覆盖参数 → 不需要分配/释放内存
-- 可以无限递归（不会栈溢出）

-- ============================
-- Q4: 命名参数怎么实现？
-- ============================

-- Lua不支持命名参数，用table模拟
local function createUser(opts)
    -- 设置默认值
    local name = opts.name or "Anonymous"
    local age = opts.age or 0
    local email = opts.email or ""
    local active = opts.active ~= false  -- 默认true
    
    return {
        name = name,
        age = age,
        email = email,
        active = active
    }
end

local user1 = createUser({name = "Alice", age = 25, email = "alice@example.com"})
local user2 = createUser({name = "Bob", active = false})
local user3 = createUser({})  -- 全用默认值

print("\nuser1:", user1.name, user1.age, user1.active)
print("user2:", user2.name, user2.age, user2.active)
print("user3:", user3.name, user3.age, user3.active)

-- ============================
-- 深入: 调用栈
-- ============================

-- 调用栈(Call Stack)：记录函数调用顺序的数据结构
-- 每个函数调用在栈上有一个栈帧(Stack Frame)

-- 栈帧包含：参数、局部变量、返回地址

-- 普通递归调用：
-- fact(5) → fact(4) → fact(3) → fact(2) → fact(1) → fact(0返回1) → ×2 → ×6 → ×24 → ×120
-- 每个调用都创建新栈帧，占用内存

-- 尾递归优化：
-- factTail(5, 1) → factTail(4, 5) → factTail(3, 20) → factTail(2, 60) → factTail(1, 120)
-- 所有调用复用同一个栈帧，不增长

-- ============================
-- 示例：完整可运行脚本
-- ============================

-- 管道函数（函数组合）
local function pipe(...)
    local funcs = {...}
    return function(init)
        local result = init
        for i = 1, #funcs do
            result = funcs[i](result)
        end
        return result
    end
end

local double = function(x) return x * 2 end
local increment = function(x) return x + 1 end
local square = function(x) return x * x end

local transform = pipe(double, increment, square)
print("\npipe demo: (5 * 2 + 1) ^ 2 =", transform(5))  -- (10+1)^2 = 121

-- 柯里化
local function curry(func, arg1)
    return function(arg2)
        return func(arg1, arg2)
    end
end

local addCurried = curry(function(a, b) return a + b end, 10)
print("curry add: addCurried(5) =", addCurried(5))
print("curry add: addCurried(20) =", addCurried(20))

-- 偏函数
local function partial(func, ...)
    local fixedArgs = {...}
    return function(...)
        local allArgs = {table.unpack(fixedArgs), ...}
        return func(table.unpack(allArgs))
    end
end

local addPartial = partial(function(a, b, c) return a + b + c end, 100, 10)
print("partial add: addPartial(1) =", addPartial(1))  -- 100+10+1=111

print("\n=== 第4章结束 ===")
