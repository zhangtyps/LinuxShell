#!/bin/bash
# 想要让Linux发送邮件，就必须配置默认的邮件发送参数，编辑/etc/mail.rc配置文件，加入如下内容：
# set from=发件人邮箱
# set smtp=smtp服务器
# set smtp-auth-user=发件人邮箱账户
# set smtp-auth-password=发件人邮箱账户密码
# set smtp-auth=login
to=$1
subject=$2
FILE=$3
mail -s "$subject" "$to" <$FILE
