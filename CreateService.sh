#!/bin/bash

# Конфигурация
SERVICE_NAME="tgbot_exchagerate"
EXEC_PATH="/root/TGBot_ExchangeRate_BC/bin/Debug/net8.0/TGBot_ExchangeRate_BC" # Замените на путь к вашему приложению
WORKING_DIRECTORY="/root/TGBot_ExchangeRate_BC/bin/Debug/net8.0"           # Ваш рабочий каталог

# Удаление существующего сервиса, если он есть
if systemctl list-unit-files | grep -q "$SERVICE_NAME.service"; then
    echo "Удаление существующего сервиса $SERVICE_NAME..."
    sudo systemctl stop "$SERVICE_NAME"
    sudo systemctl disable "$SERVICE_NAME"
    sudo rm /etc/systemd/system/"$SERVICE_NAME.service"
    echo "Сервис $SERVICE_NAME удален."
fi

# Создание нового сервиса
echo "Создание нового сервиса $SERVICE_NAME..."
cat <<EOL | sudo tee /etc/systemd/system/"$SERVICE_NAME.service"
[Unit]
Description=Telegram Bot Exchange Rate

[Service]
ExecStart=$EXEC_PATH
WorkingDirectory=$WORKING_DIRECTORY
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Перезагрузка конфигурации systemd
echo "Перезагрузка конфигурации systemd..."
sudo systemctl daemon-reload

# Запуск сервиса
echo "Запуск сервиса $SERVICE_NAME..."
sudo systemctl start "$SERVICE_NAME"
sudo systemctl enable "$SERVICE_NAME"  # Включение автозапуска при загрузке

echo "Сервис $SERVICE_NAME успешно создан и запущен."

# Создание CLI-скрипта для управления сервисом
echo "Создание CLI-скрипта для управления сервисом..."
sudo tee /usr/local/bin/tgbot_exchagerate > /dev/null <<EOL
#!/bin/bash

SERVICE_NAME="$SERVICE_NAME"

case "\$1" in
    start)
        echo "Запуск сервиса \$SERVICE_NAME..."
        sudo systemctl start "\$SERVICE_NAME"
        echo "\$SERVICE_NAME запущен."
        ;;
    
    stop)
        echo "Остановка сервиса \$SERVICE_NAME..."
        sudo systemctl stop "\$SERVICE_NAME"
        echo "\$SERVICE_NAME остановлен."
        ;;
    
    status)
        echo "Статус сервиса \$SERVICE_NAME:"
        sudo systemctl status "\$SERVICE_NAME"
        ;;
    
    restart)
        echo "Перезапуск сервиса \$SERVICE_NAME..."
        sudo systemctl restart "\$SERVICE_NAME"
        echo "\$SERVICE_NAME перезапущен."
        ;;
    
    *)
        echo "Используйте: \$0 {start|stop|status|restart}"
        ;;
esac
EOL

# Сделать скрипт исполняемым
sudo chmod +x /usr/local/bin/tgbot_exchagerate

echo "Установка завершена. Вы можете использовать команду 'tgbot_exchagerate' для управления сервисом."
