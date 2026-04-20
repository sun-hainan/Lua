# Lua Tutorial

Comprehensive Lua programming tutorial with problem-driven approach, deep principles, and complete system coverage.

## 17 Modules

| Module | File | Core Content |
|--------|------|-------------|
| 模块一 | 01_code_basics.lua | 代码规范与基础（注释/缩进/标识符/关键字） |
| 模块二 | 02_variables_types.lua | 变量与数据类型（变量/常量/作用域/生命周期/基本类型/引用类型/类型转换/空值/进制） |
| 模块三 | 03_operators.lua | 运算符与表达式（算术/赋值/关系/逻辑/位运算/三目/优先级） |
| 模块四 | 04_control_flow.lua | 流程控制（if/else/switch/match/循环/break/continue/异常） |
| 模块五 | 05_strings_arrays.lua | 字符串与数组（字符串操作/数组增删改查/排序/二分查找） |
| 模块六 | 06_functions_methods.lua | 函数/方法（定义/调用/重载/重写/递归/值传递vs引用传递/Lambda/闭包） |
| 模块七 | 07_oop.lua | 面向对象OOP（封装/继承/多态/类与对象/修饰符/抽象类/接口/内部类） |
| 模块八 | 08_collections.lua | 集合框架（List/Set/Map/泛型/工具类） |
| 模块九 | 09_io_file.lua | IO流与文件（路径/字节流/字符流/缓冲流/序列化） |
| 模块十 | 10_exceptions_debug.lua | 异常处理与调试（异常分类/自定义/断点/日志） |
| 模块十一 | 11_concurrency.lua | 并发编程（协程/生产者-消费者/迭代器/状态机） |
| 模块十二 | 12_reflection_metaprogramming.lua | 反射与元编程（动态创建/注解/动态代码执行） |
| 模块十三 | 13_networking.lua | 网络编程（TCP/UDP/Socket/HTTP） |
| 模块十四 | 14_dsa.lua | 数据结构与算法（链表/栈/队列/哈希表/树/排序/查找/复杂度） |
| 模块十五 | 15_database.lua | 数据库编程（SQL/事务/ORM/NoSQL） |
| 模块十六 | 16_engineering_design.lua | 工程化与设计思想（设计模式/代码优化/Git/CI） |
| 模块十七 | 17_event_system.lua | 信息分发与事件系统（观察者/EventEmitter/信号槽/消息队列/中间件） |

## 适用人群

- **游戏开发者**：Lua 是 Roblox (Luau)、World of Warcraft、Garry's Mod 等主流游戏的核心脚本语言
- **嵌入式/配置脚本**：Nginx (OpenResty)、Redis、Vim 配置等广泛使用 Lua
- **快速原型开发**：轻量级动态语言，适合构建原型和自动化脚本
- **学习编程**：语法简洁，概念纯粹，适合作为第二门语言入门
- **DevOps/网络工程师**：OpenResty 生态中的 Web 开发、API 网关、自动化运维

## Lua 语言特色总结

Lua 有五个核心特性，使其在嵌入式和游戏脚本领域无可替代：

### 1. Table —— 唯一复合类型，却无所不能

Table 是 Lua 的灵魂，所有复杂数据结构都由它实现：
- **数组**：`{1, 2, 3}` — 索引从 1 开始
- **字典**：`{name = "Alice", age = 30}`
- **对象**：`setmetatable(obj, {__index = methods})`
- **模块**：`local M = {}; return M`
- **命名空间**：`math.random()` 实际上是 table 的键查找

```lua
-- Table 可以嵌套任意深度
local data = {
    users = {
        {name = "Alice", scores = {98, 87, 92}},
        {name = "Bob", scores = {85, 91, 89}},
    }
}
```

### 2. Metatable / Metamethod —— 运算符重载与原型继承

Metatable 让你拦截和控制任何对 table 的操作，是 Lua OOP 的基石：

```lua
-- 运算符重载
Vec2 = {}
Vec2.__add = function(a, b) return Vec2:new(a.x + b.x, a.y + b.y) end
Vec2.__tostring = function(a) return "(" .. a.x .. "," .. a.y .. ")" end

-- 原型继承（每个对象的 __index 指向父类）
local Animal = {name = "unnamed"}
Animal.__index = Animal
local dog = setmetatable({name = "Rex"}, {__index = Animal})
-- dog:speak() 会沿着 metatable 链找到 Animal.speak
```

关键 metamethod：`__index`（查键）、`__newindex`（设键）、`__add`/`__mul` 等运算符、`__call`（使对象可调用）、`__tostring`、`__len`。

### 3. Coroutine —— 轻量级协作式并发

协程是 Lua 最强大的特性之一（相比 Python 的 generator 更接近真正的协程）：

```lua
-- 生产者-消费者
local function producer(max)
    return coroutine.create(function()
        for i = 1, max do coroutine.yield(i) end
    end)
end

-- 迭代器
local function range(from, to)
    return coroutine.create(function()
        for i = from, to do coroutine.yield(i) end
    end)
end
```

注意：Lua 协程是**单线程协作式**，不是抢占式多线程。没有内置的多线程支持（需要 LuaJIT + FFI 调用 pthread，或 OpenResty 的多 worker 架构）。

### 4. First-Class Function + Closure —— 自然的函数式编程

Lua 函数是「第一等公民」，闭包是语言内置特性，无需任何语法糖：

```lua
local function counter(start)
    local count = start  -- upvalue：内部函数可访问
    return function()
        count = count + 1
        return count
    end
end
```

这使得高阶函数、记忆化、工厂模式实现起来非常自然。

### 5. FFI（Foreign Function Interface）—— LuaJIT 的杀手级特性

LuaJIT 的 FFI 允许直接调用 C 函数，无需编写 C 模块：

```lua
local ffi = require("ffi")
ffi.cdef[[
    int printf(const char *fmt, ...);
    int strlen(const char *s);
]]
ffi.C.printf("Hello %s\n", "World")
```

FFI 让 Lua 拥有接近 C 的性能，同时保持脚本语言的灵活性——这也是 Redis Module、LuaJIT 在高性能场景中广泛使用的原因。

## 学习路线图

```
第一阶段：语言基础（第1-6章，2-3天）
├── 模块1：代码规范与基础（注释/标识符/end）
├── 模块2：变量与数据类型（table是核心）
├── 模块3：运算符与表达式（注意 ~= 和浮点除法）
├── 模块4：流程控制（repeat/for/goto）
├── 模块5：字符串与数组（模式匹配）
└── 模块6：函数与闭包（upvalue是重点）

第二阶段：核心特性（第7-12章，3-5天）
├── 模块7：OOP（metatable 实现类/继承/多态）
├── 模块8：集合框架（弱表/有序字典）
├── 模块9：IO与文件（序列化）
├── 模块10：异常与调试（pcall/xpcall）
├── 模块11：协程（生产者-消费者/迭代器）
└── 模块12：反射与元编程（loadstring/沙箱）

第三阶段：应用拓展（第13-17章，3-5天）
├── 模块13：网络编程（luasocket 需安装）
├── 模块14：数据结构与算法（手写是学习好方式）
├── 模块15：数据库（luasql/redis-lua）
├── 模块16：工程化（LuaRocks/luacheck/busted）
└── 模块17：事件系统（观察者/EventEmitter）

实战项目（可选）
├── 游戏脚本：实现一个文字冒险游戏
├── Web 开发：用 OpenResty 写 API 网关
├── 嵌入式：用 FFI 调用系统库
└── 数据处理：实现一个 JSON 解析器
```

## Features

- **问题驱动**：每节 5-8 个核心问题，围绕问题展开讲解
- **深入原理**：从表象到本质，剖析语言设计思想
- **完整体系**：覆盖 Lua 核心知识点
- **五语对比**：与 Python / Rust / Go / C++ 对比，加深理解
- **完整示例**：每个概念都有可运行的代码示例
- **练习题**：每章 4-5 道具体可操作的练习题

## Running

```bash
# Standard Lua
lua 01_code_basics.lua

# LuaJIT (recommended for performance)
luajit 01_code_basics.lua

# Interactive mode
lua -i 01_code_basics.lua
```

## Requirements

- Lua 5.3+ (or LuaJIT 2.1+)
- luarocks (optional, for additional packages)

## Structure

Each file follows the same structure:
1. 核心问题 - 本章要解决的关键问题
2. 问题解答 - 直接回答核心问题
3. 深入原理 - 剖析底层的实现机制
4. 五语对比 - 与 Python / Rust / Go / C++ 的对比
5. 完整示例 - 可运行的代码示例
6. 练习题 - 巩固所学知识

## 三语对比速查

| 特性 | Lua | Python | Rust | Go | C++ |
|------|-----|--------|------|-----|-----|
| 注释 | `--` | `#` | `//` | `//` | `//` |
| 空值 | `nil` | `None` | `None`/`Option` | `nil` | `nullptr` |
| 布尔假 | `nil, false` | `None, False, 0, ""` | `false` | `false, nil` | `false, nullptr` |
| 字符串拼接 | `..` | `+` | `format!`/`+` | `+`/`fmt` | `+` |
| 数组/列表 | `table` | `list` | `Vec<T>` | `slice` | `std::vector` |
| 字典/映射 | `table` | `dict` | `HashMap` | `map` | `std::unordered_map` |
| 函数定义 | `function f() end` | `def f():` | `fn f()` | `func f()` | `void f()` |
| OOP | `table+metatable` | `class` | `struct+impl` | 无类 | `class` |
| 并发 | 协程 | asyncio/threading | std::thread | goroutine | std::thread |
| 尾调用 | TCO | 无 | 有限支持 | 无 | 无 |
| 泛型 | 无 | `*args/**kwargs` | 强泛型 | 轻量泛型 | 模板 |

## License

MIT License
