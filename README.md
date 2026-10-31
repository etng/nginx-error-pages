# nginx-error-pages
Make your nginx error pages look great

## Installation

The project can be cloned to **any** directory — it no longer has to live at
`/srv/http/default`. Just run `make` and the absolute path of the project is
substituted into `snippets/error_pages.conf` automatically (the
`__NEP_ROOT__` placeholder in `snippets/error_pages.conf.tpl` is replaced with
the current directory).

```bash
git clone https://github.com/etng/nginx-error-pages
cd nginx-error-pages
make   # regenerates the error pages AND snippets/error_pages.conf with the right root
sudo mkdir -p /etc/nginx/snippets/
sudo ln -s "$PWD/snippets/error_pages.conf" /etc/nginx/snippets/error_pages.conf
sudo ln -s "$PWD/snippets/error_pages_content.conf" /etc/nginx/snippets/error_pages_content.conf
```

> **Note:** `make` overwrites `snippets/error_pages.conf` on every run, so if you
> move the project just run `make` again — no manual editing required.

Then add to each of your vhosts the following:
```
include snippets/error_pages.conf;
```

### Caching

The generated `snippets/error_pages.conf` adds a `Cache-Control` header, but the
two locations use **different** TTLs on purpose:

* **Error responses** (`location ~ /(...)\.html`, served via `error_page` +
  `internal`) — `Cache-Control "public, max-age=60"`. This header is attached to
  the response for the **original** URL (e.g. requesting `/ax1231` that doesn't
  exist returns a 404 for `/ax1231`). A short 60s window gives a little caching
  relief while a backend keeps failing, but means a resource you deploy a minute
  later becomes visible to returning visitors within ~1 minute instead of being
  stuck behind a long cache.
* **Static error-page assets** (`location ^~ /_errors/`, e.g. `main.css`) —
  `Cache-Control "public, max-age=3600"`. These are shared, URL-independent
  files, so a longer TTL is safe and avoids re-downloading the stylesheet on
  every error page view.

Tune either value in `snippets/error_pages.conf.tpl` and re-run `make`.

> **Note on gzip:** gzip is intentionally **not** enabled in this snippet. Error
> pages are tiny static files (a few KB at most), so compression saves almost
> nothing, and most nginx setups already enable gzip globally at the `http`/
> `server` level — which covers these pages anyway. If your vhosts don't have
> gzip on globally, enable it there rather than in this snippet.

Example:
```nginx
$ cat /etc/nginx/conf.d/plex.conf 

server {
        listen       80;
        listen       [::]:80;
        listen       443 ssl http2;
        listen       [::]:443 ssl http2;
        server_name  plex.sv1 plex.sv1.lnet;
        include snippets/ssl.conf;
        include snippets/error_pages.conf; # <== This
        root         /usr/share/nginx/html;

        location / {
                include snippets/reverse-proxy.conf;
                proxy_pass https://127.0.0.1:32400;
        }
}
```


## Screenshots
### 502 Error Page
![502 error page](screenshots/screenshot-1.png)

### 404 Error Page
![404 Error Page](screenshots/screenshot-2.png)

### 418 - I'm a Teapot
![418 Error Page](screenshots/screenshot-3.png)
