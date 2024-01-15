#!/bin/bash

cat << EOF

██████╗░░█████╗░░█████╗░██████╗░██╗░░░░░███████╗
██╔══██╗██╔══██╗██╔══██╗██╔══██╗██║░░░░░██╔════╝
██████╔╝██║░░██║██║░░██║██║░░██║██║░░░░░█████╗░░
██╔═══╝░██║░░██║██║░░██║██║░░██║██║░░░░░██╔══╝░░
██║░░░░░╚█████╔╝╚█████╔╝██████╔╝███████╗███████╗
╚═╝░░░░░░╚════╝░░╚════╝░╚═════╝░╚══════╝╚══════╝                                                          
EOF

while true; do
    # Устанавливаем список необходимого софта и список для записи того чего у нас ещё нет
    soft_=("nmap" "dirsearch" "gobuster" "wpscan" "ffuf" "wfuzz")
    need_soft_=()
    your_terminal="gnome-terminal"
    path_to_scripts="/home/$USER/Apps"
    
    # Проверяем наличие установленных программ по списку и добавлением необходимого в пустой список.
    # Если программа установлена, но возле неё отображается галочка, если нет - крестик.
    for program in "${soft_[@]}"
    do
        if [ -x "$(command -v $program)" ]; then
            echo -e "$program \033[32m✔\033[0m"
        else
            echo -e "$program \033[31m✘\033[0m"
            need_soft_+="$program"$'\n'
        fi
    done
    
    # Добавляем в переменную место, где хранятся словари
    wordlists_="/usr/share/wordlists/"
    # Проверяем наличие словарей
    if [ "ls -A $wordlists_" ]; then
        echo "============================="
        echo "Словари найдены"
    else
        echo "Словари не найдены. Проверьте где они у Вас находятся и либо перенесите их в папку $wordlists_ , либо измените путь до них в 33 строке кода."
    fi
    echo "============================="
    # Если весь необходимый софт установлен, то запускается основной цикл
    if [[ ${#need_soft_[@]} == 0 ]]; then    
        while :
        do  
            # Появляется запрос необходимого действия
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo "Сканироваине хостов"
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo "Вы хотите просканировать сеть или хост? Нажмите n"
            echo "Вы хотите просканировать директории на хосте? Нажмите d"
            echo "Вы хотите просканировать директории более глубо? Нажмите sd"
            echo "Вы хотите просканировать поддомены на хосте? Нажмите s"
            echo "Вы хотите просканировать сайт с WordPress? Нажмите wp"
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo "XXE"
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo "Вы хотите проверить сайт на уязвимость к XXE? Нажмите xxe"
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo "Подбор паролей"
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo "Если Вы хотите попытаться подобрать пароль, то наберите 'pass'"
            echo "=========================================================="
            echo "Если Вы хотите выйти, то нажмите Ctrl + C"
            read command
            # Согласно выбраной букве запускается необходимая программа
            if [ $command == "d" ]; then
                read -p "Введите IP: " ip_
                dirsearch -u $ip_
            elif [ $command == "s" ]; then
                read -p "Введите URL: " url_
                gobuster dns -w $wordlists_/seclists/Discovery/DNS/bitquark-subdomains-top100000.txt -d $url_  -t 100
            elif [ $command == "xxe" ]; then
                cat $path_to_scripts/Poodle/Modules/xxe.md
            elif [ $command == "n" ]; then
                read -p "Введите IP: " ip_
                read -p "Введите до какого порта сканировать (масксимум 65535, стандартно 1000): " ports_
                nmap -sC -sV -p -$ports_ --min-rate 5000 $ip_
                read -p  "Успешно? Если да, то нажмите y, если нет и проблема в блокировке ping, то нажмите pg для повторного сканирования с отключенным пингом: " result_
                if [ $result_ == "y" ]; then
                    continue
                elif [ $result_ == "pg" ]; then
                    nmap -sC -sV -Pn -p -$ports_ --min-rate 5000 $ip_
                fi
            elif [ $command == "sd" ]; then
                read -p "Введите IP/{direct}: " ip_
                read -p "Какой словарь хотите использовать (small/medium)? " dict_
                gobuster dir -w $wordlists_ dirbuster/directory-list-2.3-$dict_.txt -u  $ip_ -t 100
            elif [ $command == "wp" ]; then
                read -p "Введите IP/{direct}: " ip_
                wpscan --url $ip_ -e u 
                wpscan --url $ip_ -e ap
            elif [ $command == "pass" ]; then
                $path_to_scripts/Poodle/Modules/passcracker.sh
            else
        	    echo "Введено что-то не то. Попробуй ещё раз."
                echo " "
                continue
            fi
        done
    # Если какого-то софта не хватает, то появляется список того, что нужно установить
    else
        echo "Необходимо установить следующий софт:"
        for i in "${need_soft_[@]}"
        do
            echo "$i"
        done
        read -p "Устанавливаю? (Y-да, всё остальное нет): " install_or_not
        if [[ $install_or_not == "Y" || $install_or_not == "y" || $install_or_not == "yes" ]]; then
            for i in "${need_soft_[@]}"
            do
                sudo apt install -y $i
                continue
            done
        else
            break
        fi
    fi
done