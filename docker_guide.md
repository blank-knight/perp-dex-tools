# Docker环境使用指南与项目运行步骤

## 一、Docker启动

项目使用Docker进行容器化部署，确保环境一致性。执行以下命令构建Docker镜像：

```bash
# 在项目根目录执行
cd /root/workspace/perp-dex-tools
docker build -t perp-dex-tools .
```
构建过程会自动执行以下操作：
- 基于Python 3.12-slim创建容器
- 安装必要的系统依赖（build-essential、git等）
- 安装项目的Python依赖包（从requirements.txt、apex_requirements.txt和para_requirements.txt）
- 复制项目文件到容器内/app目录
- 设置必要的环境变量

## 二、进入Docker环境的步骤

### 1. 进入Docker容器的交互式会话

```bash
# 方法一：使用已创建的容器（如果存在）
docker start perp-dex-container
docker exec -it perp-dex-container bash

# 方法二：创建新的交互式容器，docker build后如果未创建容器，那么运行这个
docker run -it --name perp-dex-container -v $(pwd):/app perp-dex-tools bash
```

**关键参数说明**：
- `-it`: 以交互式终端运行
- `--name`: 指定容器名称
- `-v $(pwd):/app`: 将当前目录挂载到容器的/app目录，实现代码实时同步

### 2. 环境验证

在容器内，您可以通过以下命令验证环境：

```bash
# 检查Python版本
python3 --version

# 查看已安装的依赖
pip3 list

# 查看项目文件
ls -la
```

### 3. 运行项目

根据项目结构，您可以通过以下方式运行程序：

```bash
# 运行主程序
python3 trading_bot.py

# 或使用runbot.py
python3 runbot.py
```

## 三、Docker常用命令与最佳实践

### 镜像管理

```bash
# 查看所有镜像
docker images

# 构建镜像
docker build -t perp-dex-tools .

# 重新构建镜像（强制重新构建）
docker build --no-cache -t perp-dex-tools .
```

### 容器管理

```bash
# 查看运行中的容器
docker ps

# 查看所有容器（包括停止的）
docker ps -a

# 启动停止的容器
docker start perp-dex-container

# 停止运行中的容器
docker stop perp-dex-container

# 删除容器
docker rm perp-dex-container
```

### 开发模式最佳实践

1. **实时代码修改**：
   - 由于我们使用了卷挂载(`-v $(pwd):/app`)，您在宿主机上修改代码后，容器内会立即生效
   - 无需重新构建镜像，非常适合开发阶段

2. **依赖管理**：
   - 如需要添加新依赖，修改requirements.txt后重新构建镜像
   ```bash
   docker build -t perp-dex-tools .
   ```
   - 或在容器内临时安装测试
   ```bash
   pip3 install 新依赖
   ```

3. **日志查看**：
   ```bash
   # 查看容器日志
docker logs perp-dex-container

# 实时查看日志
docker logs -f perp-dex-container
```

4. **使用docker-compose**：
   虽然当前环境没有docker-compose命令，但配置文件已创建。如果将来系统支持，可以使用：
   ```bash
   docker-compose up -d  # 后台运行服务
   docker-compose down   # 停止并移除服务
   ```

## 四、注意事项

1. **环境变量配置**：
   - 项目可能需要环境变量配置，请参考项目中的`env_example.txt`文件
   - 在Docker容器内，可以创建`.env`文件或直接设置环境变量

2. **数据持久化**：
   - 当前配置已将项目目录挂载到容器，确保数据和代码同步
   - 如需持久化其他数据，可添加额外的卷挂载

3. **性能优化**：
   - 在实际部署时，可以考虑使用多阶段构建减小镜像体积
   - 生产环境可以使用docker-compose管理更复杂的服务配置

## 五、附录：Dockerfile和docker-compose.yml配置说明

### Dockerfile配置

```dockerfile
FROM python:3.12-slim

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# 复制requirements.txt并安装依赖
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# 复制项目文件
COPY . .

# 设置环境变量
ENV PYTHONUNBUFFERED=1

# 默认命令
CMD ["python3", "trading_bot.py"]
```

### docker-compose.yml配置

```yaml
version: '3.8'

services:
  perp-dex-bot:
    build: .
    volumes:
      - .:/app
    environment:
      - PYTHONUNBUFFERED=1
    restart: unless-stopped
```

通过Docker环境，您已经成功避免了Python版本兼容性和系统依赖问题，现在可以在一个隔离且一致的环境中开发和运行您的项目了。