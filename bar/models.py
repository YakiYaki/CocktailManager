from bar import db
from sqlalchemy.dialects.postgresql import TEXT

class Cocktail(db.Model):
    __tablename__ = 'cocktails'

    id = db.Column(db.Integer, primary_key=True, unique=True)
    name = db.Column(db.String())
    recipe = db.Column(db.Text())

    def __init__(self, name, recipe):
        self.name = name       
        self.recipe = recipe

    def __repr__(self):
        return '<id {}>'.format(self.id)