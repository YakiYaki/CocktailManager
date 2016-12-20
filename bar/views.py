from bar import app, bot, TOKEN,db
from flask import render_template, request
import json
import logging
import re
from models import Cocktail, Ingredient, Association, Chars, CharsAssociation

logging.basicConfig(filename='bot.log',level=logging.DEBUG)

@app.route('/')
@app.route('/index')
def index():
    logging.info("Test. in index")

    cocktails = Cocktail.query.all()
    if cocktails != None:
        return render_template("index.html", title='Home', cocks=cocktails)
    else:
        return render_template("index.html", title='Home')

@app.route('/cocks/<int:cock_id>')
def show_post(cock_id):
    ans = ""
    cocks = Cocktail.query.filter_by(id=cock_id)
    if cocks != None:
        for c in cocks:
            ans += c.name + "<br><br>" + c.recipe + "<br><br>"
            for i in c.ingredients:
                ans += i.ingredient.name + " " + i.quantity + i.extension + "<br>"

    return ans

def get_cock_by_id(id):
    ans = ""
    cocks = Cocktail.query.filter_by(id=id)
    if cocks != None:
        for c in cocks:
            ans += c.name + "\n\n" + c.recipe + "\n\n"
            for i in c.ingredients:
                ans += i.ingredient.name + " " + i.quantity + i.extension + "\n"
    else:
        ans += "The is no such cocktail!"

def get_cock_by_name(name):
    ans = ""
    cocks = Cocktail.query.filter_by(name=name)
    if cocks != None:
        for c in cocks:
            ans += c.name + "\n\n" + c.recipe + "\n\n"
            for i in c.ingredients:
                ans += i.ingredient.name + " " + i.quantity + i.extension + "\n"
    else:
        ans += "The is no such cocktail!"


@app.route('/filldb')
def filldb():
    logging.info("Filling db with test data. Just 20 items.")
 
    with open('test_data.txt', 'r') as f:
        cocktail = Cocktail()
        recipe = ""
        while 1:
            l = f.readline()
            if l[0] == '#':
                cocktail = Cocktail()
                recipe = ""
                cocktail.name = l[1:len(l)-1]                
            elif l[0] == '$':
                recipe += l[1:]
            elif l[0] == '@':
                cocktail.recipe = recipe
                db.session.add(cocktail)
                db.session.commit()
                logging.info("successfully added <" + cocktail.name + ">")
            elif l[0] == '!':
                break
            elif l[0] == '&':
            	continue
            else:
                ing_items = l.split(',')
                a = Association(ing_items[1], ing_items[2][:len(ing_items[2])-1])
                ings = Ingredient.query.filter_by(name=ing_items[0]).first()                
                if ings is None:
                    a.ingredient = Ingredient(ing_items[0])
                else:
                    logging.info("Ingredient id exist ====> " + str(ings.id))
                    a.ingredient = ings
                cocktail.ingredients.append(a)
    '''            
    logging.info("Test data added.")
    logging.info("Adding characteristic data.")
    with open('chars.txt', 'r') as f:
    	lines = f.readlines()
    	for l in lines:
    		if l[0] == '#':
    			continue
    		else:
    			l = l[:-1] # строка для поиска
    			char = Chars(l)    			
    			# ищем по всем ингредиентам и собираем в массив все подходящие коктейли
    			ings = Ingredient.query.all()
    			for i in ings:
    				res = re.search(l, i.name)
    				if res != None:
    					for c in i.cocktails:
    						a = CharsAssociation()    						
    						a.cocktail = c
    						char.cocktails.append(a)
    				else:
    					continue    					
    			db.session.add(char)
    			db.session.commit()
    			logging.info("successfully added <" + char.name + ">")
	'''
    return "OK"


@app.route('/bot/' + TOKEN, methods=['POST'])
def webhook():
    payload = json.loads(request.data.decode('utf-8'))
    chat_id = payload['message']['chat']['id']
    text = payload['message'].get('text')

    logger.debug(text)

    if text == "/start":
        bot.send_message(chat_id, "Hello! I'm a Cocktail Manager.\nCheck out this commands:\n/list\n/ingredients\n/cocktail/<num>")
    elif text == "/list":
        cocks = Cocktail.query.all()
        ans = "List of cocktails:\n"
        for c in cocks:
            ans += str(c.id) + ". " + c.name + "\n"
        if ans != "":
            bot.send_message(chat_id, ans)
        else:
            bot.send_message(chat_id, "Sorry, there are no cocktails in my memory yet!")
    elif text == "":
        bot.send_message(chat_id, "I don't understand you :(")
    elif text == "/ingredients":
        ings = Ingredient.query.all()
        ans = "List of ingredients:\n"
        for i in ings:
            ans += str(i.id) + ". " + i.name + "\n"
        if ans != "":
            bot.send_message(chat_id, ans)
        else:
            bot.send_message(chat_id, "Sorry, there are no cocktails in my memory yet!")
    elif re.findall("\/cocktail\/\d+"):
    	ans = ""
    	ids = re.findall("\/cocktail\/\d+")
    	cocks = Cocktail.query.filter_by(id=int(ids[0][7:]))
    	if cocks != None:
    		for c in cocks:
    			ans += c.name + "\n\n" + c.recipe + "\n\n"
    			for i in c.ingredients:
    				ans += i.ingredient.name + " " + i.quantity + " " + i.extension + "\n"
    	bot.send_message(chat_id, ans)
    elif text != "":
    	res = "I don't understand you :("
    	bot.send_message(chat_id, res)

    return 'OK'


'''
    	chars = Chars.query.all()
    	ids = []
    	for c in chars:
    		result = re.findall(c.name, text)
    		if len(result) > 0:
    			ids.append(c.id)
    		else:
    			continue
    	res = ""
    	for id in ids:
    		char = Chars.query.filter_by(id=id)
    		for c in char.cocktails:
    			res += c.name + "\n"
    	if res == "":
    		res = "Cocktail is not found :("

    '''