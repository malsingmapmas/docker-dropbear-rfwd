FROM debian as compiler
RUN apt update
RUN apt install git autoconf musl gcc musl-tools make -y
RUN cd / && git clone https://github.com/mkj/dropbear.git
COPY localoptions.h /dropbear/
RUN cd /dropbear && autoconf 
RUN cd /dropbear && autoheader 
RUN cd /dropbear && CC=musl-gcc ./configure --enable-static --disable-zlib --disable-wtmp
RUN cd /dropbear && make clean && make PROGRAMS="dropbear"
RUN cd /dropbear && chmod +x dropbear

FROM busybox
VOLUME /keys
ENV UUID=1000
RUN echo "/bin/nologin" > /etc/shells	
RUN mkdir -p /home/user/.ssh && ln -s /keys/authorized_keys /home/user/.ssh/authorized_keys
COPY run.sh /run.sh
RUN chmod +x /run.sh
COPY --from=compiler /dropbear/dropbear /bin/
ENTRYPOINT ["/run.sh"]
