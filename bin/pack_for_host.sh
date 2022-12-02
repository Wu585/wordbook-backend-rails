# 注意修改 oh-my-env 目录名为你的目录名
dir=oh-my-env

# 时间戳
time=$(date +'%Y%m%d-%H%M%S')
dist=tmp/wordbook-$time.tar.gz
current_dir=$(dirname $0)
deploy_dir=/root/tmp/workspaces/$dir/wordbook_deploy

yes | rm tmp/wordbook-*.tar.gz;
yes | rm $deploy_dir/wordbook-*.tar.gz;


# 打包项目代码到tmp目录下，文件名为 workbook-$time.tar.gz
tar --exclude="tmp/cache/*" -czv -f $dist *
# -p 如果中间目录不存在，自动创建
mkdir -p $deploy_dir
# 拷贝dockerfile
cp $current_dir/../config/host.Dockerfile $deploy_dir/Dockerfile
# 拷贝部署脚本
cp $current_dir/setup_host.sh $deploy_dir/
# 移动tar包至共享目录 /root/tmp
mv $dist $deploy_dir
# 添加个版本文件
echo $time > $deploy_dir/version
echo 'DONE!'