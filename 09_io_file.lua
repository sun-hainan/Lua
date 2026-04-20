-- ============================================================
-- 模块九：IO流与文件
-- 路径/字节流/字符流/缓冲流/序列化
-- ============================================================

-- 【问题1】Lua 如何读写文件？
--
-- io.open(filename, mode)：打开文件
-- 模式：
--   "r" - 读（默认）
--   "w" - 写（覆盖）
--   "a" - 追加
--   "r+" - 读写
--   "b" - 二进制模式

local function file_io_demo()
    -- 写文件
    local file = io.open("test_output.txt", "w")
    if file then
        file:write("Hello, Lua!\n")
        file:write("Second line\n")
        file:close()
        print("wrote to test_output.txt")
    end

    -- 读文件
    file = io.open("test_output.txt", "r")
    if file then
        local content = file:read("*a")
        print("file content:")
        print(content)
        file:close()
    end

    -- 逐行读取
    file = io.open("test_output.txt", "r")
    if file then
        for line in file:lines() do
            print("line:", line)
        end
        file:close()
    end
end

file_io_demo()

-- 【问题2】Lua 的标准输入输出如何使用？
--
-- io.read() / print() / io.write()
-- io.input() / io.output() 设置默认文件

local function stdio_demo()
    -- print 自动加换行
    print("Hello from print")

    -- io.write 不加换行
    io.write("Hello from io.write")
    io.write(" - no newline\n")

    -- 读取标准输入（交互模式）
    -- print("Enter something:")
    -- local input = io.read()
    -- print("You entered:", input)

    -- 读取整行
    -- local line = io.read("l")  -- 或 "*l"

    -- 读取单词
    -- local word = io.read("*w")  -- 或 "*n" for number

    -- 默认输入输出
    print("default input:", io.input())
    print("default output:", io.output())
end

stdio_demo()

-- 【问题3】Lua 的二进制文件如何处理？
--
-- 打开文件时加 "b" 模式
-- 使用 string.format("%c", byte) 转换字节

local function binary_io_demo()
    -- 写入二进制数据
    local file = io.open("binary.bin", "wb")
    if file then
        -- 写入字节序列
        local bytes = {0x48, 0x65, 0x6C, 0x6C, 0x6F}  -- "Hello"
        for _, b in ipairs(bytes) do
            file:write(string.char(b))
        end
        file:close()
        print("wrote binary file")
    end

    -- 读取二进制数据
    file = io.open("binary.bin", "rb")
    if file then
        local bytes = {}
        while true do
            local byte = file:read(1)
            if not byte then break end
            table.insert(bytes, string.byte(byte))
        end
        file:close()
        print("read bytes:", table.concat(bytes, ", "))
    end
end

binary_io_demo()

-- 【问题4】Lua 的路径操作如何实现？
--
-- Lua 标准库没有路径模块，需要自己处理
-- os.getenv("PATH") 或 string 操作

local function path_demo()
    -- 路径分隔符
    local sep = package.config:sub(1, 1)
    print("path separator:", sep)  -- Windows 是 \ 或 /

    -- 解析路径
    local path = "dir/subdir/file.txt"

    -- 找到文件名
    local filename = path:match("([^/\\]+)$")
    print("filename:", filename)

    -- 找到扩展名
    local ext = filename:match("%.([^.]+)$")
    print("extension:", ext)

    -- 找到目录
    local dir = path:match("^(.+)[/\\]")
    print("directory:", dir)

    -- 拼接路径
    local fullpath = "home" .. sep .. "user" .. sep .. "file.txt"
    print("full path:", fullpath)
end

path_demo()

-- 【问题5】Lua 的错误处理与文件操作如何结合？
--
-- io.open 可能返回 nil + 错误消息
-- assert 用于简化错误处理

local function file_error_handling()
    -- 基础错误处理
    local file, err = io.open("nonexistent.txt", "r")
    if not file then
        print("error opening:", err)
    end

    -- 使用 assert
    -- assert(io.open("test.txt", "r"), "cannot open file")
    -- 会抛出错误并终止脚本

    -- 安全读取
    local function safe_read(filename)
        local file, err = io.open(filename, "r")
        if not file then
            return nil, err
        end
        local content = file:read("*a")
        file:close()
        return content, nil
    end

    local content, err = safe_read("nonexistent.txt")
    if err then
        print("safe read error:", err)
    end
end

file_error_handling()

-- 【问题6】Lua 的序列化（dump/load）如何实现？
--
-- Lua table 序列化：
--   - 保存为 Lua 代码（loadstring 加载）
--   - 简单键值对
--
-- 常用库：penlight、rapidjson

local function serialization_demo()
    -- 简单序列化
    local function serialize(o)
        local t = type(o)
        if t == "nil" then return "nil"
        elseif t == "number" then return tostring(o)
        elseif t == "string" then return string.format("%q", o)
        elseif t == "boolean" then return tostring(o)
        elseif t == "table" then
            local parts = {}
            for k, v in pairs(o) do
                table.insert(parts, string.format("[%s] = %s",
                    serialize(k), serialize(v)))
            end
            return "{" .. table.concat(parts, ", ") .. "}"
        else
            return tostring(o)  -- function, userdata, thread
        end
    end

    local data = {
        name = "Alice",
        age = 30,
        scores = {95, 87, 92},
        active = true,
    }

    local s = serialize(data)
    print("serialized:")
    print(s)

    -- 反序列化（loadstring）
    local loaded = load("return " .. s)()
    print("deserialized:", loaded.name, loaded.age, loaded.scores[1])

    -- table 快速保存
    local function save_table(t, filename)
        local file = io.open(filename, "w")
        if not file then return false, "cannot open" end

        local function write_val(v, indent)
            local t = type(v)
            if t == "nil" then file:write("nil")
            elseif t == "number" then file:write(v)
            elseif t == "string" then file:write(string.format("%q", v))
            elseif t == "boolean" then file:write(v and "true" or "false")
            elseif t == "table" then
                file:write("{\n")
                for k, v in pairs(v) do
                    file:write(string.rep("  ", indent + 1))
                    write_val(k, indent + 1)
                    file:write(" = ")
                    write_val(v, indent + 1)
                    file:write(",\n")
                end
                file:write(string.rep("  ", indent), "}")
            else file:write("nil") end
        end

        write_val(t, 0)
        file:close()
        return true
    end

    local function load_table(filename)
        local file = io.open(filename, "r")
        if not file then return nil end
        local content = file:read("*a")
        file:close()
        return load("return " .. content)()
    end

    -- save_table(data, "data.lua")
    -- local loaded = load_table("data.lua")
end

serialization_demo()

-- 【问题7】Lua 的缓冲 IO 和行缓冲是什么？
--
-- io.output() 可以设置缓冲模式
-- "*l" 是行缓冲（默认）
-- "*a" 是全缓冲

local function buffered_io_demo()
    -- 行缓冲（stdin/stdout 默认）
    -- io.read("*l") 读取一行

    -- 全缓冲（文件默认）
    local file = io.open("buffered.txt", "w")
    -- file:setvbuf("full")  -- 全缓冲（默认）
    -- file:setvbuf("line")  -- 行缓冲
    -- file:setvbuf("no")    -- 无缓冲

    file:write("line 1\n")
    file:write("line 2\n")
    file:flush()  -- 手动刷新
    file:close()

    -- io.open 的缓冲
    print("buffering examples created")
end

buffered_io_demo()

-- ============================================================
-- 【对比】Rust vs Lua vs Python IO
-- ============================================================
-- Rust:
--   - File/BufReader/BufWriter 分层抽象
--   - Read/Write trait 统一接口
--   - serde 序列化框架

-- Lua:
--   - io.open / io.read / io.write 基本 IO
--   - 无缓冲 IO，需要手动 flush
--   - 无原生序列化，用 table 序列化或库

-- Python:
--   - open() 返回文件对象，统一读写
--   - 内置 JSON 支持（json 模块）
--   - pathlib 提供面向对象路径处理

function compare_io()
    print("=== 三语言IO对比 ===")

    -- 文件读取模式对比
    -- Lua:  local f = io.open("file.txt", "r") local content = f:read("*a") f:close()
    -- Python: with open("file.txt", "r") as f: content = f.read()
end

-- ============================================================
-- 练习题
-- ============================================================
-- 1. 实现一个文件复制函数
-- 2. 实现一个配置解析器（支持键=值格式）
-- 3. 比较行缓冲和全缓冲的区别

-- ============================================================
-- 总结
-- ============================================================
-- | 功能       | Lua 实现                                    |
-- |-----------|-------------------------------------------|
-- | 打开文件   | io.open(filename, mode)                   |
-- | 读         | file:read("*a") / file:lines()            |
-- | 写         | file:write(str)                           |
-- | 关闭       | file:close()                              |
-- | 刷新       | file:flush()                              |
-- | 二进制模式 | "rb" / "wb"                              |
-- | 序列化     | 手写或库                                   |

local function main()
    print("=== 模块九：IO流与文件 ===")

    file_io_demo()
    stdio_demo()
    binary_io_demo()
    path_demo()
    file_error_handling()
    serialization_demo()
    buffered_io_demo()
    compare_io()

    print("\n✅ 所有示例运行成功！")
end

main()