import test_data
from cocktail import Cocktail

class User:
 
    def __init__(self, id):
        self.id = id
        # происходит обращение к базе данных за списком любимых коктейлей
        self.favorites = ["id_1", "id_2"]

    # возвращает список объектов коктейлей
    def get_favorites(self):
    	cocktails = []
    	for id in self.favorites:
    		cocktails.append(Cocktail(id).name)
    	return cocktails