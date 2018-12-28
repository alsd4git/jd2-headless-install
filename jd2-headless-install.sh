if [ "$(whoami)" == "root" ] ; then
    echo "You are root, good."
else
    echo "Please run this script with sudo"
    exit 1
fi

if [ ! -f "/opt/jd2/JDownloader.jar" ]; then
    echo "Start to download JDownloader2"
    apt-get update
    apt-get install openjdk-8-jre openjdk-8-jre-headless openjdk-8-jdk pv
    #apt-get install -f

    jd2jar="http://installer.jdownloader.org/JDownloader.jar"

    mkdir /opt/jd2
    cd /opt/jd2
#    jd2jar='https://mega.nz/#!2A0EiA6B!wS9K4_31luGG4HzClQlnVpfRpbtCSdYkiqsUIXE6_c0'
#    git clone https://github.com/tonikelope/megadown.git
#    chmod +x /opt/jd2/megadown/megadown
#    /opt/jd2/megadown/megadown $jd2jar -o /opt/jd2/JDownloader.jar

    wget -O /opt/jd2/JDownloader.jar $jd2jar
    chmod -R 777 /opt/jd2
fi

if [ ! -f "/lib/systemd/system/jdownloader2.service" ]; then
echo "Build system service for JDownloader2"

cat << EOF > /opt/jd2/jd2.sh
#!/bin/bash
#/usr/bin/java -Djava.awt.headless=true -jar /opt/jd2/JDownloader.jar
kill $(cat /opt/jd2/JDownloader.pid)

if [ ! -f '/opt/jd2/JDownloader.jar' ]; then
cp /opt/jd2/JDownloader.jar.backup.1 /opt/jd2/JDownloader.jar
fi
/usr/bin/java -jar /opt/jd2/JDownloader.jar $1
EOF

cat << EOF > /lib/systemd/system/jdownloader2.service
[Unit]
Description=JDownloader2 without GUI
[Service]
ExecStart=/opt/jd2/jd2.sh
StandardOutput=null
[Install]
WantedBy=multi-user.target
Alias=jdownloader2.service
EOF
#Add:
#User=pi
#Group=users
#in [Service] section if you want to run jd2 as a different user than root

fi

configfile="/opt/jd2/cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json"

configured="0"

while [ $configured -lt 1 ]
do
if [ ! -f /opt/jd2/JDownloader.jar ]; then
    configured=2
fi

if [ ! -f $configfile ] || [ $(less $configfile | grep '"email" : null') ]; then
    echo "Configure JDownloader2"
    java -jar /opt/jd2/JDownloader.jar -norestart
    sleep 10
else
    configured=2
fi
done


chmod -R 777 /opt/jd2

echo "Now please run:"
echo "sudo systemctl enable jdownloader2.service"
echo "sudo systemctl start jdownloader2.service"