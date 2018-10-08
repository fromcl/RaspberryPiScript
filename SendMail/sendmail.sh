#!/bin/bash

configFile="./mail.ini"  #脚本的执行需要一个配置文件
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

temp=`curl --connect-timeout 10 -m 20 -s http://members.3322.org/dyndns/getip`
while [ true ]
do
    if [ "$ip_information" != "$temp" ]
    then
        ip_information=`curl --connect-timeout 10 -m 20 -s http://members.3322.org/dyndns/getip`
        if [ -n "$ip_information" ]
        then
            writeIni "IP" "CurrentInformation" "$configFile" "$ip_information"
            email_content="$ip_information\n`w`"  #编辑邮件内容信息
            echo -e "$email_content"
            #发送执行部分
            sendemail -f ${email_sender} -t ${email_reciver} -s ${email_smtphost} \
            -u ${email_title} -xu ${email_username} -xp ${email_password} \
            -m "$email_content" -o message-charset=utf-8
        else
            echo "IP is: null"
            temp=$ip_information
        fi
        sleep 2
    else
        temp=`curl --connect-timeout 10 -m 20 -s http://members.3322.org/dyndns/getip`
        echo "Update IP is: $temp"
        sleep 2
    fi
done