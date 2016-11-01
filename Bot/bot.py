import telebot
import sys
from config import Configuration 
from user import User
from cocktail import Cocktail
 
bot = telebot.TeleBot(Configuration.TOKEN)
LIST_FROM_MENU = ["First_Cocktail", "Second_Cocktail", "Third_Cocktail"]
FAVOURITE_COCKTAILS = ["Second_Cocktail", "Third_Cocktail"]

# заменяет таблицу Юзеров в БД
users_rep = {}
 
def check_user_in_list(id):
    if id not in users_rep:
        current_user = User(id)
        users_rep[id] = current_user
        return current_user


@bot.message_handler(regexp = "/Start|/START|/start")
def handle_start(message):
    
    user = check_user_in_list(message.from_user.id)
    
    user_markup = telebot.types.ReplyKeyboardMarkup(True, False)
    user_markup.row('/Start', '/Help', '/End')
    #print(message)
    user_markup.row('/List', '/Location', '/Favourite', '/Users')
    
    bot.send_message(user.id, 'started', reply_markup = user_markup)
  
 
@bot.message_handler(regexp = "/help|/HELP|/Help")
def handle_help(message):
    user = check_user_in_list(message.from_user.id)
    bot.send_message(message.from_user.id,\
                     ''' This is a list of available commands
                     /Start - Start working with cocktail manager
                     /Help - List of available commands (You are here now)
                     /End - Finish working with cocktail manager
                     /List - Returns list of all cocktails in menu
                     /Location - Returns your location
                     /Favourites - Returns list of your favourite cocktails
                     If you want to add or delete some cocktail from your Favourite Cocktails, you should write 'add' or 'delete' and name of cocktail''')
 
 
@bot.message_handler(regexp="/end|/quit|/END|/QUIT|/End")
def handle_end(message):
    user = check_user_in_list(message.from_user.id)
    bot.send_message(message.from_user.id, "Work was ended, if you want to continue our conversation, reboot the programm")
    sys.exit(0)
 
 
@bot.message_handler(regexp="/list|/List|/LIST|/Menu|/MENU|/menu|/cocktails|/Cocktails|/COCKTAILS")
def handle_list(message):
    user = check_user_in_list(message.from_user.id)
    bot.send_message(message.from_user.id,"Here is the list of our cocktails")
    bot.send_message(message.from_user.id,"\n".join(LIST_FROM_MENU))
 
 
@bot.message_handler(regexp="/Location|/LOCATION|/location")
def handle_location(message):
    user = check_user_in_list(message.from_user.id)
    bot.send_chat_action(message.from_user.id, 'find_location')
    bot.send_location(message.from_user.id, '54.32213', '32.31167')
 
 
@bot.message_handler(regexp="(/favourite|/Favourite|/Favourites|/favourites)+s?")
def handle_favourite(message):
    user = check_user_in_list(message.from_user.id)
    bot.send_message(message.from_user.id, str(user.get_favorites()))
 
#test 
@bot.message_handler(regexp="(/users|/Users)")
def handle_users(message):
    user = check_user_in_list(message.from_user.id)
    bot.send_message(message.from_user.id, str(users_rep))
 
@bot.message_handler(content_types=["text"])
def handle_text(message):
    user = check_user_in_list(message.from_user.id)
    if "add" in message.text:
        position_of_added_cocktail = message.text.find("add")+4
        current_user.favourites.append(message.text[position_of_added_cocktail:])
        LIST_FROM_MENU.append(message.text[position_of_added_cocktail:])
    elif "delete" in message.text and len(FAVOURITE_COCKTAILS) >=1 :
        position_of_deleted_cocktail = message.text.find("delete")+7
        deleted_cocktail = message.text[position_of_deleted_cocktail:]
        if deleted_cocktail in current_user.favourites:
            current_user.favourites.remove(deleted_cocktail)
    else:
        bot.send_message(message.from_user.id,message.text+" Sorry, I'm in beta-testing, so I don't understood non-standard commands and just repeating words, which you told me 1 second ago")


if __name__ == "__main__":
    bot.polling(none_stop=True)
