# 录播姬的docker镜像
启动示例：
```
docker run -d   \
    --name debian-bililive   \
    -e Bililive_USER=xct258  `# 录播姬默认用户名xct258`  \
    -e Bililive_PASS=xct258  `# 录播姬默认随机密码`  \
    -e Biliup_PASS=xct258  `# biliup用户名默认为biliup不可指定，默认随机密码`  \
    -v /home/xct258/bililive:/rec  \
    -e FILE_BACKUP_SH=/rec/录播姬视频备份脚本.sh `# 设置备份脚本的容器内路径，如果不需要备份则留空`  \
    -p 2356:2356 `# 录播姬默认端口`  \
    -p 19159:19159 `# biliup默认端口` \
    xct258/debian-bililive
```
