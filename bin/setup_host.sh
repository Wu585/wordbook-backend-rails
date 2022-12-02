DB_PASSWORD=123456
container_name=wordbook-prod-1

# 执行该脚本的目录要注意
version=$(cat wordbook_deploy/version)

echo 'docker build ...'
docker build wordbook_deploy -t wordbook:$version
if [ "$(docker ps -aq -f name=^wordbook-prod-1$)" ]; then
  echo 'docker rm ...'
  docker rm -f $container_name
fi
echo 'docker run ...'
docker run -e DB_HOST=$DB_HOST -e RAILS_MASTER_KEY=$RAILS_MASTER_KEY -d -p 3060:3060 --network=network1 -e DB_PASSWORD=$DB_PASSWORD --name=$container_name wordbook:$version bash
echo 'DONE!'