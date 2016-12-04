from django.db import models

# Create your models here.

class Cocktail(models.Model):
    name = models.CharField(max_length=128)
    description = models.TextField()
    recipe = models.TextField()
    rate = models.FloatField(default=0.)

class Ingredient(models.Model):
	name = models.CharField(max_length=128)
	description = models.TextField()

class Preference(models.Model):
	rate = models.FloatField(default=0.)
	# user_id
	cocktail_id = models.ForeignKey(Cocktail, null=True, blank=True, default=0, on_delete=models.SET_NULL)

class Chars(models.Model):
	name = models.CharField(max_length=128)

class Cocktails(models.Model):
	cocktail_id = models.ForeignKey(Cocktail, null=True, blank=True, default=0)
	ingredient_id = models.ForeignKey(Ingredient, null=True, blank=True, default=0)
	quantity = models.FloatField(default=0.)
	dimension = models.CharField(max_length=48)

class CocktailsChars(models.Model):
	char_id = models.ForeignKey(Chars)
	link_id = models.ForeignKey(Cocktails)

