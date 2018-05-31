#!/bin/bash
#remote config
uploadip="113.31.89.144:8092"
remote_dir="/fileserver/recordUpload"

#local config
rtp_path=/data/record
wav_path=${rtp_path}/wav
mkdir -p ${wav_path}

#get sh path
cd `dirname $0`
sh_path=$(pwd)

exec 1>>${sh_path}/$(date +%Y%m%d).log
exec 2>>${sh_path}/$(date +%Y%m%d).log

#log redict to sh path
log2file(){
   echo "$(date +%T)  $1 $2 $3 $4 $5" >> ${sh_path}/$(date +%Y%m%d).log
}

log2file "INFO:""sh_path is ${sh_path}"

cd ${rtp_path}
all_files_rtp=$(ls *.rtp | cut -d'_'  -f1-3| sort -n | uniq)
sid_rtp="9b9b1beaa0e8ba3e72e3b5cd5614b925"


if [ -z "${all_files_rtp}" ];then
    log2file "INFO:""no file to mix"
else
	log2file "INFO:""mix rtplist:${all_files_rtp}"
fi

for mix_name in ${all_files_rtp}
do 

     A_rtp=${mix_name}_a.rtp
     B_rtp=${mix_name}_b.rtp
	 
     if [ -f ${A_rtp} -a  -f ${B_rtp} ];then
		temp_sid=$(${mix_name} | cat -b 1-32)
		
		if [ ${sid_rtp} -eq ${temp_sid}];then
		
	        filename1=$(${mix_name} | cut -d'_'  -f1-2)
			filename2=$(${mix_name} | cut -d'_'  -f3-)
			filename_a=${filename1}a_${filename2}.rtp
			filename_b=${filename1}b_${filename2}.rtp
			mv ${A_rtp} ${filename_a}
			mv ${B_rtp} ${filename_b}
			
			curl -F "filename=@${filename_a}" http://${uploadip}${remote_dir}
			curl -F "filename=@${filename_b}" http://${uploadip}${remote_dir}
		else
	 
         log2file "INFO:""start to mix" "${A_rtp}"  "${B_rtp}" "to ${mix_name}.wav"
         ${sh_path}/mixer_tool ${A_rtp} ${B_rtp} ${wav_path}/${mix_name}.wav
	     #if [ "$?" = "0" ];then
            #log2file "ERROR:""mix" "${A_rtp}"  "${B_rtp}" "to ${mix_name}.wav fail"
		 #else
		    log2file "INFO:""mix" "${A_rtp}"  "${B_rtp}" "to ${mix_name}.rtp" "suc"
         #fi
            rm -f ${A_rtp} ${B_rtp} 
		fi
	 elif [ -f ${A_rtp} ];then
		log2file "WARN:""miss b ${mix_name}_b.rtp"
	 else 
	    log2file "WARN:""miss a ${mix_name}_a.rtp"
     fi 

done  

cd ${wav_path}
send_files_rtp=$(ls *.wav | cut -d'.'  -f1 | sort -n | uniq)

if [ -z "${send_files_rtp}" ];then
    log2file "INFO:""no wav to curl"
	exit
else
	log2file "INFO:""send wavlist:${send_files_rtp}"
fi

for record_name in $send_files_rtp
do

     record_rtp=${record_name}.wav

     if [ -f ${record_rtp} ];then

            log2file "INFO:""start to upload" "${record_rtp}" "to ${uploadip}"

            #upload
			ret=$(curl -s --connect-timeout 2 -m 5 -F "filename=@${record_rtp}" http://${uploadip}${remote_dir})
            if [ "${ret}" = "0" ];then
			   rm -f ${record_rtp}
			   log2file "INFO:""upload" "${record_rtp}" "to ${uploadip}" "suc"
			else
               log2file "ERROR:""upload" "${record_rtp}" "to ${uploadip}" "fail"
            fi
	 else
	    log2file "ERROR:""upload ${record_rtp} but no exsit!!"
     fi 

done
