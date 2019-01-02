#!/bin/bash

data=$(date "+%b %d - %H:%M:%S")
cont=1
path_log="/opt/zabbix/temp_monitor/debugLog"
file_log=$(date +%d%b%Y.log)
path1="/opt/zabbix/temp_monitor/hd"
path2="/opt/zabbix/temp_monitor/cpu" 

#Verificando diretorio e Criando arquivo de log 
if [ -e $path_log ]; then
    touch $path_log/$file_log
else
    mkdir -p $path_log
    touch $path_log/$file_log
fi
echo "==============Processo iniciado em $data==============" >> $path_log/$file_log 2>&1
echo "=================================================================" >> $path_log/$file_log 2>&1
#Virificando diretório do monitoramento do HDD
echo $data "Verificando diretório $path1 e dando permissões ao usuário 'zabbix'" >> $path_log/$file_log 2>&1
if [ ! -d $path1 ]; then
    mkdir -p $path1 >> $path_log/$file_log 2>&1 
    chown -R zabbix. $path1 >> $path_log/$file_log 2>&1
fi
#Virificando diretório do monitoramento da CPU e seus Núcleos
echo $data "Verificando diretório $path2 e dando permissões ao usuário 'zabbix'" >> $path_log/$file_log 2>&1
if [ ! -d $path2 ]; then
    mkdir -p $path2 >> $path_log/$file_log 2>&1 
    chown -R zabbix. $path2 >> $path_log/$file_log 2>&1
fi
#Gerando arquivos do monitoramento
echo $data "Gerando arquivos com as temperaturas" >> $path_log/$file_log 2>&1 
for (( a=0 ; a<1 ; a++ )); do
    echo $data "Gerando Arquivo $path1/hdd_temp" >> $path_log/$file_log 2>&1 
    hddtemp /dev/sda | grep '°C' | sed 's/:.*://' | cut -d "/" -f3 | cut -d " " -f2 | cut -d "C" -f1 | sed 's/°//g' >$path1/hdd_temp
    if [ -e "$path1/hdd_temp" ]; then echo $data "Arquivo $path1/hdd_temp gerado com SUCESSO" >> $path_log/$file_log 2>&1
    else echo $data "Arquivo $path1/hdd_temp NÃO foi gerado corretamente" >> $path_log/$file_log 2>&1
    fi
    echo $data "Gerando Arquivo $path2/cpu_cores_temp_general" >> $path_log/$file_log 2>&1 
    sensors | grep '°C' | sed -r 's/ +/ /g' | cut -d " " -f3 | cut -d "(" -f3 | cut -d "c" -f3 | cut -d "r" -f3 | cut -d "i" -f3 | cut -d "t" -f3 | cut -d "+" -f2 | cut -d "C" -f1 | sed 's/°//g' | cut -d "." -f1 | cut -d ":" -f2 | grep '[[:graph:]]' >$path2/cpu_cores_temp_general
    if [ -e "$path2/cpu_cores_temp_general" ]; then echo $data "Arquivo $path2/cpu_cores_temp_general gerado com SUCESSO" >> $path_log/$file_log 2>&1
    else echo $data "Arquivo $path2/cpu_cores_temp_general NÃO foi gerado corretamente" >> $path_log/$file_log 2>&1
    fi
    echo $data "Verificando do permissões ao usuário 'zabbix' para o arquivo $path1/hdd_temp" >> $path_log/$file_log 2>&1
    chown -R zabbix. $path1/hdd_temp >> $path_log/$file_log 2>&1
    qtdecores=$(wc -l $path2/cpu_cores_temp_general | head -c1)
    echo $data "Gerando arquivos com as temperaturas dos Núcleos" >> $path_log/$file_log 2>&1 
    while [ $cont -le $qtdecores ]; do
        echo $data "Gerando arquivo com a temperatura do Núcleo $cont" >> $path_log/$file_log 2>&1
        cat $path2/cpu_cores_temp_general | sed -n $cont'p' >$path2/cpu_temp_core_$cont
        if [ -e "$path2/cpu_temp_core_$cont" ]; then echo $data "Arquivo $path2/cpu_temp_core_$cont gerado com SUCESSO" >> $path_log/$file_log 2>&1
        else echo $data "Arquivo $path2/cpu_temp_core_$cont NÃO foi gerado corretamente" >> $path_log/$file_log
        fi
        echo $data "Verificando do permissões ao usuário 'zabbix' para o arquivo $path2/cpu_cores_temp_$cont" >> $path_log/$file_log 2>&1
        chown -R zabbix. $path2/cpu_cores_temp_$cont >> $path_log/$file_log 2>&1
        cont=$((cont+=1))
    done
done
echo $data "Finalizando o processo..." >> $path_log/$file_log 2>&1
#Feito
echo "=============Processo Finalizado em $data=============" >> $path_log/$file_log
echo "=================================================================" >> $path_log/$file_log
echo "" >> $path_log/$file_log

