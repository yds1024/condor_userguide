#!/bin/bash

# holdgpu.sh - 占用 GPU 并显示 GPU 映射信息

echo "========================================="
echo "Job started on: $(hostname)"
echo "Date: $(date)"
echo "========================================="

# 显示 CUDA_VISIBLE_DEVICES
echo ""
echo "CUDA_VISIBLE_DEVICES: $CUDA_VISIBLE_DEVICES"

# 如果没有分配 GPU，退出
if [ -z "$CUDA_VISIBLE_DEVICES" ]; then
    echo "No GPU assigned"
    exit 1
fi

# 获取当前主机名
HOSTNAME=$(hostname)

# 从 condor_status 获取本机的 GPU 列表
DETECTED_GPUS=$(condor_status -constraint "Machine==\"$HOSTNAME\"" -long 2>/dev/null | grep "^DetectedGPUs" | cut -d'"' -f2)

if [ ! -z "$DETECTED_GPUS" ]; then
    # 将检测到的 GPU 列表转换为数组
    IFS=', ' read -ra ALL_GPUS <<< "$DETECTED_GPUS"
    
    # 解析 CUDA_VISIBLE_DEVICES 中的 GPU
    IFS=',' read -ra GPU_ARRAY <<< "$CUDA_VISIBLE_DEVICES"
    
    echo ""
    echo "GPU 映射信息:"
    echo "--------------"
    
    # 检查是否是 UUID 格式
    if [[ "$CUDA_VISIBLE_DEVICES" == *"GPU-"* ]]; then
        # UUID 格式 - 需要查找物理索引
        for i in "${!GPU_ARRAY[@]}"; do
            gpu_uuid="${GPU_ARRAY[$i]}"
            
            # 在 ALL_GPUS 中查找索引
            physical_idx=-1
            for j in "${!ALL_GPUS[@]}"; do
                if [ "${ALL_GPUS[$j]}" == "$gpu_uuid" ]; then
                    physical_idx=$j
                    break
                fi
            done
            
            if [ $physical_idx -ne -1 ]; then
                echo "程序 GPU $i → 物理 GPU $physical_idx (UUID: $gpu_uuid)"
            else
                echo "程序 GPU $i → UUID: $gpu_uuid (物理索引未知)"
            fi
        done
    else
        # 数字索引格式
        for i in "${!GPU_ARRAY[@]}"; do
            echo "程序 GPU $i → 物理 GPU ${GPU_ARRAY[$i]}"
        done
    fi
    
    echo ""
    echo "$HOSTNAME 的所有 GPU:"
    for i in "${!ALL_GPUS[@]}"; do
        is_assigned=""
        for assigned_gpu in "${GPU_ARRAY[@]}"; do
            if [[ "$CUDA_VISIBLE_DEVICES" == *"GPU-"* ]]; then
                # UUID 格式比较
                if [ "${ALL_GPUS[$i]}" == "$assigned_gpu" ]; then
                    is_assigned=" <- 分配给当前作业"
                    break
                fi
            else
                # 数字索引格式比较
                if [ "$i" == "$assigned_gpu" ]; then
                    is_assigned=" <- 分配给当前作业"
                    break
                fi
            fi
        done
        echo "  [$i] ${ALL_GPUS[$i]}$is_assigned"
    done
else
    echo "无法获取本机 GPU 配置"
fi

# 占用 GPU
SLEEP_TIME="${1:-300}"  # 默认占用 5 分钟
echo ""
echo "Holding GPU for $SLEEP_TIME seconds..."
echo "To stop this job, use: condor_rm <jobid>"

sleep $SLEEP_TIME

echo ""
echo "Job completed at: $(date)"
echo "========================================="