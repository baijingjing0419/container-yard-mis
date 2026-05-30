FROM python:3.12-slim

WORKDIR /app

# 安装系统依赖（aiomysql 纯 Python 驱动无需系统库）
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
