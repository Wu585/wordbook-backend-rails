user=wordbook
root=/home/$user/deploys/$version
container_name=wordbook-prod-1
nginx_container_name=wordbook-nginx-1
db_container_name=db-for-wordbook

function set_env {
  name=$1
  hint=$2
  [[ ! -z "${!name}" ]] && return
  while [ -z "${!name}" ]; do
    [[ ! -z "$hint" ]] && echo "> 请输入 $name: $hint" || echo "> 请输入 $name:"
    read $name
  done
  sed -i "1s/^/export $name=${!name}\n/" ~/.bashrc
  echo "${name} 已保存至 ~/.bashrc"
}
function title {
  echo
  echo "###############################################################################"
  echo "## $1"
  echo "###############################################################################"
  echo
}

title '设置远程机器的环境变量'
set_env DB_HOST
set_env DB_PASSWORD
set_env RAILS_MASTER_KEY

title '创建数据库'
if [ "$(docker ps -aq -f name=^${DB_HOST}$)" ]; then
  echo '已存在数据库'
else
  docker run -d --name $DB_HOST \
            --network=network1 \
            -p 5432:5432 \
            -e POSTGRES_USER=wordbook \
            -e POSTGRES_DB=wordbook_production \
            -e POSTGRES_PASSWORD=$DB_PASSWORD \
            -e PGDATA=/var/lib/postgresql/data/pgdata \
            -v wordbook-data:/var/lib/postgresql/data \
            postgres:14
  echo '创建成功'
fi

title 'app: docker build'
docker build $root -t wordbook:$version

if [ "$(docker ps -aq -f name=^wordbook-prod-1$)" ]; then
  title 'app: docker rm'
  docker rm -f $container_name
fi

title 'app: docker run'
docker run -d -p 3060:3060 \
           --network=network1 \
           --name=$container_name \
           -e DB_HOST=$DB_HOST \
           -e DB_PASSWORD=$DB_PASSWORD \
           -e RAILS_MASTER_KEY=$RAILS_MASTER_KEY \
           wordbook:$version

echo
echo "是否要更新数据库？[y/N]"
read ans
case $ans in
    y|Y|1  )  echo "yes"; title '更新数据库'; docker exec $container_name bin/rails db:create db:migrate ;;
    n|N|2  )  echo "no" ;;
    ""     )  echo "no" ;;
esac

if [ "$(docker ps -aq -f name=^${nginx_container_name}$)" ]; then
  title 'doc: docker rm'
  docker rm -f $nginx_container_name
fi

title 'doc: docker run'
cd /home/$user/deploys/$version
mkdir ./dist
tar xf dist.tar.gz --directory=./dist
cd -
docker run -d -p 8888:80 \
           --network=network1 \
           --name=$nginx_container_name \
           -v /home/$user/deploys/$version/nginx.default.conf:/etc/nginx/conf.d/default.conf \
           -v /home/$user/deploys/$version/dist:/usr/share/nginx/html \
           -v /home/$user/deploys/$version/api:/usr/share/nginx/html/apidoc \
           nginx:latest

title '全部执行完毕'