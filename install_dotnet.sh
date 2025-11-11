#!/bin/bash

# Обновляем пакетный индекс
echo "Обновление индексированных пакетов..."
sudo apt update

# Установка необходимых пакетов для .NET
echo "Установка необходимых пакетов..."
sudo apt install -y wget apt-transport-https

# Добавление репозитория Microsoft
echo "Добавление репозитория Microsoft..."
wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

# Установка пакетов для работы с .NET
echo "Установка .NET SDK..."
sudo apt update
sudo apt install -y dotnet-sdk-8.0

# Проверка установки .NET
echo "Проверка установки .NET..."
dotnet --version

echo "Установка завершена!"
