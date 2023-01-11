from flask import Blueprint, render_template
from word import word, translation, pronunciation, time_now

views = Blueprint(__name__, "views")  # Initializing blueprint

@views.route("/")
def home():
    # Template will return 
    return render_template("home.html", word=word, translation=translation, pronunciation=pronunciation, time_now=time_now) 