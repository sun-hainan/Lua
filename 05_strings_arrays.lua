-- ============================================================
-- 模块五：字符串与数组
-- 字符串操作 / 数组增删改查 / 排序 / 二分查找
-- ============================================================

-- 【问题1】Lua 的字符串操作有哪些？
--
-- Lua 字符串是不可变的字节序列
-- 标准库 string 提供丰富操作：
--   - string.sub(s, i, j)：切片
--   - string.find(s, pattern)：查找
--   - string.gsub(s, pattern, repl)：替换
--   - string.format()：格式化
--   - string.rep(s, n)：重复
--   - string.reverse(s)：反转

local function string_operations()
    local s = "Hello, World!"

    -- 长度（与 # 等价）
    print("length:", #s)
    print("string.len:", string.len(s))

    -- 切片
    print("sub(1, 5):", s:sub(1, 5))
    print("sub(-6):", s:sub(-6))
    print("sub(8, -1):", s:sub(8, -1))

    -- 大小写
    print("upper:", s:upper())
    print("lower:", s:lower())

    -- 查找
    local start, ends = s:find("World")
    print("find 'World':", start, ends)
    print("find 'lua':", s:find("lua"))  -- nil

    -- 反转
    print("reverse:", s:reverse())

    -- 重复
    print("repeat:", "abc":rep(3))

    -- 替换
    print("gsub:", s:gsub("World", "Lua"))

    -- 格式化
    local pi = string.format("PI = %.4f", 3.14159)
    print(pi)

    -- 分割（需要手写或用正则）
    local function split(s, delimiter)
        local result = {}
        local pattern = string.format("([^%s]+)", delimiter)
        for word in s:gmatch(pattern) do
            table.insert(result, word)
        end
        return result
    end

    local parts = split("apple,banana,cherry", ",")
    print("split result:", table.concat(parts, ", "))
end

string_operations()

-- 【问题2】Lua 的数组（table）增删改查如何实现？
--
-- Lua 的数组就是 table（索引从 1 开始）
--
-- 常用操作：
--   - 增：table.insert(t, val) 或 t[#t+1] = val
--   - 删：table.remove(t, index)
--   - 改：t[index] = value
--   - 查：t[index]，#t 获取长度

local function array_operations()
    local arr = {10, 20, 30, 40, 50}

    -- 查（索引）
    print("arr[1]:", arr[1])
    print("arr[#arr]:", arr[#arr])
    print("#arr:", #arr)

    -- 增
    table.insert(arr, 60)
    print("after insert 60:", table.concat(arr, ", "))

    -- 在指定位置插入
    table.insert(arr, 3, 25)  -- 在索引3插入
    print("after insert 25 at 3:", table.concat(arr, ", "))

    -- 改
    arr[1] = 100
    print("after set arr[1]=100:", table.concat(arr, ", "))

    -- 删
    table.remove(arr, 3)  -- 删除索引3
    print("after remove 3:", table.concat(arr, ", "))

    -- 删除最后一个
    table.remove(arr)
    print("after remove last:", table.concat(arr, ", "))

    -- 遍历
    print("遍历:")
    for i, v in ipairs(arr) do
        print(string.format("  [%d] = %d", i, v))
    end
end

array_operations()

-- 【问题3】Lua 的 table.sort 如何排序？有几种方式？
--
-- table.sort(t)：原地排序
-- table.sort(t, comp)：自定义比较函数
--
-- 注意：
--   - 排序是原地修改，不返回新 table
--   - 默认升序
--   - 字典序排序

local function sorting_demo()
    local nums = {5, 2, 8, 1, 9, 3, 7, 4, 6}

    -- 默认升序
    table.sort(nums)
    print("sorted:", table.concat(nums, ", "))

    -- 降序
    table.sort(nums, function(a, b) return a > b end)
    print("sorted desc:", table.concat(nums, ", "))

    -- 字符串排序
    local names = {"Charlie", "Alice", "Bob", "David"}
    table.sort(names)
    print("names sorted:", table.concat(names, ", "))

    -- 按长度排序
    table.sort(names, function(a, b) return #a < #b end)
    print("names by length:", table.concat(names, ", "))

    -- 稳定排序？不保证
    local pairs = {{"a", 1}, {"b", 2}, {"a", 3}}
    table.sort(pairs, function(a, b) return a[1] < b[1] end)
    -- 相同的 "a" 的相对顺序不保证
end

sorting_demo()

-- 【问题4】Lua 如何实现二分查找？
--
-- 二分查找：O(log n)，要求已排序数组
--
-- 注意：Lua 没有内置二分查找，需要手写

local function binary_search(arr, target)
    local left, right = 1, #arr

    while left <= right do
        local mid = math.floor((left + right) / 2)
        if arr[mid] == target then
            return mid  -- 找到
        elseif arr[mid] < target then
            left = mid + 1
        else
            right = mid - 1
        end
    end

    return nil  -- 未找到
end

local function binary_search_demo()
    local sorted = {1, 3, 5, 7, 9, 11, 13, 15}

    print("array:", table.concat(sorted, ", "))
    print("find 7:", binary_search(sorted, 7))
    print("find 8:", binary_search(sorted, 8))
    print("find 1:", binary_search(sorted, 1))
    print("find 15:", binary_search(sorted, 15))
end

binary_search_demo()

-- 【问题5】Lua 的字符串模式（pattern）如何匹配？
--
-- Lua 模式（类似于正则，但简化）：
--   .  - 任意字符
--   %a - 字母
--   %c - 控制字符
--   %d - 数字
--   %l - 小写字母
--   %u - 大写字母
--   %w - 字母数字
--   %s - 空白字符
--   %p - 标点
--   %x - 十六进制数字
--
-- 量词：
--   * - 0或多个
--   + - 1或多个
--   - - 0或多个（最小匹配）
--   ? - 0或1
--
-- 转义：%

local function pattern_matching()
    -- 查找数字
    local text = "abc123def456"
    for num in text:gmatch("%d+") do
        print("found number:", num)
    end

    -- 查找单词
    local sentence = "Hello, world! Lua is great."
    for word in sentence:gmatch("%a+") do
        print("word:", word)
    end

    -- 邮箱匹配（简化）
    local email = "user@example.com"
    local pattern = "[%w_]+@[%w_]+%.[%w_]+"
    if email:match(pattern) then
        print(email, "is valid email")
    end

    -- 捕获
    local log = "2024-01-15 10:30:45 ERROR something failed"
    local date, time, level, msg = log:match("(%d+-%d+-%d+) (%d+:%d+:%d+) (%a+) (.+)")
    print("parsed:", date, time, level, msg)

    -- 转义
    print("match%.lua:", "test.lua":match("test%.lua"))
end

pattern_matching()

-- 【问题6】Lua 的多维数组如何实现？
--
-- Lua 用嵌套 table 实现多维数组

local function multidimensional_array()
    -- 固定大小矩阵
    local matrix = {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9},
    }

    -- 访问
    print("matrix[2][3]:", matrix[2][3])

    -- 遍历
    for i = 1, #matrix do
        for j = 1, #matrix[i] do
            io.write(matrix[i][j], " ")
        end
        print()
    end

    -- 不规则矩阵（每行长度不同）
    local ragged = {
        {1, 2},
        {3, 4, 5, 6},
        {7},
    }
    for i = 1, #ragged do
        print("row", i, ":", table.concat(ragged[i], ", "))
    end

    -- 动态创建
    local rows, cols = 3, 4
    local dynamic = {}
    for i = 1, rows do
        dynamic[i] = {}
        for j = 1, cols do
            dynamic[i][j] = i * cols + j
        end
    end
    print("dynamic[2][3]:", dynamic[2][3])
end

multidimensional_array()

-- 【问题7】Lua 的字符串转换（数字和进制）如何处理？
--
-- tonumber(s, base)：字符串转数字
-- string.format：数字转字符串
--
-- 进制支持：2, 8, 10, 16

local function string_number_conversion()
    -- 基本转换
    print("tonumber('123'):", tonumber("123"))
    print("tonumber('FF', 16):", tonumber("FF", 16))
    print("tonumber('1010', 2):", tonumber("1010", 2))

    -- 进制转换
    local num = 255
    print("to hex:", string.format("%x", num))
    print("to binary:", string.format("%b", num))
    print("to string:", tostring(num))

    -- 反向：十六进制字符串转数字
    print("hex 'FF' to num:", tonumber("FF", 16))

    -- 格式化输出
    print("formatted:", string.format("0x%02X", 255))
    print("padded:", string.format("%05d", 42))
    print("float:", string.format("%.2f", 3.14159))
end

string_number_conversion()

-- ============================================================
-- 【对比】Rust vs Lua vs Python
-- ============================================================
-- Rust:
--   - String（堆，可变）和 &str（切片引用）分离
--   - Vec<T> 是动态数组，数组是固定长度 [T; N]
--   - 字符串是 UTF-8 编码，索引按字节而非字符
--   - sort 是原地排序，binary_search 需要已排序数组

-- Lua:
--   - 字符串是不可变字节序列，支持模式匹配（Lua 自己的模式）
--   - table 是 Lua 的数组/映射，可以作为动态数组使用
--   - 无内置 sort，但 table.sort 可以排序数组部分
--   - string.sub 按字节索引，不是 Unicode 字符
--   - 字符串拼接用 ..（性能考虑用 table.concat）

-- Python:
--   - str 是 Unicode 不可变字符串
--   - list 是动态数组，支持增删改查
--   - sorted() 返回新数组，list.sort() 原地排序
--   - bisect 模块提供二分查找
--   - re 模块提供正则表达式

function compare_string_array()
    print("=== 三语言字符串数组对比 ===")

    -- Lua 字符串索引陷阱
    local s = "你好"
    print("Lua: '你好' len=# =", #s, ", 字节数")
    print("Lua: string.len =", string.len(s))

    -- Rust: len=6, chars=2
    -- Python: len('你好') = 2
    -- Lua: #"你好" = 6（字节数）

    -- Lua 的 table 既是数组又是字典
    local arr = {1, 2, 3}
    local dict = {a = 1, b = 2}
    print("Lua: arr[1] =", arr[1])
    print("Lua: dict.a =", dict.a)
end

-- ============================================================
-- 练习题
-- ============================================================
-- 1. 实现一个函数，统计字符串中单词数量（空格分隔）
-- 2. 实现字符串反转函数（处理多字节字符）
-- 3. 用 Lua 实现一个二维矩阵乘法
-- 4. 实现冒泡排序

-- ============================================================
-- 总结
-- ============================================================
-- | 功能       | Lua 实现                                    |
-- |-----------|-------------------------------------------|
-- | 字符串长度 | #s 或 string.len(s)                        |
-- | 切片       | s:sub(i, j)                                |
-- | 查找       | s:find(pattern)                            |
-- | 替换       | s:gsub(pattern, repl)                      |
-- | 数组长度   | #t                                         |
-- | 排序       | table.sort(t, comp)                        |
-- | 二分查找   | 手写                                       |
-- | 多维数组   | 嵌套 table                                 |

local function main()
    print("=== 模块五：字符串与数组 ===")

    string_operations()
    array_operations()
    sorting_demo()
    binary_search_demo()
    pattern_matching()
    multidimensional_array()
    string_number_conversion()
    compare_string_array()

    print("\n✅ 所有示例运行成功！")
end

main()