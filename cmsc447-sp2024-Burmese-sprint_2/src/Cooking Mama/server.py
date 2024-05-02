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
    
    try:
        c.execute('''
            CREATE TABLE IF NOT EXISTS users (
                username TEXT PRIMARY KEY,
                total_points INTEGER DEFAULT 0,
                active_music TEXT DEFAULT 'track_one',
                active_knife TEXT DEFAULT 'blue_knife',
                active_plate TEXT DEFAULT 'white_plate',
                current_level TEXT DEFAULT 'level_one',
                current_stage INTEGER DEFAULT 1
            )
        ''')

        levels = ['level_one', 'level_two', 'level_three']
        for level in levels:
            c.execute(f'''
                CREATE TABLE IF NOT EXISTS {level} (
                    username TEXT,
                    score INTEGER DEFAULT 0,
                    completed INTEGER DEFAULT 0,
                    FOREIGN KEY (username) REFERENCES users (username)
                )
            ''')

        tracks = ['track_one', 'track_two', 'track_three']
        for track in tracks:
            c.execute(f'''
                CREATE TABLE IF NOT EXISTS {track} (
                    username TEXT,
                    is_enabled INTEGER DEFAULT 0,
                    FOREIGN KEY (username) REFERENCES users (username)
                )
            ''')

        knives = ['green_knife', 'purple_knife', 'pink_knife']
        for knife in knives:
            c.execute(f'''
                CREATE TABLE IF NOT EXISTS {knife} (
                    username TEXT,
                    is_owned INTEGER DEFAULT 0,
                    FOREIGN KEY (username) REFERENCES users (username)
                )
            ''')

        plates = ['purple_plate', 'blue_plate', 'green_plate']
        for plate in plates:
            c.execute(f'''
                CREATE TABLE IF NOT EXISTS {plate} (
                    username TEXT,
                    is_owned INTEGER DEFAULT 0,
                    FOREIGN KEY (username) REFERENCES users (username)
                )
            ''')

        conn.commit()
    except sqlite3.Error as e:
        print(f"An error occurred: {e}")
    finally:
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



@app.route('/purchase_music', methods=['POST'])
def purchase_music():
    data = request.get_json()
    username = data['username']
    track_name = data['item']
    conn = sqlite3.connect('users.db')
    c = conn.cursor()

    try:
        c.execute(f"SELECT is_enabled FROM {track_name} WHERE username = ?", (username,))
        is_enabled = c.fetchone()
        if not is_enabled:
            c.execute(f"INSERT INTO {track_name} (username, is_enabled) VALUES (?, 0)", (username,))
        elif is_enabled[0] == 1:
            return {'success': False, 'message': f"{track_name} is already owned."}, 230

        #c.execute("UPDATE users SET total_points = total_points - 2 WHERE username = ?", (username,))
        c.execute(f"UPDATE {track_name} SET is_enabled = 1 WHERE username = ?", (username,))
        conn.commit()
        return {'success': True, 'message': f"{track_name} purchased successfully."}, 200
    except Exception as e:
        return {'success': False, 'error': str(e)}, 500
    finally:
        conn.close()


def print_database_contents():
    conn = sqlite3.connect('users.db')
    c = conn.cursor()

    tables = ['users', 'track_one', 'track_two', 'track_three', 'green_knife', 'purple_knife', 'pink_knife', 'purple_plate', 'blue_plate', 'green_plate']

    try:
        for table in tables:
            print(f"\nContents of {table}:")
            c.execute(f"SELECT * FROM {table}")
            rows = c.fetchall()
            for row in rows:
                print(row)
    except sqlite3.Error as e:
        print("Error accessing database:", e)
    finally:
        conn.close()


@app.route('/purchase_knife', methods=['POST'])
def purchase_knife():
    data = request.get_json()
    username = data['username']
    knife_name = data['item']
    conn = sqlite3.connect('users.db')
    c = conn.cursor()

    try:
        c.execute(f"SELECT is_owned FROM {knife_name} WHERE username = ?", (username,))
        is_owned = c.fetchone()
        if not is_owned:
            c.execute(f"INSERT INTO {knife_name} (username, is_owned) VALUES (?, 0)", (username,))
        elif is_owned[0] == 1:
            return {'success': False, 'message': f"{knife_name} is already owned."}, 230

        #c.execute("UPDATE users SET total_points = total_points - 10 WHERE username = ?", (username,))
        c.execute(f"UPDATE {knife_name} SET is_owned = 1 WHERE username = ?", (username,))
        conn.commit()
        return {'success': True, 'message': f"{knife_name} purchased successfully."}, 200
    except Exception as e:
        return {'success': False, 'error': str(e)}, 500
    finally:
        conn.close()


@app.route('/purchase_plate', methods=['POST'])
def purchase_plate():
    data = request.get_json()
    username = data['username']
    plate_name = data['item']
    conn = sqlite3.connect('users.db')
    c = conn.cursor()

    try:
        c.execute(f"SELECT is_owned FROM {plate_name} WHERE username = ?", (username,))
        is_owned = c.fetchone()
        if not is_owned:
            c.execute(f"INSERT INTO {plate_name} (username, is_owned) VALUES (?, 0)", (username,))
        elif is_owned[0] == 1:
            return {'success': False, 'message': f"{plate_name} is already owned."}, 230

        #c.execute("UPDATE users SET total_points = total_points - 2 WHERE username = ?", (username,))
        c.execute(f"UPDATE {plate_name} SET is_owned = 1 WHERE username = ?", (username,))
        conn.commit()
        return {'success': True, 'message': f"{plate_name} purchased successfully."}, 200
    except Exception as e:
        return {'success': False, 'error': str(e)}, 500
    finally:
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





@app.route('/set_active_knife', methods=['POST'])
def set_active_knife():
    conn = sqlite3.connect('users.db')
    c = conn.cursor()
    data = request.get_json()
    username = data['username']
    active_knife = data['active_knife']

    try:
        c.execute('UPDATE users SET active_knife = ? WHERE username = ?', (active_knife, username))
        conn.commit()
        return {'success': True, 'message': 'Active knife updated successfully'}, 200
    except sqlite3.Error as e:
        return {'success': False, 'error': str(e)}, 500
    finally:
        conn.close()





@app.route('/set_active_plate', methods=['POST'])
def set_active_plate():
    conn = sqlite3.connect('users.db')
    c = conn.cursor()
    data = request.get_json()
    username = data['username']
    active_plate = data['active_plate']

    try:
        c.execute('UPDATE users SET active_plate = ? WHERE username = ?', (active_plate, username))
        conn.commit()
        return {'success': True, 'message': 'Active plate updated successfully'}, 200
    except sqlite3.Error as e:
        return {'success': False, 'error': str(e)}, 500
    finally:
        conn.close()




@app.route('/get_active_knife', methods=['POST'])
def get_active_knife():
    data = request.get_json()
    username = data['username']
    conn = sqlite3.connect('users.db')
    c = conn.cursor()

    try:
        c.execute('SELECT active_knife FROM users WHERE username = ?', (username,))
        result = c.fetchone()
        if result:
            return {'success': True, 'active_knife': result[0]}, 200
        else:
            return {'success': False, 'error': 'User not found'}, 404
    finally:
        conn.close()




@app.route('/get_active_plate', methods=['POST'])
def get_active_plate():
    data = request.get_json()
    username = data['username']
    conn = sqlite3.connect('users.db')
    c = conn.cursor()

    try:
        c.execute('SELECT active_plate FROM users WHERE username = ?', (username,))
        result = c.fetchone()
        if result:
            return {'success': True, 'active_plate': result[0]}, 200
        else:
            return {'success': False, 'error': 'User not found'}, 404
    finally:
        conn.close()


@app.route('/get_ownership_details', methods=['POST'])
def get_ownership_details():
    data = request.get_json()
    username = data['username']
    conn = sqlite3.connect('users.db')
    c = conn.cursor()

    try:
        response_data = {}
        knives = ['green_knife', 'purple_knife', 'pink_knife']
        for knife in knives:
            c.execute(f"SELECT is_owned FROM {knife} WHERE username = ?", (username,))
            result = c.fetchone()
            response_data[knife + '_owned'] = bool(result[0]) if result else False

        plates = ['purple_plate', 'blue_plate', 'green_plate']
        for plate in plates:
            c.execute(f"SELECT is_owned FROM {plate} WHERE username = ?", (username,))
            result = c.fetchone()
            response_data[plate + '_owned'] = bool(result[0]) if result else False

        tracks = ['track_one', 'track_two', 'track_three']
        for track in tracks:
            c.execute(f"SELECT is_enabled FROM {track} WHERE username = ?", (username,))
            result = c.fetchone()
            response_data[track + '_owned'] = bool(result[0]) if result else False

        return {'success': True, 'data': response_data}, 200
    except Exception as e:
        return {'success': False, 'error': str(e)}, 500
    finally:
        conn.close()


@app.route('/send_top_scores', methods=['GET'])
def send_top_scores():
    conn = sqlite3.connect('users.db')
    c = conn.cursor()
    c.execute('SELECT username, total_points FROM users ORDER BY total_points DESC LIMIT 5')
    results = c.fetchall()
    conn.close()
    if results:
        data = {
            "data": [
                {
                    "Group": "Burmese",
                    "Title": "Top 5 Scores",
                }
            ]
        }
        for idx, result in enumerate(results):
            data["data"][0][f"{idx+1}st Name"] = result[0]
            data["data"][0][f"{idx+1}st score"] = result[1]

        response = requests.post("https://eope3o6d7z7e2cc.m.pipedream.net", json=data)
        if response.status_code == 200:
            return {'success': True, 'message': 'Data sent successfully!'}, 200
        else:
            return {'success': False, 'message': 'Failed to send data.'}, 500
    else:
        return {'success': False, 'message': 'No data found.'}, 404


@app.route('/get_current_level_stage', methods=['POST'])
def get_current_level_stage():
    data = request.get_json()
    username = data['username']
    conn = sqlite3.connect('users.db')
    c = conn.cursor()

    try:
        c.execute("SELECT current_level, current_stage FROM users WHERE username = ?", (username,))
        result = c.fetchone()
        if result:
            return {'success': True, 'current_level': result[0], 'current_stage': result[1]}, 200
        else:
            return {'success': False, 'error': 'User not found'}, 404
    finally:
        conn.close()


@app.route('/set_current_level_stage', methods=['POST'])
def set_current_level_stage():
    data = request.get_json()
    username = data['username']
    current_level = data['current_level']
    current_stage = data['current_stage']
    conn = sqlite3.connect('users.db')
    c = conn.cursor()

    try:
        c.execute("UPDATE users SET current_level = ?, current_stage = ? WHERE username = ?", (current_level, current_stage, username))
        conn.commit()
        return {'success': True, 'message': 'Current level and stage updated successfully.'}, 200
    except Exception as e:
        return {'success': False, 'error': str(e)}, 500
    finally:
        conn.close()


if __name__ == '__main__':
    if not os.path.exists('users.db'):
        create_database()
    #print_all_users()
    app.run(debug=True, port=8023)
