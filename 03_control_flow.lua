-- === 第3章 流程控制 ===

--[[
  本章目标：
  1. 掌握if/then/elseif/else/end条件语句
  2. 掌握while/do...end循环
  3. 掌握repeat...until循环
  4. 掌握for/ipairs/pairs遍历
  5. 理解break和return的使用

  核心问题：
  Q1: 为什么Lua的end这么多？
  Q2: 三种循环怎么选？
  Q3: 数组遍历用ipairs还是pairs？
  Q4: break和return的区别？
  深入: 条件判断真假/短路求值
]]

-- ============================
-- Q1: 为什么Lua的end这么多？
-- ============================

-- Lua用end关键字结束控制结构，不像C系语言用{}
-- if表达式 end
-- while表达式 do ... end
-- for表达式 do ... end
-- function ... end

-- 示例：if语句
local score = 85
if score >= 90 then
    print("优秀")
elseif score >= 80 then
    print("良好")
elseif score >= 60 then
    print("及格")
else
    print("不及格")
end
-- 注意：elseif连写，不是else if（这是两种写法）

-- 对比C系语言：
-- if (score >= 90) {
--     printf("优秀");
-- } else if (score >= 80) {
--     printf("良好");
-- }

-- ============================
-- Q2: 三种循环怎么选？
-- ============================

-- while循环：先判断条件，再执行，适合未知迭代次数
local i = 1
while i <= 5 do
    print("while:", i)
    i = i + 1
end

-- repeat...until：先执行，再判断条件，保证至少执行一次
local j = 1
repeat
    print("repeat:", j)
    j = j + 1
until j > 5

-- for循环：已知迭代次数，效率最高（不用每次检查条件）
for i = 1, 5 do
    print("for:", i)
end

-- for可以指定步长
for i = 10, 1, -2 do
    print("for with step:", i)
end

-- 什么时候用什么循环：
-- 1. 遍历数组/table用for或pairs/ipairs
-- 2. 条件可能一次都不满足用while
-- 3. 至少执行一次用repeat...until

-- ============================
-- Q3: 数组遍历用ipairs还是pairs？
-- ============================

local arr = {10, 20, 30, 40, 50}

print("\n--- ipairs vs pairs ---")

-- ipairs：遍历数组部分，遇到nil停止（高效，推荐用于连续数组）
print("ipairs遍历：")
for index, value in ipairs(arr) do
    print("  index:", index, "value:", value)
end

-- pairs：遍历所有键值对，包括nil值的位置（但位置会被跳过）
print("\npairs遍历：")
for key, value in pairs(arr) do
    print("  key:", key, "value:", value)
end

-- 有空洞的数组对比
local sparseArr = {10, 20, nil, 40, nil, 60}
print("\n稀疏数组 ipairs:")
for i, v in ipairs(sparseArr) do
    print("  ", i, v)
end
-- ipairs在nil处停止，只输出10,20

print("\n稀疏数组 pairs:")
for i, v in pairs(sparseArr) do
    print("  ", i, v)
end
-- pairs会输出所有存在的键值对，但跳过nil

-- 字典遍历只能用pairs
local dict = {name = "Alice", age = 25, city = "Beijing"}
print("\n字典只能用pairs:")
for key, value in pairs(dict) do
    print("  ", key, "=", value)
end

-- ============================
-- Q4: break和return的区别？
-- ============================

-- break：跳出当前循环，继续执行循环之后的代码
local found = false
for i = 1, 10 do
    if i == 6 then
        found = true
        break  -- 找到就退出循环，不是不再执行
    end
end
print("found:", found)  -- true

-- return：退出当前函数（或脚本文件）
local function checkValue(x)
    if x < 0 then
        return nil, "负数不支持"
    end
    if x > 100 then
        return nil, "超出范围"
    end
    return x * 2, "计算成功"
end

local result, msg = checkValue(-5)
print("checkValue(-5):", result, msg)

result, msg = checkValue(50)
print("checkValue(50):", result, msg)

-- 注意：return在循环中使用时，必须在end之前，不能直接在do...end中间
-- 正确写法：
for i = 1, 10 do
    if i == 5 then
        goto done  -- 或者用其他方式
    end
end
::done::
print("done with loop")

-- Lua 5.2+ 支持goto，可以实现更灵活的控制流

-- ============================
-- 深入: 条件判断真假/短路求值
-- ============================

-- Lua假值只有两个：nil和false
-- 其他都是真值：0, "", {}, function() end等

-- 短路求值：and/or从左到右求值，遇到能确定结果时就停止
local function a() print("a called"); return true end
local function b() print("b called"); return false end

print("\n--- 短路求值 ---")
-- a() or b()：a()返回true，整个表达式已经确定为true，不调用b()
print("a() or b():")
result = a() or b()  -- 只调用a

-- a() and b()：a()返回true，不能确定结果，继续调用b()
print("\na() and b():")
result = a() and b()  -- 调用a和b

-- nil and x：nil本身是假值，直接返回nil，不求值x
-- false and x：false是假值，直接返回false，不求值x

-- 典型用法：三目运算符
local function ternary(cond, a, b)
    return cond and a or b
end
print("\nternary(true, 1, 2):", ternary(true, 1, 2))
print("ternary(false, 1, 2):", ternary(false, 1, 2))
print("ternary(nil, 1, 2):", ternary(nil, 1, 2))

-- 用and/or实现默认值
local function withDefault(value, default)
    return value or default
end
print("\nwithDefault(nil, 'default'):", withDefault(nil, "default"))
print("withDefault('hello', 'default'):", withDefault('hello', 'default'))

-- ============================
-- 示例：完整可运行脚本
-- ============================

-- 模拟成绩等级分类器
local function gradeClassifier(scores)
    local results = {
        excellent = {},  -- >= 90
        good = {},       -- >= 80
        pass = {},       -- >= 60
        fail = {}        -- < 60
    }
    
    for i, score in ipairs(scores) do
        if score >= 90 then
            table.insert(results.excellent, score)
        elseif score >= 80 then
            table.insert(results.good, score)
        elseif score >= 60 then
            table.insert(results.pass, score)
        else
            table.insert(results.fail, score)
        end
    end
    
    return results
end

local scores = {85, 92, 78, 55, 67, 88, 91, 45, 73, 99}
local grouped = gradeClassifier(scores)

print("成绩分组结果:")
print("优秀:", table.concat(grouped.excellent, ", "))
print("良好:", table.concat(grouped.good, ", "))
print("及格:", table.concat(grouped.pass, ", "))
print("不及格:", table.concat(grouped.fail, ", "))

-- 查找第一个不及格学生
local function findFirstFail(scores)
    for i, score in ipairs(scores) do
        if score < 60 then
            return i, score  -- 返回索引和分数
        end
    end
    return nil, "没有不及格"
end

local idx, score = findFirstFail(scores)
print("\n第一个不及格: 索引=" .. tostring(idx) .. ", 分数=" .. score)

print("\n=== 第3章结束 ===")
