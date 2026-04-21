# Lua Tutorial

Comprehensive Lua programming tutorial with problem-driven approach, deep principles, and complete system coverage.

## 17 Modules (Markdown)

| # | 文件 | 内容 |
|---|------|------|
| 01 | `01_代码规范与基础.md` | 注释/缩进/标识符/关键字/nil |
| 02 | `02_变量与数据类型.md` | 变量/作用域/8种类型/table/进制/转换 |
| 03 | `03_运算符与表达式.md` | 算术/赋值/关系/逻辑/位运算/优先级 |
| 04 | `04_流程控制.md` | if/else/循环/break/goto/pcall |
| 05 | `05_字符串与数组.md` | 字符串操作/模式匹配/数组/排序/二分 |
| 06 | `06_函数与方法.md` | 函数/多返回值/闭包/尾调用/高阶函数 |
| 07 | `07_面向对象.md` | metatable/继承/多态/运算符重载 |
| 08 | `08_集合框架.md` | List/Map/Set/Queue/弱表 |
| 09 | `09_IO流与文件.md` | 文件读写/二进制/序列化 |
| 10 | `10_异常处理与调试.md` | error/pcall/debug/日志/性能测量 |
| 11 | `11_协程与并发.md` | coroutine/生产者消费者/迭代器 |
| 12 | `12_反射与元编程.md` | loadstring/eval/沙箱/_ENV |
| 13 | `13_网络编程.md` | luasocket/TCP/UDP/HTTP |
| 14 | `14_数据结构与算法.md` | 链表/栈/队列/BST/排序/BFS/DFS |
| 15 | `15_数据库.md` | LuaSQL/SQLite/Redis/事务 |
| 16 | `16_工程化与设计.md` | 设计模式/优化/测试/Git/CI |
| 17 | `17_信息分发与事件系统.md` | 观察者/EventEmitter/中间件/Actor |

## 适用人群

- 游戏开发者（Roblox Luau、WoW、Garry's Mod）
- 嵌入式/配置脚本（Nginx/OpenResty、Redis、Vim）
- 快速原型开发
- OpenResty 生态 Web 开发、API 网关、自动化运维

## 核心特色

- **问题驱动**：每节围绕核心问题展开
- **深入原理**：剖析语言设计思想
- **五语对比**：与 Python/Rust/Go/C++ 对比
- **完整示例**：每个概念都有可运行代码
- **生活类比 + ASCII 图示**：易懂易记

## 快速开始

```bash
# 标准 Lua
lua 01_code_basics.lua

# LuaJIT（推荐，性能更优）
luajit 01_code_basics.lua
```

## 环境要求

- Lua 5.3+ 或 LuaJIT 2.1+
- luarocks（可选，luasocket 等库需要）

## 源码

原始 `.lua` 文件已移至 `_src/` 目录。

## License

MIT License
