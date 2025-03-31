# 录播姬和biliup的docker镜像
启动示例：
```
docker run -d   \
    --name debian-bililive   \
    -e Bililive_USER=xct258  `# 录播姬默认用户名xct258`  \
    -e Bililive_PASS=xct258  `# 录播姬默认随机密码`  \
    -e Biliup_PASS=xct258  `# biliup默认用户名为biliup不可指定，biliup默认随机密码`  \
    -v /home/xct258/bililive:/rec  \
    -e FILE_BACKUP_SH=录播上传备份脚本.sh `# 设置备份脚本的容器内路径，默认为容器/rec目录下，如果不需要备份则留空`  \
    -p 2356:2356 `# 录播姬默认端口`  \
    -p 19159:19159 `# biliup默认端口` \
    xct258/debian-bililive
```

录播姬
文件名模板：
video/{{ name}}/{{ "now" | time_zone: "Asia/Shanghai" | format_date: "yyy-MM-dd" }}/{{ "now" | time_zone: "Asia/Shanghai" | format_date: "录播姬_yyy年MM月dd日HH点mm分" }}_{{ title }}_{{ name}}.flv
示例：录播姬/video/高机动持盾军官/2024-12-01/录播姬_2024年12月01日22点13分_暗区最穷_高机动持盾军官.flv

需要cookies录制原画，格式为：
SESSDATA=;DedeUserID=;DedeUserID__ckMd5=

biliup
