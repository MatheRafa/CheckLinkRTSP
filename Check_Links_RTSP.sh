#!/bin/bash

#Script para checar a conectividade e reprodução de links RTSP

# Script created by Matheus Rafael on 20/01/2023
# Version: 1.0
# Author's LinkedIn: linkedin.com/in/matherafa
# Author's Medium Blog: medium.com/@matherafa
# Copyright (c) 2023 Matheus Rafael
#
# This script is distributed under the terms of the GNU General Public License v3.0.
# The GNU GPL is a widely used free software license that allows for the distribution
# of both open source and commercial software. This license grants users the freedom to 
# run, study, share and modify the software, as long as the source code is made available 
# and any changes are also distributed under the same license.

#Color
RED='\033[0;31m'
NC='\033[0m'

# Nome do arquivo com os links RTSP
echo "Insira o nome do arquivo para analisar os links RTSP:"
read -r input_file
while [[ $input_file =~ [^a-zA-Z0-9\.] ]]; do
	echo "Entrada inválida, por favor informe o nome do arquivo sem espaco ou caracteres especiais: "
	read -r input_file
done

# Nome do arquivo para salvar o resultado
echo "Insira o nome do arquivo para salvar o resultado:"
read -r output_file
while [[ $output_file =~ [^a-zA-Z0-9\.] ]]; do
	echo "Entrada inválida, por favor informe o nome do arquivo sem espaco ou caracteres especiais: "
	read -r output_file
done


#limpar o arquivo de resultados
rm -f "$output_file"

# Verifica se o arquivo existe
if [ ! -f "$input_file" ]; then
	echo "O arquivo $input_file não existe ou não é acessível."
	exit 1
fi

#contador
count=1

# Cria o arquivo de resultado
touch "$output_file"

# Loop para ler cada linha do arquivo
while read -r line; do

    # Verifica se a linha atual é um link RTSP válido
    if [[ $line =~ ^rtsp:// ]]; then

        # Extrai o IP e a porta do link RTSP
        ip=$(echo "$line" | awk -F '@' '{print $2}' | awk -F ':' '{print $1}')
        port=$(echo "$line" | awk -F ':' '{print $4}' | awk -F '/' '{print $1}') 

        # Verifica se o IP e a porta estão abertos
        if timeout 5 nc -z "$ip" "$port"; then
            echo "Linha $count; IP/Porta acessíveis; $ip:$port;" >> "$output_file"
            echo "Linha $count; IP/Porta acessíveis; $ip:$port;"
            # Executa o comando "ffprobe -hide_banner $line" se o IP e a porta estão acessíveis
            ffprobe_result=$(timeout 10 ffprobe -hide_banner -loglevel level "$line" |& tee -a)
            echo -e "${RED}Resultado Link RTSP: $ffprobe_result ${NC}"
            result="Linha $count; Resultado Validação RTSP; $ffprobe_result;"
        else
            echo "Linha $count: IP e/ou porta do link RTSP não estão acessíveis: $line"
            result="Linha $count; IP e/ou porta do link RTSP não estão acessíveis; $line;"
        fi
    fi
    count=$((count+1))
    echo "$result" >> "$output_file"
done < "$input_file"
