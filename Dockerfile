FROM debian

# 设置中文环境
RUN apt-get update && apt-get install -y locales tzdata && rm -rf /var/lib/apt/lists/* \
    && localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8
ENV LANG zh_CN.UTF-8 
ENV TZ=Asia/Shanghai

# 安装必要的依赖项
RUN apt-get update \
    && apt-get install -y wget git curl nano jq bc tar xz-utils ffmpeg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /root/tmp \
    && cat << 'EOF' > /root/tmp/1.sh
#!/bin/bash
arch=$(uname -m | grep -i -E "x86_64|aarch64")
if [[ $arch == *"x86_64"* ]]; then
    wget -O /root/tmp/7zz.tar.xz https://www.7-zip.org/a/7z2409-linux-x64.tar.xz
    wget -O /root/tmp/BililiveRecorder-CLI.zip https://github.com/BililiveRecorder/BililiveRecorder/releases/latest/download/BililiveRecorder-CLI-linux-x64.zip
elif [[ $arch == *"aarch64"* ]]; then
    wget -O /root/tmp/7zz.tar.xz https://www.7-zip.org/a/7z2409-linux-arm64.tar.xz
    wget -O /root/tmp/BililiveRecorder-CLI.zip https://github.com/BililiveRecorder/BililiveRecorder/releases/latest/download/BililiveRecorder-CLI-linux-arm64.zip
fi
EOF
    && chmod +x /root/tmp/1.sh \
    && /root/tmp/1.sh \
    && tar -xf /root/tmp/7zz.tar.xz -C /root/tmp \
    && chmod +x /root/tmp/7zz \
    && mv /root/tmp/7zz /bin/7zz \
    && 7zz x /root/tmp/BililiveRecorder-CLI.zip -o/root/BililiveRecorder \
    && chmod +x /root/BililiveRecorder/BililiveRecorder.Cli \
    && rm -rf /root/tmp \
    && cat << 'EOF' > /usr/local/bin/start.sh
#!/bin/bash
if [ -f /root/.credentials ]; then
    source /root/.credentials
else
    if [ -z "$HTTP_BASIC_USER" ]; then
        HTTP_BASIC_USER="xct258"
        echo "HTTP_BASIC_USER=\"$HTTP_BASIC_USER\"" >> /root/.credentials
        echo "没有指定用户名，可以通过HTTP_BASIC_USER变量指定，当前用户名:"
        echo "$HTTP_BASIC_USER"
    fi
    if [ -z "$HTTP_BASIC_PASS" ]; then
        HTTP_BASIC_PASS=$(openssl rand -base64 12)
        echo "HTTP_BASIC_PASS=\"$HTTP_BASIC_PASS\"" >> /root/.credentials
        echo "没有指定密码，可以通过HTTP_BASIC_PASS变量指定，当前密码（随机）:"
        echo "$HTTP_BASIC_PASS"
    fi
fi
/root/BililiveRecorder/BililiveRecorder.Cli run --bind "http://*:2356" --http-basic-user "$HTTP_BASIC_USER" --http-basic-pass "$HTTP_BASIC_PASS" "/rec" &

# 检查备份脚本是否存在
if [ -f "$FILE_BACKUP_SH" ]; then
    chmod +x "$FILE_BACKUP_SH"
    echo "备份脚本执行中"
    # 创建调度脚本
    SCHEDULER_SCRIPT="/usr/local/bin/执行视频备份脚本.sh"
    cat << 'BACKUP_EOF' > "$SCHEDULER_SCRIPT"
#!/bin/bash
schedule_sleep_time="04:00"
while true; do
    "$FILE_BACKUP_SH" > /rec/backup.log 2>&1
    current_date=$(date +%Y-%m-%d)
    target_time="${current_date} $schedule_sleep_time"
    time_difference=$(( $(date -d "${target_time}" +%s) - $(date +%s) ))
    if [[ ${time_difference} -lt 0 ]]; then
        time_difference=$(( ${time_difference} + 86400 ))
    fi
    sleep ${time_difference}
done
BACKUP_EOF
    chmod +x "$SCHEDULER_SCRIPT"
    $SCHEDULER_SCRIPT
else
    echo "备份脚本不存在，可以通过FILE_BACKUP_SH变量指定一个sh脚本来备份录制的视频"
fi
tail -f /dev/null
EOF
    && chmod +x /usr/local/bin/start.sh

ENTRYPOINT ["/usr/local/bin/start.sh"]
