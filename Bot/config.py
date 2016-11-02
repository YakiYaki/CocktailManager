from configparser import ConfigParser

class Configuration:
    
    __init__(self):
        self.config = ConfigParser()
        self.config.read(config_path)
    
    def config_get(self, section, option, default=None):
        try:
            return self.config.get(section, option)
        except (NoSectionError, NoOptionError):
            return default
