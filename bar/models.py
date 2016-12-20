from bar import db
from sqlalchemy.dialects.postgresql import TEXT

class Association(db.Model):
	__tablename__ = 'association'
	cocktail_id = db.Column(db.Integer, db.ForeignKey('cocktails.id'), nullable=False, primary_key=True)
	ingredient_id = db.Column(db.Integer, db.ForeignKey('ingredients.id'), nullable=False, primary_key=True)
	quantity = db.Column(db.String(20))
	extension = db.Column(db.String(32))

	cocktail = db.relationship("Cocktail", back_populates="ingredients")
	ingredient = db.relationship("Ingredient", back_populates="cocktails")

	def __init__(self, quantity, extension):
		self.quantity = quantity
		self.extension = extension

class CharsAssociation(db.Model):
	__tablename__ = 'charsassociation'
	cocktail_id = db.Column(db.Integer, db.ForeignKey('cocktails.id'), nullable=False, primary_key=True)
	char_id = db.Column(db.Integer, db.ForeignKey('characteristics.id'), nullable=False, primary_key=True)

	cocktail = db.relationship("Cocktail", back_populates="chars")
	char = db.relationship("Chars", back_populates="cocktails")


class Cocktail(db.Model):
    __tablename__ = 'cocktails'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(160), unique=True)
    recipe = db.Column(db.Text)
    pos = db.Column(db.Integer)	# кол-во позитивных оценок
    neg = db.Column(db.Integer) # кол-во негативных оценок
    
    # теги (сладкий/горький/кислый/фруктовый/алкогольный/...)
    # перечисляются в строке "кислый,фруктовый"
    tags = db.Column(db.String(100))

    ingredients = db.relationship("Association", back_populates="cocktail")
    chars = db.relationship("CharsAssociation", back_populates="char")

    def __init__(self, name, recipe, tags):
        self.name = name       
        self.recipe = recipe
        self.pos = 0
        self.neg = 0
        self.tags = tags

    def __init__(self):
    	self.pos = 0
    	self.neg = 0

    def plus(self):
    	self.pos += 1

    def minus(self):
    	self.neg += 1

    def __repr__(self):
        return '<Cocktail #{}>'.format(self.id)

class Ingredient(db.Model):
	__tablename__ = 'ingredients'

	id = db.Column(db.Integer, primary_key=True)
	name = db.Column(db.String(160), unique=True)

	cocktails = db.relationship("Association", back_populates="ingredient")

	def __init__(self, name):
		self.name = name

class Chars(db.Model):
	__tablename__ = 'characteristics'

	id = db.Column(db.Integer, primary_key=True)
	name = db.Column(db.String(100), unique=True)

	cocktails = db.relationship("CharsAssociation", back_populates="char")

class User(db.Model):
	__tablename__ = 'users'

	id = db.Column(db.Integer, primary_key=True)
	chat_id = db.Column(db.Integer, unique=True)
	prev_cmd = db.Column(db.String(300))