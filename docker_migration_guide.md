# Perp-Dex-Tools Docker环境迁移指南

## 概述

本文档提供了使用Docker容器技术将Perp-Dex-Tools环境从一台服务器迁移到另一台服务器的完整指南。通过Docker容器化，您可以确保在不同环境中获得一致的运行结果，避免依赖冲突和环境配置问题。

## 环境要求

在目标服务器上，您需要安装以下软件：

- **Docker**: 版本 20.10 或更高
- **Docker Compose**: 版本 1.29 或更高
- **Git**: 用于克隆代码库（如果需要）

## 迁移步骤

### 1. 准备源环境文件

在源服务器上，确保以下文件已经准备好：

- 项目源代码
- 已配置的`.env`文件（包含所有API密钥和配置）
- Docker配置文件（Dockerfile和docker-compose.yml）
- 部署脚本（deploy_docker.sh）
- 环境变量模板（.env.docker.template）

### 2. 打包项目文件

在源服务器上，将整个项目打包以便传输：

```bash
# 进入项目目录
cd /home/admin/perp-dex-tools

# 创建项目压缩包
tar -czvf perp-dex-tools.tar.gz .
```

### 3. 传输项目到目标服务器

使用SCP或其他文件传输工具将压缩包传输到目标服务器：

```bash
# 从源服务器传输到目标服务器
scp perp-dex-tools.tar.gz user@target-server:/path/to/destination/
```

### 4. 在目标服务器上解压项目

```bash
# 进入目标目录
cd /path/to/destination/

# 解压项目文件
tar -xzvf perp-dex-tools.tar.gz

# 进入项目目录
cd perp-dex-tools
```

### 5. 配置环境变量

使用我们提供的模板文件配置环境变量：

```bash
# 复制模板文件
cp .env.docker.template .env

# 编辑.env文件，填入实际的API密钥和配置
nano .env  # 或使用其他编辑器
```

**重要注意事项**：
- 确保所有API密钥和私钥都正确设置
- 特别注意`LIGHTER_API_KEY_INDEX`应设置为有效值（通常为0）
- 检查所有交易所的配置信息是否正确

### 6. 运行部署脚本

我们提供了一个交互式部署脚本，简化整个迁移过程：

```bash
# 确保脚本有执行权限
chmod +x deploy_docker.sh

# 运行部署脚本
./deploy_docker.sh
```

脚本提供了以下功能：
- 检查Docker环境
- 配置环境变量
- 构建Docker镜像
- 启动容器
- 检查容器状态
- 查看日志
- 停止容器

您可以选择完全部署（选项1），这将执行所有必要的步骤。

### 7. 验证迁移是否成功

部署完成后，使用以下命令验证容器是否正常运行：

```bash
# 检查容器状态
docker ps | grep perp-dex-bot

# 查看日志
docker logs -f perp-dex-bot
```

如果一切正常，您应该能看到应用程序的日志输出，并且没有错误信息。

## 手动部署步骤（可选）

如果您不想使用部署脚本，也可以手动执行以下步骤：

### 1. 构建Docker镜像

```bash
docker-compose build
```

### 2. 启动容器

```bash
docker-compose up -d
```

### 3. 检查容器状态

```bash
docker ps
```

### 4. 查看容器日志

```bash
docker logs -f perp-dex-bot
```

### 5. 停止容器

```bash
docker-compose down
```

## 常见问题和故障排除

### 1. Docker镜像构建失败

**症状**：构建过程中出现错误，特别是在安装依赖时

**解决方案**：
- 检查网络连接是否正常
- 尝试增加超时时间（已在Dockerfile中设置为120秒）
- 对于特定的Git依赖，确保网络可以访问GitHub

### 2. 容器启动后立即退出

**症状**：容器启动后立即停止，状态为Exited

**解决方案**：
- 查看详细日志：`docker logs perp-dex-bot`
- 检查环境变量配置是否正确
- 确保所有必要的API密钥都已设置

### 3. API连接失败

**症状**：日志中显示API连接错误

**解决方案**：
- 检查API密钥和私钥是否正确
- 验证网络连接是否允许到相关交易所API的访问
- 特别注意`LIGHTER_API_KEY_INDEX`是否设置为有效值

### 4. 权限问题

**症状**：容器内出现权限错误

**解决方案**：
- 确保Docker有足够的权限访问挂载的卷
- 检查`.env`文件的权限设置

### 5. 内存不足

**症状**：构建或运行过程中出现内存不足错误

**解决方案**：
- 增加Docker的内存限制
- 确保目标服务器有足够的RAM（建议至少4GB）

## 最佳实践

### 1. 安全最佳实践

- **API密钥安全**：不要将包含真实API密钥的`.env`文件提交到版本控制系统
- **容器隔离**：在生产环境中使用专用网络隔离容器
- **定期更新**：定期更新Docker镜像和依赖以获取安全补丁

### 2. 性能优化

- **镜像优化**：使用多阶段构建减小镜像体积（当前Dockerfile已针对Python进行了优化）
- **日志管理**：使用日志轮转避免日志文件过大（已在docker-compose.yml中配置）
- **资源限制**：在生产环境中设置适当的CPU和内存限制

### 3. 维护建议

- **备份配置**：定期备份`.env`文件和重要配置
- **监控系统**：考虑设置监控系统来跟踪容器状态和应用程序性能
- **定期重启**：对于长时间运行的服务，考虑设置定期重启以避免内存泄漏

## 附录

### Docker常用命令

```bash
# 查看所有镜像
docker images

# 查看所有容器（包括停止的）
docker ps -a

# 删除未使用的镜像和容器
docker system prune -a

# 查看容器详细信息
docker inspect perp-dex-bot

# 进入运行中的容器
docker exec -it perp-dex-bot bash
```

### 环境变量参考

| 环境变量 | 说明 | 必需 |
|---------|------|------|
| ACCOUNT_NAME | 账户名称，用于区分日志 | 否 |
| LIGHTER_API_KEY_INDEX | Lighter API密钥索引，必须为有效值（通常为0） | 是 |
| EXTENDED_API_KEY | Extended交易所API密钥 | 是（如果使用Extended） |
| GRVT_PRIVATE_KEY | GRVT私钥 | 是（如果使用GRVT） |

### 迁移清单

- [ ] 准备源环境文件
- [ ] 打包项目文件
- [ ] 传输到目标服务器
- [ ] 解压项目
- [ ] 配置环境变量
- [ ] 运行部署脚本
- [ ] 验证迁移是否成功

---

通过按照本指南进行操作，您应该能够顺利地将Perp-Dex-Tools环境迁移到新的服务器上。如果您在迁移过程中遇到任何问题，请参考故障排除部分或寻求技术支持。