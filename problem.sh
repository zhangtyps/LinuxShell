#!/bin/bash
#把删除中需要忽略的目录加入到grep当中，多个目录用|分开
#例如：grep -vE "document1|document2|document3"
cd /config/guacamole/drive
rm -rf $(ls /config/guacamole/drive | grep -vE "7a583da0-5671-4b21-8b5a-f9854883fdbe")


#这个脚本本身没有问题，但是如果没有上面cd这么一句，rm -rf是删除不掉文件的，原因未知
#我觉得可能和$()有关，不知道有没有大佬解答一下
