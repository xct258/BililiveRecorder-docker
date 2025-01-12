FROM debian

# 设置中文环境
RUN apt-get update && apt-get install -y locales tzdata && rm -rf /var/lib/apt/lists/* \
    && localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8
ENV LANG zh_CN.UTF-8 
ENV TZ=Asia/Shanghai

# 安装必要的依赖项
RUN apt-get update \
    && apt-get install -y wget git curl nano jq bc tar xz-utils ffmpeg \
    && mkdir -p /root/tmp \
    && echo '#!/bin/bash' >> /root/tmp/1.sh \
    && echo 'arch=$(uname -m | grep -i -E "x86_64|aarch64")' >> /root/tmp/1.sh \
    && echo 'if [[ $arch == *"x86_64"* ]]; then' >> /root/tmp/1.sh \
    && echo     'wget -O /root/tmp/7zz.tar.xz https://www.7-zip.org/a/7z2409-linux-x64.tar.xz' >> /root/tmp/1.sh \
    && echo     'wget -O /root/tmp/BililiveRecorder-CLI.zip https://github.com/BililiveRecorder/BililiveRecorder/releases/latest/download/BililiveRecorder-CLI-linux-x64.zip' >> /root/tmp/1.sh \
    && echo 'elif [[ $arch == *"aarch64"* ]]; then' >> /root/tmp/1.sh \
    && echo     'wget -O /root/tmp/7zz.tar.xz https://www.7-zip.org/a/7z2409-linux-arm64.tar.xz' >> /root/tmp/1.sh \
    && echo     'wget -O /root/tmp/BililiveRecorder-CLI.zip https://github.com/BililiveRecorder/BililiveRecorder/releases/latest/download/BililiveRecorder-CLI-linux-arm64.zip' >> /root/tmp/1.sh \
    && echo 'fi' >> /root/tmp/1.sh \
    && chmod +x /root/tmp/1.sh \
    && /root/tmp/1.sh \
    && tar -xf /root/tmp/7zz.tar.xz -C /root/tmp \
    && chmod +x /root/tmp/7zz \
    && mv /root/tmp/7zz /bin/7zz \
    && 7zz x /root/tmp/BililiveRecorder-CLI.zip -o/root/BililiveRecorder \
    && chmod +x /root/BililiveRecorder/BililiveRecorder.Cli \
    && rm -rf /root/tmp \
    && echo '#!/bin/bash' >> /usr/local/bin/start.sh \
    && echo 'if [ -f /root/.credentials ]; then' >> /usr/local/bin/start.sh \
    && echo '    source /root/.credentials' >> /usr/local/bin/start.sh \
    && echo 'else' >> /usr/local/bin/start.sh \
    && echo '    if [ -z "$HTTP_BASIC_USER" ]; then' >> /usr/local/bin/start.sh \
    && echo '        HTTP_BASIC_USER="xct258"' >> /usr/local/bin/start.sh \
    && echo '        echo HTTP_BASIC_USER="$HTTP_BASIC_USER" >> /root/.credentials' >> /usr/local/bin/start.sh \
    && echo '        echo "没有指定用户名，可以通过HTTP_BASIC_USER变量指定，当前用户名:"' >> /usr/local/bin/start.sh \
    && echo '        echo "$HTTP_BASIC_USER"' >> /usr/local/bin/start.sh \
    && echo '    fi' >> /usr/local/bin/start.sh \
    && echo '    if [ -z "$HTTP_BASIC_PASS" ]; then' >> /usr/local/bin/start.sh \
    && echo '        HTTP_BASIC_PASS=$(openssl rand -base64 12)' >> /usr/local/bin/start.sh \
    && echo '        echo HTTP_BASIC_PASS="$HTTP_BASIC_PASS" >> /root/.credentials' >> /usr/local/bin/start.sh \
    && echo '        echo "没有指定密码，可以通过HTTP_BASIC_PASS变量指定，当前密码（随机）:"' >> /usr/local/bin/start.sh \
    && echo '        echo "$HTTP_BASIC_PASS"' >> /usr/local/bin/start.sh \
    && echo '    fi' >> /usr/local/bin/start.sh \
    && echo 'fi' >> /usr/local/bin/start.sh \
    && echo '/root/BililiveRecorder/BililiveRecorder.Cli run --bind "http://*:2356" --http-basic-user "$HTTP_BASIC_USER" --http-basic-pass "$HTTP_BASIC_PASS" "/rec" &' >> /usr/local/bin/start.sh \
    && echo '# 检查备份脚本是否存在' >> /usr/local/bin/start.sh \
    && echo 'if [ -f "$FILE_BACKUP_SH" ]; then' >> /usr/local/bin/start.sh \
    && echo '    chmod +x "$FILE_BACKUP_SH"' >> /usr/local/bin/start.sh \
    && echo '    echo "备份脚本执行中"' >> /usr/local/bin/start.sh \
    && echo '    # 创建调度脚本' >> /usr/local/bin/start.sh \
    && echo '    SCHEDULER_SCRIPT="/usr/local/bin/执行视频备份脚本.sh"' >> /usr/local/bin/start.sh \
    && echo '    echo '#!/bin/bash' > "$SCHEDULER_SCRIPT"' >> /usr/local/bin/start.sh \
    && echo '    echo 'schedule_sleep_time="04:00"' > "$SCHEDULER_SCRIPT"' >> /usr/local/bin/start.sh \
    && echo '    echo 'while true; do' >> "$SCHEDULER_SCRIPT"' >> /usr/local/bin/start.sh \
    && echo '    echo '    \"$FILE_BACKUP_SH\" > /rec/backup.log 2>&1' >> "$SCHEDULER_SCRIPT"' >> /usr/local/bin/start.sh \
    && echo '    echo '    current_date=$(date +%Y-%m-%d) '>> "$SCHEDULER_SCRIPT"' >> /usr/local/bin/start.sh \
    && echo '    echo '    target_time="${current_date} $schedule_sleep_time"' >> "$SCHEDULER_SCRIPT"' >> /usr/local/bin/start.sh \
    && echo '    echo '    time_difference=$(( $(date -d "${target_time}" +%s) - $(date +%s) ))' >> "$SCHEDULER_SCRIPT"' >> /usr/local/bin/start.sh \
    && echo '    echo '    if [[ ${time_difference} -lt 0 ]]; then' >> "$SCHEDULER_SCRIPT"' >> /usr/local/bin/start.sh \
    && echo '    echo '        time_difference=$(( ${time_difference} + 86400 ))' >> "$SCHEDULER_SCRIPT"' >> /usr/local/bin/start.sh \
    && echo '    echo '    fi' >> "$SCHEDULER_SCRIPT"' >> /usr/local/bin/start.sh \
    && echo '    echo '    sleep ${time_difference}' >> "$SCHEDULER_SCRIPT"' >> /usr/local/bin/start.sh \
    && echo '    echo 'done' >> "$SCHEDULER_SCRIPT"' >> /usr/local/bin/start.sh \
    && echo '    chmod +x "$SCHEDULER_SCRIPT"' >> /usr/local/bin/start.sh \
    && echo '    $SCHEDULER_SCRIPT' >> /usr/local/bin/start.sh \
    && echo 'else' >> /usr/local/bin/start.sh \
    && echo '    echo "备份脚本不存在，可以通过FILE_BACKUP_SH变量指定一个sh脚本来备份录制的视频"' >> /usr/local/bin/start.sh \
    && echo 'fi' >> /usr/local/bin/start.sh \
    && echo 'tail -f /dev/null' >> /usr/local/bin/start.sh \
    && chmod +x /usr/local/bin/start.sh

ENTRYPOINT ["/usr/local/bin/start.sh"]
