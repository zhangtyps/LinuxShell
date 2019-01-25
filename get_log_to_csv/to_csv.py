#!/usr/bin/python
# -*- coding:utf-8 -*-
#访问我的GitHub获取最新的代码：https://github.com/zhangtyps
#配合collectlog.sh导出的outlog.log，进行写表操作
#version 1.1 在写表前把成功率的值进行了处理，方便复制粘贴到excel

import os,csv

#输出excel的名称
output_excel='result.csv'
#读取的日志名称
log_name='output.log'
log_path=os.path.join(os.getcwd(),log_name)
#log_path='E:\\GitTest\\CodeDemo\\get_log_to_csv\\output.log'

out_list=[]
#打开log文件，去除行尾的\n换行符，同时按照空格分隔，保存到列表里
with open(log_path) as f:
    for line in f:
        out_list.append(line.strip().split())

for i in out_list:
    i[2]=round(float(i[2])/100,3)

#输出日志前清理上一次的日志
try:
    os.remove(output_excel)
except:
    pass

#按列表元素顺序，输出csv
with open(output_excel,"w", newline='') as datacsv:
    csvwriter = csv.writer(datacsv,dialect=("excel"))
    csvwriter.writerow(["代理IP","代理总量","成功率"])
    for i in out_list:
        csvwriter.writerow(i)