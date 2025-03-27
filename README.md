# 录播姬的docker镜像
启动示例：
```
docker run -d   \
    --name debian-bililive   \
    -e HTTP_BASIC_USER=用户名  `# 默认为xct258`  \
    -e HTTP_BASIC_PASS=密码  `# 默认随机密码`  \
    -e FILE_BACKUP_SH=/rec/录播姬视频备份脚本.sh `# 设置备份脚本的容器内路径，如果不需要备份则留空`  \
    -p 2356:2356   \
    -v /home/xct258/录播姬:/rec   \
    xct258/bililive
```
