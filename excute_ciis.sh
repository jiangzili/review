#!/bin/sh
export NLS_LANG="SIMPLIFIED CHINESE_CHINA".ZHS16GBK
#dbconn=bbsp/bbsp@11.1.198.65/orcl  /home/oracle/dbconn ,数据库连接串  
#datapava      数据日期参数，格式：yyyyMMdd
#projectName   系统的工程名
#checkflowName 需要校验的日终流程名称
#wangyulong_entegor@126.com		监控平台联系人
#18686481137									监控平台联系人电话
#dbconn=`awk '{print $1}' /home/oracle`
dbconn=CIIS/CIIS@11.1.196.9/ciis
datepava=$1
#checkflowName=$3
#dbconn=`awk '{print $1}' /home/oracle`
while [ true ]
do
echo "跑批日期: $datepava"
if [ -z "$datepava" ]
then
echo "the parameter:MAIN_DATE is null"
exit 1
fi
echo $datepava "----------------------------------"
if sqlplus -s ${dbconn} <<EOF
		set heading off;
		exit;
EOF
then
openday=`sqlplus -s ${dbconn} <<EOF
    set heading off;
select  replace(openday,'-','') from pub_sys_info;
    exit;
EOF`
if [ "$openday" -ge $datepava ];then
   echo "当前数据日期:"$datepava"下的征信监管系统日终跑批完成!"
   echo 0
   exit 0
fi
#------------------------------------
echo $datepava "----------------------------------"

#正在运行
result2=`sqlplus -s ${dbconn} <<EOF
    set heading off;
select  count (t.task_id) from c_so_task_info t where t.valid_state=1 and t.execute_state ='2';
    exit;
EOF`
if [ "$result2" -ge 1 ];then
 echo "当前数据日期:"$datepava"下的$projectName中调度正在运行,请确认后再执行!"
   echo "延时5分钟后执行"
   sleep 300
   continue
fi
#批量运行失败
result1=`sqlplus -s ${dbconn} <<EOF
    set heading off;
select  count (t.task_id) from c_so_task_info t where t.valid_state=1 and t.execute_state='3';
    exit;
EOF`
if [ "$result1" -ge 1 ];then
	result3=`sqlplus -s ${dbconn} <<EOF
           set heading off;
         select  '步骤ID:'||t.task_id||'--步骤名:'||t.task_name||'--执行失败:'||t.execute_state from c_so_task_info t where t.valid_state=1 and t.execute_state='3';
          exit;
EOF`
   echo "当前数据日期:"$datepava"下的征信监管系统日终跑批失败，请确认!"
   echo "错误步骤信息为 ："${result3}"......请确认！！！"
   echo 1
   exit 1
fi
  echo "当前数据日期:"$datepava"下的征信监管系统日终批量未执行，请确认!"
  exit 1
else
 echo "数据库连接失败"
  exit 1
fi
done
exit 1
