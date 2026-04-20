-- ============================================================
-- 模块十四：数据结构与算法
-- 链表/栈/队列/哈希表/树/排序/查找/复杂度
-- ============================================================

-- 【问题1】Lua 如何实现链表？
--
-- 链表：每个节点包含数据和指向下一个节点的引用
-- Lua 中用 table 实现，next 指向下一个节点

local function linked_list()
    -- 单向链表节点
    local function create_node(value)
        return {
            value = value,
            next = nil,
        }
    end

    -- 创建链表
    local function create_list(...)
        local head = nil
        local args = {...}
        for i = #args, 1, -1 do
            local node = create_node(args[i])
            node.next = head
            head = node
        end
        return head
    end

    -- 遍历
    local function traverse(head)
        local current = head
        local result = {}
        while current do
            table.insert(result, current.value)
            current = current.next
        end
        return result
    end

    -- 在头部插入
    local function push_front(head, value)
        local node = create_node(value)
        node.next = head
        return node
    end

    -- 在尾部插入
    local function push_back(head, value)
        local node = create_node(value)
        if not head then return node end
        local current = head
        while current.next do
            current = current.next
        end
        current.next = node
        return head
    end

    -- 反转链表
    local function reverse(head)
        local prev = nil
        local current = head
        while current do
            local next = current.next
            current.next = prev
            prev = current
            current = next
        end
        return prev
    end

    -- 测试
    local head = create_list(1, 2, 3, 4, 5)
    print("original:", table.concat(traverse(head), ", "))

    head = push_front(head, 0)
    print("after push_front:", table.concat(traverse(head), ", "))

    head = reverse(head)
    print("after reverse:", table.concat(traverse(head), ", "))

    -- 求链表长度（迭代）
    local function length(head)
        local count = 0
        local current = head
        while current do
            count = count + 1
            current = current.next
        end
        return count
    end

    print("length:", length(head))
end

linked_list()

-- 【问题2】Lua 如何实现栈和队列？
--
-- 栈（Stack）：LIFO
--   - push：压入
--   - pop：弹出
--   - top：查看顶部
--
-- 队列（Queue）：FIFO
--   - enqueue：入队
--   - dequeue：出队

local function stack_queue()
    -- 栈实现
    local function create_stack()
        return {top = 0, data = {}}
    end

    local function stack_push(s, value)
        s.top = s.top + 1
        s.data[s.top] = value
    end

    local function stack_pop(s)
        if s.top <= 0 then return nil end
        local value = s.data[s.top]
        s.top = s.top - 1
        return value
    end

    local function stack_top(s)
        if s.top <= 0 then return nil end
        return s.data[s.top]
    end

    local function stack_is_empty(s)
        return s.top == 0
    end

    -- 测试栈
    local s = create_stack()
    stack_push(s, 10)
    stack_push(s, 20)
    stack_push(s, 30)
    print("stack top:", stack_top(s))
    print("stack pop:", stack_pop(s))
    print("stack pop:", stack_pop(s))
    print("stack is empty:", stack_is_empty(s))

    -- 队列实现（注意：table.remove(1) 是 O(n)）
    local function create_queue()
        return {head = 0, tail = 0, data = {}}
    end

    local function enqueue(q, value)
        q.data[q.tail] = value
        q.tail = q.tail + 1
    end

    local function dequeue(q)
        if q.head >= q.tail then return nil end
        local value = q.data[q.head + 1]
        q.head = q.head + 1
        return value
    end

    local function queue_is_empty(q)
        return q.head >= q.tail
    end

    -- 测试队列
    local q = create_queue()
    enqueue(q, "task1")
    enqueue(q, "task2")
    enqueue(q, "task3")
    print("dequeue:", dequeue(q))
    print("dequeue:", dequeue(q))
    print("queue is empty:", queue_is_empty(q))

    -- 括号匹配（栈应用）
    local function is_balanced(s)
        local stack = create_stack()
        local pairs = {["("] = ")", ["["] = "]", ["{"] = "}"}

        for i = 1, #s do
            local c = s:sub(i, i)
            if pairs[c] then
                stack_push(stack, pairs[c])
            elseif c == ")" or c == "]" or c == "}" then
                if stack_pop(stack) ~= c then
                    return false
                end
            end
        end

        return stack_is_empty(stack)
    end

    print("'()[]{}' balanced:", is_balanced("()[]{}"))
    print("'([)]' balanced:", is_balanced("([)]"))
end

stack_queue()

-- 【问题3】Lua 的树结构（二叉树、BST）如何实现？
--
-- 二叉树：每个节点有 left 和 right 子节点
-- BST：左子树值 < 根值 < 右子树值

local function tree_structures()
    -- 二叉树节点
    local function create_node(value)
        return {
            value = value,
            left = nil,
            right = nil,
        }
    end

    -- BST 插入
    local function insert(root, value)
        if not root then
            return create_node(value)
        end

        if value < root.value then
            root.left = insert(root.left, value)
        elseif value > root.value then
            root.right = insert(root.right, value)
        end

        return root
    end

    -- BST 搜索
    local function search(root, value)
        if not root then return nil end

        if value == root.value then
            return root
        elseif value < root.value then
            return search(root.left, value)
        else
            return search(root.right, value)
        end
    end

    -- 中序遍历（升序）
    local function inorder_traverse(root)
        if not root then return {} end
        local result = {}
        local function traverse(node)
            if node.left then traverse(node.left) end
            table.insert(result, node.value)
            if node.right then traverse(node.right) end
        end
        traverse(root)
        return result
    end

    -- 构建 BST
    local values = {5, 3, 7, 1, 4, 6, 8}
    local root = nil
    for _, v in ipairs(values) do
        root = insert(root, v)
    end

    print("BST inorder:", table.concat(inorder_traverse(root), ", "))
    print("search 4:", search(root, 4) ~= nil)
    print("search 9:", search(root, 9) ~= nil)

    -- 计算树高度
    local function height(node)
        if not node then return 0 end
        local lh = height(node.left)
        local rh = height(node.right)
        return 1 + math.max(lh, rh)
    end

    print("tree height:", height(root))
end

tree_structures()

-- 【问题4】Lua 的排序算法如何实现？
--
-- 常用排序：
--   - 冒泡排序：O(n²)
--   - 选择排序：O(n²)
--   - 插入排序：O(n²)
--   - 归并排序：O(n log n)
--   - 快速排序：O(n log n) 平均

local function sorting_algorithms()
    -- 冒泡排序
    local function bubble_sort(arr)
        local n = #arr
        for i = 1, n - 1 do
            for j = 1, n - i do
                if arr[j] > arr[j + 1] then
                    arr[j], arr[j + 1] = arr[j + 1], arr[j]
                end
            end
        end
    end

    -- 选择排序
    local function selection_sort(arr)
        local n = #arr
        for i = 1, n - 1 do
            local min_idx = i
            for j = i + 1, n do
                if arr[j] < arr[min_idx] then
                    min_idx = j
                end
            end
            arr[i], arr[min_idx] = arr[min_idx], arr[i]
        end
    end

    -- 插入排序
    local function insertion_sort(arr)
        for i = 2, #arr do
            local key = arr[i]
            local j = i - 1
            while j >= 1 and arr[j] > key do
                arr[j + 1] = arr[j]
                j = j - 1
            end
            arr[j + 1] = key
        end
    end

    -- 快速排序
    local function quick_sort(arr)
        if #arr <= 1 then return arr end

        local pivot = arr[1]
        local lower = {}
        local higher = {}

        for i = 2, #arr do
            if arr[i] < pivot then
                table.insert(lower, arr[i])
            else
                table.insert(higher, arr[i])
            end
        end

        local sorted = quick_sort(lower)
        table.insert(sorted, pivot)
        for _, v in ipairs(quick_sort(higher)) do
            table.insert(sorted, v)
        end
        return sorted
    end

    -- 测试
    local test_arr = {5, 2, 8, 1, 9, 3, 7, 4, 6}

    local arr1 = {table.unpack(test_arr)}
    bubble_sort(arr1)
    print("bubble sort:", table.concat(arr1, ", "))

    local arr2 = {table.unpack(test_arr)}
    selection_sort(arr2)
    print("selection sort:", table.concat(arr2, ", "))

    local arr3 = {table.unpack(test_arr)}
    insertion_sort(arr3)
    print("insertion sort:", table.concat(arr3, ", "))

    print("quick sort:", table.concat(quick_sort(test_arr), ", "))
end

sorting_algorithms()

-- 【问题5】Lua 的二分查找如何实现？
--
-- 二分查找：O(log n)，要求已排序数组

local function binary_search()
    local function binary_search(arr, target)
        local left, right = 1, #arr

        while left <= right do
            local mid = math.floor((left + right) / 2)
            if arr[mid] == target then
                return mid
            elseif arr[mid] < target then
                left = mid + 1
            else
                right = mid - 1
            end
        end

        return nil
    end

    local sorted = {1, 3, 5, 7, 9, 11, 13, 15}

    print("array:", table.concat(sorted, ", "))
    print("find 7:", binary_search(sorted, 7))
    print("find 8:", binary_search(sorted, 8))
    print("find 1:", binary_search(sorted, 1))
    print("find 15:", binary_search(sorted, 15))

    -- 查找插入位置
    local function lower_bound(arr, target)
        local left, right = 1, #arr
        while left < right do
            local mid = math.floor((left + right) / 2)
            if arr[mid] < target then
                left = mid + 1
            else
                right = mid
            end
        end
        return left
    end

    print("lower_bound of 6:", lower_bound(sorted, 6))
    print("lower_bound of 7:", lower_bound(sorted, 7))
end

binary_search()

-- 【问题6】Lua 的哈希表（Map）内部原理是什么？
--
-- Lua 的 table 就是哈希表实现
-- 特性：
--   - 键值对存储
--   - 任意类型键（除 nil）
--   - O(1) 平均查找/插入/删除
--   - 无序（但 Lua 5.3+ 保持插入顺序）

local function hashmap_principles()
    -- 基本用法
    local map = {
        name = "Alice",
        age = 30,
    }

    -- 安全访问
    local function get(map, key, default)
        if map[key] ~= nil then
            return map[key]
        end
        return default
    end

    print("get name:", get(map, "name", "unknown"))
    print("get job:", get(map, "job", "unemployed"))

    -- 多重映射
    local multimap = {}
    local function add_to_multimap(m, key, value)
        if not m[key] then
            m[key] = {}
        end
        table.insert(m[key], value)
    end

    add_to_multimap(multimap, "fruit", "apple")
    add_to_multimap(multimap, "fruit", "banana")
    add_to_multimap(multimap, "color", "red")

    print("fruits:", table.concat(multimap["fruit"], ", "))
    print("colors:", table.concat(multimap["color"], ", "))
end

hashmap_principles()

-- 【问题7】Lua 的图（Graph）如何存储和遍历？
--
-- 邻接表：用 table 表示
-- BFS/DFS 遍历

local function graph_algorithms()
    -- 邻接表表示
    local graph = {
        [1] = {2, 3},
        [2] = {4, 5},
        [3] = {6},
        [4] = {},
        [5] = {6},
        [6] = {},
    }

    -- DFS（递归）
    local function dfs(graph, start, visited)
        visited = visited or {}
        visited[start] = true
        print("visit:", start)

        for _, neighbor in ipairs(graph[start] or {}) do
            if not visited[neighbor] then
                dfs(graph, neighbor, visited)
            end
        end
    end

    print("DFS from 1:")
    dfs(graph, 1)

    -- BFS（队列）
    local function bfs(graph, start)
        local visited = {[start] = true}
        local queue = {start}

        while #queue > 0 do
            local node = table.remove(queue, 1)
            print("visit:", node)

            for _, neighbor in ipairs(graph[node] or {}) do
                if not visited[neighbor] then
                    visited[neighbor] = true
                    table.insert(queue, neighbor)
                end
            end
        end
    end

    print("BFS from 1:")
    bfs(graph, 1)
end

graph_algorithms()

-- 【问题8】Lua 的算法复杂度分析——如何评估代码效率？
--
-- 大 O 记号：
--   - O(1)：常数
--   - O(log n)：对数
--   - O(n)：线性
--   - O(n log n)：线性对数
--   - O(n²)：平方
--   - O(2ⁿ)：指数

local function complexity_analysis()
    -- O(1) - 哈希表查找
    local map = {a = 1, b = 2}
    local _ = map.a  -- 常数时间

    -- O(n) - 遍历
    local count = 0
    for i = 1, 1000 do
        count = count + 1
    end

    -- O(n²) - 冒泡排序
    local function bubble_sort_count(arr)
        local comparisons = 0
        local n = #arr
        for i = 1, n - 1 do
            for j = 1, n - i do
                comparisons = comparisons + 1
            end
        end
        return comparisons
    end

    print("comparisons for 100 elements:", bubble_sort_count({}))
    print("comparisons for 1000 elements:", bubble_sort_count({}))

    -- 复杂度对比
    print()
    print("复杂度对比（n=1000时）:")
    print("  O(1):      1 次操作")
    print("  O(log n):  ~10 次操作")
    print("  O(n):      1000 次操作")
    print("  O(n log n): ~10000 次操作")
    print("  O(n²):     1000000 次操作")
end

complexity_analysis()

-- ============================================================
-- 【对比】Rust vs Lua vs Python 数据结构与算法
-- ============================================================
-- Rust:
--   - Vec/HashMap/HashSet/BTreeMap 标准库
--   - 手动实现数据结构是学习好方式
--   - Option/Result 提供安全的空值处理

-- Lua:
--   - table 是唯一复合类型（数组+映射）
--   - 需要手动实现链表/树等结构
--   - 无泛型，类型安全靠约定

-- Python:
--   - list/tuple/dict/set 是内建数据结构
--   - bisect 提供二分查找
--   - heapq 提供堆操作

function compare_dsa()
    print("=== 三语言数据结构对比 ===")

    -- Lua 的 table 是万能的
    local as_array = {1, 2, 3}      -- 数组
    local as_dict = {a = 1, b = 2}  -- 字典
    local as_set = {apple = true, banana = true}  -- 集合

    print("Lua table can be array, dict, or set")
end

-- ============================================================
-- 练习题
-- ============================================================
-- 1. 实现一个双向链表，支持在任意位置插入/删除
-- 2. 实现一个 BST，支持插入、删除、查找
-- 3. 用 BFS 实现无权图的最短路径

-- ============================================================
-- 总结
-- ============================================================
-- | 数据结构   | Lua 实现                                    |
-- |-----------|-------------------------------------------|
-- | 数组       | table（索引从1开始）                        |
-- | 链表       | table + next 指针                          |
-- | 栈         | table + top 指针                           |
-- | 队列       | table + head/tail                          |
-- | 树         | table + left/right 指针                   |
-- | 图         | table（邻接表）                           |
-- | 排序       | table.sort + 手写排序                      |
-- | 查找       | 手写二分/线性                              |

local function main()
    print("=== 模块十四：数据结构与算法 ===")

    linked_list()
    stack_queue()
    tree_structures()
    sorting_algorithms()
    binary_search()
    hashmap_principles()
    graph_algorithms()
    complexity_analysis()
    compare_dsa()

    print("\n✅ 所有示例运行成功！")
end

main()