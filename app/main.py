from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime, timedelta

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://app:password@localhost:5432/postgres'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), unique=True, nullable=False)
    birthday = db.Column(db.Date, nullable=False)

@app.route('/hello', methods=['GET'])
def get_hello():
    name = request.args.get('name')
    if not name:
        return jsonify({"error": "Name parameter is required"}), 400

    user = User.query.filter_by(name=name).first()
    if not user:
        return jsonify({"error": "User not found"}), 404

    today = datetime.today().date()
    next_birthday = user.birthday.replace(year=today.year)
    if next_birthday < today:
        next_birthday = next_birthday.replace(year=today.year + 1)

    days_until_birthday = (next_birthday - today).days
    return jsonify({"name": name, "days_until_birthday": days_until_birthday})

@app.route('/hello', methods=['PUT'])
def put_hello():
    data = request.get_json()
    if not data or 'name' not in data or 'birthday' not in data:
        return jsonify({"error": "Name and birthday are required"}), 400

    name = data['name']
    try:
        birthday = datetime.strptime(data['birthday'], '%Y-%m-%d').date()
        if birthday >= datetime.today().date():
            return jsonify({"error": "Birthday must be a date before today"}), 400
    except ValueError:
        return jsonify({"error": "Invalid date format. Use YYYY-MM-DD"}), 400

    user = User.query.filter_by(name=name).first()
    if user:
        user.birthday = birthday
    else:
        user = User(name=name, birthday=birthday)
        db.session.add(user)

    db.session.commit()
    return jsonify({"message": "User saved successfully"}), 200

if __name__ == '__main__':
    app.run(debug=True)
