server {
    listen 80;
    server_name ${domain};
    location /.well-known/acme-challenge/ {
        root /var/www/certbot/${domain};
    }
    location / {
        return 301 https://$host$request_uri;
    }
}

# added so docker dns is able to resolve service names
resolver 127.0.0.11 ipv6=off;

upstream cfloadbalancer {
    server coldfusion_a:8500;
    server coldfusion_b:8501;
}

server {
    listen 443 ssl;
    ssl_certificate /etc/nginx/sites/ssl/dummy/${domain}/fullchain.pem;
    ssl_certificate_key /etc/nginx/sites/ssl/dummy/${domain}/privkey.pem;
    include /etc/nginx/includes/options-ssl-nginx.conf;
    ssl_dhparam /etc/nginx/sites/ssl/ssl-dhparams.pem;
    include /etc/nginx/includes/hsts.conf;

    # block access to CFIDE and Administrator functions
    location ~ /CFIDE {
        return 403;
    }

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_pass http://cfloadbalancer;
    }
}