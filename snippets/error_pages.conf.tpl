include __NEP_ROOT__/snippets/error_pages_content.conf;

location ^~ /_errors/ {
        root __NEP_ROOT__;
        allow all;
        add_header Cache-Control "public, max-age=3600" always;
}
location ~ /(10[0-3]|2[02][1-9]|30[1-8]|4[0125][0-9]|50[0-9])\.html {
        root __NEP_ROOT__;
        sub_filter '%{HOSTNAME}' $host;
        sub_filter_once off;
        allow all;
        internal;
        # Error response for the *original* URL (e.g. /ax1231 -> 404): keep it short
        # so a resource deployed shortly after a 404 becomes visible within a minute.
        add_header Cache-Control "public, max-age=60" always;
}
