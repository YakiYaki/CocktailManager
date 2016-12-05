
import test_data

class Cocktail:

	def __init__(self, id):
		self.id = id
		# запрос к базе данных за всей информацией по айди коктейля
		self.name = test_data.names[self.id]
 		# self.recipe
		# self.ingredients
		# self.description
		self.rate = test_data.rate[self.id]

	# возвращает имя коктейля 
	def get_name(self):
		return name

	def get_desctiption(self):
		return test_data.text[self.id]

	# воврщает список ингредиентов
	def get_ingredients(self):
		return test_data.ingredients[self.id]

	def get_recipe(self):
		return test_data.recipe[self.id]

	def get_rating(self):
		return self.rate

	def __str__(self):
		return self.name