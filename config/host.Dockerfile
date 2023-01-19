FROM ruby:3.0.0

ENV RAILS_ENV production
RUN mkdir /wordbook
RUN bundle config mirror.https://rubygems.org https://gems.ruby-china.com
# 一进来的工作目录
WORKDIR /wordbook
ADD Gemfile /wordbook
ADD Gemfile.lock /wordbook
# 把服务器目录下的依拷贝到容器的/wordbook/vendor目录下
ADD vendor/cache.tar.gz /wordbook/vendor/
ADD vendor/rspec_api_documentation.tar.gz /wordbook/vendor/
# 只安装生产环境的包
RUN bundle config set --local without 'development test'
# --local指的是用本地/vendor目录下的cache依赖
RUN bundle install --local

# ADD 会自动解压缩tar包
ADD wordbook-*.tar.gz ./
# ENTRYPOINT 指当运行 docker run 的时候再执行后面的命令
ENTRYPOINT bundle exec puma