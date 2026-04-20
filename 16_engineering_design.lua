-- ============================================================
-- 模块十六：工程化与设计思想
-- 设计模式/代码优化/Git
-- ============================================================

-- 【问题1】Lua 的常用设计模式有哪些？
--
-- Lua 设计模式：
--   - 模块模式（module）
--   - 工厂模式（factory）
--   - 单例模式（singleton）
--   - 观察者模式（observer）
--   - 装饰器模式（decorator）
--   - 命令模式（command）

local function design_patterns()
    -- 模块模式（Module Pattern）
    local function create_module()
        -- 私有成员
        local _private_var = 0

        -- 公开接口
        return {
            get = function() return _private_var end,
            set = function(v) _private_var = v end,
        }
    end

    local mod = create_module()
    mod:set(100)
    print("module value:", mod:get())

    -- 单例模式
    local function Singleton()
        local instance = nil
        return function()
            if not instance then
                instance = {
                    value = "I am singleton"
                }
            end
            return instance
        end
    end

    local get_singleton = Singleton()
    local s1 = get_singleton()
    local s2 = get_singleton()
    print("same instance:", s1 == s2)

    -- 工厂模式
    local function create_shape(shape_type)
        local factory = {
            circle = function()
                return {
                    area = function(self)
                        return math.pi * self.radius * self.radius
                    end,
                    radius = 1,
                }
            end,
            rectangle = function()
                return {
                    area = function(self)
                        return self.width * self.height
                    end,
                    width = 2,
                    height = 3,
                }
            end,
        }

        local creator = factory[shape_type]
        if creator then
            return creator()
        end
        return nil
    end

    local c = create_shape("circle")
    print("circle area:", c:area())

    -- 观察者模式
    local function create_observer()
        local observers = {}

        return {
            subscribe = function(fn)
                table.insert(observers, fn)
            end,
            notify = function(data)
                for _, fn in ipairs(observers) do
                    fn(data)
                end
            end,
        }
    end

    local subject = create_observer()
    subject:subscribe(function(data)
        print("observer1 got:", data)
    end)
    subject:subscribe(function(data)
        print("observer2 got:", data)
    end)
    subject:notify("hello!")
end

design_patterns()

-- 【问题2】Lua 的代码优化技巧有哪些？
--
-- 优化技巧：
--   1. 局部变量缓存（避免重复查找）
--   2. 表预分配（避免频繁 rehash）
--   3. 避免创建不必要的 table
--   4. 字符串拼接优化（table.concat）
--   5. 避免动态 require（在需要时才 require）

local function code_optimization()
    -- 局部变量缓存
    local function slow_lookup()
        for i = 1, 1000 do
            local v = math.sin(math.cos(math.tan(i)))
        end
    end

    local function fast_lookup()
        local sin, cos, tan = math.sin, math.cos, math.tan
        for i = 1, 1000 do
            local v = sin(cos(tan(i)))
        end
    end

    local start = os.clock()
    slow_lookup()
    print("slow:", os.clock() - start)

    start = os.clock()
    fast_lookup()
    print("fast:", os.clock() - start)

    -- 表预分配
    local t = {}
    for i = 1, 1000 do
        t[i] = i  -- 可能多次 rehash
    end

    local t2 = {}
    table.resize and table.resize(t2, 1000)  -- 如果支持
    for i = 1, 1000 do
        t2[i] = i
    end

    -- 字符串拼接优化
    local function slow_concat()
        local s = ""
        for i = 1, 100 do
            s = s .. "item" .. i .. ","
        end
        return s
    end

    local function fast_concat()
        local parts = {}
        for i = 1, 100 do
            parts[i] = "item" .. i
        end
        return table.concat(parts, ",")
    end

    -- 避免创建不必要的对象
    local function process_data(items)
        local result = {}
        for _, item in ipairs(items) do
            -- 避免创建临时 table
            local processed = item * 2
            -- 只在需要时创建
            if processed > 10 then
                result[#result + 1] = processed
            end
        end
        return result
    end

    print("optimization examples done")
end

code_optimization()

-- 【问题3】Lua 的单元测试框架如何使用？
--
-- 常用测试框架：
--   - busted（BDD 风格）
--   - luaunit
--
-- 基本断言：
--   - assert(condition)
--   - assert_equal(expected, actual)
--   - assert_nil(value)

local function testing_demo()
    -- 手写简单测试
    local function assert(condition, msg)
        if not condition then
            error("Assertion failed: " .. (msg or ""))
        end
    end

    local function assert_equal(expected, actual, msg)
        if expected ~= actual then
            error(string.format("Expected %s but got %s%s",
                tostring(expected), tostring(actual),
                msg and ": " .. msg or ""))
        end
    end

    local function test(name, fn)
        local ok, err = pcall(fn)
        if ok then
            print("PASS:", name)
        else
            print("FAIL:", name, err)
        end
    end

    -- 测试函数
    test("add(2,3) = 5", function()
        local function add(a, b) return a + b end
        assert_equal(5, add(2, 3))
    end)

    test("concat strings", function()
        assert_equal("helloworld", "hello" .. "world")
    end)

    test("table length", function()
        assert_equal(3, #{1, 2, 3})
    end)
end

testing_demo()

-- 【问题4】Lua 的错误处理最佳实践是什么？
--
-- 最佳实践：
--   1. 使用 pcall 包装可能失败的调用
--   2. 返回 (nil, error) 而非抛出错误
--   3. 自定义错误类型
--   4. 日志记录错误

local function error_handling_best_practices()
    -- pcall 包装
    local function safe_divide(a, b)
        local ok, result = pcall(function()
            if b == 0 then
                error("division by zero", 2)
            end
            return a / b
        end)
        if ok then
            return result, nil
        else
            return nil, result
        end
    end

    local ok, result = safe_divide(10, 0)
    if not ok then
        print("error:", result)
    end

    -- 返回 (nil, error) 模式
    local function parse_number(s)
        local n = tonumber(s)
        if n then
            return n, nil
        else
            return nil, "invalid number"
        end
    end

    local num, err = parse_number("abc")
    if err then
        print("parse error:", err)
    else
        print("parsed:", num)
    end

    -- 错误日志
    local function log_error(err, context)
        print(string.format("[ERROR] %s: %s", context, tostring(err)))
    end

    pcall(function()
        error("something went wrong")
    end)
end

error_handling_best_practices()

-- 【问题5】Lua 的模块系统（require）如何使用？
--
-- module(name) 定义模块
-- require(name) 加载模块
-- package.path 搜索路径

local function module_system()
    -- 简单的模块定义
    local M = {}

    M.constant = 42

    M.add = function(a, b)
        return a + b
    end

    return M

    --[[ 使用：
    -- file: mymodule.lua
    local M = {}
    M.value = 100
    return M

    -- main.lua
    local mymodule = require("mymodule")
    print(mymodule.value)
    ]]
end

-- 运行时
local mod = module_system()
print("module constant:", mod.constant)
print("module add:", mod.add(2, 3))

-- 【问题6】Lua 的 Git 工作流如何配置？
--
-- Git 基础命令
-- 分支策略
-- 提交规范

local function git_basics()
    print("=== Git 基础 ===")
    print()
    print("基本命令：")
    print("  git init")
    print("  git add .")
    print("  git commit -m 'message'")
    print("  git push origin main")
    print("  git pull origin main")
    print()
    print("分支操作：")
    print("  git checkout -b feature/new-feature")
    print("  git merge feature/new-feature")
    print("  git branch -d feature/old")
    print()
    print("提交规范（Conventional Commits）：")
    print("  feat(module): add new feature")
    print("  fix(bug): resolve issue")
    print("  docs: update documentation")
    print("  refactor: code refactoring")
end

git_basics()

-- 【问题7】Lua 的 CI/CD 流程如何配置？
--
-- GitHub Actions
-- 自动测试
-- 部署脚本

local function cicd_setup()
    print("=== GitHub Actions 配置 ===")
    print()
    print("# .github/workflows/lua.yml")
    print("name: Lua CI")
    print("on: [push, pull_request]")
    print("jobs:")
    print("  test:")
    print("    runs-on: ubuntu-latest")
    print("    steps:")
    print("      - uses: actions/checkout@v4")
    print("      - name: Setup Lua")
    print("        uses: leafo/gh-actions-lua@v2")
    print("      - name: Run Tests")
    print("        run: busted")
    print("      - name: Lint")
    print("        run: luacheck .")
end

cicd_setup()

-- 【问题8】Lua 的文档如何编写？
--
-- 注释文档
-- LuaDoc 工具
-- 示例代码

local function documentation()
    print("=== Lua 文档 ===")
    print()
    print("--- 模块说明")
    print("--- @module mymodule")
    print()
    print("--- 函数说明")
    print("--- @function add")
    print("--- @param a number")
    print("--- @param b number")
    print("--- @return number")
    print("local function add(a, b)")
    print("    return a + b")
    print("end")
    print()
    print("LuaDoc 工具：")
    print("  luarocks install luadoc")
    print("  luadoc *.lua")
end

documentation()

-- 【问题9】Lua 的性能分析工具如何使用？
--
--Lua 内置性能测量：
--   - os.clock() - CPU 时间
--   - debug.sourceline() - 行号信息
--
-- 外部工具：
--   - LuaProf（性能分析器）
--   - LuaJIT 的 JIT 编译信息

local function profiling_tools()
    -- CPU 时间测量
    local function measure(func, iterations)
        iterations = iterations or 1
        local start = os.clock()
        for i = 1, iterations do
            func(i)
        end
        return os.clock() - start
    end

    -- 示例
    local function expensive(i)
        return math.sqrt(i) * math.sin(i)
    end

    local time = measure(expensive, 100000)
    print(string.format("100000 iterations took %.4f sec", time))

    -- LuaJIT 的 JIT 信息
    -- jit.on() / jit.off() 控制 JIT
    -- jit.dump() 输出编译日志
    print()
    print("LuaJIT JIT 信息：")
    print("  require('jit').on()")
    print("  require('jit').dump(true)")
end

profiling_tools()

-- ============================================================
-- 【对比】Lua vs Python vs Rust vs Go vs C++ 工程化
-- ============================================================
-- Rust:
--   - Cargo：内置构建/包管理
--   - Rustfmt：代码格式化
--   - Clippy：Linting

-- Lua:
--   - LuaRocks：包管理器
--   - 无内置格式化/Lint
--   - 动态类型

-- Python:
--   - pip/poetry：包管理
--   - black/isort/ruff：格式化/Lint
--   - pytest：测试

function compare_engineering()
    print("=== 五语言工程化对比 ===")
    print()
    print("| 方面        | Rust     | Python      | Lua      | Go       | C++        |")
    print("|-------------|----------|-------------|----------|----------|------------|")
    print("| 包管理      | Cargo    | pip/poetry   | LuaRocks | go mod   | vcpkg/cmake|")
    print("| 格式化      | rustfmt  | black        | 无       | gofmt    | clang-format|")
    print("| Lint        | clippy   | ruff/pylint  | luacheck| golangci | clang-tidy |")
    print("| 测试框架    | #[test]  | pytest       | busted   | testing  | gtest/doctest|")
end

-- ============================================================
-- 【练习题】
-- ============================================================
-- 1. 用闭包实现一个计数器模块（带私有状态），提供 increment/decrement/reset/get 操作
-- 2. 实现一个装饰器函数 logger(fn)，在函数调用前后打印日志，并返回装饰后的函数
-- 3. 配置 GitHub Actions CI 流程：安装 Lua 环境，运行 busted 测试，使用 luacheck 检查代码
-- 4. 实现一个简单的模块系统：module(name, exports)，导出命名空间
-- 5. 用 os.clock() 测量字符串拼接（..）和 table.concat 在 10000 次拼接下的性能差异

-- ============================================================
-- 总结
-- ============================================================
-- | 方面       | Lua 实现                                    |
-- |-----------|-------------------------------------------|
-- | 设计模式   | 闭包 + 表实现                              |
-- | 代码优化   | 局部缓存、table.concat                    |
-- | 测试       | busted / luaunit / 手写                   |
-- | 模块       | module / require                          |
-- | 文档       | LuaDoc                                     |
-- | 包管理     | LuaRocks                                   |
-- | CI/CD      | GitHub Actions                             |

local function main()
    print("=== 模块十六：工程化与设计思想 ===")

    design_patterns()
    code_optimization()
    testing_demo()
    error_handling_best_practices()
    module_system()
    git_basics()
    cicd_setup()
    documentation()
    profiling_tools()
    compare_engineering()

    print("\n✅ 所有示例运行成功！")
end

main()