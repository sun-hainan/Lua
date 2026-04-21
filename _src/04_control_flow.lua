-- ============================================================
-- 模块四：流程控制
-- if/else/switch/match/循环/break/continue/异常
-- ============================================================

-- 【问题1】Lua 的 if/else 语句是什么？
--
-- Lua if 语句结构：
--   if 条件 then ... end
--   if 条件 then ... else ... end
--   if 条件1 then ... elseif 条件2 then ... else ... end
--
-- 注意：
--   - 用 then 关键字（不是 {）
--   - 用 end 关键字结束（不是 }）
--   - 条件表达式使用 and/or/not

local function if_else_demo()
    local score = 85

    if score >= 90 then
        print("A")
    elseif score >= 80 then
        print("B")
    elseif score >= 70 then
        print("C")
    else
        print("D or below")
    end

    -- 单行 if（不推荐）
    if score >= 60 then print("passed") end

    -- if 作为表达式？没有！Lua 的 if 是语句不是表达式
    -- 无法写：local grade = if score >= 90 then "A" else "B"
    -- 必须用三元替代或 if 语句
end

if_else_demo()

-- 【问题2】Lua 有 switch/match 吗？如何替代？
--
-- Lua 没有 switch 或 match 语句
--
-- 替代方案：
--   1. if-elseif 链（简单情况）
--   2. 表跳转（多个值对应同一结果）
--   3. 函数表（动态分发）

local function switch_alternatives()
    -- 表跳转（推荐用于离散值）
    local day_name = {
        [1] = "Monday",
        [2] = "Tuesday",
        [3] = "Wednesday",
        [4] = "Thursday",
        [5] = "Friday",
        [6] = "Saturday",
        [7] = "Sunday",
    }

    local today = 3
    print("day:", day_name[today] or "invalid")

    -- 函数表（适合需要执行逻辑的情况）
    local operations = {
        ["add"] = function(a, b) return a + b end,
        ["sub"] = function(a, b) return a - b end,
        ["mul"] = function(a, b) return a * b end,
        ["div"] = function(a, b) return a / b end,
    }

    print("add(10, 5):", operations["add"](10, 5))
    print("mul(10, 5):", operations["mul"](10, 5))

    -- 范围匹配需要 if
    local score_to_grade = function(score)
        if score >= 90 then return "A"
        elseif score >= 80 then return "B"
        elseif score >= 70 then return "C"
        else return "D" end
    end

    print("85 ->", score_to_grade(85))
end

switch_alternatives()

-- 【问题3】Lua 的循环有哪些？while / repeat / for？
--
-- Lua 三种循环：
--   1. while 循环：while 条件 do ... end
--   2. repeat 循环：repeat ... until 条件（至少执行一次）
--   3. for 循环：数值 for 或 泛型 for
--
-- 注意：Lua 没有 continue！用 if 包裹或 goto

local function loop_types()
    -- while 循环
    local i = 1
    while i <= 5 do
        print("while:", i)
        i = i + 1
    end

    -- repeat 循环（后条件）
    local j = 1
    repeat
        print("repeat:", j)
        j = j + 1
    until j > 5

    -- 数值 for（范围）
    for k = 1, 5 do
        print("numeric for:", k)
    end

    -- 数值 for（步长）
    for k = 10, 1, -2 do
        print("numeric for step:", k)
    end

    -- 泛型 for（遍历迭代器）
    local arr = {"a", "b", "c"}
    for index, value in ipairs(arr) do
        print(string.format("array[%d] = %s", index, value))
    end

    -- pairs（遍历字典）
    local dict = {x = 1, y = 2, z = 3}
    for key, value in pairs(dict) do
        print(string.format("dict.%s = %s", key, value))
    end
end

loop_types()

-- 【问题4】Lua 的 break 和 continue 如何使用？
--
-- break：退出当前循环
-- continue：Lua 没有 continue！需要用 if 跳过或 goto
--
-- Lua 5.2+ 支持 goto，可以模拟 continue

local function break_continue_demo()
    -- break 示例
    local sum = 0
    for i = 1, 10 do
        if i == 5 then break end
        sum = sum + i
    end
    print("sum 1..4:", sum)

    -- continue 替代（用 if）
    sum = 0
    for i = 1, 5 do
        if i == 3 then
            -- 跳过 3
        else
            sum = sum + i
        end
    end
    print("sum without 3:", sum)

    -- goto 实现 continue（Lua 5.2+）
    sum = 0
    for i = 1, 5 do
        if i == 3 then goto continue end
        sum = sum + i
        ::continue::
    end
    print("sum without 3 (goto):", sum)

    -- 嵌套循环 break
    local found = false
    for i = 1, 3 do
        for j = 1, 3 do
            if i == 2 and j == 2 then
                found = true
                break  -- 只退出内层循环
            end
        end
        if found then break end  -- 需要检查才能退出外层
    end
    print("found at i=2, j=2:", found)
end

break_continue_demo()

-- 【问题5】Lua 的错误处理如何实现？
--
-- Lua 错误处理：
--   error(message, level)：抛出错误
--   assert(condition, message)：断言
--   pcall(func, ...)：保护调用
--   xpcall(func, errhandler)：带错误处理器的保护调用
--
-- 与 Rust 的区别：
--   - Lua 没有类型化的错误，所有错误都是普通值
--   - Rust 用 Result 区分错误类型，Lua 用 nil + 消息

local function error_handling_demo()
    -- error 和 assert
    local function divide(a, b)
        if b == 0 then
            error("division by zero", 2)  -- level 2 表示调用者级别
        end
        return a / b
    end

    -- pcall（protected call）
    local success, result = pcall(function()
        return divide(10, 0)
    end)

    if not success then
        print("caught error:", result)
    end

    -- assert 简化
    local function get_element(arr, index)
        assert(index > 0, "index must be positive")
        assert(index <= #arr, "index out of bounds")
        return arr[index]
    end

    local arr = {1, 2, 3}
    local elem = assert(get_element(arr, 2), "failed to get element")
    print("element:", elem)

    -- xpcall（带错误处理器的 pcall）
    local function err_handler(msg)
        print("error handler caught:", msg)
        return "handled: " .. tostring(msg)
    end

    local ok, result = xpcall(function()
        error("something went wrong")
    end, err_handler)
    print("xpcall result:", ok, result)
end

error_handling_demo()

-- 【问题6】Lua 的泛型 for 迭代器如何工作？
--
-- 泛型 for 语法：
--   for var1, var2, ... in expr do ... end
--
-- expr 返回：
--   迭代器函数, 状态, 初始值
--
-- 常见迭代器：
--   - ipairs(t)：遍历数组
--   - pairs(t)：遍历字典
--   - io.lines(filename)：遍历文件行
--   - string.gmatch(s, pattern)：遍历匹配

local function iterator_demo()
    -- ipairs 实现原理
    local function my_ipairs(t)
        return function(t, i)
            local next_i = i + 1
            if t[next_i] ~= nil then
                return next_i, t[next_i]
            end
            return nil
        end, t, 0
    end

    local arr = {"a", "b", "c"}
    for i, v in my_ipairs(arr) do
        print(string.format("my_ipairs: arr[%d] = %s", i, v))
    end

    -- string.gmatch（模式匹配迭代器）
    local text = "hello world lua"
    for word in string.gmatch(text, "%w+") do
        print("word:", word)
    end

    -- 自定义迭代器工厂
    local function range(start, stop)
        return function(state, current)
            if current >= stop then return nil end
            return current + 1, current + 1
        end, nil, start - 1
    end

    print("range 1, 5:")
    for i in range(1, 5) do
        print(" ", i)
    end
end

iterator_demo()

-- 【问题7】Lua 的 repeat...until 和 while 的区别是什么？
--
-- repeat...until：
--   - 循环体至少执行一次
--   - 条件在循环结束时检查（后条件循环）
--
-- while：
--   - 条件先检查，可能一次都不执行

local function repeat_vs_while()
    -- repeat：至少执行一次
    local count = 0
    repeat
        count = count + 1
        print("repeat:", count)
    until count >= 3

    -- while：可能不执行
    count = 0
    while count >= 3 do
        print("while will not run:", count)
        count = count + 1
    end
    print("while didn't execute (count =", count .. ")")
end

repeat_vs_while()

-- ============================================================
-- 【对比】Lua vs Python vs Rust vs Go vs C++
-- ============================================================
-- Lua:
--   - if/elseif/else 是语句（不能作为表达式返回值）
--   - 没有 match，用 if-elseif 或表跳转代替
--   - while/repeat/for 三种循环，repeat 是后条件循环（至少执行一次）
--   - 没有 break 标签，只有 break（只能退出一层）
--   - 没有 continue，用 if 或 goto（Lua 5.2+）模拟

-- Python:
--   - if/elif/else 是语句
--   - match-case（3.10+）是模式匹配
--   - while/for 循环，有 break/continue
--   - try/except/finally/else 异常处理
--   - for 可迭代任意可迭代对象

-- Rust:
--   - if/else 是表达式，可以返回值
--   - match 是强大的模式匹配
--   - loop/while/for 三种循环，break 可返回值
--   - 标签 'label 支持多层循环控制
--   - panic/Result/Option 分离不可恢复错误和可恢复错误

-- Go:
--   - if/switch 是语句，支持初始化语句
--   - switch 无需 break（自动中断），fallthrough 可穿透
--   - for 是唯一循环关键字（while 用 for 代替）
--   - 没有 continue，用 if 跳过
--   - defer 延迟执行，常用于资源清理

-- C++:
--   - if/switch 是语句，switch 无需 break（可穿透）
--   - if 可以使用 constexpr if（C++17）
--   - while/do-while/for 三种循环
--   - break/continue 控制循环
--   - try/catch/throw 异常处理，noexcept 指定不抛异常

function compare_control_flow()
    print("=== 五语言流程控制对比 ===")

    -- Lua: 没有 match/switch，用 if-elseif 或表跳转；repeat 是后条件循环（至少执行一次）
    -- Python 3.10+: match-case 模式匹配
    -- Rust: 强大的 match 表达式
    -- Go: switch 自动穿透（fallthrough 可控制），无 continue
    -- C++: switch 无需 break，可穿透

    -- Lua 没有 continue（goto 是 Lua 5.2+ 才支持）
end

-- ============================================================
-- 【练习题】
-- ============================================================
-- 1. 实现一个月份天数计算函数：用表模拟 switch，输入月份（1-12），返回天数
-- 2. 比较 repeat...until 和 while 的使用场景，各举一个实际例子
-- 3. 用 goto 实现 continue 的功能（跳过循环中某些迭代）
-- 4. 用泛型 for 迭代器实现一个 my_ipairs 函数，并验证它和原生 ipairs 行为一致
-- 5. 用 pcall 包装一个除法函数，使其在除以 0 时不崩溃，而是返回错误信息

-- ============================================================
-- 总结
-- ============================================================
-- | 特性           | Lua 行为                                    |
-- |---------------|-------------------------------------------|
-- | if            | if cond then ... end                      |
-- | if-else       | if ... then ... else ... end              |
-- | if-elseif     | if ... then ... elseif ... then ... end   |
-- | 循环 while    | while cond do ... end                     |
-- | 循环 repeat   | repeat ... until cond（至少执行一次）      |
-- | 循环 for      | for i=1,n do ... end 或 for k,v in iter   |
-- | break         | 退出当前循环                               |
-- | continue      | Lua 无，需要用 if 或 goto 模拟            |
-- | 错误处理       | error/assert/pcall/xpcall                |

local function main()
    print("=== 模块四：流程控制 ===")

    if_else_demo()
    switch_alternatives()
    loop_types()
    break_continue_demo()
    error_handling_demo()
    iterator_demo()
    repeat_vs_while()
    compare_control_flow()

    print("\n✅ 所有示例运行成功！")
end

main()