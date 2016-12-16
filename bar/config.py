from configparser import ConfigParser, NoSectionError, NoOptionError

class Configuration:
	def config_get(self, section, option, defaul=None):
		try:		
			self.config = ConfigParser()
			self.config.read("config.ini")	
			return self.config.get(section, option)
		except (NoSectionError, NoOptionError):
			return default