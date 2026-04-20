-- ============================================================
-- 模块六：函数与方法
-- 定义/调用/重载/重写/递归/值传递vs引用传递/Lambda/闭包
-- ============================================================

-- 【问题1】Lua 函数的基本定义与调用机制是什么？
--
-- Lua 函数定义：
--   function name(args) ... end
--
-- Lua 函数是一等公民：
--   - 可以赋值给变量
--   - 可以作为参数传递
--   - 可以作为返回值
--   - 可以匿名

local function function_basics()
    -- 基本函数
    local function add(a, b)
        return a + b
    end
    print("add(3, 4) =", add(3, 4))

    -- 函数赋值给变量
    local multiply = function(a, b)
        return a * b
    end
    print("multiply(3, 4) =", multiply(3, 4))

    -- 多返回值
    local function minmax(arr)
        local min, max = math.huge, -math.huge
        for _, v in ipairs(arr) do
            if v < min then min = v end
            if v > max then max = v end
        end
        return min, max
    end

    local m, n = minmax({3, 1, 4, 1, 5, 9, 2, 6})
    print("minmax:", m, n)

    -- 参数默认值
    local function greet(name)
        name = name or "World"
        return "Hello, " .. name .. "!"
    end
    print(greet())
    print(greet("Lua"))

    -- 可变参数
    local function sum(...)
        local args = {...}
        local total = 0
        for _, v in ipairs(args) do
            total = total + v
        end
        return total
    end
    print("sum(1,2,3,4,5) =", sum(1, 2, 3, 4, 5))

    -- select 函数访问可变参数
    local function print_args(...)
        for i = 1, select("#", ...) do
            print(string.format("arg[%d] = %s", i, tostring(select(i, ...))))
        end
    end
    print_args("a", "b", "c")
end

function_basics()

-- 【问题2】Lua 支持函数重载吗？
--
-- Lua 不支持函数重载（同名的多个函数，后面的覆盖前面的）
--
-- 实现类似重载的方式：
--   - 使用可变参数
--   - 使用类型检查
--   - 使用表分发

local function no_overload()
    -- Lua 中同名函数会被覆盖
    local function test()
        print("first version")
    end

    test()  -- 调用的是新版本

    local function test()
        print("second version")
    end

    test()  -- 覆盖了旧版本

    -- 类型检查实现类似重载
    local function process(arg)
        if type(arg) == "number" then
            return arg * 2
        elseif type(arg) == "string" then
            return arg .. arg
        elseif type(arg) == "table" then
            return #arg
        else
            return nil
        end
    end

    print("process(5):", process(5))
    print("process('hi'):", process("hi"))
    print("process({1,2,3}):", process({1, 2, 3}))
end

no_overload()

-- 【问题3】Lua 的递归函数与尾递归优化是什么？
--
-- 递归：函数调用自身
-- 尾递归：递归调用是函数的最后一个操作
--
-- Lua VM 支持尾调用消除（TCO）：
--   - 尾递归不会导致栈溢出
--   - 必须是尾调用（return func(args) 形式）

local function recursion_demo()
    -- 普通递归：阶乘
    local function factorial(n)
        if n <= 1 then return 1 end
        return n * factorial(n - 1)
    end
    print("5! =", factorial(5))

    -- 尾递归版本
    local function factorial_tail(n, acc)
        acc = acc or 1
        if n <= 1 then return acc end
        return factorial_tail(n - 1, n * acc)  -- 尾调用
    end
    print("5! (tail) =", factorial_tail(5))

    -- 斐波那契数列
    local function fibonacci(n)
        if n <= 1 then return n end
        return fibonacci(n - 1) + fibonacci(n - 2)
    end
    print("fib(10) =", fibonacci(10))

    -- 迭代版本（避免栈溢出）
    local function fibonacci_iter(n)
        if n <= 1 then return n end
        local a, b = 0, 1
        for i = 2, n do
            a, b = b, a + b
        end
        return b
    end
    print("fib(10) (iter) =", fibonacci_iter(10))

    -- 链表递归求和
    local function create_list(...)
        return {...}
    end

    local function sum_list(t)
        if #t == 0 then return 0 end
        return t[1] + sum_list({table.unpack(t, 2)})
    end

    local list = create_list(1, 2, 3, 4, 5)
    print("sum list:", sum_list(list))
end

recursion_demo()

-- 【问题4】Lua 的值传递 vs 引用传递是什么？
--
-- Lua 的值类型 vs 引用类型：
--   - 值类型：nil, boolean, number, string, light userdata
--   - 引用类型：table, function, full userdata, thread
--
-- 行为：
--   - 值类型：传递副本
--   - 引用类型：传递引用（共享底层数据）
--
-- 注意：字符串虽然是值类型，但内部是共享的（不可变）

local function value_vs_reference()
    -- 数字是值传递
    local function increment(n)
        n = n + 1
        return n
    end

    local num = 10
    print("before:", num)
    increment(num)
    print("after (no change):", num)  -- 不会改变

    -- table 是引用传递
    local function add_element(t, value)
        t[#t + 1] = value
    end

    local arr = {1, 2, 3}
    print("before:", table.concat(arr, ", "))
    add_element(arr, 4)
    print("after (changed):", table.concat(arr, ", "))  -- 改变了

    -- 共享引用示例
    local original = {1, 2, 3}
    local copy = original  -- 共享同一个表
    copy[4] = 4
    print("original:", table.concat(original, ", "))  -- 也会改变
    print("copy:", table.concat(copy, ", "))

    -- 浅拷贝函数
    local function shallow_copy(t)
        local new = {}
        for k, v in pairs(t) do
            new[k] = v
        end
        return new
    end

    local original2 = {1, 2, 3}
    local deep = shallow_copy(original2)
    deep[4] = 4
    print("original2:", table.concat(original2, ", "))  -- 不会改变
    print("deep:", table.concat(deep, ", "))
end

value_vs_reference()

-- 【问题5】Lua 的闭包（closure）是什么？
--
-- 闭包：能捕获外部变量的函数
-- Lua 的函数可以访问创建时存在的外部变量（upvalue）
--
-- 用途：
--   - 工厂函数（生成函数）
--   - 私有变量（封装）
--   - 回调函数

local function closure_demo()
    -- 简单闭包
    local function counter(start)
        local count = start or 0
        return function()
            count = count + 1
            return count
        end
    end

    local c1 = counter(0)
    local c2 = counter(100)

    print("c1():", c1())  -- 1
    print("c1():", c1())  -- 2
    print("c1():", c1())  -- 3
    print("c2():", c2())  -- 101
    print("c1():", c1())  -- 4

    -- 工厂函数
    local function multiplier(factor)
        return function(n)
            return n * factor
        end
    end

    local double = multiplier(2)
    local triple = multiplier(3)

    print("double(5):", double(5))   -- 10
    print("triple(5):", triple(5))   -- 15

    -- 私有变量
    local function create_person(name)
        local _name = name  -- 私有变量
        return {
            get_name = function() return _name end,
            set_name = function(n) _name = n end,
        }
    end

    local p = create_person("Alice")
    print("name:", p.get_name())
    p.set_name("Bob")
    print("name:", p.get_name())
    -- print(_name)  -- ❌ 访问不到
end

closure_demo()

-- 【问题6】Lua 的高阶函数是什么？
--
-- 高阶函数：接受函数作为参数或返回函数的函数
--
-- 常用高阶函数：
--   - map：对每个元素执行操作
--   - filter：过滤元素
--   - reduce：聚合元素

local function higher_order_functions()
    -- map
    local function map(arr, func)
        local result = {}
        for i, v in ipairs(arr) do
            result[i] = func(v)
        end
        return result
    end

    local nums = {1, 2, 3, 4, 5}
    local doubled = map(nums, function(x) return x * 2 end)
    print("doubled:", table.concat(doubled, ", "))

    -- filter
    local function filter(arr, predicate)
        local result = {}
        for _, v in ipairs(arr) do
            if predicate(v) then
                table.insert(result, v)
            end
        end
        return result
    end

    local evens = filter(nums, function(x) return x % 2 == 0 end)
    print("evens:", table.concat(evens, ", "))

    -- reduce
    local function reduce(arr, func, init)
        local acc = init
        for _, v in ipairs(arr) do
            acc = func(acc, v)
        end
        return acc
    end

    local sum = reduce(nums, function(acc, x) return acc + x end, 0)
    print("sum:", sum)

    local product = reduce(nums, function(acc, x) return acc * x end, 1)
    print("product:", product)
end

higher_order_functions()

-- 【问题7】Lua 的尾调用消除（TCO）是什么？
--
-- 尾调用：函数的最后一条语句是调用另一个函数
-- 尾调用消除：调用者直接跳转到被调用者，不创建新栈帧
--
-- 条件：
--   - return func(args) 形式
--   - 不能有后续操作
--
-- 好处：可以递归调用而不栈溢出

local function tail_call_demo()
    -- 阶乘尾调用版本
    local function factorial_tco(n, acc)
        if n <= 1 then return acc end
        return factorial_tco(n - 1, n * acc)
    end
    print("factorial(1000) =", factorial_tco(1000, 1))

    -- 遍历链表（尾调用）
    local function traverse_list(list, func, index)
        index = index or 1
        if index > #list then return end
        func(list[index])
        return traverse_list(list, func, index + 1)  -- 尾调用
    end

    traverse_list({1, 2, 3, 4, 5}, function(v)
        print("element:", v)
    end)
end

tail_call_demo()

-- ============================================================
-- 【对比】Lua vs Python vs Rust vs Go vs C++
-- ============================================================
-- Lua:
--   - 函数用 function 关键字定义
--   - 函数是一等公民，可赋值、传递、返回
--   - 闭包自然（函数可访问外部变量 upvalue）
--   - 无方法语法糖，所有方法调用都是 table.func(obj, ...) 形式
--   - 支持尾调用消除（TCO）

-- Python:
--   - 函数用 def 定义，lambda 用于匿名函数
--   - 不支持真正的函数重载，靠默认参数模拟
--   - 闭包通过 nonlocal 关键字修改外层变量
--   - 方法第一个参数是 self
--   - 装饰器是元编程核心

-- Rust:
--   - 函数用 fn 定义，支持泛型、Trait 约束
--   - 不支持函数重载（靠泛型或 Trait）
--   - 闭包 |x| expr 有三种捕获方式（按引用/可变引用/按值）
--   - 方法用 impl Type {} 定义
--   - 支持尾调用优化（但不如 Lua 彻底）

-- Go:
--   - 函数用 func 关键字定义
--   - 不支持函数重载
--   - 没有闭包语法糖，但支持匿名函数和闭包
--   - 方法用 func (receiver) name() 语法
--   - 不支持尾调用优化（栈会增长）

-- C++:
--   - 函数用 return_type name() 定义
--   - 不支持函数重载（靠模板实现泛型）
--   - std::function + lambda 提供闭包
--   - lambda：[capture](params) -> ret { body }
--   - 不支持尾调用优化

function compare_functions()
    print("=== 五语言函数对比 ===")

    -- Rust: local f = |x| x * 2
    -- Lua:  local f = function(x) return x * 2 end
    -- Python: f = lambda x: x * 2
    -- Go: f := func(x int) int { return x * 2 }
    -- C++: auto f = [](int x) { return x * 2; }

    -- Lua 的 upvalue vs Python nonlocal vs Rust 借用
    local function make_counter(start)
        local count = start
        return function()
            count = count + 1
            return count
        end
    end

    local c = make_counter(0)
    print("Lua closure count:", c(), c(), c())
end

-- ============================================================
-- 【练习题】
-- ============================================================
-- 1. 实现一个 memoize 函数（记忆化），对斐波那契函数进行记忆化优化
-- 2. 实现一个 compose 函数：compose(f, g)(x) = f(g(x))，支持多个函数组合
-- 3. 解释 Lua 的 upvalue 和 Python 的 nonlocal 的区别，并用代码演示
-- 4. 实现一个带默认值参数的函数：function defaults(a, b, c)，a 默认 1，b 默认 2
-- 5. 用尾递归实现一个列表求和函数，并说明尾调用优化的条件

-- ============================================================
-- 总结
-- ============================================================
-- | 特性           | Lua 行为                                    |
-- |---------------|-------------------------------------------|
-- | 函数定义       | function name(args) ... end              |
-- | 多返回值       | return a, b, c                            |
-- | 默认参数       | arg = arg or default                      |
-- | 可变参数       | ... / select()                            |
-- | 函数重载       | 不支持，用类型检查代替                    |
-- | 闭包           | 自然的 upvalue 机制                       |
-- | 高阶函数       | 支持，接受/返回函数                        |
-- | 尾调用         | 支持（TCO）                               |

local function main()
    print("=== 模块六：函数与方法 ===")

    function_basics()
    no_overload()
    recursion_demo()
    value_vs_reference()
    closure_demo()
    higher_order_functions()
    tail_call_demo()
    compare_functions()

    print("\n✅ 所有示例运行成功！")
end

main()