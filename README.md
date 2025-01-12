# 录播姬的docker镜像
启动示例：
```
docker run -d   \
    --name debian-bililiverecorder   \
    # 设置备份脚本的容器内路径，如果不需要备份则留空
    -e FILE_BACKUP_SH=/rec/录播姬视频备份脚本.sh   \
    -p 2356:2356   \
    -v /home/xct258/录播姬:/rec   \
    xct258/debian-bililiverecorder
```
