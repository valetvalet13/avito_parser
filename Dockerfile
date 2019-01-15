FROM ubuntu:16.04
RUN apt update && apt upgrade -y && \
    apt install cpanminus make gcc libnet-ssleay-perl libcrypt-ssleay-perl cron tzdata -y && \
    PERL_MM_USE_DEFAULT=1 cpan -i CPAN && \
    cpan LWP::Simple LWP::Protocol::https HTML::TreeBuilder Data::Dumper Spreadsheet::WriteExcel Authen::SASL MIME::Lite Net::SMTP::SSL || true && \
    touch /var/log/avito.log
RUN ln -fs /usr/share/zoneinfo/Europe/Moscow /etc/localtime && dpkg-reconfigure -f noninteractive tzdata
COPY init.pl /opt/
COPY SendEmail.pm /opt/
COPY avito_cron /etc/cron.d/
CMD service cron start && tail -f /var/log/avito.log
