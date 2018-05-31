#!/bin/bash

#code:key1088
#mail:key1088#163.com
#version 0.1
#bash --version
#GNU bash, version 3.2.25(1)-release (i686-redhat-linux-gnu)
#Copyright (C) 2005 Free Software Foundation, Inc

if [ $(whoami) != "root" ];
then
        echo "Not root"
        exit 0
fi

xlkmroot=/usr/local/xlkm

help(){
echo -e "\033[32m List:"
echo "[1.Start LKM List Backup]"
echo "[2.Test LKM List Change]"
echo "[3.Delete All Backup]"
echo "[4.Quit]"
echo -e "\033[0m"
}

SETUPXLKM(){
        if test -d $xlkmroot ;then
                echo "LKM exist Backup!!"
                exit 1
        fi
        mkdir $xlkmroot
        chmod 700 $xlkmroot
}

DELXLKM(){
        rm -rf $xlkmroot
        echo
        echo -e "\033[34mDelete XLKM Backup Sccessfully\033[0m"
        echo
}

START(){
        while [ -z $passwd ]
        do
                echo
                echo -n "Input encrypt passwd[No Null]:"
                read passwd
        done
        echo "WAITing....."
        lsmod > $xlkmroot/lkmlist.main
        for i in $(modprobe -l)
        do
                md5sum $i >> $xlkmroot/lkmfile.md5.main
        done
        cd $xlkmroot
        zip -P $passwd mainfile.zip ./*.main > /dev/null
        rc=$?
        if [ "$rc" == 0 ];
        then
                echo
                echo -e "\033[34mLKM List Backup Successfully!\033[0m"
                echo 
        else
                echo
                echo -e "\033[34mBeijule! Error!\033[0m"
                echo 
        fi
        rm -f $xlkmroot/lkm* > /dev/null        
}

LKMCHANGE(){
        echo "Test LKM Change"

        cd $xlkmroot
        while [ "$ra" != 0 ]
        do
                echo
                echo -n "Input encrypt passwd[No Null]:"
                read passwd
                unzip -P $passwd mainfile.zip > /dev/null 2>&1
                ra=$?
                if [ "$ra" != 0 ];then echo "Invalid password!! "; fi
        done
        echo "WAITing....."
        lsmod > $xlkmroot/lkmlist.new
        for i in $(modprobe -l)
        do
                md5sum $i >> $xlkmroot/lkmfile.md5.new
        done
        echo "LKM List Change:"
        echo -e "\033[31m"
        diff $xlkmroot/lkmlist.main $xlkmroot/lkmlist.new
        echo -e "\033[0m"
        echo "LKM File Md5 Change:"
        echo -e "\033[31m"
        diff $xlkmroot/lkmfile.md5.main $xlkmroot/lkmfile.md5.new
        echo -e "\033[0m"
        rm -f *.new *.main

}

while :
do

help
echo -n "Input List num:"
read x

case "$x" in
1)
        SETUPXLKM
        START
;;
2)
        LKMCHANGE
;;
3)
        DELXLKM
;;
4)
        exit 0
;;
*)
        echo -e "\033[31mError !!!!!"
        echo -e "Pleae input [1-4] list option \033[0m"
;;
esac

done