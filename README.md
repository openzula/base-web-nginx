# openzula/base-web-nginx
This Docker image is most likely not useful to anybody except for us! It provides a base image to serve our web
applications using Nginx (and PHP-FPM). It offers the following features:

* HTTP & HTTPS
* Automatic Let's Encrypt certificate generation & renewal (using AWS Route53 plugin)
* Redirection to canonical domain
* Sane Cache-Control & gzip defaults
* PHP-FPM fastcgi

## Prerequisites
Due to the automatic Let's Encrypt certificate generation & renewal which uses the AWS Route53 plugin, you must ensure
that either the EC2 role or `AWS_*` credentials has permission to modify AWS Route53 hosted zones. This is so `certbot`
can create the DNS records required for verification.

See [certbot-dns-route53’s documentation](https://certbot-dns-route53.readthedocs.io/en/stable/) for further details. An
example policy that you'll need is as follows:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "route53:GetChange",
                "route53:ListHostedZones",
                "route53:ChangeResourceRecordSets"
            ],
            "Resource": "*"
        }
    ]
}
```

## Deployment
This image is intended to be used as a base only and not to be ran directly. Instead you should create and build your
own image using our standard directory structure as follows:

```
./build
-- aws
---- web.dockerfile
./src
-- application
-- modules
-- ...
```

The `./build/aws/web.dockerfile` should as a minimum contain the following instructions, however it could of course
contain any further instructions that you require:

```dockerfile
FROM openzula/base-web-nginx:latest
COPY ./src/ /var/www/public/
```

Then build the image by running the following command in the top most directly of your project:

```shell script
docker build -f build/aws/web.dockerfile -t example/web .
```

All configuration of this Docker image is done at run time instead of build time. This allows you to use the same
(already built) Docker image and configure it per environment by simply passing in different environmental variables, e.g.

```shell script
docker run -it --rm -d \
    -p 80:80 -p 443:443 \
    -e DOMAIN='example.com,www.example.com' \
    -e CANONICAL_DOMAIN='www.example.com' \
    --name example/web \
    example/web
```

## Configuration
The following environmental variables can be used at run time to configure the image:

| Name | Description | Required | Default |
| ---- | ----------- | -------- | ------- |
| `DOMAIN` | Comma separated list of domains to include on the SSL certificate | Yes | - |
| `CANONICAL_DOMAIN` | The main domain to use. All other `Host`'s will redirect to the this value | Yes | - |

## License
This project is licensed under the BSD 3-clause license - see [LICENSE.md](LICENSE.md) file for details.
