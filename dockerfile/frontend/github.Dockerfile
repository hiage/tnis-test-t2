FROM python:3.8-alpine

RUN apk fix && \
    apk add --no-cache \ 
    tzdata \
    curl
    
ENV TZ=Asia/Jakarta
RUN rm -rf /var/cache/apk/*

COPY ./frontend /app
WORKDIR /app
RUN pip install -r requirements.txt

EXPOSE 3000
CMD python main.py