FROM bitnami/minideb:stretch
LABEL maintainer "Bitnami <containers@bitnami.com>"

ENV PATH="/opt/bitnami/apache/bin:/opt/bitnami/php/bin:/opt/bitnami/php/sbin:/opt/bitnami/mysql/bin:/opt/bitnami/drupal/vendor/bin:/opt/bitnami/nami/bin:$PATH"

COPY prebuildfs /
# Install required system packages and dependencies
RUN install_packages ca-certificates curl dirmngr gnupg libbz2-1.0 libc6 libcomerr2 libcurl3 libexpat1 libffi6 libfreetype6 libgcc1 libgcrypt20 libgmp10 libgnutls30 libgpg-error0 libgssapi-krb5-2 libhogweed4 libicu57 libidn11 libidn2-0 libjpeg62-turbo libk5crypto3 libkeyutils1 libkrb5-3 libkrb5support0 libldap-2.4-2 liblzma5 libmemcached11 libmemcachedutil2 libncurses5 libnettle6 libnghttp2-14 libp11-kit0 libpcre3 libpng16-16 libpq5 libpsl5 libreadline7 librtmp1 libsasl2-2 libsqlite3-0 libssh2-1 libssl1.0.2 libssl1.1 libstdc++6 libsybdb5 libtasn1-6 libtidy5 libtinfo5 libunistring0 libxml2 libxslt1.1 libzip4 procps sudo unzip zlib1g
RUN chmod -R +x /build /opt /usr && /build/bitnami-user.sh && chmod +x  /build/install-nami.sh && \
    /build/install-nami.sh
RUN bitnami-pkg unpack apache-2.4.41-4 --checksum 496e9cc3e12fd38832aae5dc1873cb4593666e6146379f55b2312908917eb666
RUN bitnami-pkg unpack php-7.3.13-1 --checksum 6b8ab93e7b05a5675667509352383e773d7bd65c6e7b8e1f9705d743bfdc8745
RUN bitnami-pkg unpack mysql-client-10.3.21-0 --checksum 19c6b964f289772a4e5963e22929133fa65222f66752eb29af715ce3d0b7ef0e
RUN bitnami-pkg install libphp-7.3.13-2 --checksum cdad3af7b23f54dbcf13818651979d7f23324c6092e5bde760eee1be1a740346
RUN bitnami-pkg unpack drupal-8.8.1-1 --checksum fa359dcc7521a6708e93db60547e9f38f317ec67e8b4ca303d47da2a099dbafb
RUN apt-get update && apt-get upgrade && \
    rm -r /var/lib/apt/lists /var/cache/apt/archives
RUN /build/install-gosu.sh
RUN /build/install-tini.sh

COPY rootfs /
ENV ALLOW_EMPTY_PASSWORD="no" \
    BITNAMI_APP_NAME="drupal" \
    BITNAMI_IMAGE_VERSION="8.8.1-debian-9-r24" \
    DRUPAL_DATABASE_NAME="bitnami_drupal" \
    DRUPAL_DATABASE_PASSWORD="" \
    DRUPAL_DATABASE_USER="bn_drupal" \
    DRUPAL_EMAIL="user@example.com" \
    DRUPAL_HTTPS_PORT="8443" \
    DRUPAL_HTTP_PORT="8080" \
    DRUPAL_PASSWORD="bitnami" \
    DRUPAL_PROFILE="standard" \
    DRUPAL_USERNAME="user" \
    MARIADB_HOST="mariadb" \
    MARIADB_PORT_NUMBER="3306" \
    MARIADB_ROOT_PASSWORD="" \
    MARIADB_ROOT_USER="root" \
    MYSQL_CLIENT_CREATE_DATABASE_NAME="" \
    MYSQL_CLIENT_CREATE_DATABASE_PASSWORD="" \
    MYSQL_CLIENT_CREATE_DATABASE_PRIVILEGES="ALL" \
    MYSQL_CLIENT_CREATE_DATABASE_USER=""
RUN sed -i "s/80/8080/g" /opt/bitnami/apache/conf/httpd.conf && \
    sed -i "s/80/8080/g" /opt/bitnami/apache/conf/bitnami/bitnami.conf && \
    sed -i "s/80/8080/g" /opt/bitnami/apache/conf/vhosts/httpd-vhosts.conf && \
    sed -i "s/443/8443/g" /opt/bitnami/apache/conf/bitnami/bitnami-ssl.conf
	
EXPOSE 8080 8443
# Create user, chown, and chmod
# RUN user drupal -u 2000 -G root \
RUN cp -r /root/.nami / && chmod -R g+rwx /.nami
RUN usermod -d /root -u 2000 -a -G root bitnami \
&& chown -R 2000:0 /app-entrypoint.sh /opt /root /usr \
&& chmod -R g+rwx /app-entrypoint.sh /root /opt /usr  \
##&& cp -r /root/.nami / && chmod -R g+rwx /.nami \
##&& chmod -R u+x /app-entrypoint.sh /root /opt /usr
 
##USER 2000
ENTRYPOINT [ "/app-entrypoint.sh" ]
CMD [ "nami", "start", "--foreground", "apache" ]