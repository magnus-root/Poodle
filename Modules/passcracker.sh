#!/bin/bash

cat << EOF
                                                        
+--------------------------------------------------------------------+
|                                                                    |
|                     Модуль для подбора паролей                     |
|                                                                    |
+--------------------------------------------------------------------+                                                                 
                                                           
EOF

echo "Добро пожаловать во взломщик паролей iST"
echo "============================="

while :
do
    echo "Вы хотите сбрутить пароль с помощью Hydra? Нажмите hy"
    echo "Вы хотите подобрать хэш с помощью Hashcat? Нажмите hc"
    echo "Вы хотите подобрать хэш с помощью John the Ripper? Нажмите jr"
    echo "Если Вы хотите выйти, то нажмите Ctrl + C"
    read command

    if [ $command == "hc" ]; then
        read -p "Вы хотите делать брут по словарю или полный перебор (b/p)? " mode_
        if [ $mode_ == "b" ]; then
            read -p "Введите цифру, соответствующую типу хэша (можно определить здесь https://suip.biz/ru/?act=hashtag): " hash_type
            read -p "Введите хэш: " hash_
            hashcat -a 0 -m $hash_type $hash_ /usr/share/wordlists/rockyou.txt
        elif [ $mode_ == "p" ]; then
            read -p "Введите цифру, соответствующую типу хэша: " hash_type
            read -p "Введите хэш: " hash_
            hashcat -a 0 -m $hash_type $hash_
        fi
    elif [ $command == "jr" ]; then
        read -p "Введите хэш: " hash_
        john $hash_ -w=/usr/share/wordlists/rockyou.txt
    elif [ $command == "hy" ]; then
        read -p "Вы знаете логин (y/n)?" ansvr_
        if [ $ansvr_ == "y" ]; then
            read -p "Введите логин: " login_
            read -p "Введите {service}(Например: ssh): " service_
            read -p "Введите {Target_IP}: " ip_
            hydra -l $login_ -P /usr/share/wordlists/rockyou.txt $service_://$ip_
        else
            read -p "Введите {service}(Например: ssh): " service_
            read -p "Введите {Target_IP}: " ip_
            hydra -L /usr/share/wordlists/brutespray/$service_/user -P /usr/share/wordlists/rockyou.txt $service_://$ip_
        fi
    else
	    echo "Введено что-то не то. Попробуй ещё раз."
        echo " "
        continue
    fi
done