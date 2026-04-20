-- ============================================================
-- 模块八：集合框架
-- List/Set/Map/泛型/工具类
-- ============================================================

-- 【问题1】Lua 的 table 如何作为 List（动态数组）使用？
--
-- Lua 的 table 就是动态数组：
--   - #t 获取长度
--   - table.insert / table.remove 操作
--   - 索引从 1 开始

local function list_demo()
    -- 创建列表
    local list = {10, 20, 30, 40, 50}
    print("initial:", table.concat(list, ", "))

    -- 添加元素
    table.insert(list, 60)
    print("after insert 60:", table.concat(list, ", "))

    -- 在指定位置插入
    table.insert(list, 3, 25)
    print("after insert 25 at 3:", table.concat(list, ", "))

    -- 访问
    print("list[1]:", list[1])
    print("list[#list]:", list[#list])

    -- 删除
    table.remove(list, 3)
    print("after remove 3:", table.concat(list, ", "))

    -- 删除最后一个
    table.remove(list)
    print("after remove last:", table.concat(list, ", "))

    -- 遍历
    print("for loop:")
    for i = 1, #list do
        print(string.format("  [%d] = %d", i, list[i]))
    end

    -- 泛型 for（ipairs）
    print("ipairs:")
    for i, v in ipairs(list) do
        print(string.format("  [%d] = %d", i, v))
    end
end

list_demo()

-- 【问题2】Lua 的 table 如何作为 Map（字典）使用？
--
-- Map 特性：
--   - 键值对存储
--   - 任意类型作为键（除 nil）
--   - 无序（可以用 pairs 或排序后遍历）

local function map_demo()
    -- 创建字典
    local dict = {
        name = "Alice",
        age = 30,
        ["city"] = "Beijing",
    }

    -- 访问（两种方式）
    print("dict.name:", dict.name)
    print("dict['age']:", dict["age"])
    print("dict.city:", dict.city)

    -- 赋值
    dict.job = "engineer"
    print("after assignment:", dict.job)

    -- 删除（设为 nil）
    dict.job = nil
    print("after delete:", dict.job)

    -- 遍历（pairs，无序）
    print("pairs:")
    for k, v in pairs(dict) do
        print(string.format("  %s = %s", tostring(k), tostring(v)))
    end

    -- 判断键是否存在
    print("name exists:", dict.name ~= nil)
    print("job exists:", dict.job ~= nil)

    -- 安全的访问（检查存在）
    local function safe_get(t, key)
        if t[key] ~= nil then
            return t[key]
        end
        return nil
    end
    print("safe_get name:", safe_get(dict, "name"))
    print("safe_get job:", safe_get(dict, "job"))
end

map_demo()

-- 【问题3】Lua 如何模拟 Set（集合）？
--
-- Set 特性：
--   - 唯一元素
--   - 快速查找
--   - 无序
--
-- Lua 实现：用 table 作为 set（值作为键，值为 true）

local function set_demo()
    -- 创建集合
    local function Set(...)
        local set = {}
        for _, v in ipairs({...}) do
            set[v] = true
        end
        return set
    end

    local fruits = Set("apple", "banana", "cherry", "apple")  -- 重复被忽略
    print("fruits:", next(fruits))  -- 打印第一个（无序）

    -- 检查元素
    print("has apple:", fruits["apple"])
    print("has orange:", fruits["orange"])

    -- 集合运算
    local function union(a, b)
        local result = {}
        for k in pairs(a) do result[k] = true end
        for k in pairs(b) do result[k] = true end
        return result
    end

    local function intersection(a, b)
        local result = {}
        for k in pairs(a) do
            if b[k] then result[k] = true end
        end
        return result
    end

    local a = Set(1, 2, 3, 4)
    local b = Set(3, 4, 5, 6)

    local u = union(a, b)
    local inter = intersection(a, b)

    print("union:", next(u), next(u))
    print("intersection:", next(inter), next(inter))

    -- 集合转列表
    local function set_to_list(s)
        local list = {}
        for k in pairs(s) do
            table.insert(list, k)
        end
        return list
    end
end

set_demo()

-- 【问题4】Lua 的 table 作为队列如何使用？
--
-- 队列：FIFO
-- Lua 实现：table.insert（尾） + table.remove（头）
-- 注意：table.remove(1) 是 O(n) 操作，大队列用循环缓冲区

local function queue_demo()
    -- 简单队列
    local function create_queue()
        return {}
    end

    local function enqueue(q, item)
        table.insert(q, item)  -- 插入尾部
    end

    local function dequeue(q)
        return table.remove(q, 1)  -- 移除头部（O(n)）
    end

    local function is_empty(q)
        return #q == 0
    end

    local q = create_queue()
    enqueue(q, "task1")
    enqueue(q, "task2")
    enqueue(q, "task3")

    print("dequeue:", dequeue(q))  -- task1
    print("dequeue:", dequeue(q))  -- task2
    print("is empty:", is_empty(q))
    print("dequeue:", dequeue(q))  -- task3
    print("is empty:", is_empty(q))

    -- 双端队列（deque）
    local function create_deque()
        return {}
    end

    local function push_front(q, item)
        table.insert(q, 1, item)
    end

    local function push_back(q, item)
        table.insert(q, item)
    end

    local function pop_front(q)
        return table.remove(q, 1)
    end

    local function pop_back(q)
        return table.remove(q)
    end
end

queue_demo()

-- 【问题5】Lua 的 table 工具函数（table library）有哪些？
--
-- table 库函数：
--   table.insert(t, pos, value) - 插入
--   table.remove(t, pos) - 删除
--   table.sort(t, comp) - 排序
--   table.concat(t, sep, i, j) - 连接
--   table.move(a, f, e, t) - 移动
--   table.unpack - 展开

local function table_library()
    local arr = {5, 2, 8, 1, 9, 3, 7, 4, 6}

    -- sort
    table.sort(arr)
    print("sorted:", table.concat(arr, ", "))

    -- sort with comparator
    table.sort(arr, function(a, b) return a > b end)
    print("sorted desc:", table.concat(arr, ", "))

    -- concat
    local words = {"hello", "world", "lua"}
    print("concat:", table.concat(words, " "))
    print("concat with indices:", table.concat(words, ", ", 2, 3))

    -- unpack
    local t = {1, 2, 3}
    print("unpack:", table.unpack(t))
    print("partial unpack:", table.unpack(t, 1, 2))

    -- 常用模式：打平
    local nested = {{1, 2}, {3, 4}, {5, 6}}
    local flat = {}
    for _, sub in ipairs(nested) do
        for _, v in ipairs(sub) do
            table.insert(flat, v)
        end
    end
    print("flattened:", table.concat(flat, ", "))
end

table_library()

-- 【问题6】Lua 的弱表（weak table）是什么？
--
-- 弱表：引用可以被垃圾回收的 table
-- 设置：setmetatable(t, {__mode = "k"}) 或 "v" 或 "kv"
--
-- 用途：缓存、记忆化、避免循环引用

local function weak_table_demo()
    -- 弱引用值（value 是弱引用）
    local cache = setmetatable({}, {__mode = "v"})

    local key = {}
    cache[key] = "expensive result"

    print("cache[key]:", cache[key])

    -- key 没有其他引用，可以被回收
    key = nil  -- 解除引用

    -- 强制垃圾回收
    collectgarbage()

    print("cache after GC:", next(cache))  -- nil（key 已被回收）

    -- 记忆化示例
    local function memoize(fn)
        local cache = setmetatable({}, {__mode = "kv"})
        return function(...)
            local key = table.concat({...}, ",", 1, select("#", ...))
            if cache[key] == nil then
                cache[key] = fn(...)
            end
            return cache[key]
        end
    end

    local function expensive(n)
        print("computing...")
        return n * 2
    end

    local memo = memoize(expensive)
    print(memo(5))  -- computing...
    print(memo(5))  -- 直接返回缓存
end

weak_table_demo()

-- 【问题7】Lua 的有序字典（Sorted Map）如何实现？
--
-- Lua 的 pairs 是无序的（按插入顺序，但不是排序）
-- Lua 5.3+ 保证 pairs 按插入顺序
-- 但要排序需要手动处理

local function sorted_map_demo()
    local map = {
        {key = "zebra", value = 1},
        {key = "apple", value = 2},
        {key = "banana", value = 3},
    }

    -- 按 key 排序
    table.sort(map, function(a, b)
        return a.key < b.key
    end)

    print("sorted by key:")
    for _, pair in ipairs(map) do
        print(string.format("  %s = %d", pair.key, pair.value))
    end

    -- 按值排序
    table.sort(map, function(a, b)
        return a.value > b.value
    end)

    print("sorted by value:")
    for _, pair in ipairs(map) do
        print(string.format("  %s = %d", pair.key, pair.value))
    end

    -- BTree 实现（需要外部库或手写）
    print("For true sorted map, use sortedmap library")
end

sorted_map_demo()

-- ============================================================
-- 【对比】Rust vs Lua vs Python 集合
-- ============================================================
-- Rust:
--   - Vec<T>: 动态数组
--   - HashMap<K, V>: 哈希映射
--   - HashSet<T>: 哈希集合
--   - BTreeMap/TreeSet: 有序映射/集合

-- Lua:
--   - table: 唯一的复合类型，可作数组/映射/集合
--   - 无内置 Set，用 table[key] = true 模拟
--   - 弱表用于缓存和避免循环引用

-- Python:
--   - list: 动态数组
--   - dict: 哈希映射
--   - set: 哈希集合
--   - collections.OrderedDict: 有序字典（Python 3.7+ 保持插入顺序）

function compare_collections()
    print("=== 三语言集合对比 ===")

    -- Lua 的 table 是万能的
    local as_array = {1, 2, 3}      -- 数组
    local as_dict = {a = 1, b = 2}  -- 字典
    local as_set = {apple = true, banana = true}  -- 集合

    print("Lua table can be array, dict, or set")
end

-- ============================================================
-- 练习题
-- ============================================================
-- 1. 实现一个 LRU 缓存（用有序表或双向链表）
-- 2. 实现一个图（用邻接表表示）
-- 3. 比较 Lua 的 table 和 Python 的 dict 的性能特点

-- ============================================================
-- 总结
-- ============================================================
-- | 集合类型   | Lua 实现                                    |
-- |-----------|-------------------------------------------|
-- | List      | table（索引从1开始）                        |
-- | Map       | table（键值对）                             |
-- | Set       | table（值作为键，值为true）                 |
-- | Queue     | table（insert/remove模拟）                  |
-- | 有序集合   | 表的数组部分排序                            |
-- | 弱表       | setmetatable(t, {__mode=...})             |

local function main()
    print("=== 模块八：集合框架 ===")

    list_demo()
    map_demo()
    set_demo()
    queue_demo()
    table_library()
    weak_table_demo()
    sorted_map_demo()
    compare_collections()

    print("\n✅ 所有示例运行成功！")
end

main()