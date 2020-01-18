#!/bin/bash
:<<INFO
@File : backup.sh
@Time : 2020/01/18 17:16:09
@Author : zhangtyps
@GitHub : https://github.com/zhangtyps
@Version : 1.0
@Desc : 通过定时任务运行此脚本，每次运行备份一次docker-mariadb数据库；并检查备份文件数量是否超过指定数量，删除最旧的备份文件。
INFO

#指定备份的目录路径，指定保留该路径内文件的数量（超过数量的将会被删除）
BACKUP_URL=/opt/phpipam/backup_data
RESERVED_NUM=7
BACKUP_FILE_NAME=phpipam_backup

#备份文件模块
function backup_data() {
    DATE=`date +'%Y-%m-%d_%H-%M-%S'`
    echo $DATE
    docker exec -it phpipam_phpipam-mariadb_1 mysqldump -uroot -pmy_secret_mysql_root_pass -B phpipam | gzip >$BACKUP_URL/$BACKUP_FILE_NAME-$DATE.gz
    touch $BACKUP_URL/$BACKUP_FILE_NAME-$DATE.gz
}

#检测删除备份模块
function delete_backup_data() {
    #获取当前备份目录下备份文件的个数
    FILE_NUM=`ls -al $BACKUP_URL | grep '^-' | grep "$BACKUP_FILE_NAME" |wc -l`
    #如果文件数大于设定好的数，则进行删除
    if [ $FILE_NUM -gt $RESERVED_NUM ];then
        #计算多出来的文件数量
        DELETE_NUM=`expr $FILE_NUM - $RESERVED_NUM`
        echo "即将删除的文件有："
        ls -tr $BACKUP_URL | head -n $DELETE_NUM
        echo "开始删除文件："
        cd $BACKUP_URL
        ls -tr $BACKUP_URL | head -n $DELETE_NUM | xargs -i -n 1 rm -rf {}
        echo 1
    fi
}

function main() {
    backup_data
    delete_backup_data
}

main