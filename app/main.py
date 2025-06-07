from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime, timedelta
import re
import os

# Get the target IP address from environment variable or default to localhost
target_ip = os.getenv("TARGET_IP_ADDRESS")
if not target_ip:
    target_ip = 'localhost'
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = "postgresql://app:password@" + target_ip +":5432/postgres"
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

class Birthdays(db.Model):
    username = db.Column(db.String(255), primary_key=True)
    birthday = db.Column(db.Date, nullable=False)

def is_valid_username(username):
    # check size constraints
    if len(username) > 255 and len(username) < 3:
        return False
    # check if username contains only letters
    if not username.isalpha():
        return False
    # Check for leading or trailing spaces
    if username != username.strip():
        return False
    # check if username has not special characters
    if not re.match(r'^[a-zA-Z0-9_-]+$', username):
        return False
    return True

@app.route('/hello', methods=['GET'])
def get_hello():
    name = request.args.get('username')
    if not name:
        return jsonify({"error": "Name parameter is required"}), 400

    user = Birthdays.query.filter_by(username=name).first()
    if not user:
        return jsonify({"error": "User not found"}), 404

    today = datetime.today().date()
    next_birthday = user.birthday.replace(year=today.year)
    days_until_birthday = today - next_birthday
    if next_birthday < today:
        next_birthday = next_birthday.replace(year=today.year + 1)

    
    days_until_birthday = (next_birthday - today).days
    if days_until_birthday == 0:
        return jsonify({"message":"Hello, " + name + "! Happy birthday!"}), 200
    
    return jsonify({"message": "Hello, " + name + "! Your birthday is in " + str(days_until_birthday) + " days"}),200

@app.route('/hello/<username>', methods=['PUT'])
def put_hello(username):
    data = request.get_json()

    if is_valid_username(username) is False:
        return jsonify({"error": "Username must contain only letters, not spaces and not special chars."}), 400
    
    if not data or 'dateOfBirth' not in data:
        return jsonify({"error": "dateOfBirth is required"}), 400

    try:
        birthday = datetime.strptime(data['dateOfBirth'], '%Y-%m-%d').date()
        if birthday >= datetime.today().date():
            return jsonify({"error": "dateOfBirth must be a date before today"}), 400
    except ValueError:
        return jsonify({"error": "Invalid date format. Use YYYY-MM-DD"}), 400

    user = Birthdays.query.filter_by(username=username).first()
    if user:
        user.birthday = birthday
    else:
        user = Birthdays(username=username, birthday=birthday)
        db.session.add(user)

    db.session.commit()
    return '', 204

if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0', port=5000)
