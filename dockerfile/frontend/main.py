from flask import Flask, render_template
import requests
import json
import os

backend = os.getenv('BACKEND_API')

app = Flask(__name__)

@app.route('/')
def index():
    #url = 'http://127.0.0.1:8080/hellotrivia' #local test
    url = 'http://' + backend + '/hellotrivia' 
    response = requests.get(url,headers={'Content-Type': 'application/json'})
    trivia = response.json()
    return render_template('index.html', trivia=trivia['message'])

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000, debug=True)
