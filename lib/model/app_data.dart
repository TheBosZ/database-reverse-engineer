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

	bool hasMultipleDatabases() => _dbList.length > 1;

	Database getDatabase([String name = null, bool doFinalInit = true]) {
		if(doFinalInit) {
			doFinalInitialization();
		}

		if(name == null) {
			return _dbList.first;
		}

		return _dbList.where((Database db) => db.getName() == name).first;
	}

	bool hasDatabase(String name) => _dbList.where((Database db) => db.getName() == name).isNotEmpty;

	Database addDatabase(Object data) {
		if(data is Database) {
			data.setAppData(this);
			if(data.getPlatform() == null) {
				PropelPlatformInterface pf;
				//GeneratorConfig gc = getGeneratorConfig();

				//if(gc != null) {
					//pf = gc.getGetConfiguredPlatform(null, data.getName());

				//}
				data.setPlatform(pf != null ? pf : _platform);
			}
			_dbList.add(data);
			return data;
		}

		Database db = new Database();
		db.setAppData(this);
		db.loadFromXML(data);
		return addDatabase(db);
	}

	void doFinalInitialization() {
		if(!_isInitialized) {
			_dbList.forEach((Database db) => db.doFinalInitialization());
			_isInitialized = true;
		}
	}


}