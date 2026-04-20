-- === 第11章 函数式编程 ===

--[[
  本章目标：
  1. 掌握匿名函数和高阶函数
  2. 实现map/filter/reduce
  3. 理解闭包与upvalue
  4. 理解偏函数与柯里化

  核心问题：
  Q1: upvalue是什么？
  Q2: 为什么要用闭包？
  Q3: 函数为什么是一等公民？
  深入: 词法作用域/一级函数
]]

-- ============================
-- Q1: upvalue是什么？
-- ============================

-- upvalue（向上取值）：闭包中捕获的外部局部变量
-- upvalue使得内部函数能读取和修改外部变量

local function createCounter()
    local count = 0  -- 这是upvalue
    
    return function()
        count = count + 1
        return count
    end
end

local counter1 = createCounter()
local counter2 = createCounter()

print("--- upvalue示例 ---")
print("counter1():", counter1())  -- 1
print("counter1():", counter1())  -- 2
print("counter1():", counter1())  -- 3
print("counter2():", counter2())  -- 1（独立的upvalue）
print("counter1():", counter1())  -- 4

-- upvalue vs 全局变量：
-- upvalue是局部变量，只能被一个闭包访问
-- 全局变量全局可见，可能被意外修改

-- ============================
-- Q2: 为什么要用闭包？
-- ============================

-- 闭包的作用：
-- 1. 数据封装（私有状态）
-- 2. 函数工厂（生成特定的函数）
-- 3. 回调处理（保存上下文）

-- 示例：函数工厂
local function makePowerFunc(power)
    return function(base)
        return base ^ power
    end
end

local square = makePowerFunc(2)
local cube = makePowerFunc(3)

print("\n--- 函数工厂 ---")
print("square(5):", square(5))  -- 25
print("cube(5):", cube(5))    -- 125

-- 示例：数据封装
local function createStack()
    local stack = {}
    local top = 0
    
    return {
        push = function(item)
            top = top + 1
            stack[top] = item
        end,
        pop = function()
            if top > 0 then
                local item = stack[top]
                stack[top] = nil
                top = top - 1
                return item
            end
            return nil, "stack is empty"
        end,
        size = function()
            return top
        end,
        isEmpty = function()
            return top == 0
        end
    }
end

print("\n--- 栈封装 ---")
local stack = createStack()
stack:push(1)
stack:push(2)
stack:push(3)
print("size:", stack:size())
print("pop:", stack:pop())
print("pop:", stack:pop())
print("isEmpty:", stack:isEmpty())

-- ============================
-- Q3: 函数为什么是一等公民？
-- ============================

-- 一等公民：函数可以像变量一样使用
-- 1. 可以赋值给变量
-- 2. 可以作为参数传递
-- 3. 可以作为返回值
-- 4. 可以存储在数据结构中

-- 函数赋值给变量
local add = function(a, b) return a + b end
print("\n--- 函数是一等公民 ---")
print("add(1, 2):", add(1, 2))

-- 函数作为参数
local function apply(func, value)
    return func(value)
end
print("apply(square, 5):", apply(square, 5))

-- 函数作为返回值
local function makeAdder(n)
    return function(m)
        return n + m
    end
end
local add10 = makeAdder(10)
print("add10(5):", add10(5))

-- 函数存储在table中
local mathOps = {
    add = function(a, b) return a + b end,
    sub = function(a, b) return a - b end,
    mul = function(a, b) return a * b end,
    div = function(a, b) return a / b end
}
print("mathOps.add(10, 3):", mathOps.add(10, 3))

-- ============================
-- 深入: 词法作用域/一级函数
-- ============================

-- 词法作用域（Lexical Scoping）：
-- 函数在定义时确定能访问哪些变量，而不是运行时

local x = 10
local function f()
    print("f中x:", x)  -- 这里x是外层的10
end

local function test()
    local x = 20  -- 局部变量
    f()  -- 仍然打印10，因为f定义时能访问的外层x是10
end

f()   -- 10
test()  -- 10

-- 一级函数（First-Class Function）：
-- 函数的地位和其他值一样，可以自由传递

-- ============================
-- 示例：完整可运行脚本
-- ============================

-- map: 对数组每个元素应用函数
local function map(t, func)
    local result = {}
    for i, v in ipairs(t) do
        result[i] = func(v, i)
    end
    return result
end

-- filter: 过滤元素
local function filter(t, pred)
    local result = {}
    for i, v in ipairs(t) do
        if pred(v, i) then
            result[#result + 1] = v
        end
    end
    return result
end

-- reduce: 归约
local function reduce(t, func, init)
    local acc = init
    for i, v in ipairs(t) do
        acc = func(acc, v, i)
    end
    return acc
end

-- 更多函数式工具

-- compose: 函数组合
local function compose(f, g)
    return function(...)
        return f(g(...))
    end
end

-- pipe: 管道（从左到右执行）
local function pipe(...)
    local funcs = {...}
    return function(x)
        for _, f in ipairs(funcs) do
            x = f(x)
        end
        return x
    end
end

-- curry: 柯里化（固定第一个参数）
local function curry(func, x)
    return function(...)
        return func(x, ...)
    end
end

print("\n--- 函数式工具示例 ---")
local nums = {1, 2, 3, 4, 5}

-- map
local doubled = map(nums, function(x) return x * 2 end)
print("map(x*2):", table.concat(doubled, ", "))

-- filter
local evens = filter(nums, function(x) return x % 2 == 0 end)
print("filter偶数:", table.concat(evens, ", "))

-- reduce
local sum = reduce(nums, function(acc, x) return acc + x end, 0)
print("reduce求和:", sum)

local product = reduce(nums, function(acc, x) return acc * x end, 1)
print("reduce求积:", product)

-- 链式调用
local result = reduce(
    filter(
        map(nums, function(x) return x + 1 end),
        function(x) return x % 2 == 0 end
    ),
    function(acc, x) return acc + x end,
    0
)
print("链式( (nums+1)过滤偶数求和 ):", result)

-- compose
local function addOne(x) return x + 1 end
local function double(x) return x * 2 end
local addThenDouble = compose(double, addOne)
print("compose: addThenDouble(5) =", addThenDouble(5))  -- (5+1)*2 = 12

-- pipe
local process = pipe(
    function(x) return x + 1 end,
    function(x) return x * 2 end,
    function(x) return x - 3 end
)
print("pipe: process(5) =", process(5))  -- ((5+1)*2)-3 = 9

-- 偏函数（Partial Application）
local function partial(func, ...)
    local fixedArgs = {...}
    return function(...)
        local allArgs = {table.unpack(fixedArgs)}
        for _, arg in ipairs({...}) do
            allArgs[#allArgs + 1] = arg
        end
        return func(table.unpack(allArgs))
    end
end

local function threeArgs(a, b, c)
    return a + b + c
end

local add5and10 = partial(threeArgs, 5, 10)
print("partial: add5and10(3) =", add5and10(3))  -- 5+10+3=18

print("\n=== 第11章结束 ===")
