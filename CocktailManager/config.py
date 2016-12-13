from configparser import ConfigParser, NoSectionError, NoOptionError

class Configuration:
	def config_get(self, section, option, defaul=None):
		try:		
			self.config = ConfigParser()
			self.config.read("config.ini")  #А это нормально, что у нас используется дефолтная конфигурация?????????????
			return self.config.get(section, option)
		except (NoSectionError, NoOptionError):
			return default
