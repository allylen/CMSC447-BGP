from flask import Flask, send_file, send_from_directory, request
from flask_cors import CORS
import os
import sqlite3

app = Flask(__name__)
CORS(app)

DIRECTORY = os.path.dirname(os.path.abspath(__file__))
DEFAULT_FILE = 'cookingmama.html'

def create_database():
    conn = sqlite3.connect('users.db')
    c = conn.cursor()

    c.execute('''
        CREATE TABLE IF NOT EXISTS users (
            username TEXT PRIMARY KEY,
            total_points INTEGER DEFAULT 0,
            active_music TEXT DEFAULT 'track_one'
        )
    ''')

    levels = ['level_one', 'level_two', 'level_three']
    for level in levels:
        c.execute(f'''
            CREATE TABLE IF NOT EXISTS {level} (
                username TEXT,
                score INTEGER DEFAULT 0,
                completed BOOLEAN DEFAULT FALSE,
                FOREIGN KEY (username) REFERENCES users (username)
            )
        ''')

    tracks = ['track_one', 'track_two', 'track_three']
    for track in tracks:
        c.execute(f'''
            CREATE TABLE IF NOT EXISTS {track} (
                username TEXT,
                is_enabled BOOLEAN DEFAULT FALSE,
                FOREIGN KEY (username) REFERENCES users (username)
            )
        ''')

    conn.commit()
    conn.close()



@app.route('/create_account', methods=['POST'])
def create_account():
    print("Received a request!")
    conn = sqlite3.connect('users.db')
    c = conn.cursor()

    data = request.get_json()  
    username = data['username']
    
    try:
        c.execute('INSERT INTO users (username) VALUES (?)', (username,))
        conn.commit()
        return {'success': True}, 200
    except sqlite3.IntegrityError:
        return {'success': False, 'error': 'Username already exists'}, 409
    finally:
        conn.close()


def print_all_users():
    conn = sqlite3.connect('users.db')
    c = conn.cursor()
    c.execute('SELECT username FROM users')
    users = c.fetchall()
    print("All users:", users[1][0])
    conn.close()

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


@app.route('/login', methods=['POST'])
def login():
    print("Request Received rawr xD")
    conn = sqlite3.connect('users.db')
    c = conn.cursor()
    data = request.get_json()  
    username = data['username']
    
    try:
        c.execute('SELECT * FROM users WHERE username = ?', (username,))
        user = c.fetchone()[0]
        if user:
            return {'success': True}, 200
        else:
            return {'success': False, 'error': 'Username does not exist'}, 404
    finally:
        conn.close()

if __name__ == '__main__':
    if not os.path.exists('users.db'):
        create_database()
    print_all_users()
    app.run(debug=True, port=8023)
