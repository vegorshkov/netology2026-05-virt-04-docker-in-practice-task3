#!/bin/bash

# 1. Останавливаем старый MySQL если есть
docker stop mysql-local 2>/dev/null || true
docker rm mysql-local 2>/dev/null || true

# 2. Запускаем MySQL
echo "Starting MySQL..."
docker run -d --name mysql-local \
  -e MYSQL_ROOT_PASSWORD=YtReWq4321 \
  -e MYSQL_DATABASE=virtd \
  -e MYSQL_USER=app \
  -e MYSQL_PASSWORD=QwErTy1234 \
  -p 3306:3306 \
  mysql:8.0

echo "Waiting for MySQL to start..."
sleep 25

# 3. Проверяем MySQL
echo "Testing MySQL connection..."
docker exec mysql-local mysql -uapp -pQwErTy1234 -e "SHOW DATABASES;" && echo "MySQL ready" || echo "MySQL not ready"

# 4. Устанавливаем переменные окружения
export DB_HOST=localhost
export DB_PORT=3306
export DB_NAME=virtd
export DB_USER=app
export DB_PASSWORD=QwErTy1234

# 5. Запускаем приложение
echo "Starting FastAPI application..."
echo "Press Ctrl+C to stop"
echo "Access: http://localhost:5000"
echo

uvicorn main:app --host 0.0.0.0 --port 5000 --reload
