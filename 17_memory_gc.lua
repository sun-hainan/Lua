-- === 第17章 内存与性能 ===

--[[
  本章目标：
  1. 理解垃圾回收原理和GC阶段
  2. 掌握弱表weak table
  3. 理解内存泄漏检测
  4. 理解table预分配

  核心问题：
  Q1: GC什么时候触发？
  Q2: 弱表有什么用？
  Q3: 怎么避免内存泄漏？
  深入: 增量GC/三色标记/分代假设
]]

-- ============================
-- Q1: GC什么时候触发？
-- ============================

-- Lua使用自动垃圾回收（GC）
-- 当检测到内存使用达到阈值时触发

-- 手动控制GC（不推荐日常使用）
print("--- GC控制 ---")
print("collectgarbage('count'):", collectgarbage("count"), "KB")
print("collectgarbage('stop'):", collectgarbage("stop"))
print("collectgarbage('restart'):", collectgarbage("restart"))
print("collectgarbage('collect'):", collectgarbage("collect"))
print("collectgarbage('count'):", collectgarbage("count"), "KB")

-- GC的触发条件：
-- - 内存分配超过阈值
-- - manual call collectgarbage("collect")

-- ============================
-- Q2: 弱表有什么用？
-- ============================

-- 弱表：包含弱引用的table
-- 当唯一的引用是指向对象的弱引用时，对象会被GC回收

-- 三种弱表模式：
-- __mode = "k" - 键是弱引用
-- __mode = "v" - 值是弱引用
-- __mode = "kv" - 键和值都是弱引用

print("\n--- 弱表示例 ---")

-- 示例：缓存计算结果
local cache = setmetatable({}, {__mode = "v"})

local function cachedExpensive(id, compute)
    if cache[id] then
        print("命中缓存:", id)
        return cache[id]
    end
    print("计算中:", id)
    local result = compute()
    cache[id] = result
    return result
end

cachedExpensive("task1", function() return 12345 end)
cachedExpensive("task1", function() return 12345 end)  -- 命中缓存

-- 当cache[id]的唯一引用被删除时，对象会被GC回收

-- 示例：自动清理的观察者列表
local observers = setmetatable({}, {__mode = "k"})

local function addObserver(obs)
    observers[obs] = true
end

local myObserver = {name = "MyObserver"}
addObserver(myObserver)
print("观察者数:", #observers)

-- 移除观察者
myObserver = nil
collectgarbage("collect")  -- myObserver会被回收
print("观察者数:", #observers)

-- ============================
-- Q3: 怎么避免内存泄漏？
-- ============================

-- 常见内存泄漏：
-- 1. 全局变量引用不需要的对象
-- 2. table引用不需要的对象
-- 3. 闭包捕获大对象
-- 4. 循环引用（大意的闭包）

-- 示例：检测泄漏
local function createLeaker()
    local bigData = string.rep("x", 10000)
    return function()
        return #bigData
    end
end

-- 解决方案：用nil断开引用
local function createSafe()
    local bigData = string.rep("x", 10000)
    return function()
        return #bigData, function() bigData = nil end  -- 提供清理函数
    end
end

-- 闭包循环引用
--[[
local function createCycle()
    local obj = {name = "cycle"}
    obj.self = obj  -- 循环引用，但如果obj是唯一引用，整组会被GC（如果没有闭包捕获）
    
    local callback
    callback = function()
        return obj.name
    end
    obj.callback = callback
    
    return obj
end
]]

-- ============================
-- 深入: 增量GC/三色标记
-- ============================

-- Lua 5.1+使用增量式垃圾回收
-- 把GC工作分成多个小步骤，避免长停顿

-- 三色标记算法：
-- 白色(white)：未访问的对象，可回收
-- 灰色(gray)：已访问但未处理的对象
-- 黑色(black)：已处理完成的对象

-- GC阶段：
-- 1. Stop-the-world（停止运行）
-- 2. Mark（标记）：遍历所有可达对象，标记为灰色
-- 3. Mark-roots（标记根）：把全局对象和寄存器标记
-- 4. Traverse（遍历）：递归遍历灰色对象的引用，转为黑色
-- 5. Sweep（清扫）：遍历所有对象，白色对象被回收
-- 6. Finalize（终结）：调用userdata的析构函数
-- 7. Restart（继续）

-- 分代假设（Generational Hypothesis）：
-- 大多数对象很快就会变成垃圾
-- 长期存活的对象通常会活很久

-- Lua的分代GC（LuaJIT 2.1）：
-- - 分为年轻代和老年代
-- - 年轻代的GC更频繁
-- - 老年代GC更保守

-- ============================
-- 示例：内存分析工具
-- ============================

local MemoryProfiler = {}
MemoryProfiler.__index = MemoryProfiler

function MemoryProfiler.new()
    return setmetatable({
        snapshots = {},
        names = {}
    }, MemoryProfiler)
end

function MemoryProfiler.takeSnapshot(self, name)
    collectgarbage("collect")  -- 先GC
    local kb = collectgarbage("count")
    table.insert(self.snapshots, {
        name = name,
        kb = kb,
        time = os.time()
    })
    print(string.format("快照 [%s]: %.2f KB", name, kb))
    return kb
end

function MemoryProfiler.diff(self, snap1, snap2)
    if snap1 > #self.snapshots or snap2 > #self.snapshots then
        return nil, "无效的快照索引"
    end
    local s1 = self.snapshots[snap1]
    local s2 = self.snapshots[snap2]
    local diff = s2.kb - s1.kb
    print(string.format("差异 [%s -> %s]: %.2f KB (%.2f%%)",
        s1.name, s2.name, diff, (diff / s1.kb) * 100))
    return diff
end

print("\n--- 内存分析示例 ---")
local profiler = MemoryProfiler.new()

profiler:takeSnapshot("启动")
local bigTable = {}
for i = 1, 10000 do
    bigTable[i] = {
        data = string.rep("x", 100)
    }
end
profiler:takeSnapshot("创建10000条记录")

bigTable = nil
profiler:takeSnapshot("清空后")
collectgarbage("collect")
profiler:takeSnapshot("GC后")

print("\n快照列表:")
for i, snap in ipairs(profiler.snapshots) do
    print(string.format("  [%d] %s: %.2f KB", i, snap.name, snap.kb))
end

-- ============================
-- table预分配
-- ============================

print("\n--- table预分配 ---")

-- 预分配可以减少扩容次数，提高性能
-- Lua 5.3+ 使用table.create
--[[
local t = table.create(1000, 0)  -- 预分配1000个数组位置
for i = 1, 1000 do
    t[i] = i
end
]]

-- 手动预热
local function preallocateArray(size)
    local t = {}
    for i = 1, size do
        t[i] = true
    end
    for i = size, 1, -1 do
        t[i] = nil
    end
    return t
end

print("预分配测试（代码示例，实际不执行）")

print("\n=== 第17章结束 ===")
