from flask import Flask, send_file, send_from_directory
import os
import sqlite3

app = Flask(__name__)

DIRECTORY = os.path.dirname(os.path.abspath(__file__))
DEFAULT_FILE = 'cookingmama.html'

# Create the SQLite3 database
def create_database():
    conn = sqlite3.connect('users.db')
    c = conn.cursor()

    c.execute('''CREATE TABLE IF NOT EXISTS users
                 (username TEXT PRIMARY KEY)''')

    c.execute('''CREATE TABLE IF NOT EXISTS items
                 (username TEXT,
                  item TEXT,
                  status INTEGER,
                  FOREIGN KEY (username) REFERENCES users (username))''')

    c.execute('''CREATE TABLE IF NOT EXISTS levels
                 (username TEXT,
                  level TEXT,
                  status INTEGER,
                  FOREIGN KEY (username) REFERENCES users (username))''')

    conn.commit()
    conn.close()



@app.route('/create_account', methods=['POST'])
def create_account():
    conn = sqlite3.connect('users.db')
    c = conn.cursor()

    username = request.form['username']
    c.execute('INSERT INTO users (username) VALUES (?)', (username,))
    conn.commit()
    conn.close()
    return {'success': True}


@app.route('/')
def serve_default_file():
    return send_file(DEFAULT_FILE)

@app.route('/<path:filename>')
def serve_file(filename):
    return send_from_directory(DIRECTORY, filename)

@app.after_request
def add_headers(response):
    response.headers['Cross-Origin-Opener-Policy'] = 'same-origin'
    response.headers['Cross-Origin-Embedder-Policy'] = 'require-corp'
    return response

if __name__ == '__main__':
    create_database()
    app.run(debug=True, port=8000)