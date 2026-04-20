-- === 第9章 Table——Lua的核心 ===

--[[
  本章目标：
  1. 掌握数组用法、索引、长度#
  2. 掌握字典用法、键值对、混合使用
  3. 掌握table.insert/remove/concat
  4. 理解table.unpack vs table.move

  核心问题：
  Q1: 为什么table既是数组又是字典？
  Q2: #为什么不是精确长度？
  Q3: 扩容的代价是什么？
  深入: hash部分与array部分的实现
]]

-- ============================
-- Q1: 为什么table既是数组又是字典？
-- ============================

-- Lua的table是唯一的数据结构，同时充当：
-- 1. 数组（连续整数索引从1开始）
-- 2. 字典（任意类型键值对）
-- 3. 对象（方法和状态）

-- 数组用法
local arr = {10, 20, 30, 40, 50}
print("数组arr:", arr[1], arr[2], arr[3])
print("长度#arr:", #arr)

-- 字典用法
local dict = {
    name = "Alice",
    age = 25,
    city = "Beijing"
}
print("\n字典dict:", dict.name, dict["age"])

-- 混合使用（同一个table既有数组部分又有字典部分）
local mixed = {10, 20, 30, name = "Bob", active = true}
print("\n混合table:")
print("  数组部分:", mixed[1], mixed[2], mixed[3])
print("  字典部分:", mixed.name, mixed.active)

-- 内部实现：table分成数组部分和hash部分
-- 数组部分：存储整数键1,2,3...n（高效，O(1)索引）
-- Hash部分：存储其他类型键（O(1)查找）

-- ============================
-- Q2: #为什么不是精确长度？
-- ============================

-- #操作符返回table的"长度"，但不是精确的元素个数
-- 它返回最大的整数索引连续数组部分的长度

-- 连续数组部分的定义：从1开始，索引连续，没有空洞

-- 有空洞的情况
local sparse = {10, 20, nil, 40, 50}
print("\n稀疏数组sparse:")
print("  #sparse:", #sparse)  -- 不一定是3
print("  table.maxn:", table.maxn(sparse))  -- 最大整数索引

-- 为什么这样设计？
-- 1. 性能：#是O(1)，不用遍历
-- 2. 语义：数组部分天然是没有nil的连续区域

-- 安全获取长度的方法
local function safeLen(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

-- 或者用ipairs（遇到nil停止）
local function arrayLen(t)
    local count = 0
    for _ in ipairs(t) do
        count = count + 1
    end
    return count
end

print("  safeLen:", safeLen(sparse))
print("  arrayLen:", arrayLen(sparse))

-- 特殊情况：空table或纯字典
local empty = {}
local pureDict = {a = 1, b = 2}
print("\n空table #:", #empty)  -- 0
print("纯字典 #:", #pureDict)  -- 0

-- ============================
-- Q3: 扩容的代价是什么？
-- ============================

-- Lua的table使用渐进式扩容（power of 2）
-- 当数组满了，自动扩容到2倍容量

-- 扩容过程：
-- 1. 分配新的更大的table
-- 2. 把所有元素复制到新table
-- 3. 旧table等待GC

-- 扩容代价：O(n)，n是元素个数
-- 频繁扩容会降低性能

-- 预分配容量优化
-- Lua 5.3+ 可以用 table.create(n, hint)
--[[
local t = table.create(1000, 0)  -- 预分配1000个元素容量
for i = 1, 1000 do
    t[i] = i
end
]]

-- 或者通过赋值预热容量
local function preallocate(size)
    local t = {}
    for i = 1, size do
        t[i] = true  -- 先填满
    end
    for i = size, 1, -1 do
        t[i] = nil  -- 再清空
    end
    return t
end

-- ============================
-- 深入: hash部分与array部分的实现
-- ============================

-- table的内存布局：
-- +-------------+
-- | array part  |  索引1,2,3...n的连续整数键
-- +-------------+
-- | hash part   |  其他类型的键值对
-- +-------------+

-- array部分的扩容阈值：50%
-- 当数组元素占用超过50%时，扩容

-- hash部分使用闭散列（closed hashing）
-- 如果hash冲突，用线性探测找空位

-- 键的hash算法：
-- Lua使用字符串的混合hash（string hash）
-- 对于数字，直接转为指针索引

-- nil的特殊性：
-- nil值会导致键被"删除"
-- 所以{1, nil, 3}的数组部分是[1, _, 3]，_会被跳过

-- ============================
-- 示例：完整可运行脚本
-- ============================

-- table操作函数库

-- map: 对数组每个元素执行函数
local function map(t, func)
    local result = {}
    for i, v in ipairs(t) do
        result[i] = func(v, i)
    end
    return result
end

-- filter: 过滤数组
local function filter(t, pred)
    local result = {}
    for i, v in ipairs(t) do
        if pred(v, i) then
            table.insert(result, v)
        end
    end
    return result
end

-- reduce: 归约数组
local function reduce(t, func, init)
    local acc = init
    for i, v in ipairs(t) do
        acc = func(acc, v, i)
    end
    return acc
end

-- 使用示例
local nums = {1, 2, 3, 4, 5}

print("--- table操作示例 ---")
print("原始数组:", table.concat(nums, ", "))

local doubled = map(nums, function(x) return x * 2 end)
print("map(x*2):", table.concat(doubled, ", "))

local evens = filter(nums, function(x) return x % 2 == 0 end)
print("filter偶数:", table.concat(evens, ", "))

local sum = reduce(nums, function(acc, x) return acc + x end, 0)
print("reduce求和:", sum)

local product = reduce(nums, function(acc, x) return acc * x end, 1)
print("reduce求积:", product)

-- table.unpack vs table.move
print("\n--- unpack vs move ---")

local source = {10, 20, 30, 40, 50}

-- table.unpack: 解包table为多个值
local a, b, c = table.unpack(source, 1, 3)
print("unpack(source,1,3):", a, b, c)

-- table.move: 移动或复制table的元素（Lua 5.3+）
-- table.move(src, start, end, destPos, [dest])
--[[
local dest = {}
table.move(source, 1, 3, 1, dest)  -- 复制source[1:3]到dest[1:]
print("move结果:", dest[1], dest[2], dest[3])
]]

-- 实现自己的unpack（递归）
local function myUnpack(t, i, j)
    i = i or 1
    j = j or #t
    if i > j then
        return  -- 返回零个值
    end
    return t[i], myUnpack(t, i + 1, j)
end

print("myUnpack:", myUnpack(source, 1, 3))

-- 练习：实现groupBy
local function groupBy(t, keyFunc)
    local groups = {}
    for _, v in ipairs(t) do
        local key = keyFunc(v)
        if not groups[key] then
            groups[key] = {}
        end
        table.insert(groups[key], v)
    end
    return groups
end

local users = {
    {name = "Alice", dept = "Engineering"},
    {name = "Bob", dept = "Sales"},
    {name = "Charlie", dept = "Engineering"},
    {name = "David", dept = "Sales"}
}

print("\n--- groupBy示例 ---")
local byDept = groupBy(users, function(u) return u.dept end)
for dept, members in pairs(byDept) do
    print(dept .. ":")
    for _, u in ipairs(members) do
        print("  - " .. u.name)
    end
end

print("\n=== 第9章结束 ===")
