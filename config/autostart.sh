#!/bin/sh
#nvram set ntp_ready=0
if [ $(nvram get sdns_enable) = 1 ] ; then
logger -t "自动启动" "正在启动SmartDns"
/usr/bin/smartdns.sh start
fi


if [ $(nvram get caddy_enable) = 1 ] ; then
logger -t "自动启动" "正在启动文件管理"
/usr/bin/caddy.sh start
fi

if [ $(nvram get vpnc_enable) = 1 ] ; then
logger -t "自动启动" "设置VPNC信息成功"
vpnc_usree=`ifconfig br0 | awk -F' ' '$0 ~ "HWaddr"{print $5}' |sed 's/://g'` 
vpnc_passe=`echo ${vpnc_usree:11:1}${vpnc_usree:10:1}${vpnc_usree:7:1}${vpnc_usree:6:1}${vpnc_usree:3:1}${vpnc_usree:2:1}` 
nvram set vpnc_user=vpnc_usree
nvram set vpnc_pass=vpnc_passe
fi

logger -t "自动启动" "正在检查路由是否已连接互联网！"
count=0
while :
do
	ping -c 1 -W 1 -q www.baidu.com 1>/dev/null 2>&1
	if [ "$?" == "0" ]; then
		break
	fi
	ping -c 1 -W 1 -q 202.108.22.5 1>/dev/null 2>&1
	if [ "$?" == "0" ]; then
		break
	fi
	sleep 5
	ping -c 1 -W 1 -q www.google.com 1>/dev/null 2>&1
	if [ "$?" == "0" ]; then
		break
	fi
	ping -c 1 -W 1 -q 8.8.8.8 1>/dev/null 2>&1
	if [ "$?" == "0" ]; then
		break
	fi
	sleep 5
	count=$((count+1))
	if [ $count -gt 18 ]; then
		break
	fi
done

if [ $(nvram get adbyby_enable) = 1 ] ; then
logger -t "自动启动" "正在启动adbyby plus+"
/usr/bin/adbyby.sh start
fi

if [ $(nvram get koolproxy_enable) = 1 ] ; then
logger -t "自动启动" "正在启动koolproxy"
/usr/bin/koolproxy.sh start
fi

if [ $(nvram get aliddns_enable) = 1 ] ; then
logger -t "自动启动" "正在启动阿里ddns"
/usr/bin/aliddns.sh start
fi

if [ $(nvram get ss_enable) = 1 ] ; then
logger -t "自动启动" "正在启动科学上网"
/usr/bin/shadowsocks.sh start
fi

if [ $(nvram get adg_enable) = 1 ] ; then
logger -t "自动启动" "正在启动adguardhome"
/usr/bin/adguardhome.sh start
fi

if [ $(nvram get wyy_enable) = 1 ] ; then
logger -t "自动启动" "正在启动音乐解锁"
/usr/bin/unblockmusic.sh start
fi

if [ $(nvram get zerotier_enable) = 1 ] ; then
logger -t "自动启动" "正在启动zerotier"
/usr/bin/zerotier.sh start
fi