-- ============================================================
-- 模块十五：数据库编程
-- SQL/事务/ORM
-- ============================================================

-- 注意：Lua 没有内置数据库支持，需要使用库
-- 常用库：luasql（SQLite/MySQL/PostgreSQL）、luasql-mysql

-- 【问题1】Lua 的 luasql 如何安装和使用？
--
-- 安装：luarocks install luasql-sqlite3
-- 使用：require("luasql.sqlite3")

local function luasql_intro()
    print("=== LuaSQL 简介 ===")
    print()
    print("LuaSQL 是 Lua 的数据库抽象层")
    print("支持：SQLite3、MySQL、PostgreSQL、ODBC")
    print()
    print("安装：")
    print("  luarocks install luasql-sqlite3")
    print("  luarocks install luasql-mysql")
    print("  luarocks install luasql-postgres")
    print()

    --[[ 实际运行需要 luasql
    local luasql = require("luasql.sqlite3")
    local env = luasql.sqlite3()
    local conn = env:open("test.db")

    -- 执行 SQL
    conn:execute("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)")
    conn:execute("INSERT INTO users VALUES (1, 'Alice')")

    -- 查询
    local cursor = conn:execute("SELECT * FROM users")
    local row = cursor:fetch({}, "a")  -- 按列名获取
    while row do
        print(row.id, row.name)
        row = cursor:fetch(row, "a")
    end

    cursor:close()
    conn:close()
    env:close()
    ]]

    print("基本用法：")
    print("  env = luasql.sqlite3()")
    print("  conn = env:open('test.db')")
    print("  conn:execute(sql)")
    print("  cursor = conn:execute('SELECT')")
end

luasql_intro()

-- 【问题2】Lua 的 SQL 基本操作（CRUD）如何实现？
--
-- CRUD：Create, Read, Update, Delete
-- 参数化查询防 SQL 注入

local function sql_crud()
    print("=== CRUD 操作示例 ===")
    print()

    --[[
    local conn = env:open("test.db")

    -- INSERT（创建）
    conn:execute("INSERT INTO users (name, age) VALUES ('Alice', 30)")
    conn:execute("INSERT INTO users (name, age) VALUES ('Bob', 25)")

    -- SELECT（读取）
    local cursor = conn:execute("SELECT name, age FROM users WHERE age > 20")
    local row = cursor:fetch({}, "a")
    while row do
        print(row.name, row.age)
        row = cursor:fetch(row, "a")
    end
    cursor:close()

    -- UPDATE（更新）
    conn:execute("UPDATE users SET age = 31 WHERE name = 'Alice'")

    -- DELETE（删除）
    conn:execute("DELETE FROM users WHERE name = 'Bob'")

    conn:close()
    ]]

    print("CRUD 操作：")
    print("  conn:execute('INSERT INTO ...')")
    print("  conn:execute('SELECT ...')")
    print("  conn:execute('UPDATE ...')")
    print("  conn:execute('DELETE ...')")
    print()
    print("安全注意：LuaSQL 不支持参数化查询")
    print("需要手动转义或使用其他库")
end

sql_crud()

-- 【问题3】Lua 的事务处理如何实现？
--
-- 事务：原子性操作
-- BEGIN / COMMIT / ROLLBACK

local function transaction_demo()
    print("=== 事务处理示例 ===")
    print()

    --[[
    conn:execute("BEGIN")

    local ok, err = pcall(function()
        conn:execute("INSERT INTO accounts (id, balance) VALUES (1, 100)")
        conn:execute("UPDATE accounts SET balance = balance - 50 WHERE id = 1")
        -- 检查余额
        local cursor = conn:execute("SELECT balance FROM accounts WHERE id = 1")
        local row = cursor:fetch({}, "a")
        if row.balance < 0 then
            error("余额不足")
        end
        cursor:close()
    end)

    if ok then
        conn:execute("COMMIT")
    else
        print("事务失败:", err)
        conn:execute("ROLLBACK")
    end
    ]]

    print("事务语法：")
    print("  conn:execute('BEGIN')")
    print("  conn:execute('COMMIT')")
    print("  conn:execute('ROLLBACK')")
end

transaction_demo()

-- 【问题4】Lua 的 SQL 注入防御如何实现？
--
-- LuaSQL 不支持参数化查询
-- 防御方法：
--   1. 转义特殊字符
--   2. 输入验证
--   3. 使用 ORM 库

local function sql_injection_prevention()
    print("=== SQL 注入防御 ===")
    print()

    print("问题：LuaSQL 不支持参数化查询")
    print("解决方案：")
    print("  1. 手动转义")
    print("  2. 白名单验证")
    print("  3. 使用 ORM")

    -- 转义函数
    local function quote_string(s)
        if s == nil then return "NULL" end
        return "'" .. tostring(s):gsub("'", "''") .. "'"
    end

    local user_input = "'; DROP TABLE users; --"
    local safe_input = quote_string(user_input)
    print("safe:", safe_input)

    -- 白名单验证
    local function validate_sort_column(col)
        local allowed = {name = true, age = true, id = true}
        if allowed[col] then
            return col
        end
        return "id"  -- 默认
    end

    local column = validate_sort_column("name")
    print("validated column:", column)
end

sql_injection_prevention()

-- 【问题5】Lua 的 ORM（对象关系映射）有哪些库？
--
-- 常用 Lua ORM：
--   - Lucia（简单）
--   - lustache（模板）
--   - 自定义实现
--
-- ORM 将表映射为对象

local function orm_intro()
    print("=== ORM 简介 ===")
    print()

    --[[ 自定义简单 ORM
    local function create_model(conn, table_name)
        return setmetatable({}, {
            __index = {
                find = function(self, id)
                    local cursor = conn:execute(
                        string.format("SELECT * FROM %s WHERE id = %d", table_name, id)
                    )
                    local row = cursor:fetch({}, "a")
                    cursor:close()
                    return row
                end,
                all = function(self)
                    local cursor = conn:execute("SELECT * FROM " .. table_name)
                    local rows = {}
                    local row = cursor:fetch({}, "a")
                    while row do
                        table.insert(rows, row)
                        row = cursor:fetch(row, "a")
                    end
                    cursor:close()
                    return rows
                end,
            },
        })
    end

    local User = create_model(conn, "users")
    local alice = User:find(1)
    print(alice.name, alice.age)
    ]]

    print("简单 ORM 实现思路：")
    print("  - 每个表对应一个 model 对象")
    print("  - find(id) 查找单条记录")
    print("  - all() 查找所有记录")
    print("  - save() 保存记录")
end

orm_intro()

-- 【问题6】Lua 的 NoSQL 支持如何？（Redis / MongoDB）
--
-- Redis：redis-lua
-- MongoDB：luamongo

local function nosql_support()
    print("=== NoSQL 支持 ===")
    print()

    --[[ redis-lua
    local redis = require("redis")
    local client = redis.connect("127.0.0.1", 6379)

    -- 字符串操作
    client:set("key", "value")
    local val = client:get("key")
    print(val)

    -- 哈希操作
    client:hset("user:1", "name", "Alice")
    client:hset("user:1", "age", "30")
    local name = client:hget("user:1", "name")
    print(name)

    -- 列表操作
    client:lpush("queue", "task1")
    client:lpush("queue", "task2")
    local task = client:rpop("queue")
    print(task)

    -- Lua 连接池（需要 redis-pool 库）
    ]]

    print("Redis (redis-lua)：")
    print("  client = redis.connect('host', port)")
    print("  client:set(key, value)")
    print("  client:get(key)")
    print("  client:hset(key, field, value)")
    print("  client:lpush(key, value)")
end

nosql_support()

-- 【问题7】Lua 的连接池如何实现？
--
-- 连接池：复用数据库连接
-- 避免频繁创建/销毁连接的开销

local function connection_pool_demo()
    print("=== 连接池示例 ===")
    print()

    --[[ 简单连接池实现
    local function create_pool(create_func, max_size)
        local pool = {
            available = {},
            in_use = {},
            create = create_func,
            max_size = max_size or 10,
        }

        return setmetatable(pool, {
            __index = {
                acquire = function(self)
                    if #self.available > 0 then
                        local conn = table.remove(self.available)
                        self.in_use[conn] = true
                        return conn
                    end
                    if #self.in_use < self.max_size then
                        local conn = self.create()
                        self.in_use[conn] = true
                        return conn
                    end
                    error("no available connections")
                end,
                release = function(self, conn)
                    self.in_use[conn] = nil
                    table.insert(self.available, conn)
                end,
            },
        })
    end

    -- 使用
    local pool = create_pool(function()
        return luasql.sqlite3():open("test.db")
    end, 5)

    local conn = pool:acquire()
    -- 使用 conn
    pool:release(conn)
    ]]

    print("连接池概念：")
    print("  acquire() 获取连接")
    print("  release(conn) 归还连接")
    print("  控制最大连接数")
end

connection_pool_demo()

-- ============================================================
-- 【对比】Rust vs Lua vs Python 数据库
-- ============================================================
-- Rust:
--   - rusqlite：SQLite
--   - diesel：ORM
--   - sqlx：异步 SQL

-- Lua:
--   - luasql：SQLite/MySQL/PostgreSQL
--   - redis-lua：Redis

-- Python:
--   - sqlite3：内置
--   - SQLAlchemy：ORM
--   - psycopg2：PostgreSQL

function compare_databases()
    print("=== 三语言数据库对比 ===")

    print()
    print("| 特性       | Rust        | Python           | Lua          |")
    print("|------------|-------------|------------------|--------------|")
    print("| SQLite     | rusqlite    | sqlite3 (内置)    | luasql-sqlite|")
    print("| ORM        | Diesel/SQLx | SQLAlchemy       | 自定义       |")
    print("| Redis      | redis-rs    | redis-py         | redis-lua    |")
end

-- ============================================================
-- 练习题
-- ============================================================
-- 1. 用 luasql 创建表、插入数据、查询数据
-- 2. 实现一个简单的事务包装函数
-- 3. 实现一个 Redis 连接池

-- ============================================================
-- 总结
-- ============================================================
-- | 功能       | Lua 实现                                    |
-- |-----------|-------------------------------------------|
-- | SQLite     | luasql-sqlite3                            |
-- | MySQL      | luasql-mysql                              |
-- | PostgreSQL | luasql-postgres                           |
-- | Redis      | redis-lua                                 |
-- | 连接池     | 自定义实现                                 |
-- | ORM        | 自定义或库                                |

local function main()
    print("=== 模块十五：数据库编程 ===")

    luasql_intro()
    sql_crud()
    transaction_demo()
    sql_injection_prevention()
    orm_intro()
    nosql_support()
    connection_pool_demo()
    compare_databases()

    print("\n✅ 所有示例运行成功！")
end

main()