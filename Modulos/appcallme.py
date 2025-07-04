from flask import Flask, request, jsonify
from datetime import datetime, timedelta
import sqlite3
import os

app = Flask(__name__)

# Database setup
DATABASE = '/root/database.db'

def init_db():
    if not os.path.exists(DATABASE):
        conn = sqlite3.connect(DATABASE)
        c = conn.cursor()
        c.execute('''CREATE TABLE IF NOT EXISTS tokens (
                     id INTEGER PRIMARY KEY AUTOINCREMENT,
                     Name TEXT,
                     Key TEXT UNIQUE,
                     Valid INTEGER,
                     Expiration TEXT)''')
        conn.commit()
        conn.close()

init_db()

@app.route('/pphdev/tokens', methods=['POST'])
def create_token():
    data = request.get_json()
    Name = data.get('Name')
    Key = data.get('Key')
    Valid = data.get('Valid')
    Expiration = data.get('Expiration')
    
    if not all([Name, Key, Valid, Expiration]):
        return jsonify({'error': 'Missing required fields'}), 400
    
    try:
        conn = sqlite3.connect(DATABASE)
        c = conn.cursor()
        c.execute("INSERT INTO tokens (Name, Key, Valid, Expiration) VALUES (?, ?, ?, ?)",
                  (Name, Key, Valid, Expiration))
        conn.commit()
        conn.close()
        return jsonify({'message': 'Token created successfully'}), 201
    except sqlite3.IntegrityError:
        return jsonify({'error': 'Key already exists'}), 400

@app.route('/pphdev/tokens/<key>', methods=['PUT'])
def update_token(key):
    data = request.get_json()
    Name = data.get('Name')
    NewKey = data.get('Key')
    
    if not all([Name, NewKey]):
        return jsonify({'error': 'Missing required fields'}), 400
    
    conn = sqlite3.connect(DATABASE)
    c = conn.cursor()
    c.execute("UPDATE tokens SET Name = ?, Key = ? WHERE Key = ?", (Name, NewKey, key))
    if c.rowcount == 0:
        conn.close()
        return jsonify({'error': 'Token not found'}), 404
    conn.commit()
    conn.close()
    return jsonify({'message': 'Token updated successfully'}), 200

@app.route('/pphdev/tokens/<key>', methods=['DELETE'])
def delete_token(key):
    conn = sqlite3.connect(DATABASE)
    c = conn.cursor()
    c.execute("DELETE FROM tokens WHERE Key = ?", (key,))
    if c.rowcount == 0:
        conn.close()
        return jsonify({'error': 'Token not found'}), 404
    conn.commit()
    conn.close()
    return jsonify({'message': 'Token deleted successfully'}), 200

@app.route('/pphdev/tokens', methods=['GET'])
def get_tokens():
    conn = sqlite3.connect(DATABASE)
    c = conn.cursor()
    c.execute("SELECT * FROM tokens")
    tokens = c.fetchall()
    conn.close()
    return jsonify([{'id': t[0], 'Name': t[1], 'Key': t[2], 'Valid': t[3], 'Expiration': t[4]} for t in tokens])

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=89)
