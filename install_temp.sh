#!/bin/bash

#Execute o script como administrador root(ou sudo)
#Executando esse script, será instalados os pacotes necessários e atualizado os modulos para o monitoramento de temperatura.

data=$(date "+%b %d - %H:%M:%S")
path_log="/opt/zabbix/temp_monitor/debugLog"
file_log=$(date +%d%b%Y.Install_Log.log)

#Verificando diretorio e Criando arquivo de log 
if [ -e $path_log ]; then
    touch $path_log/$file_log
else
    mkdir -p $path_log
    touch $path_log/$file_log
fi

echo "==============Processo de instalação iniciado em $data==============" >> $path_log/$file_log 2>&1
echo "===============================================================================" >> $path_log/$file_log 2>&1
echo $data "Instalando pacotes necessários...">> $path_log/$file_log 2>&1
sudo apt-get install -y lm-sensors i2c-tools hddtemp >> $path_log/$file_log 2>&1
sensors-detect --auto >> $path_log/$file_log 2>&1
sensors -s >> $path_log/$file_log 2>&1

# Colocando o serviço do 'zabbix-agent' para iniciar com o sistema.
echo $data "Colocando o serviço do 'zabbix-agent' para iniciar com o sistema." >> $path_log/$file_log 2>&1
update-rc.d zabbix-agent defaults >> $path_log/$file_log 2>&1

#Incluindo no '/etc/crontab' a inicialização do 'temp_script'
echo $data "Incluindo no '/etc/crontab' a inicialização do 'temp_script.sh'" >> $path_log/$file_log 2>&1
sudo sed -i '$c*/2 * * * * root  /usr/bin/temp_script.sh\' /etc/crontab >> $path_log/$file_log 2>&1
sudo sed -i '$a#' /etc/crontab >> $path_log/$file_log 2>&1


#Incluindo no '/etc/zabbix/zabbix_agentd.conf' os parametros dos itens.
echo $data "Incluindo no '/etc/zabbix/zabbix_agentd.conf' os parametros dos itens." >> $path_log/$file_log 2>&1
sudo sed -i  -e '$a\' -e 'UserParameter=temp.hd,cat /opt/zabbix/temp_monitor/hd/hdd_temp\nUserParameter=temp.cpu[*],cat /opt/zabbix/temp_monitor/cpu/cpu_temp_core_$\1' /etc/zabbix/zabbix_agentd.conf >> $path_log/$file_log 2>&1

#Reistartando o Zabbix.
echo $data "Reistartando o Zabbix." >> $path_log/$file_log 2>&1
/etc/init.d/zabbix-agent restart >> $path_log/$file_log 2>&1

#Reistartando o Cron.
echo $date "Reistartando o Cron." >> $path_log/$file_log 2>&1
sudo service cron restart >> $path_log/$file_log 2>&1

echo "==============Processo de instalação finalizado em $data==============" >> $path_log/$file_log 2>&1
echo "=================================================================================" >> $path_log/$file_log 2>&1


