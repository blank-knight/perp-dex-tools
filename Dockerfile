FROM python:3.12-slim

# 设置工作目录
WORKDIR /app

# 安装系统依赖（用于编译某些Python包）
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# 先复制requirements.txt安装依赖，利用Docker缓存机制
COPY requirements.txt .
COPY apex_requirements.txt .
COPY para_requirements.txt .

# 安装Python依赖，增加timeout和no-cache-dir参数确保安装稳定
RUN pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir --timeout=120 -r requirements.txt

# 复制项目文件
COPY . .

# 设置环境变量
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# 创建环境变量文件的挂载目录
RUN mkdir -p /app/env

# 设置默认命令
CMD ["python", "runbot.py"]