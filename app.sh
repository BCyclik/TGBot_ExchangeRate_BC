#!/bin/bash

# Указываем URL репозитория (замените на нужный вам репозиторий)
REPO_URL="https://github.com/BCyclik/TGBot_ExchangeRate_BC.git"
PROJECT_DIR="TGBot_ExchangeRate_BC" # Имя директории для клонированного проекта

# Проверяем, установлен ли Git
if ! command -v git &> /dev/null
then
    echo "Git не установлен. Установите Git и попробуйте снова."
    exit 1
fi

# Проверяем, установлен ли .NET SDK
if ! command -v dotnet &> /dev/null
then
    echo ".NET SDK не установлен. Установите .NET SDK и попробуйте снова."
    exit 1
fi

# Клонируем репозиторий
if [ -d "$PROJECT_DIR" ]; then
    echo "Директория '$PROJECT_DIR' уже существует. Обновляем репозиторий."
    cd "$PROJECT_DIR"
    git pull origin main # Поменяйте 'main', если у вас другая ветка
else
    echo "Клонирование репозитория..."
    git clone "$REPO_URL" "$PROJECT_DIR"
    cd "$PROJECT_DIR"
fi

# Устанавливаем зависимости
echo "Установка зависимостей..."
dotnet add package Telegram.Bot
dotnet add package Newtonsoft.Json

# Сборка проекта
echo "Сборка проекта..."
dotnet build

# Запуск проекта в фоновом режиме
#echo "Запуск проекта в фоновом режиме..."
#nohup dotnet run > output.log 2>&1 &

# Получаем PID
#echo "Приложение запущено с PID: $!"
#echo "Вывод приложения сохраняется в file output.log"
