-- === 第1章 Hello World与运行原理 ===

--[[
  本章目标：
  1. 理解Lua解释器如何执行脚本
  2. 理解print()的工作原理
  3. 区分lua解释器与luac编译器
  4. 了解字节码和虚拟机的基本概念

  核心问题：
  Q1: 计算机怎么跑脚本？
  Q2: 为什么要安装解释器？
  Q3: lua和luac的区别是什么？
  Q4: print为什么简单？
  深入: 解释器执行流程/字节码/虚拟机
]]

-- ============================
-- Q1: 计算机怎么跑脚本？
-- ============================

-- Lua是一种解释型语言，但实际运行时会经过以下步骤：
-- 源代码(.lua) → 词法分析 → 语法分析 → 字节码 → 虚拟机执行

-- 最简单的Hello World
print("Hello, World!")

-- 解释一下print函数：
-- print是Lua标准库函数，接受任意数量参数，输出到标准输出(stdout)
-- 它会自动在参数之间加Tab分隔，并在末尾加换行符

-- 对比：不用print，直接表达式
-- "Hello, World!"  -- 如果直接写字符串字面量，什么都不会发生
-- Lua REPL会打印表达式结果，但脚本文件中不会

-- ============================
-- Q2: 为什么要安装解释器？
-- ============================

-- 问题：为什么不能直接双击.lua文件运行？
-- 答案：.lua文件是源代码，不是可执行程序
-- 计算机CPU只能执行机器码，需要解释器把Lua源码翻译成机器码

-- Lua解释器(lua.exe)的工作：
-- 1. 读取.lua文件内容
-- 2. 编译成字节码(bytecode)
-- 3. 在虚拟机(VM)上执行字节码

-- 在命令行运行脚本：
-- lua hello.lua
-- luac -o hello.luac hello.lua  -- 先编译成字节码文件
-- lua hello.luac               -- 再执行字节码

-- ============================
-- Q3: lua和luac的区别是什么？
-- ============================

-- lua = 解释器（解释+执行）
-- luac = 编译器（只编译不执行，用于检查语法或发布字节码）

-- 示例：使用luac查看字节码
-- luac -l hello.lua  -- -l列出字节码
-- luac -p hello.lua  -- -p只做语法检查，不输出文件

-- lua和luac的关系：
-- lua = luac + 虚拟机
-- luac只是编译器，不包含运行时

-- ============================
-- Q4: print为什么简单？
-- ============================

-- print函数设计哲学：简单易用
print("Hello")           -- 单参数
print("Hello", "World")  -- 多参数，自动用Tab分隔
print(1, 2, 3)           -- 数字自动转字符串

-- 底层原理：
-- print内部调用io.write或类似函数
-- io.write不会自动加换行，print会

-- 对比io.write
io.write("Hello")       -- 无换行
io.write("Hello\n")     -- 加\n才有换行

-- ============================
-- 深入: 解释器执行流程
-- ============================

-- Lua解释器的核心组件：
-- 1. 词法分析器(Lexer) - 把源码切成token
-- 2. 语法分析器(Parser) - 把token组成AST(抽象语法树)
-- 3. 编译器(Compiler) - 把AST编译成字节码
-- 4. 虚拟机(VM) - 执行字节码指令

-- 字节码示例（伪代码）：
-- local a = 1 + 2 编译后类似:
-- LOADK 0, 1      ; 将常数1加载到寄存器0
-- LOADK 1, 2      ; 将常数2加载到寄存器1
-- ADD 0, 0, 1     ; 相加，结果存到寄存器0
-- STORE 0, a      ; 把结果存到变量a

-- 虚拟机是基于寄存器的(register-based)
-- 相比栈式虚拟机(Stack VM)，指令更少，效率更高

-- ============================
-- 示例：完整可运行脚本
-- ============================

-- 问候函数
local function greet(name)
    local message = "Hello, " .. name .. "!"
    print(message)
    return message
end

greet("Lua Developer")

-- 多行字符串
local html = [[
<html>
    <body>
        <h1>Welcome to Lua</h1>
    </body>
</html>
]]
print(html)

-- 长注释示例（使用LuaDoc风格）
--- 这是一个加法函数
--- @param a number 第一个数
--- @param b number 第二个数
--- @return number 两数之和
local function add(a, b)
    return a + b
end

print("2 + 3 =", add(2, 3))

-- ============================
-- 练习题
-- ============================

-- 练习1: 修改greet函数，支持多语言问候
local function greetMulti(name, lang)
    local greetings = {
        zh = "你好,",
        en = "Hello,",
        ja = "こんにちは,",
        ko = "안녕하세요,"
    }
    local greeting = greetings[lang] or greetings.en
    print(greeting .. name .. "!")
end

greetMulti("小明", "zh")
greetMulti("John", "en")

-- 练习2: 用print输出九九乘法表
for i = 1, 9 do
    local row = {}
    for j = 1, i do
        table.insert(row, i .. "x" .. j .. "=" .. i*j)
    end
    print(table.concat(row, "\t"))
end

print("\n=== 第1章结束 ===")
