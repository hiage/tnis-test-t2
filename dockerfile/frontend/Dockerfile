FROM python:3.8-alpine
##https://github.com/hiage/webapps

RUN apk fix && \
    apk add --no-cache \ 
    tzdata \
    curl
    
ENV TZ=Asia/Jakarta
RUN rm -rf /var/cache/apk/*

RUN mkdir -p /app
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt

EXPOSE 3000
CMD python main.py