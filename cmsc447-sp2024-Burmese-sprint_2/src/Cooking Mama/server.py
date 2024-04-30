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


@app.route('/get_points', methods=['POST'])
def get_points():
    conn = sqlite3.connect('users.db')
    c = conn.cursor()
    data = request.get_json()
    username = data['username']
    
    try:
        c.execute('SELECT total_points FROM users WHERE username = ?', (username,))
        result = c.fetchone()
        if result:
            points = result[0]
            points += 1
            return {'success': True, 'points': points}, 200
        else:
            return {'success': False, 'error': 'User not found'}, 404
    finally:
        conn.close()

@app.route('/get_active_track', methods=['POST'])
def get_active_track():
    conn = sqlite3.connect('users.db')
    c = conn.cursor()
    data = request.get_json()
    username = data['username']

    try:
        c.execute('SELECT active_music FROM users WHERE username = ?', (username,))
        result = c.fetchone()
        if result:
            return {'success': True, 'active_music': result[0]}, 200
        else:
            return {'success': False, 'error': 'User not found'}, 404
    finally:
        conn.close()

@app.route('/set_active_track', methods=['POST'])
def set_active_track():
    conn = sqlite3.connect('users.db')
    c = conn.cursor()
    data = request.get_json()
    username = data['username']
    active_music = data['active_music']

    try:
        c.execute('UPDATE users SET active_music = ? WHERE username = ?', (active_music, username))
        conn.commit()
        return {'success': True}, 200
    except sqlite3.Error as e:
        return {'success': False, 'error': str(e)}, 500
    finally:
        conn.close()

@app.route('/set_level_points', methods=['POST'])
def set_level_points():
    conn = sqlite3.connect('users.db')
    c = conn.cursor()
    data = request.get_json()
    username = data['username']
    level = data['level']
    points = data['points']
    completed = data['completed']

    try:
        c.execute(f'UPDATE {level} SET score = ?, completed = ? WHERE username = ?', (points, completed, username))
        conn.commit()
        return {'success': True}, 200
    except sqlite3.Error as e:
        return {'success': False, 'error': str(e)}, 500
    finally:
        conn.close()

@app.route('/get_level_points', methods=['POST'])
def get_level_points():
    conn = sqlite3.connect('users.db')
    c = conn.cursor()
    data = request.get_json()
    username = data['username']
    level = data['level']

    try:
        c.execute(f'SELECT score, completed FROM {level} WHERE username = ?', (username,))
        result = c.fetchone()
        if result:
            return {'success': True, 'points': result[0], 'completed': result[1]}, 200
        else:
            return {'success': False, 'error': 'Level not found'}, 404
    finally:
        conn.close()

@app.route('/set_total_points', methods=['POST'])
def set_total_points():
    conn = sqlite3.connect('users.db')
    c = conn.cursor()
    data = request.get_json()
    username = data['username']
    total_points = data['total_points']

    try:
        c.execute('UPDATE users SET total_points = ? WHERE username = ?', (total_points, username))
        conn.commit()
        return {'success': True}, 200
    except sqlite3.Error as e:
        return {'success': False, 'error': str(e)}, 500
    finally:
        conn.close()

@app.route('/get_total_points', methods=['POST'])
def get_total_points():
    conn = sqlite3.connect('users.db')
    c = conn.cursor()
    data = request.get_json()
    username = data['username']

    try:
        c.execute('SELECT total_points FROM users WHERE username = ?', (username,))
        result = c.fetchone()
        if result:
            return {'success': True, 'total_points': result[0]}, 200
        else:
            return {'success': False, 'error': 'User not found'}, 404
    finally:
        conn.close()

@app.route('/send_top_scores', methods=['GET'])
def send_top_scores():
    conn = sqlite3.connect('users.db')
    c = conn.cursor()
    
    # Query the database for the top 5 users with the highest total points
    c.execute('SELECT username, total_points FROM users ORDER BY total_points DESC LIMIT 5')
    results = c.fetchall()
    
    # Close the database connection
    conn.close()

    # Prepare the data in the required JSON format
    if results:
        data = {
            "data": [
                {
                    "Group": "Burmese",
                    "Title": "Top 5 Scores",
                }
            ]
        }

        # Dynamically add names and scores based on query results
        for idx, result in enumerate(results):
            data["data"][0][f"{idx+1}st Name"] = result[0]
            data["data"][0][f"{idx+1}st score"] = result[1]
    
        # Send the data to the specified URI
        response = requests.post("https://eope3o6d7z7e2cc.m.pipedream.net", json=data)
        
        # Return a response depending on success
        if response.status_code == 200:
            return {'success': True, 'message': 'Data sent successfully!'}, 200
        else:
            return {'success': False, 'message': 'Failed to send data.'}, 500
    else:
        return {'success': False, 'message': 'No data found.'}, 404



if __name__ == '__main__':
    if not os.path.exists('users.db'):
        create_database()
    #print_all_users()
    app.run(debug=True, port=8023)
