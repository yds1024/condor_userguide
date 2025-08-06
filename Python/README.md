# 在 HTCondor 集群中运行 Python 程序

本目录包含在 HTCondor 集群中运行 Python 程序的示例和说明。

## 目录结构

- `test.py` - Python 示例程序
- `run.sh` - 执行脚本
- `test.submit` - HTCondor 作业提交文件

## 环境配置

### 重要提示

**不能只在一台机器上安装 Python 环境！** 需要将 Python 环境安装到共享目录 `/mnt/net1` 上，以确保所有计算节点都能访问。

### 使用共享 Conda 环境

集群已在 `/mnt/net1/common/anaconda3` 安装了 conda 环境。

**安装环境前必须先退出当前终端的 conda 环境：**

```bash
conda deactivate
```

### 查看可用环境

查看所有在 `/mnt/net1/common/anaconda3` 下的环境：

```bash
/mnt/net1/common/anaconda3/bin/conda run conda info -e
```

查看 base 环境的所有安装包：

```bash
/mnt/net1/common/anaconda3/bin/conda run --name base python -m pip list
```

### 创建自己的环境

建议创建自己的环境，环境名最好包含用户名：

```bash
/mnt/net1/common/anaconda3/bin/conda create -p /mnt/net1/common/anaconda3/envs/username_env python=3.12
```

### 安装 Python 包

1. 首先确认包的安装位置正确：

```bash
export PYTHONNOUSERSITE=1
/mnt/net1/common/anaconda3/bin/conda run --name base python -m site
```

确保输出中的 `ENABLE_USER_SITE: False`。如果为 True，包会安装到用户目录下，其他机器无法访问。

2. 设置环境变量并安装包：

```bash
export PYTHONNOUSERSITE=1
/mnt/net1/common/anaconda3/bin/conda run --name base python -m pip install xxx
```

**注意**：集群中有 3090 和 4090 不同型号的 GPU，安装的包可能对 GPU 型号有要求。

## 使用步骤

### 1. 编写 Python 程序

创建您的 Python 程序，例如 `test.py`。

### 2. 创建执行脚本

创建 `run.sh` 脚本，用于在集群环境中正确运行 Python 程序。记得设置执行权限：

```bash
chmod +x run.sh
```

### 3. 修改提交文件

修改 `test.submit` 文件中的参数：

- `initialdir` - 修改为您的项目路径
- `request_GPUs` - 如需要 GPU，设置数量
- `request_CPUs` - 设置所需的 CPU 数量
- `transfer_input_files` - 列出所有需要传输的文件
- `arguments` - 设置传递给脚本的参数

### 4. 提交作业

```bash
csub test.submit
```

或

```bash
condor_submit test.submit
```

### 5. 查看结果

作业运行完成后，会在当前目录下创建 `logs` 目录，包含：

- 标准输出：`logs/job_<ClusterId>.<ProcId>.out`
- 错误输出：`logs/job_<ClusterId>.<ProcId>.err`
- HTCondor 日志：`logs/job_<ClusterId>.log`

## 注意事项

### 验证环境

提交文件中的示例要求在 hengshan 上运行：

```
Requirements = (TARGET.Machine=="hengshan")
```

这是为了验证 Python 环境在所有机器上都能正确识别。确认无误后可以删除此限制。

### 短作业优化

如果程序运行时间少于 30 分钟，启用短作业标志：

```
+SHORT_JOB=true
```

### 传输文件

确保在 `transfer_input_files` 中列出所有需要的文件，包括：

- Python 脚本
- 数据文件
- 配置文件
- 其他依赖文件

## 故障排查

1. 检查作业匹配情况：

```bash
cq -better-analyze <jobid>
```

2. 查看详细信息：

```bash
cq -l <jobid>
```

3. 查看实时输出：

```bash
condor_tail <jobid>
```

4. 检查 Python 路径是否正确：

   - 确保 `sys.path` 中的路径指向 `/mnt/net1`
   - 确保没有使用用户本地的包路径