# Oracle DB Check Collect

**Oracle 数据库自动化巡检采集工具**

一键采集 Oracle 数据库和操作系统的健康检查数据，支持多版本、多实例、RAC 集群环境。

## 功能特性

### 数据库巡检（支持 10g / 11g / 19c）

| 分类               | 检查项                                                       |
| ------------------ | ------------------------------------------------------------ |
| **性能指标**       | Buffer Hit、Library Hit、Latch Hit、Soft Parse、Execute to Parse、In-Memory Sort |
| **表空间**         | 使用率、空闲率、自动扩展情况                                 |
| **Top SQL**        | Top Buffer Get、Top CPU、Top Elapsed、Top Disk Read、Top Event、Top Wait |
| **Data Guard**     | 归档日志同步 Gap 检测                                        |
| **RMAN 备份**      | 近 7 天备份状态、耗时、吞吐量                                |
| **AWR / 统计信息** | AWR 快照、统计信息收集记录                                   |
| **无效对象**       | 约束、索引、触发器、对象状态                                 |
| **安全审计**       | 统一审计、常规审计、SYSDBA 登录记录                          |
| **数据库配置**     | 参数设置、字符集、时区、Patch 信息、Profile                  |
| **数据库对象**     | 用户、DBA 角色、Job、Scheduler、Sequence                     |
| **存储**           | ASM 磁盘组、Flash Recovery Area、Recyclebin                  |
| **RAC 集群**       | CRS 状态、LMS 进程（仅 11g/19c）                             |

### 操作系统巡检

| 平台      | 检查项                                                       |
| --------- | ------------------------------------------------------------ |
| **Linux** | 基本信息、硬件信息、磁盘空间、网络 MTU/Loopback、Oracle/Grid 用户限制、OS 内核参数 |
| **AIX**   | 基本信息、硬件信息、磁盘空间、网络配置、用户限制、OS 参数、CRS 状态 |

## 目录结构

```
dbcheck_collect/
├── collect.sh                 # 主入口脚本
├── dbcheck/
│   ├── 10g/                   # Oracle 10g 巡检脚本
│   ├── 11g/                   # Oracle 11g 巡检脚本
│   └── 19c/                   # Oracle 19c 巡检脚本
├── oscheck_for_linux/         # Linux OS 巡检脚本
├── oscheck_for_aix/           # AIX OS 巡检脚本
├── data_collect/              # 数据采集输出目录
└── log/                       # 执行日志目录
```

## 使用方法

### 1. 部署

将整个目录上传到 Oracle 数据库服务器的 `/oracle/dbcheck_collect` 目录：

```bash
# 解压并部署
unzip dbcheck_collect.zip -d /oracle/
chmod -R 777 /oracle/dbcheck_collect
```

### 2. 执行巡检

以 root 用户执行主脚本：

```bash
cd /oracle/dbcheck_collect
bash collect.sh
```

### 3. 获取结果

巡检完成后，采集数据打包在 `data_collect/` 目录下：

```
data_collect/
└── hostname_data_20260531_120000.tar
    ├── os_hostname/           # OS 巡检结果
    │   ├── linux_basic.txt
    │   ├── linux_hardware.txt
    │   ├── linux_df.txt
    │   └── ...
    ├── dbname_instance1/      # 数据库实例巡检结果
    │   ├── tbs_use_pct.csv
    │   ├── dg_gap.csv
    │   ├── rman.csv
    │   ├── alert_info.txt
    │   └── ...
    └── dbname_instance2/      # 多实例时逐个目录
```

## 工作原理

1. **自动检测操作系统类型**（Linux / AIX），执行对应的 OS 巡检脚本
2. **自动发现数据库实例**（通过 `ora_smon_` 进程）
3. **自动识别 RAC 集群**（通过 `asm_smon_+ASM` 进程）
4. **自动判断数据库版本**（10g / 11g / 19c），加载对应的巡检脚本
5. **以对应用户身份执行**：OS 检查用 root，DB 检查用 oracle，CRS 检查用 grid/root
6. **结果打包压缩**为 tar 文件，便于离线分析

## 输出格式

- **TXT 文件**：键值对格式，使用 `$-$` 分隔符，便于解析
- **CSV 文件**：标准逗号分隔，可直接用 Excel 打开

## 适用场景

- Oracle 数据库定期健康巡检
- 数据库迁移前后的健康状态对比
- 数据库性能问题排查前的数据采集
- 运维团队标准化巡检流程

## 注意事项

- 需要以 **root** 用户执行主脚本（内部会自动切换到 oracle/grid 用户）
- 确保 `oracle` 用户对 `/oracle/dbcheck_collect` 目录有读写权限
- 确保 `sqlplus` 命令在 oracle 用户的 PATH 中
- 采集结果中的 alert log 会截取最近 50000 行

## License

MIT
