#!/bin/sh
export PATH='/etc/storage/bin:/tmp/script:/etc/storage/script:/opt/usr/sbin:/opt/usr/bin:/opt/sbin:/opt/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin'
export LD_LIBRARY_PATH=/lib:/opt/lib
output="$1"
url1="$2"
url2="$3"
check_n="$4"
check_lines="$5"

wget_err=""
curl_err=""

[ -z "$url1" ] && exit 0
[ -z "$url2" ] && url2="$url1"
[ -z "$output" ] && exit 0
[ -f "$output" ] && rm -f "$output"
mkdir -p $(dirname "$output")

mkdir -p /tmp/wait/a
mkdir -p /tmp/wait/b
mkdir -p /tmp/wait/check
pid0="$$"
hash wait 2>/dev/null && wait_x="1"
hash wait 2>/dev/null || wait_x="0"


check_newlines () {
if [ -f "$output" ] && [ ! -z "$check_lines" ] ; then
lines_nu="`cat $output | grep -v ! | wc -l`"
if [ $lines_nu -lt 5 ] ; then
	logger -t "【下载】" "错误！下载文件行数 $lines_nu ，重新下载。"
	[ -f "$output" ] && rm -f "$output"
fi
fi
}

check_avail () {
 line_path=`dirname $output`
avail=`check_disk_size $line_path`
if [ "$?" == "0" ] ; then
	#logger -t "【下载】" "$avail M 可用容量:【$line_path】" 
	echo "$avail M 可用容量:【$line_path】" 
else
	avail=0
	logger -t "【下载】" "错误！提取可用容量失败:【$line_path】" 
	return 1
fi
if [ "$avail" != "0" ] ; then
	#logger -t "【下载】" "$avail M 可用容量:【$line_path】" 
	echo "$avail M 可用容量:【$line_path】" 
else
	avail=0
	logger -t "【下载】" "$avail M 可用！提取可用容量失败:【$line_path】" 
	return 1
fi
	length=0
if [ ! -z "$(echo $url1 | grep 127.0.0.1)" ] || [ ! -z "$(grep "$url1" /tmp/check_avail_error.txt)" ] ; then
	length=0
else
	length_wget=$(wget  -T 5 -t 3 "$url1" -O /dev/null --spider --server-response 2>&1 | grep "[Cc]ontent-[Ll]ength" | grep -Eo '[0-9]+' | tail -n 1)
	[ ! -z "$length_wget" ] && length=$length_wget
	if [ -z "$length_wget" ] ; then
		#logger -t "【下载】" "错误！提取文件大小失败:【$url1】" 
		echo $url1 >> /tmp/check_avail_error.txt
		if [ ! -z "$(echo $url2 | grep 127.0.0.1)" ] || [ ! -z "$(grep "$url2" /tmp/check_avail_error.txt)" ] ; then
			length=0
		else
			length_wget=$(wget  -T 5 -t 3 "$url2" -O /dev/null --spider --server-response 2>&1 | grep "[Cc]ontent-[Ll]ength" | grep -Eo '[0-9]+' | tail -n 1)
			[ ! -z "$length_wget" ] && length=$length_wget
			if [ -z "$length_wget" ] ; then
				length=0
				#logger -t "【下载】" "错误！提取文件大小失败:【$url2】" 
				echo $url2 >> /tmp/check_avail_error.txt
				return 1
			fi
		fi
	fi
fi
if [ "$length" != "0" ] && [ "$avail" != "0" ] ; then
	length=`expr $length + 512000`
	length=`expr $length / 1048576`
	#logger -t "【下载】" "$length M 文件大小:【$url1】"
	echo "$length M 文件大小:【$url1】"
	if [ "$length" -gt "$avail" ] ; then
		logger -t "【下载】" "错误！剩余空间不足:【文件大小 $length M】>【$avail M 可用容量】"
		logger -t "【下载】" "跳过 下载【 $output 】"
		exit 1
	fi
fi
}

download_curl () {
if  [ "$wait_x" != "0" ] ; then
curl_path=$*
[ -f "$output" ] && rm -f "$output"
{ check="`$curl_path --user-agent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36' -L -s -w "%{http_code}" -o $output`" ; echo "$check" > /tmp/wait/check/$pid0 ; [ -f /tmp/wait/b/$pid0 ] && kill `cat /tmp/wait/b/$pid0` ; } &
pid1="$!"
echo $pid1 > /tmp/wait/a/$pid0
{ sleep 1800 ; echo "超时 1800s" ; [ -f /tmp/wait/a/$pid0 ] && kill `cat /tmp/wait/a/$pid0` ; } &
pid2="$!"
echo $pid2 > /tmp/wait/b/$pid0
wait 
check=`cat /tmp/wait/check/$pid0`
rm -f /tmp/wait/a/$pid0
rm -f /tmp/wait/b/$pid0
rm -f /tmp/wait/check/$pid0
else
check="`$curl_path --user-agent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36' -L -s -w "%{http_code}" -o $output`"
fi
[ "$check" != "200" ] && { curl_err="$check错误！" ; rm -f "$output" ; }
check_newlines

}

download_wget () {
if  [ "$wait_x" != "0" ] ; then
wget_path=$*
[ -f "$output" ] && rm -f "$output"
{ $wget_path --user-agent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36' -O $output -T "$pid0" -t 10 ; [ "$?" == "0" ] && check=200 || check=404 ; echo "$check" > /tmp/wait/check/$pid0 ; [ -f /tmp/wait/b/$pid0 ] && kill `cat /tmp/wait/b/$pid0` ; } &
pid1="$!"
echo $pid1 > /tmp/wait/a/$pid0
{ sleep 1800 ; echo "超时 1800s" ; [ -f /tmp/wait/a/$pid0 ] && kill `cat /tmp/wait/a/$pid0` ; kill_ps "T $pid0" ; } &
pid2="$!"
echo $pid2 > /tmp/wait/b/$pid0
wait 
check=`cat /tmp/wait/check/$pid0`
rm -f /tmp/wait/a/$pid0
rm -f /tmp/wait/b/$pid0
rm -f /tmp/wait/check/$pid0
else
$wget_path --user-agent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36' -O $output -T 10 -t 10
[ "$?" == "0" ] && check=200 || check=404 
fi
[ "$check" == "404" ] && { wget_err="$check错误！" ; rm -f "$output" ; }
check_newlines
}

kill_ps () {

COMMAND="$1"
if [ ! -z "$COMMAND" ] ; then
	eval $(ps -w | grep "$COMMAND" | grep -v "$$ " | grep -v grep | awk '{print "kill "$1";";}')
	eval $(ps -w | grep "$COMMAND" | grep -v "$$ " | grep -v grep | awk '{print "kill -9 "$1";";}')
fi
if [ "$2" == "exit0" ] ; then
	exit 0
fi
}

if [ "$check_n" != "N" ] ; then
	hash check_disk_size 2>/dev/null && check_avail
fi

[ -f "$output" ] && rm -f "$output"

if [ -s "/opt/bin/curl" ] && [ ! -s "$output" ] ; then
	[ -d "/opt/bin" ] && cd /opt/bin
	download_curl /opt/bin/curl $url1
	#
fi
if [ -s "/usr/sbin/curl" ] && [ ! -s "$output" ] ; then
	download_curl /usr/sbin/curl --capath /etc/ssl/certs $url1
	
fi
if [ -s "/opt/bin/wget" ] && [ ! -s "$output" ] ; then
	[ -d "/opt/bin" ] && cd /opt/bin
	download_wget /opt/bin/wget $url1
	
fi
if [ -s "/usr/bin/wget" ] &&  [ ! -s "$output" ] ; then
	download_wget /usr/bin/wget $url1
	
fi
if [ ! -s "$output" ] ; then
	logger -t "【下载】" "下载失败:【$output】 URL:【$url1】"
	logger -t "【下载】" "重新下载:【$output】 URL:【$url2】"
	if [ -s "/opt/bin/curl" ] && [ ! -s "$output" ] ; then
		[ -d "/opt/bin" ] && cd /opt/bin
		download_curl /opt/bin/curl $url2
		
	fi
	if [ -s "/usr/sbin/curl" ] && [ ! -s "$output" ] ; then
		download_curl /usr/sbin/curl --capath /etc/ssl/certs $url2
		
	fi
	if [ -s "/opt/bin/wget" ] && [ ! -s "$output" ] ; then
		[ -d "/opt/bin" ] && cd /opt/bin
		download_wget /opt/bin/wget $url2
		
	fi
	if [ -s "/usr/bin/wget" ] &&  [ ! -s "$output" ] ; then
		download_wget /usr/bin/wget $url2
		
	fi
fi

if [ ! -s "$output" ] ; then
	[ -f "$output" ] && rm -f "$output"
	logger -t "【下载】" "下载失败:【$output】 URL:【$url2】"
	[ ! -z "$curl_err" ] && logger -t "【下载】" "curl_err ：$check错误！"
	[ ! -z "$wget_err" ] && logger -t "【下载】" "wget_err ：$check错误！"
	return 1
else
	chmod 777 $output
	return 0
fi

