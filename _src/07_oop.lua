-- ============================================================
-- 模块七：面向对象OOP
-- 封装/继承/多态/类与对象/修饰符/抽象类/接口/内部类
-- ============================================================

-- 【问题1】Lua 如何实现封装？私有变量如何实现？
--
-- Lua 没有 class 的概念，用 table + metatable 模拟 OOP
-- 封装方式：
--   - 约定：_ 前缀表示私有
--   - 闭包：工厂函数返回对象，局部变量变成私有
--   - 下划线前缀约定

local function encapsulation_demo()
    -- 闭包方式（完全私有）
    local function create_person(name, age)
        -- 私有变量（闭包内可见，外部无法直接访问）
        local _name = name
        local _age = age

        -- 公开方法（闭包访问私有变量）
        return {
            get_name = function() return _name end,
            get_age = function() return _age end,
            set_age = function(a) _age = a end,
            to_string = function()
                return string.format("Person(%s, %d)", _name, _age)
            end,
        }
    end

    local p = create_person("Alice", 30)
    print(p:get_name())
    print(p:to_string())
    p:set_age(31)
    print(p:to_string())

    -- 约定方式（Lua 风格的对象）
    local function new_counter()
        return {
            -- 约定 _ 前缀为私有
            _count = 0,
            increment = function(self)
                self._count = self._count + 1
            end,
            get = function(self)
                return self._count
            end,
        }
    end

    local c = new_counter()
    c:increment()
    c:increment()
    print("counter:", c:get())
end

encapsulation_demo()

-- 【问题2】Lua 的继承如何实现？metatable 链是什么？
--
-- Lua 继承通过 metatable 实现：
--   - 子类的 metatable 指向父类
--   - 访问子类的键找不到时，会查找 metatable（父类）
--
-- 实现方式：
--   - Class: 普通表，包含方法
--   - Class.__index = Class：查找机制
--   - 子类继承父类方法

local function inheritance_demo()
    -- 父类
    local Animal = {
        name = "unnamed",
        new = function(self, name)
            local obj = {name = name}
            setmetatable(obj, {__index = self})
            return obj
        end,
        speak = function(self)
            return self.name .. " makes a sound"
        end,
    }

    -- 子类（继承 Animal）
    local Dog = Animal:new()
    Dog.bark = function(self)
        return self.name .. " says woof!"
    end
    -- Dog 没有覆盖 speak，使用父类的

    local cat = Animal:new("Kitty")
    print(cat:speak())  -- Kitty makes a sound

    local dog = Dog:new("Rex")
    print(dog:speak())  -- Rex makes a sound（继承自 Animal）
    print(dog:bark())   -- Rex says woof!
end

inheritance_demo()

-- 【问题3】Lua 的多态如何实现？
--
-- 多态：同一操作对不同对象有不同行为
-- Lua 通过 metatable 实现：
--   - 方法覆盖（子类重写父类方法）
--   - 运行时方法查找（__index）

local function polymorphism_demo()
    local Shape = {
        area = function(self) return 0 end,
    }

    local Circle = Shape:new()
    Circle.new = function(self, radius)
        local obj = Shape.new(self, "circle")
        obj.radius = radius
        return obj
    end
    Circle.area = function(self)
        return math.pi * self.radius * self.radius
    end

    local Rectangle = Shape:new()
    Rectangle.new = function(self, w, h)
        local obj = Shape.new(self, "rect")
        obj.width = w
        obj.height = h
        return obj
    end
    Rectangle.area = function(self)
        return self.width * self.height
    end

    local shapes = {
        Circle:new(5),
        Rectangle:new(4, 6),
    }

    -- 多态：同一接口（area）不同实现
    local total_area = 0
    for _, shape in ipairs(shapes) do
        print(shape.name, "area =", shape:area())
        total_area = total_area + shape:area()
    end
    print("total area:", total_area)
end

polymorphism_demo()

-- 【问题4】Lua 的"类"系统如何构建？工厂模式 vs metaclass？
--
-- 两种方式：
--   1. 工厂函数：每次返回新对象
--   2. 元类（metaclass）：定义"类的类"
--
-- 元类方式更接近传统 OOP：
--   - Class 是 metaclass 的实例
--   - obj 是 Class 的实例

local function class_system()
    -- 元类
    local Class = {}
    Class.__index = Class

    function Class:new(...)
        local obj = setmetatable({}, self)
        if self.__init then
            self.__init(obj, ...)
        end
        return obj
    end

    -- 定义 Person 类
    local Person = setmetatable({}, Class)
    Person.__index = Person
    Person.__init = function(self, name, age)
        self.name = name
        self.age = age
    end
    Person.introduce = function(self)
        return "I am " .. self.name .. ", " .. self.age .. " years old"
    end

    -- 创建实例
    local alice = Person:new("Alice", 30)
    print(alice:introduce())

    -- 检查类型
    print("is Person:", getmetatable(alice) == Person)
    print("is Class:", getmetatable(Person) == Class)
end

class_system()

-- 【问题5】Lua 有接口吗？如何实现接口概念？
--
-- Lua 没有显式的接口
-- 但可以用约定和契约实现接口：
--   - 表中包含特定方法
--   - 类型检查函数验证
--   - 文档约定

local function interface_demo()
    -- 接口约定：必须实现 draw() 方法
    local function draw_shape(obj)
        -- 类型检查
        if type(obj.draw) ~= "function" then
            error("object must implement draw() method")
        end
        obj:draw()
    end

    -- 实现接口
    local Circle = {
        draw = function(self)
            print("drawing circle")
        end,
    }

    local Rectangle = {
        draw = function(self)
            print("drawing rectangle")
        end,
    }

    draw_shape(Circle)
    draw_shape(Rectangle)

    -- 鸭子类型（duck typing）
    local duck_like = {
        draw = function()
            print("drawing something like a duck")
        end,
    }
    draw_shape(duck_like)  -- 只要有 draw 方法就行
end

interface_demo()

-- 【问题6】Lua 的多重继承如何实现？
--
-- 多重继承：子类继承多个父类
-- Lua 实现方式：
--   - 多个父类的 metatable 链
--   - 使用 __index 函数手动查找
--
-- 注意：多重继承复杂，可能导致命名冲突

local function multiple_inheritance()
    -- 父类 A
    local A = {
        method_a = function() return "from A" end,
    }
    A.__index = A

    -- 父类 B
    local B = {
        method_b = function() return "from B" end,
    }
    B.__index = B

    -- 多重继承类 C
    local C = {}
    C.__index = function(self, key)
        -- 先在 C 本身找
        if C[key] then return C[key] end
        -- 再在 A 找
        if A[key] then return A[key] end
        -- 再在 B 找
        if B[key] then return B[key] end
        return nil
    end

    local obj = setmetatable({}, C)
    print("method_a:", obj:method_a())
    print("method_b:", obj:method_b())

    -- mixin 方式（更简单）
    local function mixin(obj, ...)
        for _, mix in ipairs({...}) do
            for k, v in pairs(mix) do
                if not obj[k] then
                    obj[k] = v
                end
            end
        end
        return obj
    end

    local target = {}
    mixin(target, A, B)
    print("mixin method_a:", target:method_a())
end

multiple_inheritance()

-- 【问题7】Lua 的运算符重载（ metamethods）是什么？
--
-- 元方法（metamethods）定义对象的运算符行为：
--   __add(a, b)      a + b
--   __sub(a, b)      a - b
--   __mul(a, b)      a * b
--   __div(a, b)      a / b
--   __eq(a, b)       a == b
--   __lt(a, b)       a < b
--   __le(a, b)       a <= b
--   __concat(a, b)   a .. b
--   __tostring(a)    tostring(a)
--   __call(a, ...)   a(...)

local function metamethods_demo()
    local Vec2 = {
        new = function(x, y)
            return setmetatable({x = x, y = y}, {
                __add = function(a, b) return Vec2:new(a.x + b.x, a.y + b.y) end,
                __sub = function(a, b) return Vec2:new(a.x - b.x, a.y - b.y) end,
                __mul = function(a, s) return Vec2:new(a.x * s, a.y * s) end,
                __eq = function(a, b) return a.x == b.x and a.y == b.y end,
                __lt = function(a, b) return a.x < b.x or (a.x == b.x and a.y < b.y) end,
                __tostring = function(a) return string.format("Vec2(%.2f, %.2f)", a.x, a.y) end,
                __len = function(a) return math.sqrt(a.x * a.x + a.y * a.y) end,
            })
        end,
    }

    local v1 = Vec2:new(1, 2)
    local v2 = Vec2:new(3, 4)

    print("v1:", v1)
    print("v2:", v2)
    print("v1 + v2:", v1 + v2)
    print("v1 - v2:", v1 - v2)
    print("v1 * 2:", v1 * 2)
    print("v1 == v1:", v1 == v1)
    print("v1 < v2:", v1 < v2)
    print("#v1:", #v1)  -- 长度
end

metamethods_demo()

-- ============================================================
-- 【对比】Rust vs Lua vs Python OOP
-- ============================================================
-- Rust:
--   - 无类和对象，有 struct + impl
--   - 无继承，用 Trait + 组合替代
--   - pub 控制可见性
--   - Trait 类似接口，支持默认实现

-- Lua:
--   - 没有类，用 table + metatable 模拟 OOP
--   - 通过 metatable 链实现"继承"
--   - 封装靠约定（_private）或闭包
--   - 没有接口，用约定代替

-- Python:
--   - 有类（class），支持单继承
--   - 多态通过继承和方法重写实现
--   - 抽象基类（ABC）定义接口
--   - 可见性靠约定（_protected / __private）

function compare_oop()
    print("=== 五语言OOP对比 ===")

    -- Lua: table + metatable，__index 实现继承链
    -- Python: class 关键字，单继承 + 多继承
    -- Rust: struct + impl，无继承，用 trait 代替
    -- Go: struct + 方法，无类/继承，用组合代替
    -- C++: class 关键字，多继承，运算符重载

    print("Lua uses table + metatable for OOP")
end

-- ============================================================
-- 【练习题】
-- ============================================================
-- 1. 用 metatable 实现一个栈类（push/pop/peek/isEmpty），返回栈顶元素但不弹出
-- 2. 实现一个带继承的 Shape 层次结构（Shape -> Circle + Rectangle），各自实现 area()
-- 3. 用元方法实现复数运算（Complex 类型，支持 +、-、*、==、tostring）
-- 4. 实现一个带私有变量的银行账户类（balance 是私有的，提供 deposit/withdraw/get_balance）
-- 5. 实现多重继承：A 和 B 各有一个方法，C 同时继承 A 和 B，实现 __index 查找链

-- ============================================================
-- 总结
-- ============================================================
-- | 特性       | Lua 实现                                    |
-- |-----------|-------------------------------------------|
-- | 类         | table + metatable                          |
-- | 继承       | metatable 链                               |
-- | 多态       | 方法查找 __index                            |
-- | 封装       | 闭包（完全私有）或约定（_前缀）              |
-- | 接口       | 约定（方法存在性检查）                      |
-- | 运算符重载 | metamethods（__add 等）                     |

local function main()
    print("=== 模块七：面向对象OOP ===")

    encapsulation_demo()
    inheritance_demo()
    polymorphism_demo()
    class_system()
    interface_demo()
    multiple_inheritance()
    metamethods_demo()
    compare_oop()

    print("\n✅ 所有示例运行成功！")
end

main()