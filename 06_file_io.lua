-- === 第6章 文件IO ===

--[[
  本章目标：
  1. 掌握io.open/read/write/close的使用
  2. 理解文件模式r/b/w/a
  3. 理解io.lines迭代器
  4. 理解二进制文件处理

  核心问题：
  Q1: io和os模块的区别？
  Q2: 为什么要close文件？
  Q3: 迭代器的优势是什么？
  深入: 文件描述符/缓冲区/行缓冲
]]

-- ============================
-- Q1: io和os模块的区别？
-- ============================

-- io模块：高级文件操作（面向流的IO）
-- - io.open() 打开文件
-- - io.read()/write() 读写文件
-- - io.close() 关闭文件
-- - io.lines() 迭代器逐行读取

-- os模块：系统级操作（文件和进程管理）
-- - os.remove() 删除文件
-- - os.rename() 重命名文件
-- - os.execute() 执行shell命令
-- - os.getenv() 获取环境变量

local testFile = "test_io.txt"

-- 用io模块写入文件
local f = io.open(testFile, "w")  -- "w"=写模式，会清空文件
f:write("第1行: Hello Lua\n")
f:write("第2行: 文件IO演示\n")
f:write("第3行: 测试数据\n")
f:close()
print("写入文件完成")

-- 用io模块读取文件
local f = io.open(testFile, "r")  -- "r"=读模式
local content = f:read("*a")      -- "*a"=读取全部内容
f:close()
print("读取内容:", content)

-- ============================
-- Q2: 为什么要close文件？
-- ============================

-- 文件是一种资源（文件描述符fd），操作系统限制同时打开的数量
-- 不关闭会导致：资源泄漏、系统变慢、程序崩溃

-- 正确做法1：手动close
local f1 = io.open(testFile, "r")
local data = f1:read("*a")
f1:close()

-- 正确做法2：使用local file = io.open()确保file句柄
-- Lua GC会在适当时机关闭未引用的文件，但不要依赖GC

-- 最佳实践：使用带gc保护的封装
local function withFile(filename, mode, func)
    local file, err = io.open(filename, mode)
    if not file then
        return nil, err
    end
    local success, result = pcall(func, file)
    file:close()
    if not success then
        return nil, result
    end
    return result
end

-- 使用示例
local lines = withFile(testFile, "r", function(f)
    local result = {}
    for line in f:lines() do
        table.insert(result, line)
    end
    return result
end)

if lines then
    print("\nwithFile读取结果:")
    for i, line in ipairs(lines) do
        print("  " .. i .. ":", line)
    end
end

-- ============================
-- Q3: 迭代器的优势是什么？
-- ============================

-- io.lines()返回一个迭代器，逐行读取，不会把整个文件加载到内存
-- 适合处理大文件

-- 方式1：逐行读取（大文件推荐）
print("\nio.lines逐行读取:")
local count = 0
for line in io.lines(testFile) do
    count = count + 1
    print("  行" .. count .. ":", line)
end

-- 方式2：一次性读取全部（小文件）
local f = io.open(testFile, "r")
local all = f:read("*a")
f:close()
print("\n一次性读取:", string.len(all), "字节")

-- 方式3：read的格式参数
local f = io.open(testFile, "r")
local line1 = f:read("*l")      -- 读一行（不含换行）
local line2 = f:read("*l")
local num = f:read("*n")         -- 读一个数字
local rest = f:read("*a")        -- 读剩余全部
f:close()
print("\n分格式读取:")
print("  line1:", line1)
print("  line2:", line2)
print("  num:", num)
print("  rest:", rest)

-- ============================
-- 深入: 文件描述符/缓冲区/行缓冲
-- ============================

-- 文件描述符(File Descriptor)：操作系统分配的数字，代表打开的文件
-- 标准文件描述符：
-- 0 = stdin（标准输入）
-- 1 = stdout（标准输出）
-- 2 = stderr（标准错误）

-- io.stdout, io.stdin, io.stderr是预定义的文件句柄
io.stdout:write("直接用stdout写入\n")  -- 不自动加换行

-- 缓冲模式（默认行为）：
-- 1. 完全缓冲：积累一定数据再写入（文件）
-- 2. 行缓冲：遇到换行符就写入（终端）
-- 3. 无缓冲：立即写入（错误输出）

-- 可以用:setvbuf设置缓冲模式
local f = io.open(testFile, "w")
-- f:setvbuf("no")      -- 无缓冲
-- f:setvbuf("full")    -- 完全缓冲，可指定大小
-- f:setvbuf("line")    -- 行缓冲（默认）

-- ============================
-- 示例：二进制文件处理
-- ============================

local binFile = "test_binary.bin"

-- 写入二进制数据
local f = io.open(binFile, "wb")  -- "b"=二进制模式
-- 写入字节：\x00-\xFF的字符
f:write(string.char(0x48, 0x65, 0x6C, 0x6C, 0x6F))  -- "Hello"
f:write(struct.pack("<I32", 12345))  -- 小端32位无符号整数（需要LuaSocket或类似库）
f:close()

-- 读取二进制数据
local f = io.open(binFile, "rb")
local header = f:read(5)  -- 读5字节
local num = f:read(4)     -- 读4字节作为数字
f:close()

print("\n二进制读取:")
print("  header:", header)
print("  bytes:", string.format("0x%02X", string.byte(num, 1, 4)))

-- 简单二进制操作
local bytes = {0x48, 0x65, 0x6C, 0x6C, 0x6F}
local str = string.char(table.unpack(bytes))
print("  字符串转换:", str)

-- 清理测试文件
os.remove(testFile)
os.remove(binFile)

print("\n=== 第6章结束 ===")
