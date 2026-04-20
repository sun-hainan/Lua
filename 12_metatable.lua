-- === 第12章 元表与元方法 ===

--[[
  本章目标：
  1. 掌握setmetatable/getmetatable
  2. 理解算术元方法__add/__eq/__lt/__le等
  3. 理解__index/__newindex
  4. 理解__call/__tostring/__len
  5. 掌握OOP在Lua中的实现

  核心问题：
  Q1: 元表是什么？
  Q2: 怎么实现面向对象？
  Q3: __index的查找顺序是什么？
  深入: 面向对象的原型链/多重继承
]]

-- ============================
-- Q1: 元表是什么？
-- ============================

-- 元表(metatable)：一个table，用于定义另一个table的行为
-- 当对table执行特定操作时，Lua会查找元表中的元方法(metamethod)

-- 基础元表操作
local t = {1, 2, 3}
print("--- 元表基础 ---")
print("t的类型:", type(t))

local mt = {}  -- 创建一个空元表
setmetatable(t, mt)  -- 给t设置元表

print("元表:", getmetatable(t))

-- 元方法是元表中的特殊键，如__add, __index等
-- 当执行t1 + t2时，Lua先检查t1的元表是否有__add

-- ============================
-- Q2: 怎么实现面向对象？
-- ============================

-- Lua没有class，用table + metatable模拟OOP

-- 简单的类模拟
local Vector = {}
Vector.__index = Vector  -- 关键：让实例查找方法到Vector

function Vector.new(x, y)
    return setmetatable({x = x, y = y}, Vector)
end

function Vector:add(other)
    return Vector.new(self.x + other.x, self.y + other.y)
end

function Vector:scale(s)
    return Vector.new(self.x * s, self.y * s)
end

function Vector:__tostring()
    return "(" .. self.x .. ", " .. self.y .. ")"
end

-- 设置__tostring元方法
Vector.__tostring = Vector.__tostring

print("\n--- 面向对象示例 ---")
local v1 = Vector.new(1, 2)
local v2 = Vector.new(3, 4)

print("v1:", v1)
print("v2:", v2)
print("v1:add(v2):", v1:add(v2))
print("v1:scale(3):", v1:scale(3))

-- ============================
-- Q3: __index的查找顺序是什么？
-- ============================

-- 查找顺序（读取属性时）：
-- 1. 检查table本身是否有键
-- 2. 检查table的元表是否有__index
-- 3. 如果__index是table，查找那个table
-- 4. 如果__index是函数，调用函数
-- 5. 如果都没找到，返回nil

-- 示例：继承
local Animal = {}
Animal.__index = Animal

function Animal.new(name, sound)
    return setmetatable({
        name = name,
        sound = sound
    }, Animal)
end

function Animal:speak()
    return self.name .. " says " .. self.sound
end

local Cat = setmetatable({}, {__index = Animal})
Cat.__index = Cat

function Cat.new(name)
    return setmetatable({
        name = name,
        sound = "meow"
    }, Cat)
end

print("\n--- 继承示例 ---")
local cat = Cat.new("Whiskers")
print(cat:speak())  -- 从Animal继承speak方法
print(cat.name)

-- ============================
-- 算术元方法
-- ============================

local Fraction = {}
Fraction.__index = Fraction

function Fraction.new(n, d)
    return setmetatable({n = n, d = d}, Fraction)
end

function Fraction:simplify()
    local gcd = function(a, b)
        while b ~= 0 do
            a, b = b, a % b
        end
        return a
    end
    local g = gcd(self.n, self.d)
    return Fraction.new(self.n / g, self.d / g)
end

-- 算术元方法
Fraction.__add = function(a, b)
    return Fraction.new(a.n * b.d + b.n * a.d, a.d * b.d):simplify()
end

Fraction.__sub = function(a, b)
    return Fraction.new(a.n * b.d - b.n * a.d, a.d * b.d):simplify()
end

Fraction.__mul = function(a, b)
    return Fraction.new(a.n * b.n, a.d * b.d):simplify()
end

Fraction.__div = function(a, b)
    return Fraction.new(a.n * b.d, a.d * b.n):simplify()
end

Fraction.__eq = function(a, b)
    return a.n * b.d == b.n * a.d
end

Fraction.__lt = function(a, b)
    return a.n * b.d < b.n * a.d
end

Fraction.__le = function(a, b)
    return a.n * b.d <= b.n * a.d
end

Fraction.__tostring = function(f)
    return f.n .. "/" .. f.d
end

Fraction.__concat = function(a, b)
    return tostring(a) .. " " .. tostring(b)
end

print("\n--- 算术元方法示例 ---")
local f1 = Fraction.new(1, 2)
local f2 = Fraction.new(1, 3)

print("f1:", f1)
print("f2:", f2)
print("f1 + f2:", f1 + f2)
print("f1 - f2:", f1 - f2)
print("f1 * f2:", f1 * f2)
print("f1 / f2:", f1 / f2)
print("f1 == f2:", f1 == f2)
print("f1 < f2:", f1 < f2)

-- ============================
-- __index/__newindex深入
-- ============================

-- __newindex：设置不存在的键时触发
local readonly = {}
readonly.__index = function(t, k)
    return rawget(t, k) or "只读属性"
end
readonly.__newindex = function(t, k, v)
    error("Cannot set property: " .. k .. " is readonly")
end

local config = setmetatable({debug = true, port = 8080}, readonly)

print("\n--- 只读表 ---")
print("config.debug:", config.debug)
print("config.port:", config.port)
print("config.nonexistent:", config.nonexistent)

-- config.debug = false  -- 这行会报错

-- ============================
-- __call元方法
-- ============================

local FuncWrapper = {}
FuncWrapper.__index = FuncWrapper

function FuncWrapper.new(func)
    return setmetatable({_func = func}, FuncWrapper)
end

function FuncWrapper:call(...)
    return self._func(...)
end

function FuncWrapper:__call(...)
    return self:call(...)
end

print("\n--- __call示例 ---")
local wrappedAdd = FuncWrapper.new(function(a, b)
    return a + b
end)

print("wrappedAdd(10, 20):", wrappedAdd(10, 20))  -- 使用__call

-- ============================
-- 深入: 原型链与多重继承
-- ============================

-- 原型链(Prototype Chain)：对象继承自另一个对象
-- Lua用__index实现原型链

-- 多重继承：继承多个父类
local function createMultiClass(...)
    local parents = {...}
    
    local class = {}
    local mt = {
        __index = function(t, k)
            for _, parent in ipairs(parents) do
                local v = rawget(parent, k)
                if v ~= nil then
                    return v
                end
                local parentMt = getmetatable(parent)
                if parentMt and parentMt.__index then
                    if type(parentMt.__index) == "function" then
                        local val = parentMt.__index(t, k)
                        if val ~= nil then return val end
                    else
                        local val = parentMt.__index[k]
                        if val ~= nil then return val end
                    end
                end
            end
            return nil
        end
    }
    
    return setmetatable(class, mt)
end

print("\n--- 多重继承示例 ---")
local Speakable = {
    speak = function(self)
        return self.name .. " speaks"
    end
}

local Walkable = {
    walk = function(self)
        return self.name .. " walks"
    end
}

local Human = createMultiClass(Speakable, Walkable)
function Human.new(name)
    return setmetatable({name = name}, Human)
end

local h = Human.new("Alice")
print(h:speak())
print(h:walk())

print("\n=== 第12章结束 ===")
