#### 使用方法

* 系统必须先安装``sendemail``、``screen``命令；

* 修改``mail.ini``文件中的个人邮件信息；

* 修改``sendmail.sh``文件中``configFile``变量的指向路径；

* 修改``launch.sh``文件中的指向``sendmail.sh``文件路径；

* 在``/etc/rc.local``文件中添加脚本启动项：
```bash
su ubuntu -c "/home/ubuntu/RaspberryPiScript/SendMail/launch.sh"
```
