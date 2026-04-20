-- === 第7章 数据库 ===

--[[
  本章目标：
  1. 理解LuaSQL连接SQLite
  2. 掌握SQL基础CRUD操作
  3. 理解游标概念
  4. 理解事务机制

  核心问题：
  Q1: Lua怎么连接数据库？
  Q2: 游标是什么？
  Q3: 为什么要用事务？
  深入: 预编译语句/防SQL注入
]]

-- ============================
-- Q1: Lua怎么连接数据库？
-- ============================

-- LuaSQL是最流行的Lua数据库库，支持MySQL, PostgreSQL, SQLite等
-- 本章以SQLite为例（单文件数据库，适合入门和测试）

-- 注意：以下代码需要安装LuaSQL库
-- luarocks install luasql-sqlite3

-- 示例代码（模拟，不依赖实际库）
--[[
local luasql = require("luasql.sqlite3")
local env = luasql.sqlite3()
local conn = env:open("test.db")  -- 打开或创建数据库

-- 检查连接是否成功
if not conn then
    error("无法连接数据库")
end

print("数据库连接成功")

-- 关闭连接
conn:close()
env:close()
]]

-- ============================
-- Q2: 游标是什么？
-- ============================

-- 游标(Cursor)：执行SQL后返回的结果集，指针在结果间移动

-- 伪代码演示游标概念：
local function mockQuery(sql)
    -- 模拟查询结果
    return {
        rows = {
            {id = 1, name = "Alice", age = 25},
            {id = 2, name = "Bob", age = 30},
            {id = 3, name = "Charlie", age = 35}
        },
        current = 0
    }
end

--[[
local cursor = conn:execute("SELECT * FROM users")
while cursor:fetch() do  -- fetch返回当前行，移动指针
    print(cursor.name, cursor.age)
end
cursor:close()
]]

-- 现代LuaSQL用法（更简洁）：
--[[
for row in conn:rows("SELECT * FROM users") do
    print(row.id, row.name, row.age)
end
]]

-- ============================
-- Q3: 为什么要用事务？
-- ============================

-- 事务确保一组操作要么全部成功，要么全部失败
-- 保证数据一致性

-- 事务的ACID特性：
-- Atomic（原子性）：所有操作作为一个单元
-- Consistent（一致性）：操作前后数据库状态一致
-- Isolated（隔离性）：并发操作互不干扰
-- Durable（持久性）：提交后数据永久保存

-- 事务示例（伪代码）：
--[[
conn:execute("BEGIN TRANSACTION")  -- 开始事务

local success, err = pcall(function()
    conn:execute("INSERT INTO users VALUES (1, 'Alice')")
    conn:execute("INSERT INTO users VALUES (2, 'Bob')")
    conn:execute("UPDATE users SET age = 26 WHERE id = 1")
end)

if success then
    conn:execute("COMMIT")  -- 提交
else
    conn:execute("ROLLBACK")  -- 回滚
end
]]

-- ============================
-- 深入: 预编译语句/防SQL注入
-- ============================

-- SQL注入攻击示例（危险）：
-- 用户输入：'; DROP TABLE users; -- 
-- 拼接SQL：SELECT * FROM users WHERE name = ''; DROP TABLE users; --'
-- 执行后会删除整个表

-- 预编译语句(Prepared Statement)：
-- 使用占位符，避免字符串拼接
--[[
local stmt = conn:prepare("SELECT * FROM users WHERE name = ? AND age > ?")
stmt:bind(1, "Alice")
stmt:bind(2, 20)
for row in stmt:rows() do
    print(row.name, row.age)
end
stmt:close()
]]

-- 在LuaSQL中更简单的做法：
--[[
local result = conn:execute(
    "SELECT * FROM users WHERE name = ?",
    "Alice"  -- 参数自动转义
)
]]

-- 自定义安全查询函数示例
local function safeQuery(conn, sql, ...)
    local args = {...}
    -- 简单的参数化查询模拟
    local safeSql = sql
    for i, arg in ipairs(args) do
        safeSql = safeSql:gsub("?", "'" .. tostring(arg) .. "'")
    end
    return safeSql
end

print("\n--- SQL注入防护演示 ---")
local sql = "SELECT * FROM users WHERE name = ? AND age > ?"
local safe = safeQuery(nil, sql, "Alice", 20)
print("原始SQL:", sql)
print("安全SQL:", safe)

-- ============================
-- 示例：完整可运行脚本（模拟数据库操作）
-- ============================

-- 用table模拟数据库表
local MockDB = {}
MockDB.__index = MockDB

function MockDB.new()
    return setmetatable({
        tables = {
            users = {
                {id = 1, name = "Alice", email = "alice@example.com"},
                {id = 2, name = "Bob", email = "bob@example.com"},
                {id = 3, name = "Charlie", email = "charlie@example.com"}
            }
        },
        nextId = {
            users = 4
        }
    }, MockDB)
end

-- Create (插入)
function MockDB.insert(self, tableName, record)
    record.id = self.nextId[tableName]
    self.nextId[tableName] = self.nextId[tableName] + 1
    table.insert(self.tables[tableName], record)
    return record.id
end

-- Read (查询)
function MockDB.select(self, tableName, where)
    local results = {}
    for _, row in ipairs(self.tables[tableName]) do
        local match = true
        if where then
            for k, v in pairs(where) do
                if row[k] ~= v then
                    match = false
                    break
                end
            end
        end
        if match then
            table.insert(results, row)
        end
    end
    return results
end

-- Update (更新)
function MockDB.update(self, tableName, where, updates)
    local count = 0
    for _, row in ipairs(self.tables[tableName]) do
        local match = true
        if where then
            for k, v in pairs(where) do
                if row[k] ~= v then
                    match = false
                    break
                end
            end
        end
        if match then
            for k, v in pairs(updates) do
                row[k] = v
            end
            count = count + 1
        end
    end
    return count
end

-- Delete (删除)
function MockDB.delete(self, tableName, where)
    local count = 0
    for i = #self.tables[tableName], 1, -1 do
        local row = self.tables[tableName][i]
        local match = true
        if where then
            for k, v in pairs(where) do
                if row[k] ~= v then
                    match = false
                    break
                end
            end
        end
        if match then
            table.remove(self.tables[tableName], i)
            count = count + 1
        end
    end
    return count
end

-- 事务模拟
function MockDB.transaction(self, func)
    local backup = {}
    for k, v in pairs(self.tables) do
        backup[k] = {}
        for i, row in ipairs(v) do
            backup[k][i] = {}
            for kk, vv in pairs(row) do
                backup[k][i][kk] = vv
            end
        end
    end
    
    local ok, err = pcall(func, self)
    
    if not ok then
        -- 回滚
        self.tables = backup
        return nil, err
    end
    return true
end

-- 使用示例
local db = MockDB.new()

print("初始用户表:")
for _, u in ipairs(db.tables.users) do
    print(string.format("  id=%d name=%s email=%s", u.id, u.name, u.email))
end

print("\n插入新用户:")
local newId = db:insert("users", {name = "David", email = "david@example.com"})
print("新用户ID:", newId)

print("\n查询Alice:")
local alices = db:select("users", {name = "Alice"})
for _, u in ipairs(alices) do
    print(string.format("  找到: id=%d name=%s", u.id, u.name))
end

print("\n更新用户年龄:")
local updated = db:update("users", {name = "Bob"}, {age = 35})
print("更新了", updated, "条记录")

print("\n删除用户:")
local deleted = db:delete("users", {id = 3})
print("删除了", deleted, "条记录")

print("\n最终用户表:")
for _, u in ipairs(db.tables.users) do
    print(string.format("  id=%d name=%s email=%s", u.id, u.name, u.email))
end

print("\n=== 第7章结束 ===")
