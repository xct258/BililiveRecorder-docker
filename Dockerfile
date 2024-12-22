FROM debian

# 设置中文环境
RUN apt-get update && apt-get install -y locales tzdata && rm -rf /var/lib/apt/lists/* \
    && localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8
ENV LANG zh_CN.UTF-8 
ENV TZ=Asia/Shanghai

# 安装必要的依赖项
RUN apt-get update \
    && apt-get install -y wget git curl nano jq tar \
    && echo '#!/bin/bash' >> /usr/local/bin/start.sh \
    && echo '/root/BililiveRecorder/BililiveRecorder.Cli run --bind "http://*:2356" --http-basic-user "xct258" --http-basic-pass "vR^u8EKkaoD8fb" "/src"' >> /usr/local/bin/start.sh \
    && echo 'tail -f /dev/null' >> /usr/local/bin/start.sh \
    && chmod +x /usr/local/bin/start.sh
    
ENTRYPOINT ["/usr/local/bin/start.sh"]
