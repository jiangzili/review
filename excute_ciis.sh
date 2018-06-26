#!/bin/sh
export NLS_LANG="SIMPLIFIED CHINESE_CHINA".ZHS16GBK
#dbconn=bbsp/bbsp@11.1.198.65/orcl  /home/oracle/dbconn ,���ݿ����Ӵ�  
#datapava      �������ڲ�������ʽ��yyyyMMdd
#projectName   ϵͳ�Ĺ�����
#checkflowName ��ҪУ���������������
#wangyulong_entegor@126.com		���ƽ̨��ϵ��
#18686481137									���ƽ̨��ϵ�˵绰
#dbconn=`awk '{print $1}' /home/oracle`
dbconn=CIIS/CIIS@11.1.196.9/ciis
datepava=$1
#checkflowName=$3
#dbconn=`awk '{print $1}' /home/oracle`
while [ true ]
do
echo "��������: $datepava"
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
   echo "��ǰ��������:"$datepava"�µ����ż��ϵͳ�����������!"
   echo 0
   exit 0
fi
#------------------------------------
echo $datepava "----------------------------------"

#��������
result2=`sqlplus -s ${dbconn} <<EOF
    set heading off;
select  count (t.task_id) from c_so_task_info t where t.valid_state=1 and t.execute_state ='2';
    exit;
EOF`
if [ "$result2" -ge 1 ];then
 echo "��ǰ��������:"$datepava"�µ�$projectName�е�����������,��ȷ�Ϻ���ִ��!"
   echo "��ʱ5���Ӻ�ִ��"
   sleep 300
   continue
fi
#��������ʧ��
result1=`sqlplus -s ${dbconn} <<EOF
    set heading off;
select  count (t.task_id) from c_so_task_info t where t.valid_state=1 and t.execute_state='3';
    exit;
EOF`
if [ "$result1" -ge 1 ];then
	result3=`sqlplus -s ${dbconn} <<EOF
           set heading off;
         select  '����ID:'||t.task_id||'--������:'||t.task_name||'--ִ��ʧ��:'||t.execute_state from c_so_task_info t where t.valid_state=1 and t.execute_state='3';
          exit;
EOF`
   echo "��ǰ��������:"$datepava"�µ����ż��ϵͳ��������ʧ�ܣ���ȷ��!"
   echo "��������ϢΪ ��"${result3}"......��ȷ�ϣ�����"
   echo 1
   exit 1
fi
  echo "��ǰ��������:"$datepava"�µ����ż��ϵͳ��������δִ�У���ȷ��!"
  exit 1
else
 echo "���ݿ�����ʧ��"
  exit 1
fi
done
exit 1
