-- === 第20章 工程工具链 ===

--[[
  本章目标：
  1. 掌握LuaRocks包管理
  2. 理解luacheck静态分析
  3. 理解luaformatter格式化
  4. 了解性能测试工具
  5. 理解JIT编译优化技巧

  核心问题：
  Q1: rock是什么？
  Q2: 怎么找库？
  Q3: JIT加速了多少？
  深入: JIT编译原理/trace记录
]]

-- ============================
-- Q1: rock是什么？
-- ============================

-- Rock = LuaRocks包
-- LuaRocks是Lua的包管理器（类似npm, pip, gem）

-- 常用命令：
-- luarocks search <name>   搜索包
-- luarocks install <name>  安装包
-- luarocks remove <name>   卸载包
-- luarocks list            列出已安装的包

-- 示例安装：
-- luarocks install luasocket
-- luarocks install luafilesystem
-- luarocks install busted

print("--- LuaRocks示例 ---")
-- 查看已安装的包
-- local installed = require("luarocks_installed")
-- for _, rock in ipairs(installed) do
--     print(rock)
-- end

-- ============================
-- Q2: 怎么找库？
-- ============================

-- 1. luarocks.org 官方仓库
-- 2. github搜索 "lua" + 功能关键词
-- 3. awesome-lua列表

-- 常用库分类：
-- Web: Lapis, OpenResty
-- 数据库: LuaSQL, LuaMongoDB
-- 网络: LuaSocket, cURL
-- JSON: cjson, rapidjson
-- 测试: busted, luatest

-- ============================
-- Q3: JIT加速了多少？
-- ============================

-- LuaJIT是Lua的高性能实现
-- 通常比标准Lua快10-100倍

-- JIT加速的场景：
-- 1. 循环：热点代码被JIT编译
-- 2. 数值计算：SIMD优化
-- 3. 字符串操作：优化过的C实现
-- 4. table操作：高效的hash实现

-- 不被JIT加速的场景：
-- 1. 动态特性：eval, loadstring
-- 2. 复杂类型：userdata
-- 3. FFI调用开销
-- 4. 某些table操作

-- ============================
-- 深入: JIT编译原理
-- ============================

-- LuaJIT使用Tracing JIT
-- 1. 解释执行，发现热点
-- 2. 记录trace（执行路径）
-- 3. 生成机器码
-- 4. 后续执行直接用机器码

-- trace recording：
-- 当循环执行多次后，JIT开始recording
-- 记录循环体的执行路径
-- 编译成高效的机器码

-- 优化技术：
-- 1. 范围分析 - 确定整数边界
-- 2. 类型 specialization - 针对具体类型优化
-- 3. 寄存器分配 - 减少内存访问
-- 4. 指令融合 - 合并多个操作

-- ============================
-- 示例：性能测试
-- ============================

local function benchmark(name, iterations, func)
    local start = os.clock()
    for i = 1, iterations do
        func()
    end
    local elapsed = os.clock() - start
    print(string.format("[%s] %d次迭代，耗时 %.4f秒，平均每次 %.6fms",
        name, iterations, elapsed, (elapsed / iterations) * 1000))
    return elapsed
end

print("\n--- 性能测试示例 ---")

-- table操作
local function testTableOp()
    local t = {}
    for i = 1, 100 do
        t[i] = i
    end
    local sum = 0
    for i = 1, 100 do
        sum = sum + t[i]
    end
    return sum
end

benchmark("table操作", 10000, testTableOp)

-- 字符串拼接
local function testStringConcat()
    local s = ""
    for i = 1, 100 do
        s = s .. i .. ","
    end
    return s
end

benchmark("字符串拼接", 1000, testStringConcat)

-- table.insert
local function testTableInsert()
    local t = {}
    for i = 1, 100 do
        table.insert(t, i)
    end
    return t
end

benchmark("table.insert", 10000, testTableInsert)

-- 预分配
local function testPreallocate()
    local t = {}
    for i = 1, 100 do
        t[i] = true
    end
    for i = 100, 1, -1 do
        t[i] = nil
    end
    return t
end

benchmark("预分配", 10000, testPreallocate)

-- ============================
-- 静态分析工具
-- ============================

print("\n--- 静态分析示例 ---")
-- luacheck检测：
-- - 未使用的变量
-- - 全局变量使用
-- - 潜在的错误

-- 示例代码（有问题）
local problematicCode = [[
local function example()
    local x = 10
    print(y)  -- y未定义
    x = x + 1  -- x重新赋值（未使用局部变量优化）
    return x
end
]]

print("问题代码示例:")
print(problematicCode)
print("\n注释: luacheck会报告y未定义，x重新赋值")

-- ============================
-- 示例：代码格式化
-- ============================

print("\n--- 代码格式化示例 ---")

-- 简单的Lua代码美化器
local function formatLua(code)
    local formatted = {}
    local indent = 0
    local inString = false
    local stringChar = nil
    
    for line in code:gmatch("[^\r\n]+") do
        -- 简单的格式化逻辑
        line = line:gsub("^%s+", "")  -- 去除前导空格
        
        if line:match("then$") or line:match("do$") or line:match("^if ") or line:match("^for ") or line:match("^while ") then
            table.insert(formatted, string.rep("    ", indent) .. line)
            indent = indent + 1
        elseif line:match("^end") or line:match("^else") or line:match("^elseif") then
            indent = math.max(0, indent - 1)
            table.insert(formatted, string.rep("    ", indent) .. line)
        else
            table.insert(formatted, string.rep("    ", indent) .. line)
        end
    end
    
    return table.concat(formatted, "\n")
end

local uglyCode = [[
local function greet(name)
if name then
print("Hello, "..name.."!")
end
end
greet("World")
]]

print("格式化前:")
print(uglyCode)
print("\n格式化后:")
print(formatLua(uglyCode))

print("\n=== 第20章结束 ===")
