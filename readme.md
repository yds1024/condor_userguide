# HTCondor 集群用户指南

## GPU 使用注意事项

taishan 的 GPU 分为两类：

- 0-5：纳管到 HTCondor 集群（提交作业会用到）
- 6-9：预留给你在 taishan 上手动调试（不要提交到 HTCondor）

**测试阶段（手动调试）**：使用 GPU 6、7、8 或 9

**提交作业（HTCondor）**：不要手动指定物理 GPU；作业里使用 GPU 0（HTCondor 会把分配到的 GPU 映射成 0）

## 集群说明

本集群采用 HTCondor 作为作业调度系统，用于高吞吐量任务的统一调度与资源管理。

整个集群由多台 GPU 计算服务器和共享存储服务器组成。用户在提交节点（taishan）提交任务后，HTCondor 会根据资源可用性和作业需求自动将任务分发到合适的计算节点执行。

### 常用命令

- **查看集群资源状态**

  - `condor_status` - 查看集群所有机器状态
  - `condor_status -gpus` - 查看 GPU slot 的详细占用情况
  - `condor_status -gpus -compact` - 查看各节点纳管的 GPU 总数和当前空闲 GPU 数量
  - `condor_status -af Name Cpus` - 查看各节点可用 CPU 数量
- **作业管理**

  - `csub job.submit` 或 `condor_submit job.submit` - 提交作业
  - `cq` 或 `condor_q` - 查看当前用户的所有作业状态
  - `condor_q -global -allusers` - 查看整个 Condor pool 中所有 schedd 的作业；当任务是在 `huashan` 提交、但你在 `taishan` 上排查时，使用这条命令
  - `cq <username>` - 查看指定用户的作业状态
  - `cq -l <jobid>` - 查看作业详细信息
  - `cq -run` - 查看正在运行的作业及其分配的机器
  - `condor_rm <jobid>` - 删除指定作业
  - `condor_rm -all` - 删除当前用户的所有作业
  - `condor_tail <jobid>` - 查看运行中作业的实时输出
- **作业优先级调整**

  - `condor_prio -p +15 <jobid>` - 提高作业优先级
  - `condor_prio -p -15 <jobid>` - 降低作业优先级
- **问题排查**

  - `cq -better-analyze <jobid>` - 分析作业与资源匹配情况
  - `condor_tail <jobid>` - 查看运行中作业的实时输出

## 集群硬件资源

### 服务器简介

注：`配置` 列中的核心数为物理核心数，不是超线程数。

注：已下线机器见后文「历史机器」。

| 服务器 / IP                  | 配置                                      | 型号 / SN                                | 硬盘编码（含大小）                           | 挂载点                                                      | 位置                           |
| ---------------------------- | ----------------------------------------- | ---------------------------------------- | -------------------------------------------- | ----------------------------------------------------------- | ------------------------------ |
| taishan / 192.168.81.6       | Xeon Gold 6226R / 32C / 251 GiB / 10 x 3090 | —                                        | `sda: 893.3G / sdb: 9.1T / sdc: 32.8T`       | `sda: /boot + /`；`sdb1: /mnt/lab`；`sdc: /mnt/lab1`        | —                              |
| huashan / 192.168.81.7       | Xeon Gold 6226R / 32C / 251 GiB / 10 x 3090 | —                                        | `sda: 893.3G / sdb: 9.1T / sdc: 32.8T`       | `sda: /boot + /`；`sdb: /mnt/lab`；`sdc: /mnt/lab1`         | —                              |
| hengshan / 192.168.81.8      | Xeon Gold 6226R / 32C / 251 GiB / 10 x 3090 | —                                        | `sda: 893.3G / sdb: 9.1T / sdc: 32.8T`       | `sda: /boot + /`；`sdb: /mnt/lab`；`sdc: /mnt/lab1`         | —                              |
| shanshuimeng / 192.168.81.17 | Xeon Silver 4214 / 24C / 125 GiB / 4 x 3090 | —                                        | `sda: 223.6G / sdb: 1.7T`                    | `sda: /boot/efi + /boot + /`；`sdb1: /mnt/lab`              | rack-B-3F-D32-09 08/40-04/44   |
| shuitianxu / 192.168.81.18   | Xeon Gold 5122 / 8C / 125 GiB / 4 x 4090   | —                                        | `sda: 894.3G / sdb: 1.8T / sdc: 1.8T`        | `sda: /boot/efi + /boot + /`；`sdb1: /mnt/lab`；`sdc1: /mnt/lab1` | rack-B-3F-D32-09 09/39-13/35   |
| tianshuisong / 192.168.81.14 | Xeon Gold 5122 / 8C / 125 GiB / 4 x 3090   | —                                        | `sda: 894.3G / sdb: 1.8T / sdc: 1.8T`        | —                                                           | rack-B-3F-D32-08 10/38-14/34   |
| ditiantai / 192.168.81.32    | EPYC 7513 / 64C / 125 GiB / 3 x 4090       | 赋创 FG4812T-A3 / 80102086T25C021245     | `sda: 893.8G / sdb: 1.7T`                    | `sda: /boot/efi + /`；`sdb1: /mnt/lab`                      | rack-B-3F-D32-B-07柜2U-5U      |
| fengtianxiaoxu / 192.168.81.15 | Xeon Silver 4314 / 32C                     | —                                        | `nvme0n1 / sda-sdl（大小未采集）`            | `nvme0n1: /boot/efi + /boot + /`；`vg_data/lv_data: /mnt/lab` | rack-B-3F-D32-07 26/22-27/21   |
| tianzelu / 192.168.81.16     | —                                         | —                                        | 未采集                                       | —                                                           | —                              |

### 历史机器

注：历史机器的 IP 可能已被复用，仅用于留档参考。

| 服务器 / IP               | 配置                                   | 型号 / SN | 硬盘编码（含大小）                | 挂载点 | 位置 |
| ------------------------- | -------------------------------------- | -------- | --------------------------------- | ------ | ---- |
| qianweitian / 192.168.63.86 | i9-10900X / 10C / 31 GiB / 2 x 3090    | —        | `sda: 3.6T / nvme0n1: 953.9G`     | —      | —    |
| kunweidi / 192.168.63.87 | i9-10900X / 10C / 62 GiB / 2 x 3090    | —        | `sda: 3.6T / nvme0n1: 953.9G`     | —      | —    |
| shuileizhun / 192.168.63.88 | i9-10900X / 10C / 62 GiB / 2 x 3090    | —        | `sda: 3.6T / nvme0n1: 953.9G`     | —      | —    |
| shuidibi / 192.168.81.15 | i9-10900X / 10C / 62 GiB / 4 x 3090    | —        | `nvme0n1: 931.5G`                 | —      | —    |
| dishuishi / 192.168.81.16 | i9-10900X / 10C / 62 GiB / 4 x 3090    | —        | `nvme0n1: 931.5G`                 | —      | —    |

### 存储服务器

| NFS 源 | 容量 | 计算节点挂载点 |
| ------ | ---- | -------------- |
| `192.168.81.15:/mnt/lab` | 174T | `/mnt/net1` |
| `192.168.81.16:/mnt/lab` | 174T | `/mnt/net0` |

集群的每台计算服务器都可以访问这两台共享存储服务器，并挂载到 `/mnt/net*`（如 `/mnt/net1`、`/mnt/net0`）。可以将 python 环境装到共享目录下，从而保证每台服务器的 python 环境一致。

## 使用规范

我们的集群使用 HTCondor 来管理所有用户的任务和硬件资源。

所有用户都统一在任务提交节点：taishan 提交任务，所提交的任务会被 HTCondor 分发到集群中的所有机器。

> 注意：
> 不要在 taishan 的 0-5 GPU 上手动调试，否则会与 HTCondor 集群任务冲突。

## Condor 系统

[condor 用户手册](https://htcondor.readthedocs.io/en/latest/users-manual/index.html)

### 提交资源说明

- 如果是纯 CPU 任务，不使用 GPU，需要把 submit 文件中的 `request_GPUs = 1` 去掉。
- 集群当前默认资源配比是 `1 GPU : 2 CPU`。
- 如果你需要 `1 GPU` 搭配更多 CPU，请联系我，我可以单独给你配置。

### 运行示例

HTCondor 支持多种编程语言和框架。以下是常见的使用场景：

- **[C/CUDA 程序](./C/)** - 包含 CUDA GPU 程序的编译和提交示例
- **[Python 程序](./Python/)** - 包含 Python 环境配置和作业提交示例
- **[占用 GPU 示例](./holdGPU/)** - 展示如何在特定机器上占用 GPU 并查看分配的 GPU ID

每个目录中都包含完整的示例代码、配置文件和详细说明。请根据您的需求查看相应的示例。

### 作业优先级管理

有时，你想运行一些快速测试，但你已经提交了一堆长时间运行的任务。可以使用以下命令调整作业优先级：

- 提高优先级：`condor_prio -p +15 <jobid>`
- 降低优先级：`condor_prio -p -15 <jobid>`

默认优先级是0，数字越大优先级越高。

## 排查问题

检查作业要求匹配：

```
cq -better-analyze 566396.0
```

使用 `condor_q` 命令详细查看：

```
cq -l 565618.0
```

如果需要在 `taishan` 上查看整个 pool 里所有 schedd 的任务，例如排查 `huashan` 上提交的作业，可以使用：

```
condor_q -global -allusers
```

查看某台机器的 `startd` 配置时，这两个命令通常搭配使用：先查 `MyAddress`，再按地址读取配置摘要。

```bash
condor_status -startd -af MyAddress Name
condor_config_val -address "<MyAddress>" -summary
```

在每台机器的 `/var/log/condor/` 下有 `job/` 目录。

在执行节点上查看 job 的详细信息：`/var/log/condor/StarterLog.slot*`
