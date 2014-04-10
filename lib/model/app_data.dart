part of database_reverse_engineer;

class AppData {
	List<Database> _dbList = new List<Database>();

	PropelPlatformInterface _platform;

	Object _generatorConfig;

	String _name;

	bool _isInitialized = false;

	Appdata([PropelPlatformInterface defaultPlatform = null]) {
		if(defaultPlatform != null) {
			_platform = defaultPlatform;
		}
	}

	void setPlatform(PropelPlatformInterface plat) {
		_platform = plat;
	}

	PropelPlatformInterface getPlatform() => _platform;

	void setGeneratorConfig(Object config) {
		_generatorConfig = config;
	}

	Object getGeneratorConfig() => _generatorConfig;

	void setName(String n) {
		_name = n;
	}

	String getName() => _name;

	String getShortName() => _name.substring(0, _name.lastIndexOf('-schema'));

	List<Database> getDatabases([bool doFinalInit = true]) {
		if(doFinalInit) {
			doFinalInitialization();
		}
		return _dbList;
	}
}