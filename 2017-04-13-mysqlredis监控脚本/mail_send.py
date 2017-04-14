#!/usr/bin/env python
import smtplib,datetime
from email.MIMEText import MIMEText
from email.Header import Header
from email.MIMEMultipart import MIMEMultipart
import sys

mailto_list=["406256232@qq.com","13916510937@139.com","dhx@yiban.cn","wwy@yiban.cn","wqz@yiban.cn"]
#####################
mail_host="mail.yiban.cn"
mail_user="dhx"
mail_pass="6515363"
mail_postfix="yiban.cn"
sub=sys.argv[1]
content=sys.argv[2]
######################
def send_mail(to_list,sub,content):
    me=mail_user+"<"+mail_user+"@"+mail_postfix+">"
    msg = MIMEText(content,'plain','utf-8')
    msg['Subject'] = sub
    msg['From'] = me
    msg['To'] = ";".join(to_list)
    try:
        s = smtplib.SMTP()
        s.connect(mail_host)
        s.login(mail_user,mail_pass)
        s.sendmail(me, to_list, msg.as_string())
        s.close()
        return True
    except Exception, e:
        print str(e)
        return False
if __name__ == '__main__':
    if send_mail(mailto_list,sub,content):
        print "has error,the mail send sucessfly"
        file_object=open("//tmp//mail.log",'a')
        file_object.write(content+'\r\n')
        file_object.close()
    else:
        print "the mail has wrong,please check why mail can't be send......"
