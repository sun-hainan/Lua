-- ============================================================
-- 模块二：变量与数据类型
-- 变量/常量/作用域/生命周期/基本类型/引用类型/类型转换/空值/进制
-- ============================================================

-- 【问题1】Lua 的变量声明有哪些方式？全局 vs 局部？
--
-- Lua 变量：
--   - 全局变量：直接赋值，无需声明
--   - 局部变量：local 关键字声明
--
-- 推荐：始终使用 local，除非确实需要全局变量
-- 原因：
--   - local 访问更快（寄存器 vs 全局表查找）
--   - 避免命名冲突
--   - 作用域明确

-- 局部变量（推荐）
local name = "Alice"
print("local name:", name)

-- 全局变量（不推荐）
age = 30  -- 全局变量，挂在 _G 表中
print("global age:", age)

-- 多个变量赋值
local x, y, z = 1, 2, 3
print("multiple:", x, y, z)

-- 【问题2】Lua 的数据类型有哪些？
--
-- Lua 8 种基本类型：
--   nil         - 空值
--   boolean     - true/false
--   number      - 整数和浮点数（双精度）
--   string      - 字符串
--   function    - 函数
--   table       - 表（唯一复合类型）
--   userdata    - 用户数据（C 结构）
--   thread      - 协程/线程
--
-- 可以用 type() 函数查看类型

local type_examples = {
    {value = nil,       desc = "空值"},
    {value = true,      desc = "布尔"},
    {value = 42,        desc = "数字"},
    {value = "hello",   desc = "字符串"},
    {value = function() end, desc = "函数"},
    {value = {},        desc = "表"},
}

for _, item in ipairs(type_examples) do
    print(string.format("%-10s -> %s", type(item.value), item.desc))
end

-- 【问题3】Lua 的 table（表）是什么？为什么重要？
--
-- table 是 Lua 唯一的复合类型，可以：
--   - 作为数组（索引从 1 开始）
--   - 作为字典/映射
--   - 作为对象/结构体
--   - 作为命名空间
--
-- 核心概念：
--   - 键值对存储
--   - 动态大小
--   - 引用语义（table 是引用类型）

-- 数组用法
local arr = {10, 20, 30, 40, 50}
print("arr[1]:", arr[1])  -- Lua 索引从 1 开始
print("arr length:", #arr)

-- 字典用法
local dict = {name = "Alice", age = 30}
print("dict.name:", dict.name)
print("dict['age']:", dict["age"])

-- 混合用法
local mixed = {
    "string",           -- arr[1]
    42,                 -- arr[2]
    key = "value",      -- dict.key
    nested = {a = 1, b = 2}  -- 嵌套
}
print("mixed[1]:", mixed[1])
print("mixed.key:", mixed.key)
print("mixed.nested.a:", mixed.nested.a)

-- 【问题4】Lua 的作用域规则是什么？
--
-- Lua 作用域层级：
--   1. 全局作用域（_G）
--   2. 模块作用域（文件级 local）
--   3. 函数作用域
--   4. 块作用域（if/for/while 内）
--
-- upvalue：内部函数引用外部局部变量

local module_level = "module"

local function outer()
    local outer_local = "outer"

    local function inner()
        local inner_local = "inner"
        -- upvalue：inner 可以访问 outer_local
        print("inner sees:", outer_local)
        print("inner sees module:", module_level)
    end

    inner()
    -- print(inner_local)  -- ❌ outer 无法访问 inner 的局部变量
end

outer()

-- 块级作用域示例
if true then
    local block_var = "in block"
    print("inside block:", block_var)
end
-- print(block_var)  -- ❌ 块外无法访问

-- 【问题5】Lua 的 nil 和 false 的区别是什么？
--
-- 都是"假"值，但语义不同：
--   - nil：表示"没有值"，未定义
--   - false：明确是"假"
--
-- 使用场景：
--   - nil：可选参数默认值，未找到的结果
--   - false：明确的布尔状态

local function test_nil_false()
    local not_set = nil       -- 未定义
    local explicitly_false = false  -- 明确为假

    print("nil is falsy:", not not_set)           -- true
    print("false is falsy:", not explicitly_false)  -- true

    -- nil 用来"删除"
    local temp = 100
    temp = nil  -- 删除变量

    -- false 用来"设置状态"
    local is_enabled = false

    return not_set, explicitly_false
end

local a, b = test_nil_false()
print("returned nil:", a)
print("returned false:", b)

-- 【问题6】Lua 的数字类型如何处理进制？
--
-- Lua number 是双精度浮点数（IEEE 754 64位）
-- 支持多种进制字面量：
--   - 十进制：42
--   - 十六进制：0xFF
--   - 科学计数法：1.5e10

local number_samples = {
    decimal = 42,
    hex = 0xFF,              -- 255
    binary = 0b1010,         -- 10 (Lua 5.3+)
    octal = 0o77,            -- 63 (Lua 5.3+)
    scientific = 1.5e10,
    negative = -273.15,
}

for name, val in pairs(number_samples) do
    print(string.format("%-10s = %s (0x%x)", name, val, val))
end

-- 字符串到数字转换
local str_num = "255"
local converted = tonumber(str_num)
print("tonumber('255'):", converted)

-- 带进制转换
print("tonumber('FF', 16):", tonumber("FF", 16))
print("tonumber('1010', 2):", tonumber("1010", 2))

-- 【问题7】Lua 的类型转换规则是什么？
--
-- Lua 自动转换：
--   - 数字和字符串在运算时自动转换
--   - tostring() 数字转字符串
--   - tonumber() 字符串转数字
--
-- 注意：Lua 不支持隐式布尔转换（需要显式比较）

-- 字符串拼接会自动转换数字
local num = 42
print("string concat:", num .. " is the answer")  -- "42 is the answer"

-- 算术运算会自动转换字符串数字
print("string + number:", "123" + 1)  -- 124

-- 但字符串拼接不是算术运算
-- print("hello" + 1)  -- ❌ 错误：尝试对字符串做算术

-- 显式转换
local function explicit_conversion()
    local num = 42
    local str = tostring(num)
    print("tostring(42):", str, type(str))

    local back = tonumber(str)
    print("tonumber('42'):", back, type(back))

    local invalid = tonumber("hello")
    print("tonumber('hello'):", invalid)  -- nil

    -- 格式化数字为字符串
    local formatted = string.format("%.2f", 3.14159)
    print("formatted:", formatted)
end

explicit_conversion()

-- 【问题8】Lua 的字符串操作有哪些？
--
-- Lua 字符串是不可变的字节序列
-- 常用操作：
--   - 拼接：..（两个点）
--   - 长度：#str
--   - 切片：string.sub(s, i, j)
--   - 查找：string.find(s, pattern)
--   - 替换：string.gsub(s, pattern, replacement)

local function string_operations()
    local s = "Hello, World!"

    -- 长度
    print("length:", #s)

    -- 拼接
    local greeting = "Hello" .. ", " .. "World!"
    print("concatenation:", greeting)

    -- 切片
    print("sub(1,5):", s:sub(1, 5))      -- Hello
    print("sub(-6):", s:sub(-6))          -- World!

    -- 大小写
    print("upper:", s:upper())
    print("lower:", s:lower())

    -- 查找
    local start, ends = s:find("World")
    print("find 'World':", start, ends)

    -- 替换
    print("gsub:", s:gsub("World", "Lua"))

    -- 分割（Lua 没有内置，需要手写或用正则）
    local parts = {}
    for part in s:gmatch("[^, ]+") do
        table.insert(parts, part)
    end
    print("split:", table.concat(parts, ", "))
end

string_operations()

-- ============================================================
-- 【对比】Rust vs Lua vs Python
-- ============================================================
-- Rust:
--   - let 声明变量，默认不可变，mut 可变
--   - 所有权：每个值唯一所有者，move 语义
--   - 借用：& 不可变，&mut 可变，无空引用
--   - Option<T> 替代 null
--   - 基本类型：i32/u32/f64/bool/char

-- Lua:
--   - local 声明变量，全局变量直接赋值
--   - 无所有权概念，垃圾回收自动处理
--   - 变量直接访问，无借用概念
--   - nil 表示空值（Lua 唯一"空"的表示）
--   - 基本类型：nil/boolean/number/string/function/table/userdata/thread
--   - 类型转换自动进行（"123" + 1 = 124）

-- Python:
--   - x = value，动态类型，可重新赋值
--   - 垃圾回收（引用计数）
--   - 无借用概念
--   - None 表示空值
--   - 基本类型：int/float/bool/str/complex

function compare_types()
    print("=== 三语言对比：变量与类型 ===")

    -- Lua 的 nil vs Rust 的 None vs Python 的 None
    local lua_nil = nil
    local lua_false = false

    print("Lua nil is:", type(lua_nil))
    print("Lua false is:", type(lua_false))

    -- Lua 的 table 既是数组又是字典
    local arr = {1, 2, 3}      -- 数组
    local dict = {a = 1, b = 2}  -- 字典
    print("array:", arr[1], arr[2])
    print("dict:", dict.a, dict.b)
end

-- ============================================================
-- 练习题
-- ============================================================
-- 1. 解释 Lua 的 table 为什么索引从 1 开始
-- 2. 比较 nil、false、0 在 Lua 中的布尔判断
-- 3. 实现一个字符串反转函数

-- ============================================================
-- 总结
-- ============================================================
-- | 类型         | Lua 说明                                     |
-- |-------------|----------------------------------------------|
-- | nil         | 空值，删除变量                               |
-- | boolean     | true / false（注意：nil 也是 falsy）         |
-- | number      | 双精度浮点数，支持多进制                     |
-- | string      | 不可变字节序列，用 .. 拼接                   |
-- | table       | 唯一复合类型，可作数组/字典/对象             |
-- | function    | 一等公民，可存储/传递/闭包                   |
-- | userdata    | C 结构体                                    |
-- | thread      | 协程                                        |

local function main()
    print("=== 模块二：变量与数据类型 ===")

    compare_types()

    print("\n✅ 所有示例运行成功！")
end

main()