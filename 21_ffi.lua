-- === 第21章 C集成与FFI ===

--[[
  本章目标：
  1. 理解C函数导出到Lua
  2. 理解luaL_newstate/lua_call/lua_pcall
  3. 掌握LuaJIT FFI
  4. 掌握ffi.cdef/ffi.metatype
  5. 理解回调函数

  核心问题：
  Q1: 为什么Lua容易和C结合？
  Q2: FFI比C API简单在哪？
  Q3: 怎么写C扩展？
  深入: 栈操作/用户数据/轻量用户数据
]]

-- ============================
-- Q1: 为什么Lua容易和C结合？
-- ============================

-- Lua的设计哲学：嵌入式语言
-- 1. 简单的C API：只有约120个API函数
-- 2. 基于栈的接口：参数和返回值通过虚拟栈传递
-- 3. 轻量用户数据：可以存储C指针
-- 4. 垃圾回收集成：Lua自动管理C对象

-- Lua C API的核心理念：
-- "It is easier to write in C the programs that would be
--  written in Lua, than to write in Lua the programs that
--  would be written in C"
--   -- Roberto Ierusalimschy

-- ============================
-- Q2: FFI比C API简单在哪？
-- ============================

-- FFI（Foreign Function Interface）：外部函数接口
-- LuaJIT的FFI允许直接调用C函数和结构体

-- 传统C API方式：
--[[
// 需要写C代码，编译成.so/.dll
static int l_add(lua_State *L) {
    double a = luaL_checknumber(L, 1);
    double b = luaL_checknumber(L, 2);
    lua_pushnumber(L, a + b);
    return 1;  // 返回值个数
}
]]

-- FFI方式：纯Lua代码，无需编译
--[[
local ffi = require("ffi")
ffi.cdef[[
int printf(const char *fmt, ...);
double sin(double x);
]]

ffi.C.printf("Hello %s\n", "world")
local s = ffi.C.sin(1.0)
]]

-- ============================
-- Q3: 怎么写C扩展？
-- ============================

-- 基本步骤：
-- 1. 包含lua.h头文件
-- 2. 定义luaL_Reg数组注册函数
-- 3. 用luaL_newlib创建模块
-- 4. 在luaopen_*函数中返回模块table

-- 示例C扩展（伪代码）：
--[[
#include "lua.h"
#include "lauxlib.h"

static int l_greet(lua_State *L) {
    const char *name = luaL_checkstring(L, 1);
    lua_pushfstring(L, "Hello, %s!", name);
    return 1;
}

static const luaL_Reg mylib[] = {
    {"greet", l_greet},
    {NULL, NULL}
};

LUAMOD_API int luaopen_mylib(lua_State *L) {
    luaL_newlib(L, mylib);
    return 1;
}
]]

-- 编译：
-- gcc -shared -o mylib.dll mylib.c -llua54

-- ============================
-- 深入: 栈操作/用户数据
-- ============================

-- Lua栈是连接Lua和C的桥梁
-- 索引：1=栈底，-1=栈顶，-2=次栈顶

-- 栈操作：
-- lua_pushnumber(L, n)      推入数字
-- lua_pushstring(L, s)      推入字符串
-- lua_pushboolean(L, b)      推入布尔
-- lua_pushnil(L)            推入nil
-- lua_pop(L, n)             弹出n个元素
-- lua_gettop(L)             获取栈顶索引
-- lua_settop(L, idx)        设置栈顶

-- 取值：
-- lua_tonumber(L, idx)     转数字
-- lua_tostring(L, idx)      转字符串
-- lua_toboolean(L, idx)    转布尔
-- lua_isnumber(L, idx)      检查类型

-- 用户数据：
-- lua_newuserdata(L, size)  创建用户数据
-- luaL_checkudata(L, idx)   检查用户数据类型

-- ============================
-- 示例：FFI基础用法（模拟）
-- ============================

print("\n--- FFI基础用法 ---")

-- 注意：以下代码需要LuaJIT的FFI库
-- luarocks install luajit

--[[
local ffi = require("ffi")

-- 定义C函数
ffi.cdef[[
typedef struct { double x, y; } Point;
int printf(const char *fmt, ...);
size_t strlen(const char *s);
]]

-- 调用C标准库
ffi.C.printf("Hello from C!\n")
print("strlen('hello'):", ffi.C.strlen("hello"))

-- 分配C结构体
local p = ffi.new("Point")
p.x = 1.0
p.y = 2.0
print("Point:", p.x, p.y)

-- 分配数组
local arr = ffi.new("int[10]")
for i = 0, 9 do
    arr[i] = i * 2
end
print("arr[5]:", arr[5])
]]

print("(注释掉的FFI代码，需要LuaJIT环境)")

-- ============================
-- 示例：回调函数
-- ============================

-- C函数需要回调Lua函数时，使用lua_CFunction

--[[
在C端定义：
static int l_call_callback(lua_State *L) {
    lua_CFunction callback = lua_tocfunction(L, 1);
    // 调用回调
    lua_pushnumber(L, 42);
    callback(L);  // 调用Lua函数
    return 1;
}
]]

-- 在FFI中处理回调：
--[[
local ffi = require("ffi")

ffi.cdef[[
typedef void (*callback_t)(int value);
void register_callback(callback_t cb);
]]

local function luaCallback(value)
    print("回调收到:", value)
end

-- 将Lua函数转为C函数指针
ffi.cast("callback_t", luaCallback)
]]

-- ============================
-- 示例：面向对象的C扩展模拟
-- ============================

print("\n--- 模拟C风格OOP ---")

-- 用table模拟C结构体
local Vector = {}
Vector.__index = Vector

function Vector.new(x, y)
    return setmetatable({x = x, y = y}, Vector)
end

function Vector:add(other)
    return Vector.new(self.x + other.x, self.y + other.y)
end

function Vector:dot(other)
    return self.x * other.x + self.y * other.y
end

function Vector:__tostring()
    return string.format("Vector(%.2f, %.2f)", self.x, self.y)
end

-- 模拟C中的vtable（虚函数表）
local VectorMethods = {
    add = Vector.add,
    dot = Vector.dot
}

print("Vector加法:")
local v1 = Vector.new(1, 2)
local v2 = Vector.new(3, 4)
print("v1:", v1)
print("v2:", v2)
print("v1 + v2:", v1:add(v2))
print("v1 · v2:", v1:dot(v2))

-- ============================
-- 示例：轻量用户数据
-- ============================

print("\n--- 轻量用户数据 vs 用户数据 ---")

-- Lua用户数据类型：
-- 1. 完全用户数据（full userdata）：分配的内存块，可以任意操作
-- 2. 轻量用户数据（light userdata）：就是一个指针

-- 完全用户数据：
--[[
local udata = lua_newuserdata(L, size)
local ptr = lua_touserdata(L, -1)
]]

-- 轻量用户数据（Lua 5.3+）：
-- lua_pushlightuserdata(L, ptr)
-- local ptr = lua_touserdata(L, -1)

-- 在纯Lua中模拟：
local LightUserdata = {}
LightUserdata.__index = LightUserdata

function LightUserdata.new(ptr)
    return setmetatable({ptr = ptr, type = "light"}, LightUserdata)
end

-- 用于存储C指针
local cPtr = LightUserdata.new(0x12345678)
print("模拟轻量用户数据:")
print("  类型:", cPtr.type)
print("  指针值:", string.format("0x%08X", cPtr.ptr))

-- ============================
-- 综合示例：C扩展模拟
-- ============================

print("\n--- 综合示例：C扩展模拟 ---")

-- 模拟一个模块
local MyLibrary = {}

-- 模拟C函数：gcd
function MyLibrary.gcd(a, b)
    while b ~= 0 do
        a, b = b, a % b
    end
    return a
end

-- 模拟C函数：lcm
function MyLibrary.lcm(a, b)
    return math.abs(a * b) / MyLibrary.gcd(a, b)
end

-- 模拟C函数：clamp
function MyLibrary.clamp(value, minVal, maxVal)
    return math.max(minVal, math.min(maxVal, value))
end

-- 导出模块
print("模拟C扩展:")
print("gcd(12, 8):", MyLibrary.gcd(12, 8))
print("lcm(12, 8):", MyLibrary.lcm(12, 8))
print("clamp(15, 0, 10):", MyLibrary.clamp(15, 0, 10))
print("clamp(-5, 0, 10):", MyLibrary.clamp(-5, 0, 10))

print("\n=== 第21章结束 ===")
print("=== Lua教程全部完成 ===")
