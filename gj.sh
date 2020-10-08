#!/bin/bash
if [ $1 ]; then
  sb=$1
  #echo "设备号:"$sb
  echo "">${sb}.txt
  #查找设备与端口的对应关系。
  #----------------------------------------
  lineno=1
  for pid in `cat siplog|grep -B 3 $sb|grep -a info|awk '{print $5}'|sort|uniq`
  do
    l=`cat siplog|grep $pid|grep -a "udp client"|awk '{print $1,$2,$8}'`
    if [ ${#l} != 0 ]; then
      rq=`echo $l|awk '{print $1}'`
      sj=`echo $l|awk '{print $2}'`
      iip=`echo $l|awk '{print $3}'`
      gip="--"
      nsip="--"
      #`cat siplog|grep -A 6 $pid|grep -A 6 "revice:SIP"|grep Via|awk '{print $3}'|awk -F ';' '{print $1}'`
      l=`cat siplog|grep $pid|grep -a "udp proxy"|awk '{print $8,$11}'`
      ndip=`echo $l|awk '{print $1}'`
      sip=`echo $l|awk '{print $2}'`
      
      echo $rq,$sj,"00",$sb,$iip,$gip,$nsip,$ndip,$sip,"<=====>">>${sb}.txt
    fi

    for line in `cat siplog|grep -A 6 $pid`
    do
      (( lineno=lineno+1 ))
      head=${line:0:2}
      if [ ${head} == "20" -a ${#line} -eq 10 ]; then
        lineno=1
        iip="--"
        sip="--"
        gip="--"
        nsip="--"
        ndip="--"
        rq=$line
      fi
      if [ ${lineno} -eq 2 ]; then
        sj=$line
      fi
      if [ ${lineno} -eq 7 ]; then
        type=$line
      fi
      if [ ${lineno} -gt 7 ]; then
        if [ "$type" != "udp"  ]; then
          if [ "$type" == "revice:SIP/2.0" ]; then
            #echo $lineno,$line
            if [ ${lineno} -eq 8 ]; then
               rcode=$line
               #echo $rq,$sj,$sb,$iip,$gip,$nsip,$ndip,$sip,"--->MSG"
            fi
            if [ ${lineno} -eq 10 ]; then
               siptype=$line
               #echo $rq,$sj,$sb,$iip,$gip,$nsip,$ndip,$sip,"--->MSG"
            fi
            if [ ${lineno} -eq 12 ]; then
              if [ "$siptype" == "CSeq:" ]; then
                rtype=${line:0:1}
              else
                if [ "$siptype" == "Via:" ]; then
                  iip=`echo $line|awk -F ';' '{print $1}'`
                  gip=$iip
                fi

              fi
              #echo $siptype,$rtype
            fi
            if [ ${lineno} -eq 21 ]; then
              if [ "$siptype" == "Via:" ]; then
                rtype=${line:0:1}
                if [ "$rtype" == "S" ]; then
                   if [ "$rcode" == "200" ]; then
                     echo $rq,$sj,"23",$sb,$iip,$gip,$nsip,$ndip,$sip,"${rtype}->${rcode}">>${sb}.txt
                   else
                     echo $rq,$sj,"24",$sb,$iip,$gip,$nsip,$ndip,$sip,"${rtype}->${rcode}">>${sb}.txt
                    
                   fi
                else
                    if [ "$rtype" == "I" ]; then
                       if [ "$rcode" == "200" ]; then
                         echo $rq,$sj,"53",$sb,$iip,$gip,$nsip,$ndip,$sip,"${rtype}->${rcode}">>${sb}.txt
                       else
                         echo $rq,$sj,"54",$sb,$iip,$gip,$nsip,$ndip,$sip,"${rtype}->${rcode}">>${sb}.txt
                       fi
                    else
                         echo $rq,$sj,"91",$sb,$iip,$gip,$nsip,$ndip,$sip,"${rtype}->${rcode}">>${sb}.txt
                    fi
                fi
              fi
              if [ "$siptype" == "CSeq:" ]; then
               nsip=`echo $line|awk -F ';' '{print $1}'`
               ndip=`echo $line|awk -F ';' '{print $1}'|awk -F ':' '{print $1}'`":"`echo $line|awk -F ';' '{print $2}'|awk -F '=' '{print $2}'`
               gip="--"
               iip="--"
               sip="--"
               if [ "$rtype" == "R" ]; then
                 if [ "$rcode" == "401" ]; then
                   echo $rq,$sj,"11",$sb,$iip,$gip,$nsip,$ndip,$sip,"${rtype}${rcode}<-">>${sb}.txt
                 else
                   echo $rq,$sj,"14",$sb,$iip,$gip,$nsip,$ndip,$sip,"${rtype}${rcode}<-">>${sb}.txt
                 fi
               else
                   if [ "$rtype" == "M" ]; then
                     if [ "$rcode" == "200" ]; then
                       echo $rq,$sj,"42",$sb,$iip,$gip,$nsip,$ndip,$sip,"${rtype}${rcode}<-">>${sb}.txt
                     else
                       echo $rq,$sj,"43",$sb,$iip,$gip,$nsip,$ndip,$sip,"${rtype}${rcode}<-">>${sb}.txt
                     fi
                   else
                      echo $rq,$sj,"92",$sb,$iip,$gip,$nsip,$ndip,$sip,"${rtype}<-${rcode}">>${sb}.txt
                   fi
               fi
             fi
            fi
          fi
          if [ "$type" == "revice:SUBSCRIBE" ]; then
            if [ ${lineno} -eq 8 ]; then
               ndip=`echo $line|awk -F '@' '{print $2}'`
            fi
            if [ ${lineno} -eq 12 ]; then
               gip=`echo $line|awk -F ';' '{print $1}'`
               iip="--"
               sip="--"
               nsip="--"
               echo $rq,$sj,"21",$sb,$iip,$gip,$nsip,$ndip,$sip,"SUB<---">>${sb}.txt
               #echo $rq,$sj,"2",$sb,$iip,$gip,$nsip,$ndip,$sip,"SUB<---"
            fi
          fi
          if [ "$type" == "return:SUBSCRIBE" ]; then
            if [ ${lineno} -eq 8 ]; then
               ndip=`echo $line|awk -F '@' '{print $2}'`
            fi
            if [ ${lineno} -eq 12 ]; then
               gip=`echo $line|awk -F ';' '{print $1}'`
               iip="--"
               sip="--"
               nsip="--"
               #echo $rq,$sj,"4",$sb,$iip,$gip,$nsip,$ndip,$sip,"INV<---"
               echo $rq,$sj,"22",$sb,$iip,$gip,$nsip,$ndip,$sip,"<---SUB">>${sb}.txt
            fi
          fi
          if [ "$type" == "revice:REGISTER" ]; then
            if [ ${lineno} -eq 12 ]; then
              nsip=`echo $line|awk -F ';' '{print $1}'`
            fi
            if [ ${lineno} -eq 14 ]; then
              gip=`echo $line|awk -F '@' '{print $2}'|awk -F ';' '{print $1}'`
              iip="--"
              ndip="--"
              sip="--"
              if [ "${nsip:0:3}" == "192" ];then
                echo $rq,$sj,"10",$sb,$iip,$gip,$nsip,$ndip,$sip,"->REG-1">>${sb}.txt
              else
                echo $rq,$sj,"13",$sb,$iip,$gip,$nsip,$ndip,$sip,"->REG-2">>${sb}.txt
              fi
            fi
          fi
          if [ "$type" == "revice:ACK" ]; then

            #echo $lineno,$line
            if [ ${lineno} -eq 8 ]; then
               ndip=`echo $line|awk -F '@' '{print $2}'`
            fi
            if [ ${lineno} -eq 17 ]; then
               gip=`echo $line|awk -F ';' '{print $1}'`
               iip="--"
               sip="--"
               nsip="--"
               #echo $rq,$sj,"4",$sb,$iip,$gip,$nsip,$ndip,$sip,"INV<---"
               echo $rq,$sj,"55",$sb,$iip,$gip,$nsip,$ndip,$sip,"--->ACK">>${sb}.txt
            fi
          fi
          if [ "$type" == "revice:BYE" ]; then
            #echo $lineno,$line
            if [ ${lineno} -eq 8 ]; then
               ndip=`echo $line|awk -F '@' '{print $2}'`
            fi
            if [ ${lineno} -eq 12 ]; then
               gip=`echo $line|awk -F ';' '{print $1}'`
            fi
            if [ ${lineno} -eq 14 ]; then
               sip=`echo $line|awk -F '@' '{print $2}'|awk -F '>' '{print $1}'`
               #echo $rq,$sj,"4",$sb,$iip,$gip,$nsip,$ndip,$sip,"INV<---"
               echo $rq,$sj,"71",$sb,$iip,$gip,$nsip,$ndip,$sip,"BYE<---">>${sb}.txt
            fi
          fi
          if [ "$type" == "return:BYE" ]; then
            #echo $lineno,$line
            if [ ${lineno} -eq 8 ]; then
               ndip=`echo $line|awk -F '@' '{print $2}'`
            fi
            if [ ${lineno} -eq 12 ]; then
               gip=`echo $line|awk -F ';' '{print $1}'`
            fi
            if [ ${lineno} -eq 14 ]; then
               sip=`echo $line|awk -F '@' '{print $2}'|awk -F '>' '{print $1}'`
               #echo $rq,$sj,"4",$sb,$iip,$gip,$nsip,$ndip,$sip,"INV<---"
               echo $rq,$sj,"72",$sb,$iip,$gip,$nsip,$ndip,$sip,"<---BYE">>${sb}.txt
            fi
          fi
          if [ "$type" == "revice:INVITE" ]; then
            if [ ${lineno} -eq 8 ]; then
               ndip=`echo $line|awk -F '@' '{print $2}'`
            fi
            if [ ${lineno} -eq 12 ]; then
               gip=`echo $line|awk -F ';' '{print $1}'`
               iip="--"
               sip="--"
               nsip="--"
               #echo $rq,$sj,"4",$sb,$iip,$gip,$nsip,$ndip,$sip,"INV<---"
               echo $rq,$sj,"51",$sb,$iip,$gip,$nsip,$ndip,$sip,"INV<---">>${sb}.txt
            fi
          fi
          if [ "$type" == "return:INVITE" ]; then
            if [ ${lineno} -eq 8 ]; then
               ndip=`echo $line|awk -F '@' '{print $2}'`
            fi
            if [ ${lineno} -eq 12 ]; then
               gip=`echo $line|awk -F ';' '{print $1}'`
               iip="--"
               sip="--"
               nsip="--"
               #echo $rq,$sj,"5",$sb,$iip,$gip,$nsip,$ndip,$sip,"<---INV"
               echo $rq,$sj,"52",$sb,$iip,$gip,$nsip,$ndip,$sip,"<---INV">>${sb}.txt
            fi
          fi
          if [ "$type" == "revice:MESSAGE" ]; then
            #echo $lineno,$line
            if [ ${lineno} -eq 8 ]; then
               gip=`echo $line|awk -F '@' '{print $2}'`
            fi
            if [ ${lineno} -eq 12 ]; then
              if [ "${line:0:1}" != "C" ]; then
                mtype="1"
                gip="--"
                nsip=`echo $line|awk -F ';' '{print $1}'`
                echo $rq,$sj,"41",$sb,$iip,$gip,$nsip,$ndip,$sip,"--->MSG">>${sb}.txt
              else
                mtype="2"
              fi
            fi
            if [ ${lineno} -eq 20 ]; then
              if [ "$mtype" == "2" ]; then
                 nsip=`echo $line|awk -F '@' '{print $2}'|awk -F '>' '{print $1}'`
                 echo $rq,$sj,"41",$sb,$iip,$gip,$nsip,$ndip,$sip,"--->MSG">>${sb}.txt
              fi
            fi
          fi
          if [ "$type" == "return:SIP/2.0" ]; then
            if [ ${lineno} -eq 8 ]; then
               rcode=$line
               #echo $rq,$sj,$sb,$iip,$gip,$nsip,$ndip,$sip,"--->MSG"
            fi
            if [ ${lineno} -eq 10 ]; then
               siptype=$line
               #echo $rq,$sj,$sb,$iip,$gip,$nsip,$ndip,$sip,"--->MSG"
            fi
            if [ ${lineno} -eq 12 ]; then
              if [ "$siptype" == "CSeq:" ]; then
                rtype=${line:0:1}
              else
                rtype="N"
              fi
              #echo $siptype,$line
            fi
            if [ ${lineno} -eq 16 ]; then
              sb2=`echo $line|awk -F ':' '{print $2}'|awk -F '@' '{print $1}'`
              #echo $sb2 
              if [ "${sb2}" == "${sb}" ]; then
                mark="OK"
              else
                mark="NOT"
              fi
            fi
            if [ ${lineno} -eq 21 ]; then
              if [ ${mark} == "OK" ]; then
               nsip=`echo $line|awk -F ';' '{print $1}'`
               ndip=`echo $line|awk -F ';' '{print $1}'|awk -F ':' '{print $1}'`":"`echo $line|awk -F ';' '{print $2}'|awk -F '=' '{print $2}'`
               gip="--"
               iip="--"
               sip="--"
               if [ "$rtype" == "R" ]; then
                 if [ "$rcode" == "401" ]; then
                   echo $rq,$sj,"12",$sb,$iip,$gip,$nsip,$ndip,$sip,"${rtype}<-${rcode}">>${sb}.txt
                 else
                   echo $rq,$sj,"15",$sb,$iip,$gip,$nsip,$ndip,$sip,"${rtype}<-${rcode}">>${sb}.txt
                 fi
               else
                 if [ "$rtype" == "S" ]; then
                   if [ "$rcode" == "200" ]; then
                     echo $rq,$sj,"25",$sb,$iip,$gip,$nsip,$ndip,$sip,"${rtype}<-${rcode}">>${sb}.txt
                   else
                     echo $rq,$sj,"26",$sb,$iip,$gip,$nsip,$ndip,$sip,"${rtype}<-${rcode}">>${sb}.txt
                   fi
                 else
                   if [ "$rtype" == "M" ]; then
                     if [ "$rcode" == "200" ]; then
                       echo $rq,$sj,"44",$sb,$iip,$gip,$nsip,$ndip,$sip,"${rtype}<-${rcode}">>${sb}.txt
                     else
                       echo $rq,$sj,"45",$sb,$iip,$gip,$nsip,$ndip,$sip,"${rtype}<-${rcode}">>${sb}.txt
                     fi
                   else
                      echo $rq,$sj,"99",$sb,$iip,$gip,$nsip,$ndip,$sip,"${rtype}<-${rcode}">>${sb}.txt
                   fi
                 fi
               fi
              fi
            fi
          fi
        fi
      fi
    done
    
  done
  #----------------------------------------
  cat ${sb}.txt|sort
fi 
#cat gj.txt|grep $sb
