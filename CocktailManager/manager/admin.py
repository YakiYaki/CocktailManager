from django.contrib import admin
from manager.models import Cocktail, Ingredient, Preference, Chars, Cocktails, CocktailsChars

# Register your models here.

admin.site.register(Cocktail)
admin.site.register(Cocktails)
admin.site.register(Preference)
admin.site.register(Chars)
admin.site.register(CocktailsChars)
admin.site.register(Ingredient)


