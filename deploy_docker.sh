#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}Perp-Dex-Tools Docker 环境迁移部署脚本${NC}"
echo -e "${BLUE}============================================================${NC}"

# 检查Docker是否安装
check_docker() {
    echo -e "${YELLOW}正在检查Docker环境...${NC}"
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}错误: Docker未安装!${NC}"
        echo -e "请先安装Docker: https://docs.docker.com/get-docker/"
        return 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}错误: docker-compose未安装!${NC}"
        echo -e "请先安装docker-compose: https://docs.docker.com/compose/install/"
        return 1
    fi
    
    echo -e "${GREEN}Docker环境检查通过!${NC}"
    echo -e "Docker版本: $(docker --version)"
    echo -e "Docker Compose版本: $(docker-compose --version)"
    return 0
}

# 配置环境变量
config_env() {
    echo -e "${YELLOW}正在配置环境变量...${NC}"
    
    if [ ! -f ".env.docker.template" ]; then
        echo -e "${RED}错误: .env.docker.template文件不存在!${NC}"
        return 1
    fi
    
    if [ -f ".env" ]; then
        echo -e "${YELLOW}.env文件已存在，是否覆盖? (y/n)${NC}"
        read -r overwrite
        if [ "$overwrite" != "y" ] && [ "$overwrite" != "Y" ]; then
            echo -e "${BLUE}跳过环境变量配置${NC}"
            return 0
        fi
    fi
    
    # 复制模板文件
    cp .env.docker.template .env
    echo -e "${GREEN}环境变量模板已复制到.env文件${NC}"
    echo -e "${YELLOW}请编辑.env文件并填入实际的API密钥和配置值${NC}"
    
    # 询问是否需要编辑环境变量
    echo -e "${YELLOW}是否现在编辑.env文件? (y/n)${NC}"
    read -r edit_now
    if [ "$edit_now" = "y" ] || [ "$edit_now" = "Y" ]; then
        if command -v nano &> /dev/null; then
            nano .env
        elif command -v vim &> /dev/null; then
            vim .env
        else
            echo -e "${YELLOW}请使用您喜欢的编辑器手动编辑.env文件${NC}"
        fi
    fi
    
    return 0
}

# 构建Docker镜像
build_image() {
    echo -e "${YELLOW}正在构建Docker镜像...${NC}"
    docker-compose build
    if [ $? -ne 0 ]; then
        echo -e "${RED}错误: 镜像构建失败!${NC}"
        return 1
    fi
    echo -e "${GREEN}Docker镜像构建成功!${NC}"
    return 0
}

# 启动容器
start_containers() {
    echo -e "${YELLOW}正在启动容器...${NC}"
    docker-compose up -d
    if [ $? -ne 0 ]; then
        echo -e "${RED}错误: 容器启动失败!${NC}"
        return 1
    fi
    echo -e "${GREEN}容器启动成功!${NC}"
    echo -e "容器名称: perp-dex-bot"
    return 0
}

# 检查容器状态
check_status() {
    echo -e "${YELLOW}正在检查容器状态...${NC}"
    docker ps | grep perp-dex-bot
    if [ $? -ne 0 ]; then
        echo -e "${RED}错误: 容器未运行!${NC}"
        return 1
    fi
    echo -e "${GREEN}容器运行正常!${NC}"
    return 0
}

# 查看日志
view_logs() {
    echo -e "${YELLOW}查看容器日志 (按Ctrl+C退出)...${NC}"
    docker logs -f perp-dex-bot
}

# 停止容器
stop_containers() {
    echo -e "${YELLOW}正在停止容器...${NC}"
    docker-compose down
    echo -e "${GREEN}容器已停止!${NC}"
}

# 显示菜单
show_menu() {
    echo -e "\n${BLUE}============================================================${NC}"
    echo -e "${BLUE}                  Perp-Dex-Tools Docker管理菜单${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${GREEN}1.${NC} 完全部署 (检查环境 + 配置 + 构建 + 启动)"
    echo -e "${GREEN}2.${NC} 仅配置环境变量"
    echo -e "${GREEN}3.${NC} 仅构建镜像"
    echo -e "${GREEN}4.${NC} 仅启动容器"
    echo -e "${GREEN}5.${NC} 检查容器状态"
    echo -e "${GREEN}6.${NC} 查看容器日志"
    echo -e "${GREEN}7.${NC} 停止容器"
    echo -e "${GREEN}8.${NC} 退出"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "请选择操作 [1-8]:"
}

# 主函数
main() {
    # 设置脚本执行权限
    chmod +x "$0"
    
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1)
                check_docker && \
                config_env && \
                build_image && \
                start_containers && \
                check_status && \
                view_logs
                ;;
            2)
                config_env
                ;;
            3)
                build_image
                ;;
            4)
                start_containers && check_status
                ;;
            5)
                check_status
                ;;
            6)
                view_logs
                ;;
            7)
                stop_containers
                ;;
            8)
                echo -e "${BLUE}退出脚本，感谢使用!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}无效选择，请输入1-8之间的数字!${NC}"
                ;;
        esac
    done
}

# 执行主函数
main