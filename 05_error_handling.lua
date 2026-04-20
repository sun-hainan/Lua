-- === 第5章 错误处理 ===

--[[
  本章目标：
  1. 掌握error()和assert()的使用
  2. 理解pcall和xpcall的保护调用
  3. 自定义错误处理逻辑
  4. 理解错误传播和栈展开

  核心问题：
  Q1: 为什么Lua没有try/catch？
  Q2: pcall是什么？
  Q3: 怎么捕获特定错误？
  深入: 保护调用/错误传播/栈展开
]]

-- ============================
-- Q1: 为什么Lua没有try/catch？
-- ============================

-- Lua使用pcall(pcall = protected call)实现错误处理
-- 这是更轻量的设计，不像Java的异常机制那么重

-- error()函数：抛出错误
local function divide(a, b)
    if b == 0 then
        error("除数不能为零", 2)  -- 第二个参数：错误级别（1=error位置，2=调用者位置）
    end
    return a / b
end

-- 测试error
-- divide(10, 0)  -- 这行会中断执行，输出错误信息

-- assert()函数：断言条件，不满足则报错
local function getArrayElement(arr, index)
    assert(type(arr) == "table", "arr必须是table")
    assert(type(index) == "number", "index必须是number")
    return arr[index]
end

local arr = {1, 2, 3}
print("assert demo:", getArrayElement(arr, 2))

-- assert vs error的选择：
-- assert：用于检查"不应该发生"的错误（程序bug）
-- error：用于检查"可能发生"的错误（用户输入错误）

-- ============================
-- Q2: pcall是什么？
-- ============================

-- pcall = protected call，保护调用
-- 格式：success, result = pcall(func, arg1, arg2, ...)
-- success=true表示执行成功，result是返回值
-- success=false表示出错，result是错误信息

local function mightFail(x)
    if x < 0 then
        error("x必须是正数")
    end
    return x * 2
end

print("\n--- pcall demo ---")
local ok, result = pcall(mightFail, 10)
print("pcall(10): ok=", ok, "result=", result)

ok, result = pcall(mightFail, -5)
print("pcall(-5): ok=", ok, "result=", result)

-- pcall捕获错误后不会继续传播
-- 如果想看栈追踪，用debug.traceback()

-- ============================
-- Q3: 怎么捕获特定错误？
-- ============================

-- 方法1：检查错误信息字符串
local function safeDivide(a, b)
    local ok, result = pcall(divide, a, b)
    if not ok then
        if string.find(result, "除数不能为零") then
            return nil, "除法错误：除数为零"
        else
            return nil, "未知错误：" .. tostring(result)
        end
    end
    return result
end

print("\nsafeDivide(10, 0):", safeDivide(10, 0))
print("safeDivide(10, 2):", safeDivide(10, 2))

-- 方法2：使用xpcall自定义错误处理
-- xpcall(protected_func, error_handler, arg1, ...)
-- error_handler接收错误信息，可以自定义处理

local function myErrorHandler(err)
    print("=== 错误被捕获 ===")
    print("错误信息:", err)
    print("调用栈:")
    print(debug.traceback())
    return "处理后的错误"  -- 返回值会成为pcall的结果
end

print("\n--- xpcall demo ---")
ok, result = xpcall(mightFail, myErrorHandler, -5)
print("xpcall result: ok=", ok, "result=", result)

-- 方法3：用table作为错误码
local ErrorCodes = {
    DIVISION_BY_ZERO = "E001",
    INVALID_INPUT = "E002",
    NOT_FOUND = "E003"
}

local function divideWithCode(a, b)
    if b == 0 then
        error(ErrorCodes.DIVISION_BY_ZERO)
    end
    return a / b
end

local function safeDivideWithCode(a, b)
    local ok, result = pcall(divideWithCode, a, b)
    if not ok then
        -- 返回错误码而不是完整错误
        return nil, result
    end
    return result
end

print("\nsafeDivideWithCode(10, 0):", table.unpack({safeDivideWithCode(10, 0)}))

-- ============================
-- 深入: 错误传播/栈展开
-- ============================

-- 错误传播：error抛出后，Lua会展开调用栈，查找最近的pcall
-- 如果一直没被pcall捕获，程序终止

local function level3()
    error("深层错误")  -- 级别3
end

local function level2()
    level3()  -- 级别2
end

local function level1()
    level2()  -- 级别1
end

print("\n--- 栈展开 demo ---")
ok, err = pcall(level1)
print("捕获到错误:", err)
print("错误发生在:", debug.traceback())

-- debug.getinfo() 获取函数信息
print("\n--- debug.getinfo demo ---")
local info = debug.getinfo(mightFail)
print("函数名:", info.name)
print("文件:", info.source)
print("行号:", info.currentline)
print("函数类型:", info.what)

-- ============================
-- 示例：完整可运行脚本
-- ============================

-- 错误处理工具库
local ErrorHandler = {}
ErrorHandler.__index = ErrorHandler

function ErrorHandler.new()
    return setmetatable({
        errors = {},
        count = 0
    }, ErrorHandler)
end

function ErrorHandler.try(self, func, ...)
    local ok, result = pcall(func, ...)
    if not ok then
        self.count = self.count + 1
        self.errors[self.count] = {
            message = result,
            time = os.date("%Y-%m-%d %H:%M:%S"),
            stack = debug.traceback()
        }
        return nil, result
    end
    return result
end

function ErrorHandler.getErrors(self)
    return self.errors
end

function ErrorHandler.errorCount(self)
    return self.count
end

-- 使用示例
local handler = ErrorHandler.new()

handler:try(function() print("正常执行") end)
handler:try(function() error("模拟错误1") end)
handler:try(function() error("模拟错误2") end)
handler:try(function() error("模拟错误3") end)

print("\n错误统计:", handler:errorCount(), "个错误")
for i, err in pairs(handler:getErrors()) do
    print(string.format("  [%d] %s - %s", i, err.time, err.message))
end

print("\n=== 第5章结束 ===")
