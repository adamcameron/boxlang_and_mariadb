FROM ortussolutions/boxlang:miniserver

COPY root_home/.bashrc /root/.bashrc
COPY root_home/.vimrc /root/.vimrc

ENV BOXLANG_HOME=/root/.boxlang

COPY root_home/.boxlang/boxlang.json /root/.boxlang/boxlang.json

RUN apt update
RUN apt install vim gpg apt-utils -y
RUN curl -fsSl https://downloads.ortussolutions.com/debs/gpg | gpg --dearmor | tee /usr/share/keyrings/ortussolutions.gpg > /dev/null
RUN echo "deb [signed-by=/usr/share/keyrings/ortussolutions.gpg] https://downloads.ortussolutions.com/debs/noarch /" | tee /etc/apt/sources.list.d/commandbox.list
RUN apt update
RUN apt install apt-transport-https commandbox -y

WORKDIR /app

EXPOSE 8080

COPY --chmod=755 usr/local/bin/entrypoint.sh /usr/local/bin/
ENTRYPOINT entrypoint.sh
