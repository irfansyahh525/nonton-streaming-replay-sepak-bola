from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime
import json
from database.db_connection import Database
from config import Config

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})
app.config.from_object(Config)

db = Database()

# Helper function untuk validasi
def validate_required_fields(data, required_fields):
    missing_fields = [field for field in required_fields if field not in data]
    return missing_fields

# ROUTE: Login
@app.route('/api/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        
        # Validasi input
        missing_fields = validate_required_fields(data, ['username', 'password'])
        if missing_fields:
            return jsonify({
                'success': False,
                'message': f'Missing required fields: {", ".join(missing_fields)}'
            }), 400
        
        username = data['username']
        password = data['password']
        
        # Query database (password tidak di-hash sesuai permintaan)
        query = "SELECT id, username, email FROM users WHERE username = %s AND password = %s"
        result = db.execute_query(query, (username, password))
        
        if result and len(result) > 0:
            user = result[0]
            return jsonify({
                'success': True,
                'message': 'Login successful',
                'user': user
            }), 200
        else:
            return jsonify({
                'success': False,
                'message': 'Invalid username or password'
            }), 401
            
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Server error: {str(e)}'
        }), 500

# ROUTE: Register (tambahan)
@app.route('/api/register', methods=['POST'])
def register():
    try:
        data = request.get_json()
        
        missing_fields = validate_required_fields(data, ['username', 'password', 'email'])
        if missing_fields:
            return jsonify({
                'success': False,
                'message': f'Missing required fields: {", ".join(missing_fields)}'
            }), 400
        
        username = data['username']
        password = data['password']  # Tidak di-hash sesuai permintaan
        email = data['email']
        
        # Cek apakah username sudah ada
        check_query = "SELECT id FROM users WHERE username = %s"
        existing_user = db.execute_query(check_query, (username,))
        
        if existing_user:
            return jsonify({
                'success': False,
                'message': 'Username already exists'
            }), 400
        
        # Insert user baru
        insert_query = """
            INSERT INTO users (username, password, email) 
            VALUES (%s, %s, %s)
        """
        user_id = db.execute_query(insert_query, (username, password, email))
        
        if user_id:
            return jsonify({
                'success': True,
                'message': 'Registration successful',
                'user_id': user_id
            }), 201
        else:
            return jsonify({
                'success': False,
                'message': 'Registration failed'
            }), 500
            
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Server error: {str(e)}'
        }), 500

# ROUTE: Get All Matches
@app.route('/api/matches', methods=['GET'])
def get_matches():
    try:
        status = request.args.get('status')
        is_replay = request.args.get('is_replay')
        search = request.args.get('search', '')

        query = """
            SELECT id, team_a, team_b, league,
                   DATE_FORMAT(match_date, '%Y-%m-%d %H:%i:%s') as match_date,
                   status, stream_url, is_replay
            FROM matches
            WHERE 1=1
        """
        params = []

        # Filter Status
        if status:
            query += " AND status = %s"
            params.append(status)

        # Filter is_replay (hanya jika nilainya 0 atau 1)
        if is_replay in ["0", "1"]:
            query += " AND is_replay = %s"
            params.append(int(is_replay))

        # Filter Search
        if search:
            query += " AND (team_a LIKE %s OR team_b LIKE %s OR league LIKE %s)"
            like = f"%{search}%"
            params.extend([like, like, like])

        query += " ORDER BY match_date DESC"

        matches = db.execute_query(query, params)

        return jsonify({
            'success': True,
            'matches': matches or []
        }), 200

    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Server error: {str(e)}'
        }), 500

# ROUTE: Get Live Matches
@app.route('/api/matches/live', methods=['GET'])
def get_live_matches():
    try:
        query = """
            SELECT id, team_a, team_b, league, 
                   DATE_FORMAT(match_date, '%Y-%m-%d %H:%i:%s') as match_date,
                   status, stream_url, is_replay
            FROM matches
            WHERE LOWER(status) = 'live'
            ORDER BY match_date DESC
        """
        
        matches = db.execute_query(query)
        
        return jsonify({
            'success': True,
            'matches': matches or []
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Server error: {str(e)}'
        }), 500

# ROUTE: Get Replay Matches
@app.route('/api/matches/replay', methods=['GET'])
def get_replay_matches():
    try:
        query = """
            SELECT id, team_a, team_b, league, 
                   DATE_FORMAT(match_date, '%Y-%m-%d %H:%i:%s') as match_date,
                   status, stream_url, is_replay
            FROM matches
            WHERE is_replay = 1
            ORDER BY match_date DESC
        """
        
        matches = db.execute_query(query)
        
        return jsonify({
            'success': True,
            'matches': matches or []
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Server error: {str(e)}'
        }), 500

# ROUTE: Add Match History
@app.route('/api/history', methods=['POST'])
def add_history():
    try:
        data = request.get_json()
        
        missing_fields = validate_required_fields(data, ['user_id', 'match_id'])
        if missing_fields:
            return jsonify({
                'success': False,
                'message': f'Missing required fields: {", ".join(missing_fields)}'
            }), 400
        
        user_id = data['user_id']
        match_id = data['match_id']
        
        query = """
            INSERT INTO user_history (user_id, match_id) 
            VALUES (%s, %s)
        """
        history_id = db.execute_query(query, (user_id, match_id))
        
        if history_id:
            return jsonify({
                'success': True,
                'message': 'History added successfully',
                'history_id': history_id
            }), 201
        else:
            return jsonify({
                'success': False,
                'message': 'Failed to add history'
            }), 500
            
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Server error: {str(e)}'
        }), 500

# ROUTE: Search Matches
@app.route('/api/matches/search', methods=['GET'])
def search_matches():
    try:
        search_term = request.args.get('q', '')
        
        if not search_term:
            return jsonify({
                'success': True,
                'matches': []
            }), 200
        
        query = """
            SELECT id, team_a, team_b, league, 
                   DATE_FORMAT(match_date, '%Y-%m-%d %H:%i:%s') as match_date,
                   status, stream_url, is_replay
            FROM matches
            WHERE team_a LIKE %s 
               OR team_b LIKE %s 
               OR league LIKE %s
            ORDER BY match_date DESC
            LIMIT 20
        """
        
        search_pattern = f"%{search_term}%"
        matches = db.execute_query(query, (search_pattern, search_pattern, search_pattern))
        
        return jsonify({
            'success': True,
            'matches': matches or []
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Server error: {str(e)}'
        }), 500

# ROUTE: Health Check
@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({
        'status': 'healthy',
        'service': 'Streaming Bola API',
        'timestamp': datetime.now().isoformat()
    }), 200

# Error handlers
@app.errorhandler(404)
def not_found(error):
    return jsonify({
        'success': False,
        'message': 'Endpoint not found'
    }), 404

@app.errorhandler(405)
def method_not_allowed(error):
    return jsonify({
        'success': False,
        'message': 'Method not allowed'
    }), 405

@app.errorhandler(500)
def internal_server_error(error):
    return jsonify({
        'success': False,
        'message': 'Internal server error'
    }), 500

if __name__ == '__main__':
    print("Starting Streaming Bola API Server...")
    print(f"Database: {Config.MYSQL_DB}")
    print(f"Debug Mode: {Config.DEBUG}")
    app.run(host='0.0.0.0', port=5000, debug=Config.DEBUG)