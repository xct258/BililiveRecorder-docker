FROM debian

# 设置中文环境
RUN apt-get update && apt-get install -y locales tzdata && rm -rf /var/lib/apt/lists/* \
    && localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8
ENV LANG zh_CN.UTF-8 
ENV TZ=Asia/Shanghai

# 安装必要的依赖项
RUN apt-get update
    apt-get install -y wget git curl nano jq tar xz-utils
    mkdir -p /root/tmp
    echo '#!/bin/bash' >> /root/tmp/1.sh
    echo 'arch=$(uname -m | grep -i -E "x86_64|aarch64")' >> /root/tmp/1.sh
    echo 'if [[ $arch == *"x86_64"* ]]; then' >> /root/tmp/1.sh
    echo     'wget -O /root/tmp/7zz.tar.xz https://www.7-zip.org/a/7z2409-linux-x64.tar.xz' >> /root/tmp/1.sh
    echo     'wget -O /root/tmp/BililiveRecorder-CLI.zip https://github.com/BililiveRecorder/BililiveRecorder/releases/latest/download/BililiveRecorder-CLI-linux-x64.zip' >> /root/tmp/1.sh
    echo 'elif [[ $arch == *"aarch64"* ]]; then' >> /root/tmp/1.sh
    echo     'wget -O /root/tmp/7zz.tar.xz https://www.7-zip.org/a/7z2409-linux-arm64.tar.xz' >> /root/tmp/1.sh
    echo     'wget -O /root/tmp/BililiveRecorder-CLI.zip https://github.com/BililiveRecorder/BililiveRecorder/releases/latest/download/BililiveRecorder-CLI-linux-arm64.zip' >> /root/tmp/1.sh
    echo 'fi' >> /root/tmp/1.sh
    chmod +x /root/tmp/1.sh
    /root/tmp/1.sh
    tar -xf /root/tmp/7zz.tar.xz -C /root/tmp
    chmod +x /root/tmp/7zz
    mv /root/tmp/7zz /bin/7zz
    7zz x /root/tmp/BililiveRecorder-CLI.zip -o/root/BililiveRecorder
    chmod +x /root/BililiveRecorder/BililiveRecorder.Cli
    rm -rf /root/tmp
    echo '#!/bin/bash' >> /usr/local/bin/start.sh
    echo '/root/BililiveRecorder/BililiveRecorder.Cli run --bind "http://*:2356" --http-basic-user "xct258" --http-basic-pass "vR^u8EKkaoD8fb" "/src"' >> /usr/local/bin/start.sh
    echo 'tail -f /dev/null' >> /usr/local/bin/start.sh
    chmod +x /usr/local/bin/start.sh

ENTRYPOINT ["/usr/local/bin/start.sh"]
