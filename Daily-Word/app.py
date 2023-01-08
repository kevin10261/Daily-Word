from flask import Flask
from view import views

app = Flask(__name__)  # Initializing app
app.register_blueprint(views, url_prefix="/")

if __name__ == '__main__':
    # debug=True allows website to refresh when we change things automatically
    app.run(debug=True)