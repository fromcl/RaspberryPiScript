#!/bin/bash

configFile="/home/user/RaspberryPiScript/SendMail/mail.ini"  #脚本的执行需要一个配置文件,注意：必须是绝对路径
function readIni()
{
    item=$1;section=$2;file=$3;
    val=$(awk -F '=' '/\['${section}'\]/{a=1} (a==1 && "'${item}'"==$1){a=0;print $2}' ${file})
    echo ${val}
}

function writeIni()
{
    item=$1;section=$2;file=$3;val=$4
    awk -F '=' '/\['${section}'\]/{a=1} (a==1 && "'${item}'"==$1){gsub($2,"'${val}'");a=0} {print $0}' ${file} 1<>${file}
}

function readIniSections()
{
    file=$1;
    val=$(awk '/\[/{printf("%s ",$1)}' ${file} | sed 's/\[//g' | sed 's/\]//g')
    echo ${val}
}

#邮件设置部分
email_reciver=`readIni "email_reciver" "Sendmail" "$configFile"`  #收件人邮箱
email_sender=`readIni "email_sender" "Sendmail" "$configFile"`  #发送者邮箱
email_username=`readIni "email_username" "Sendmail" "$configFile"`  #发送者邮箱用户名
email_password=`readIni "email_password" "Sendmail" "$configFile"`  #邮箱密码
email_smtphost=`readIni "email_smtphost" "Sendmail" "$configFile"`  #smtp服务器地址
#邮件内容部分
email_title=`readIni "email_title" "SendmailContent" "$configFile"`
ip_information=`readIni "IP" "CurrentInformation" "$configFile"`  #防止重启机器时，发送与上次一致的IP信息

ipv4=`curl --connect-timeout 10 -m 20 -s http://members.3322.org/dyndns/getip`
ipv6=`ifconfig -a | grep '240e' | awk '(NR==1||length(min)>length()){min=$0}END{print $2}'`
while [ true ]
do
    if [ "$ip_information" != "$ipv4\n$ipv6" -a -n "$ipv4" -a ${#ipv4} -lt 16 -a ${#ipv6} -lt 40 ]
    then
        ip_information=$ipv4"\n"$ipv6
        if [ -n "$ip_information" ]
        then
            writeIni "IP" "CurrentInformation" "$configFile" "$ip_information"
            email_content="$ip_information\niKuai: http://$ipv4:8094/\nDD-WRT: http://$ipv4:8081/\nESXI: https://$ipv4:8093/\nCockpit: https://$ipv4:8095/    https://$ipv6/\n\n`w`\n\n`df -h`"
            echo -e "$email_content"
            #发送执行部分
            sendemail -f ${email_sender} -t ${email_reciver} -s ${email_smtphost} \
            -u ${email_title} -xu ${email_username} -xp ${email_password} \
            -m "$email_content" -o message-charset=utf-8
        else
            echo "IP is: null"
        fi
        sleep 30
    else
        ipv4=`curl --connect-timeout 10 -m 20 -s http://members.3322.org/dyndns/getip`
        ipv6=`ifconfig -a | grep '240e' | awk '(NR==1||length(min)>length()){min=$0}END{print $2}'`
        echo "Update IP is: $ipv4    $ipv6"
        sleep 30
    fi
done
