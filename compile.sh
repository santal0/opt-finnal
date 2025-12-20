#!/bin/bash

# 检测并安装LaTeX包的函数
install_if_missing() {
    local package_name=$1
    
    echo "检查包: $package_name"
    
    # 使用dpkg检查包是否已安装（Debian/Ubuntu）
    if dpkg -l "$package_name" 2>/dev/null | grep -q "^ii"; then
        echo "✓ $package_name 已安装"
        return 0
    else
        echo "✗ $package_name 未安装，正在安装..."
        sudo apt-get install -y "$package_name"
        if [ $? -eq 0 ]; then
            echo "✓ $package_name 安装成功"
            return 1
        else
            echo "✗ $package_name 安装失败"
            return 2
        fi
    fi
}

# 更精确的检查函数，检查包是否存在（即使未安装）
check_package_exists() {
    local package_name=$1
    apt-cache show "$package_name" > /dev/null 2>&1
    return $?
}

# 主要安装逻辑
echo "=== 开始检查并安装LaTeX包 ==="

# 更新包列表
echo "更新包列表..."
sudo apt-get update

# 检查texlive-science
install_if_missing "texlive-science"

# 检查texlive-latex-extra
install_if_missing "texlive-latex-extra"

# 检查texlive-fonts-extra
install_if_missing "texlive-fonts-extra"

# 安装缺失的单个包（如果前面的包组安装失败）
echo "=== 检查特定包 ==="

# 检查bbm.sty对应的包
if ! check_package_exists "texlive-science"; then
    echo "尝试安装bbm包..."
    if apt-cache search "^bbm$" | grep -q "bbm"; then
        sudo apt-get install -y bbm
    else
        echo "注意：未找到bbm包，可能需要从CTAN手动安装"
    fi
fi

echo "=== 安装完成 ==="

echo "=== 开始编译 ==="

make clean
make
make clean