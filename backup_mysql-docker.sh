#!/bin/bash
:<<INFO
@File : backup_mysql-docker.sh
@Time : 2020/01/18 17:16:09
@Author : zhangtyps
@GitHub : https://github.com/zhangtyps
@Version : 1.1
@Desc : 通过定时任务运行此脚本，每次运行备份一次docker-mariadb数据库；并检查备份文件数量是否超过指定数量，删除最旧的备份文件（不会删除目录下不包含该文件名的文件，防止误删除）。
INFO

#指定备份文件保存的路径
BACKUP_URL=/opt/phpipam/backup_data
#指定保留该路径内备份文件的数量（超过数量的将会被删除）
RESERVED_NUM=7
#指定备份文件的名称（后面会自动追加日期组合成文件名）
BACKUP_FILE_NAME=phpipam_backup
#备份的数据库相关信息（数据库的容器名，数据库的账户，数据库的密码，需要备份的库名）
DB_DOCKER_NAME=phpipam_phpipam-mariadb_1
DB_DOCKER_USER=root
DB_DOCKER_PASSWD=my_secret_mysql_root_pass
DB_DOCKER_DATABASE=phpipam


#备份容器数据库模块
function backup_data() {
    DATE=`date +'%Y-%m-%d_%H-%M-%S'`
    echo $DATE
    docker exec $DB_DOCKER_NAME mysqldump -u$DB_DOCKER_USER -p$DB_DOCKER_PASSWD -B $DB_DOCKER_DATABASE | gzip >$BACKUP_URL/$BACKUP_FILE_NAME-$DATE.gz
    if [ $? -eq 0 ];then
        echo "数据库备份成功！备份文件位于：$BACKUP_URL/$BACKUP_FILE_NAME-$DATE.gz"
    else
        echo "数据库备份失败，请检查数据库容器的运行状态！"
        exit 0
    fi
}

#检测删除备份文件模块
function delete_backup_data() {
    #获取当前备份目录下备份文件的个数
    FILE_NUM=`ls -al $BACKUP_URL | grep '^-' | grep "$BACKUP_FILE_NAME" | wc -l`
    #如果文件数大于设定好的数，则进行删除
    if [ $FILE_NUM -gt $RESERVED_NUM ];then
        #计算多出来的文件数量
        DELETE_NUM=`expr $FILE_NUM - $RESERVED_NUM`
        echo "即将删除的旧备份文件有："
        ls -tr $BACKUP_URL | grep "$BACKUP_FILE_NAME" | head -n $DELETE_NUM
        cd $BACKUP_URL
        ls -tr $BACKUP_URL | grep "$BACKUP_FILE_NAME" | head -n $DELETE_NUM | xargs -i -n 1 rm -rfv {}
    fi
}

function main() {
    backup_data
    delete_backup_data
}

main
