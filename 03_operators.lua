-- ============================================================
-- 模块三：运算符与表达式
-- 算术 / 赋值 / 关系 / 逻辑 / 位运算 / 三目 / 优先级
-- ============================================================

-- 【问题1】Lua 的算术运算符有哪些？与 Rust 的区别？
--
-- Lua 算术运算符：
--   +  -  *  /  %（取模）
--   ^（指数）
--   //（整数除法，Lua 5.3+）
--
-- 与 Rust 区别：
--   - Lua 使用 # 获取长度（不是函数）
--   - Lua / 是浮点除法，整数除用 //
--   - Lua ^ 是指数（Rust 用 .pow()）
--   - Lua 无 ++/+= 自增语法

local function arithmetic_demo()
    local a, b = 10, 3

    print("10 + 3 =", a + b)
    print("10 - 3 =", a - b)
    print("10 * 3 =", a * b)
    print("10 / 3 =", a / b)        -- 3.3333...
    print("10 // 3 =", a // b)       -- 3 (整数除法)
    print("10 % 3 =", a % b)        -- 1
    print("10 ^ 2 =", a ^ 2)        -- 100

    -- 长度运算符
    local arr = {1, 2, 3, 4, 5}
    print("#arr =", #arr)           -- 5

    local str = "hello"
    print("#str =", #str)          -- 5
end

arithmetic_demo()

-- 【问题2】Lua 的赋值运算符有什么特点？
--
-- Lua 赋值是语句，不是表达式（不返回值）
--
-- 与 Rust 区别：
--   - Rust 赋值不返回值，Lua 赋值也不返回值
--   - Lua 支持多目标赋值：a, b = b, a（交换）
--   - Lua 赋值会先计算右侧，再赋值给左侧

local function assignment_demo()
    -- 多目标赋值
    local x, y = 1, 2
    print("before swap:", x, y)
    x, y = y, x
    print("after swap:", x, y)

    -- 返回多个值
    local function minmax(arr)
        return math.min(table.unpack(arr)), math.max(table.unpack(arr))
    end

    local m, n = minmax({3, 1, 4, 1, 5, 9, 2, 6})
    print("min, max =", m, n)

    -- 长度赋值
    local t = {1, 2, 3}
    print("before:", #t)
    t[#t + 1] = 4
    print("after append:", #t)
end

assignment_demo()

-- 【问题3】Lua 的关系运算符有哪些？
--
-- Lua 关系运算符：
--   ==  ~=（不等于）<  >  <=  >=
--
-- 重要注意：
--   - ~= 是"不等于"（不是 !=）
--   - 字符串比较按字典序
--   - 不同类型比较会返回 false（不会报错）
--   - 数字和字符串不会自动比较

local function relational_demo()
    -- 基本比较
    print("5 == 5:", 5 == 5)
    print("5 ~= 3:", 5 ~= 3)
    print("5 < 10:", 5 < 10)
    print("5 > 3:", 5 > 3)
    print("5 <= 5:", 5 <= 5)
    print("5 >= 5:", 5 >= 5)

    -- 字符串比较
    print("'apple' < 'banana':", "apple" < "banana")
    print("'hello' == 'hello':", "hello" == "hello")

    -- 不同类型比较
    print("1 == '1':", 1 == "1")  -- false（类型不同）
    print("1 < 'hello':", 1 < "hello")  -- false

    -- nil 比较
    print("nil == nil:", nil == nil)  -- true
    print("nil == false:", nil == false)  -- false
end

relational_demo()

-- 【问题4】Lua 的逻辑运算符和短路求值是什么？
--
-- Lua 逻辑运算符：
--   and  or  not（是关键字，不是符号）
--
-- 重要特性：
--   - and 和 or 返回实际值，不是布尔值
--   - 短路求值
--   - nil 和 false 是假，其他都是真（包括 0 和空字符串）
--
-- 语义：
--   - a and b：若 a 为假返回 a，否则返回 b
--   - a or b：若 a 为真返回 a，否则返回 b

local function logical_demo()
    -- and 和 or 返回实际值
    print("true and 5:", true and 5)       -- 5
    print("false and 5:", false and 5)    -- false
    print("nil and 5:", nil and 5)        -- nil
    print("0 and 5:", 0 and 5)            -- 5（0 是真！）

    print("true or 5:", true or 5)         -- true
    print("false or 5:", false or 5)      -- 5
    print("nil or 5:", nil or 5)          -- 5
    print("0 or 5:", 0 or 5)             -- 0（0 是真）

    -- not 总是返回布尔
    print("not nil:", not nil)           -- true
    print("not false:", not false)       -- true
    print("not 0:", not 0)               -- false（0 是真）
    print("not '':", not '')             -- false（空字符串是真）
    print("not 'hello':", not 'hello')   -- false

    -- 短路求值
    local function side_effect()
        print("side effect!")
        return false
    end

    print("testing and:")
    if true and side_effect() then end  -- 会执行

    print("testing and (short circuit):")
    if false and side_effect() then end  -- 不会执行
end

logical_demo()

-- 【问题5】Lua 有三元运算符吗？如何实现？
--
-- Lua 没有 ?: 三目运算符
--
-- 替代方案：
--   - and/or 组合
--   - if 语句
--
-- 注意：and/or 组合要小心，优先级和语义复杂

local function ternary_demo()
    -- and/or 实现三元
    local condition = true
    local result = condition and "yes" or "no"
    print("condition=true:", result)

    condition = false
    result = condition and "yes" or "no"
    print("condition=false:", result)

    -- 陷阱：当可能值是假时
    local value = 0
    result = value and "truthy" or "falsy"
    print("value=0:", result)  -- 错误！应该是 "truthy"

    -- 正确做法：使用 if
    if value ~= 0 then
        result = "truthy"
    else
        result = "falsy or zero"
    end
    print("correct handling:", result)
end

ternary_demo()

-- 【问题6】Lua 的位运算符是什么？（Lua 5.3+）
--
-- Lua 5.3+ 支持位运算符：
--   &  |  ~（按位异或）
--   << >>（位移）
--
-- 注意：需要数字是整数（不是浮点）

local function bitwise_demo()
    -- 按位操作
    local a, b = 0b1100, 0b1010  -- 12, 10

    print(string.format("0x%x & 0x%x = 0x%x", a, b, a & b))  -- 0x8
    print(string.format("0x%x | 0x%x = 0x%x", a, b, a | b))  -- 0xE
    print(string.format("0x%x ~ 0x%x = 0x%x", a, b, a ~ b))  -- 0x6

    -- 移位
    local shifted = 1 << 4  -- 16
    print("1 << 4 =", shifted)
    print("16 >> 2 =", 16 >> 2)

    -- 常见技巧：判断某一位
    local flags = 0b10101
    local bit2_set = (flags & (1 << 2)) ~= 0
    print("bit 2 of 0b10101 is set:", bit2_set)
end

bitwise_demo()

-- 【问题7】Lua 的运算符优先级是什么？
--
-- Lua 优先级（从高到低）：
--   1. ^（指数，右结合）
--   2. not  #  -（一元）
--   3. *  /  //  %
--   4. +  -（二元）
--   5. ..
--   6. <  >  <=  >=  ~=  ==
--   7. and
--   8. or
--
-- 建议：复杂表达式用括号

local function precedence_demo()
    -- ^ 是右结合的
    print("2 ^ 2 ^ 3 =", 2 ^ 2 ^ 3)   -- 2 ^ 8 = 256
    print("(2 ^ 2) ^ 3 =", (2 ^ 2) ^ 3)  -- 4 ^ 3 = 64

    -- 建议用括号
    local result = (2 + 3) * 4
    print("(2+3)*4 =", result)

    -- 字符串拼接优先级低于算术
    local s = "hello" .. ("world" or "")
    print("'hello' .. 'world' =", s)
end

precedence_demo()

-- ============================================================
-- 【对比】Rust vs Lua vs Python
-- ============================================================
-- Rust:
--   - 算术：+ - * / %（整数除法 5/2=2），溢出分 debug/release 行为
--   - 位运算：& | ^ ~ << >>
--   - 逻辑：&& || !（短路求值）
--   - 比较：== != < <= > >=
--   - 无三目运算符，if 是表达式

-- Lua:
--   - 算术：+ - * / %（浮点除法 5/2=2.5），整数除法用 //
--   - 位运算：& | ~ ^ << >>（Lua 5.3+）
--   - 逻辑：and or not（关键字，返回实际值）
--   - 比较：== ~= < <= > >=（~= 是不等于）
--   - 无三目运算符，用 and/or 组合实现
--   - nil 和 false 是假，其他都是真（包括 0）

-- Python:
--   - 算术：+ - * / // %（地板除法）
--   - 位运算：& | ^ ~ << >>
--   - 逻辑：and or not（关键字，返回实际值）
--   - 比较：== != < <= > >=
--   - 有三目运算符：x if cond else y
--   - False 值：None, False, 0, "", [], {}, set()

function compare_operators()
    print("=== 三语言运算符对比 ===")

    -- Lua 浮点除法 vs Python 地板除 vs Rust 整数除
    print("5 / 2 (Lua):", 5 / 2)
    -- Python: 5 / 2 = 2.5, 5 // 2 = 2
    -- Rust: 5 / 2 = 2 (整数除), 5.0 / 2.0 = 2.5 (浮点)

    -- 逻辑运算符
    print("true and 5 (Lua):", true and 5)
    print("false or 'hello' (Lua):", false or "hello")

    -- 0 是真
    print("0 and true (Lua):", 0 and true)  -- true
    -- Python: 0 and True = 0
end

-- ============================================================
-- 练习题
-- ============================================================
-- 1. 实现一个函数，判断一个数是否是 2 的幂（用位运算）
-- 2. 比较 and/or 的返回机制与 Python 的区别
-- 3. 解释为什么 Lua 的 ~= 表示不等于（而不是 !=）

-- ============================================================
-- 总结
-- ============================================================
-- | 运算符       | Lua 行为                                     |
-- |-------------|----------------------------------------------|
-- | + - * /     | 标准算术，/ 是浮点除法                       |
-- | //          | 整数除法（Lua 5.3+）                        |
-- | %           | 取模                                        |
-- | ^           | 指数，右结合                                |
-- | #           | 长度（数组/字符串）                         |
-- | == ~=       | 相等/不等（~= 不是 !=）                     |
-- | and or not  | 逻辑运算符，返回实际值而非布尔              |
-- | & | ~ << >> | 位运算（Lua 5.3+）                           |

local function main()
    print("=== 模块三：运算符与表达式 ===")

    arithmetic_demo()
    assignment_demo()
    relational_demo()
    logical_demo()
    ternary_demo()
    bitwise_demo()
    precedence_demo()
    compare_operators()

    print("\n✅ 所有示例运行成功！")
end

main()