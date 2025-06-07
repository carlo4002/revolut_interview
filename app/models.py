from main import db

class Birthdays(db.Model):
    __tablename__ = 'birthdays'
    username = db.Column(db.String(255), primary_key=True)
    birthday = db.Column(db.Date, nullable=False)
