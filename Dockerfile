FROM nrel/openstudio:latest

RUN mkdir /code 
COPY ./Gemfile-Docker /code/Gemfile
WORKDIR /code

RUN gem install openstudio-model-articulation --no-ri --no-rdoc
RUN gem install openstudio-standards --no-ri --no-rdoc
RUN bundle install

RUN mkdir /code/src
COPY ./lib /code/src/lib/
COPY ./assets /code/src/assets/
COPY ./superstudio.gemspec /code/src/

WORKDIR /code/src
RUN gem build superstudio.gemspec
RUN gem install superstudio-0.1.0.gem

RUN mkdir ~/.superstudio
COPY ./bin/superstudio-settings.json /root/.superstudio/superstudio-settings.json
RUN mkdir ~/.superstudio/templates
COPY ./templates/* /root/.superstudio/templates/

COPY ./bin/superstudio /usr/local/bin/superstudio
