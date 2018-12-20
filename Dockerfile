FROM golang:1.11 AS build
RUN apt-get update
RUN apt-get install libwebkit2gtk-4.0-dev -y
WORKDIR /src
COPY ./go.mod ./go.sum ./
RUN go mod download
COPY . .
ENV GO111MODULE=on
RUN GOOS=linux go build -o connector ./cmd

FROM ubuntu:16.04 AS ca-stores
RUN apt-get update -y
RUN apt-get install -y ca-certificates curl
RUN update-ca-certificates -v
RUN curl -s "http://www.microsoft.com/pki/mscorp/msitwww2(1).crt" > cert.crt && openssl x509 -in cert.crt -inform DER -out pem.pem -outform PEM && cat pem.pem >> /etc/ssl/certs/ca-certificates.crt
RUN curl -s http://www.microsoft.com/pki/mscorp/Microsoft%20IT%20TLS%20CA%201.crt > cert.crt && openssl x509 -in cert.crt -inform DER -out pem.pem -outform PEM && cat pem.pem >> /etc/ssl/certs/ca-certificates.crt
RUN curl -s http://www.microsoft.com/pki/mscorp/Microsoft%20IT%20TLS%20CA%202.crt > cert.crt && openssl x509 -in cert.crt -inform DER -out pem.pem -outform PEM && cat pem.pem >> /etc/ssl/certs/ca-certificates.crt
RUN curl -s http://www.microsoft.com/pki/mscorp/Microsoft%20IT%20TLS%20CA%204.crt > cert.crt && openssl x509 -in cert.crt -inform DER -out pem.pem -outform PEM && cat pem.pem >> /etc/ssl/certs/ca-certificates.crt
RUN curl -s http://www.microsoft.com/pki/mscorp/Microsoft%20IT%20TLS%20CA%205.crt > cert.crt && openssl x509 -in cert.crt -inform DER -out pem.pem -outform PEM && cat pem.pem >> /etc/ssl/certs/ca-certificates.crt

FROM scratch
COPY --from=ca-store /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /src/connector /bin/connector
ENTRYPOINT ["connector", "-cert", "/etc/ssl/certs/ca-certificates.crt"]
