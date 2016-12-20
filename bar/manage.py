import os
from flask_script import Manager
from flask_migrate import Migrate, MigrateCommand
import socket

from bar import app, db, ProductionConfig, DebugConfig

if socket.gethostname() == 'linux-yaki':
	app.config.from_object(DebugConfig)
else:
	app.config.from_object(ProductionConfig)

migrate = Migrate(app, db)
manager = Manager(app)

manager.add_command('db', MigrateCommand)

if __name__ == '__main__':
    manager.run()