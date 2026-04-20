-- === 第13章 模块与require ===

--[[
  本章目标：
  1. 理解module/require机制
  2. 掌握package.path/package.cpath
  3. 理解环境隔离和循环require

  核心问题：
  Q1: require怎么找到文件？
  Q2: 为什么会有循环依赖？
  Q3: 环境是什么意思？
  深入: 模块加载搜索路径/预编译缓存
]]

-- ============================
-- Q1: require怎么找到文件？
-- ============================

-- require是Lua的模块加载函数
-- 搜索路径存储在package.path中

print("--- package.path ---")
print("当前路径:", package.path)

-- package.path使用分号分隔的路径模板
-- 每个模板用分号(;)分隔，用问号(?)代替模块名

-- 常见路径模板：
-- ./?.lua              当前目录的.lua文件
-- ./?.luac             当前目录的字节码
-- /usr/local/lua/?.lua 系统目录

-- 示例：模拟require的搜索过程
local function searchPath(modname, path)
    local result = {}
    for template in path:gmatch("[^;]+") do
        local filepath = template:gsub("%?", modname)
        table.insert(result, filepath)
    end
    return result
end

local paths = searchPath("mymodule", package.path)
print("\n搜索路径示例:")
for i, p in ipairs(paths) do
    print("  " .. i .. ":", p)
end

-- ============================
-- Q2: 为什么会有循环依赖？
-- ============================

-- 循环依赖示例：
-- a.lua requires b.lua
-- b.lua requires a.lua

-- 问题场景：
-- module A在加载时，需要先加载module B
-- 但B又依赖A，而A还没加载完成

-- 解决方案：
-- 1. 延迟绑定：不在模块顶层require，先定义函数再require
-- 2. 拆分模块：把共享的部分提取到第三个模块
-- 3. 重新设计：避免循环，改用事件或回调

-- 示例：正确的模块结构
--[[
-- common.lua（共享部分）
local Common = {}
return Common

-- a.lua
local Common = require("common")
local A = {}
function A.func() end
return A

-- b.lua
local Common = require("common")
local B = {}
function B.func() end
return B
]]

-- ============================
-- Q3: 环境是什么意思？
-- ============================

-- 每个Lua模块有自己的环境（_ENV）
-- 模块内的全局变量实际存在模块的环境中

-- _G是全局环境（所有模块共享）
-- _ENV是当前环境的引用

print("\n--- _G vs _ENV ---")
print("_G:", type(_G))
print("_ENV:", type(_ENV))
print("_G == _ENV:", _G == _ENV)  -- 主模块中相同

-- 模块内的全局变量查找链：
-- 1. 当前环境的局部变量
-- 2. _ENV（当前环境）
-- 3. _G（全局环境）

-- ============================
-- 深入: 模块加载搜索路径/预编译缓存
-- ============================

-- require的加载过程：
-- 1. 检查package.loaded[modname]，如果已加载直接返回
-- 2. 否则，按顺序搜索package.path
-- 3. 找到文件后，加载代码（loadfile或load）
-- 4. 执行代码，把返回值存入package.loaded
-- 5. 返回加载的模块

-- package.loaded是已加载模块的缓存
print("\n--- package.loaded ---")
print("package.loaded._PRELOAD:")
for k, v in pairs(package.loaded or {}) do
    print("  " .. tostring(k) .. ":", type(v))
end

-- 自定义require行为
local function myLoader(modname)
    print("尝试加载:", modname)
    return nil, "不支持自定义加载器"
end

-- table.insert(package.loaders, myLoader)  -- 添加搜索器

-- ============================
-- 示例：完整可运行脚本
-- ============================

-- 定义一个简单的模块（不使用文件，用table模拟）
local MyMath = {}

-- 模块级变量（私有）
local PI = 3.14159

-- 导出函数
function MyMath.circleArea(r)
    return PI * r * r
end

function MyMath.circlePerimeter(r)
    return 2 * PI * r
end

function MyMath.sphereVolume(r)
    return (4/3) * PI * r^3
end

-- 可以这样使用：
-- local MyMath = require("mymath")
-- print(MyMath.circleArea(5))

print("\n--- 自定义模块示例 ---")
print("圆面积(半径5):", MyMath.circleArea(5))
print("圆周长(半径5):", MyMath.circlePerimeter(5))
print("球体积(半径5):", MyMath.sphereVolume(5))

-- 模块工厂模式
local function createModule(name, data)
    local module = {
        name = name,
        data = data or {}
    }
    
    function module:getData(key)
        return self.data[key]
    end
    
    function module:setData(key, value)
        self.data[key] = value
    end
    
    return module
end

print("\n--- 模块工厂模式 ---")
local mod1 = createModule("module1", {a = 1, b = 2})
local mod2 = createModule("module2", {x = 10})

print("mod1.name:", mod1.name)
print("mod1:getData('a'):", mod1:getData('a'))
print("mod2:getData('x'):", mod2:getData('x'))

-- 命名空间模式
local Namespace = {}
_G.MyNamespace = Namespace  -- 注册到全局

Namespace.utils = {}
Namespace.utils.double = function(x) return x * 2 end
Namespace.utils.triple = function(x) return x * 3 end

print("\n--- 命名空间模式 ---")
print("MyNamespace.utils.double(5):", Namespace.utils.double(5))
print("MyNamespace.utils.triple(5):", Namespace.utils.triple(5))

print("\n=== 第13章结束 ===")
