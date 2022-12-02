FROM ruby:3.0.0

ENV RAILS_ENV production
RUN mkdir /wordbook
RUN bundle config mirror.https://rubygems.org https://gems.ruby-china.com
# 一进来的工作目录
WORKDIR /wordbook
# ADD 会自动解压缩tar包
ADD wordbook-*.tar.gz ./
# 只安装生产环境的包
RUN bundle config set --local without 'development test'
RUN bundle install
# ENTRYPOINT 指当运行 docker run 的时候再执行后面的命令
ENTRYPOINT bundle exec puma