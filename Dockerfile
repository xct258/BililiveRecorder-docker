FROM debian

# 设置中文环境
RUN apt-get update && apt-get install -y locales tzdata && rm -rf /var/lib/apt/lists/* \
    && localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8
ENV LANG zh_CN.UTF-8 
ENV TZ=Asia/Shanghai

# 安装必要的依赖项
RUN apt-get update \
    && apt-get install -y wget git curl nano jq tar xz-utils \
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
    && echo '        echo HTTP_BASIC_USER="xct258" >> /root/.credentials' >> /usr/local/bin/start.sh \
    && echo '        echo "用户名: $HTTP_BASIC_USER"' >> /usr/local/bin/start.sh \
    && echo '    fi' >> /usr/local/bin/start.sh \
    && echo '    if [ -z "$HTTP_BASIC_PASS" ]; then' >> /usr/local/bin/start.sh \
    && echo '        HTTP_BASIC_PASS=$(openssl rand -base64 12)' >> /usr/local/bin/start.sh \
    && echo '        echo HTTP_BASIC_PASS="$HTTP_BASIC_PASS" >> /root/.credentials' >> /usr/local/bin/start.sh \
    && echo '        echo "密码: $HTTP_BASIC_PASS"' >> /usr/local/bin/start.sh \
    && echo '    fi' >> /usr/local/bin/start.sh \
    && echo 'fi' >> /usr/local/bin/start.sh \
    && echo '/root/BililiveRecorder/BililiveRecorder.Cli run --bind "http://*:2356" --http-basic-user "$HTTP_BASIC_USER" --http-basic-pass "$HTTP_BASIC_PASS" "/rec"' >> /usr/local/bin/start.sh \
    && echo 'tail -f /dev/null' >> /usr/local/bin/start.sh \
    && chmod +x /usr/local/bin/start.sh

ENTRYPOINT ["/usr/local/bin/start.sh"]
