FROM ruby:2.6

RUN mkdir /broken-record
WORKDIR /broken-record

ADD . /broken-record

RUN gem install bundler:2.1.4
RUN bundle install
