part of database_reverse_engineer;

class Table extends ScopedElement implements IDMethod {
	Table([String this._commonName = null]): super('Table');

	final bool DEBUG = false;

	String _commonName;

	List<Column> _columnList = new List<Column>();

	List<Validator> _validatorList = new List<Validator>();

	List<ForeignKey> _foreignKeys = new List<ForeignKey>();

	Map<String, Index> _indicies = new Map<String, Index>();

	List<Unique> _unices = new List<Unique>();

	List<IdMethodParameter> _idMethodParameters = new List<IdMethodParameter>();

	String _description;

	String _dartName;

	String _idMethod;

	bool _allowPkInsert;

	String _dartNamingMethod;

	Database _database;

	List<ForeignKey> _referrers = new List<ForeignKey>();

	List<String> _foreignTableNames;

	bool _containsForeignPK;

	Column _inheritanceColumn;

	bool _skipSql;

	bool _readOnly;

	bool _abstractValue;

	String _alias;

	String _interface;

	String _baseClass;

	String _basePeer;

	Map<String, Column> _columnsByName = new Map<String, Column>();

	Map<String, Column> _columnsByLowercaseName = new Map<String, Column>();

	Map<String, Column> _columnsByDartName = new Map<String, Column>();

	bool _needsTransactionInPostgres;

	bool _heavyIndexing;

	bool _forReferenceOnly;

	String _treeMode;

	bool _reloadOnInsert;

	bool _reloadOnUpdate;

	Map<String, Object> _behaviors = new Map<String, Object>();

	bool _isCrossRef = false;

	String _defaultStringFormat;

	String _getStdSeparatedName() {
		if (_schema != null && getBuildProperty('schemaAutoPrefix') != null) {
			return "${_schema}${NameGenerator.STD_SEPARATOR_CHAR}${getCommonName()}";
		}
		return getCommonName();
	}

	void _setupObject() {
		super._setupObject();

		_commonName = "${getDatabase().getTablePrefix()}${getAttribute('name')}";
		_dartNamingMethod = getAttribute('dartNamingMethod', getDatabase().getDefaultDartNamingMethod());
		_dartName = getAttribute('dartName', buildDartName(_getStdSeparatedName()));
		_idMethod = getAttribute('idMethod', getDatabase().getDefaultIdMethod());
		_allowPkInsert = _booleanValue(getAttribute('allowPkInsert'));

		_skipSql = _booleanValue(getAttribute('skipSql'));
		_readOnly = _booleanValue(getAttribute('readOnly'));

		_abstractValue = _booleanValue(getAttribute('abstract'));
		_baseClass = getAttribute('baseClass');
		_basePeer = getAttribute('basePeer');
		_alias = getAttribute('alias');

		_heavyIndexing = (_booleanValue(getAttribute('heavyIndexing')) || ('false' != getAttribute('heavyIndexing') && getDatabase().isHeavyIndexing()));

		_description = getAttribute('description');
		_interface = getAttribute('interface');
		_treeMode = getAttribute('treeMode');

		_reloadOnInsert = _booleanValue(getAttribute('reloadOnInsert'));
		_reloadOnUpdate = _booleanValue(getAttribute('reloadOnUpdate'));
		_isCrossRef = _booleanValue(getAttribute('isCrossRef', false.toString()));
		_defaultStringFormat = getAttribute('defaultStringFormat');
	}

	String getBuildProperty(String key) {
		Database d = getDatabase();
		return d != null ? d.getBuildProperty(key) : '';
	}

	void applyBehaviors() {
		throw new UnimplementedError('Behaviors not implemented');
	}

	void doFinalInitialization() {
		if (_heavyIndexing != null && _heavyIndexing) {
			_doHeavyIndexing();
		}

		doNaming();

		bool anyAutoInc = false;
		for(Column c in getColumns()) {
			if (c.isAutoIncrement()) {
				anyAutoInc = true;
			}
		}

		if (getIdMethod() == IDMethod.NATIVE && !anyAutoInc) {
			setIdMethod(IDMethod.NO_ID_METHOD);
		}
	}

	void _doHeavyIndexing() {
		List<Column> pks = getPrimaryKey();

		int size = pks.length;

		for (int x = 1; x < size; ++x) {
			Index idx = new Index();
			idx.setColumns(pks.sublist(x));
			addIndex(idx);
		}
	}

	void addExtraIndicies() {
		Map<String, Index> indicies = collectIndexedColumns('PRIMARY', getPrimaryKey());

		List<Index> tableIndicies = new List<Index>();
		tableIndicies.addAll(getIndices());
		tableIndicies.addAll(getUnices());

		for(Index i in tableIndicies) {
			indicies.addAll(collectIndexedColumns(i.getName(), i.getColumns()));
		}

		int counter = 0;
		for(ForeignKey fk in getReferrers()) {
			List<Column> refedColumns = fk.getForeignColumnObjects();
			String refedColumnsHash = getColumnList(refedColumns);
			if (!_indicies.containsKey(refedColumnsHash)) {
				Index idx = new Index();
				idx.setName("I_referenced_${fk.getName()}_${(++counter).toString()}");
				idx.setColumns(refedColumns);
				idx.resetColumnSize();
				addIndex(idx);
				collectIndexedColumns(idx.getName(), refedColumns);
			}
		}

		for(ForeignKey fk in getForeignKeys())  {
			List<Column> localColumns = fk.getLocalColumnObjects();
			String localColHash = getColumnList(localColumns);
			if (!_indicies.containsKey(localColHash)) {
				String fkname = fk.getName();
				int fkInd = fkname.toUpperCase().lastIndexOf('FK_');
				String name = "${fkname.substring(0, fkInd)}FI_${fkname.substring(fkInd+3)}";
				Index idx = new Index();
				idx.setName(name);
				idx.setColumns(localColumns);
				idx.resetColumnSize();
				addIndex(idx);
				collectIndexedColumns(idx.getName(), localColumns);
			}
		}
	}

	Map<String, Index> collectIndexedColumns(String indexName, List<Column> columns) {
		Map<String, Index> idxList = new Map<String, Index>();
		List<Column> idxCols = new List<Column>();
		List<Index> indices = getIndices().where((Index i) => i.getName().toUpperCase() == indexName.toUpperCase()).toList();
		if(indices.isEmpty) {
			return idxList;
		}
		Index idx = indices.first;
		for(Column c in columns) {
			idxCols.add(c);
			String idxColHash = getColumnList(idxCols);
			if (!idxList.containsKey(idxColHash)) {
				idxList[idxColHash] = idx;
			}
		}
		return idxList;
	}

	String getColumnList(List<Object> columns, [String delim = ',']) {
		List<String> lis = new List<String>();
		for(Object c in columns) {
			String name;
			if (c is Column) {
				name = c.getName();
			} else {
				name = c.toString();
			}
			lis.add(name);
		}
		return lis.join(delim);
	}

	void doNaming() {
		int size = _foreignKeys.length,
				x;
		String name;
		for (x = 0; x < size; ++x) {
			ForeignKey fk = _foreignKeys.elementAt(x);
			name = fk.getName();
			if (name.isEmpty) {
				name = acquireConstraintName("FK", x + 1);
				fk.setName(name);
			}
		}


		List<Index> idxes = _indicies.values.toList();
		size = idxes.length;
		for (x = 0; x < size; ++x) {
			Index idx = idxes.elementAt(x);
			name = idx.getName();
			if (name.isEmpty) {
				name = acquireConstraintName('I', x + 1);
				idx.setName(name);
			}
		}

		size = _unices.length;
		for (x = 0; x < size; ++x) {
			Index idx = _unices.elementAt(x);
			name = idx.getName();
			if (name.isEmpty) {
				name = acquireConstraintName("U", x + 1);
				idx.setName(name);
			}
		}
	}

	String acquireConstraintName(String nameType, int nbr) {
		List<Object> inputs = new List<Object>();
		inputs.add(getDatabase());
		inputs.add(getCommonName());
		inputs.add(nameType);
		inputs.add(nbr);
		return NameFactory.generateName(NameFactory.CONSTRAINT_GENERATOR, inputs);
	}

	String getBaseClass() {
		if (isAlias() && _baseClass == null) {
			return _alias;
		}
		if (_baseClass == null) {
			return getDatabase().getBaseClass();
		}
		return _baseClass;
	}

	void setBaseClass(String v) {
		_baseClass = v;
	}

	String getBasePeer() {
		if (isAlias() && _basePeer == null) {
			return "${_alias}Peer";
		}
		if (_basePeer == null) {
			return getDatabase().getBasePeer();
		}
		return _basePeer;
	}

	void setBasePeer(String v) {
		_basePeer = v;
	}

	Column addColumn(Object data) {
		if (data is Column) {
			data.setTable(this);
			if (data.isInheritance()) {
				_inheritanceColumn = data;
			}
			if (_columnsByName.containsKey(data.getName())) {
				throw new ArgumentError("Duplicate column declared: ${data.getName()}");
			}
			_columnList.add(data);
			_columnsByName[data.getName()] = data;
			_columnsByLowercaseName[data.getName().toLowerCase()] = data;
			_columnsByDartName[data.getDartName()] = data;
			data.setPosition(_columnList.length);
			_needsTransactionInPostgres = (_needsTransactionInPostgres != null && _needsTransactionInPostgres) || data.requiresTransactionInPostgres();
			return data;
		} else {
			Column col = new Column();
			col.setTable(this);
			col.loadFromXML(data);
			return addColumn(col);
		}
	}

	void removeColumn(Object sentcol) {
		Column col;
		if (sentcol is String) {
			col = getColumn(sentcol);
		}
		if (sentcol is Column) {
			col = sentcol;
		}
		if (col == null || !_columnList.contains(col)) {
			throw new ArgumentError('No column named ${col.getName()} found in table ${getName()}');
		}
		_columnList.remove(col);
		_columnsByName.remove(col.getName());
		_columnsByLowercaseName.remove(col.getName().toLowerCase());
		_columnsByDartName.remove(col.getDartName());
		adjustColumnPositions();
	}

	void adjustColumnPositions() {
		int cnt = getNumColumns();
		for (int x = 0; x < cnt; ++x) {
			_columnList.elementAt(x).setPosition(x + 1);
		}
	}

	Validator addValidator(Object data) {
		if (data is Validator) {
			Column col = getColumn(data.getColumnName());
			if (col == null) {
				throw new ArgumentError('Failed adding validator to table "${getName()}": column "${data.getColumnName()}" does not exist!');
			}
			data.setColumn(col);
			data.setTable(this);
			_validatorList.add(data);
			return data;
		}
		Validator v = new Validator();
		v.setTable(this);
		v.loadFromXML(data);
		return addValidator(v);
	}

	void removeValidatorForColumn(String colName) {
		for(Validator v in _validatorList) {
			if (v.getColumnName() == colName) {
				_validatorList.remove(v);
			}
		}
	}

	ForeignKey addForeignKey(Object data) {
		if (data is ForeignKey) {
			data.setTable(this);
			_foreignKeys.add(data);
			if (_foreignTableNames == null) {
				_foreignTableNames = new List<String>();
			}
			if (!_foreignTableNames.contains(data.getForeignTableName())) {
				_foreignTableNames.add(data.getForeignTableName());
			}
			return data;
		}
		ForeignKey fk = new ForeignKey();
		fk.setTable(this);
		fk.loadFromXML(data);
		return addForeignKey(fk);
	}

	Column getChildrenColumn() => _inheritanceColumn;

	List<String> getChildrenNames() {
		if (_inheritanceColumn == null || _inheritanceColumn.isEnumeratedClasses()) {
			return null;
		}
		List<Inheritance> children = _inheritanceColumn.getChildren();
		List<String> names = new List<String>();
		for (int x = 0; x < children.length; ++x) {
			names.add(children.elementAt(x).runtimeType.toString());
		}
		return names;
	}

	void addRefferer(ForeignKey fk) {
		if (_referrers == null) {
			_referrers = new List<ForeignKey>();
		}
		_referrers.add(fk);
	}

	List<ForeignKey> getReferrers() => _referrers;

	void setupReferrers([bool throwErrors = false]) {
		for(ForeignKey fk in getForeignKeys()) {
			Table foreignTable = getDatabase().getTable(fk.getForeignTableName());
			if (foreignTable != null) {
				List<ForeignKey> referrers = getReferrers();
				if (referrers == null || !referrers.contains(fk)) {
					foreignTable.addRefferer(fk);
				}
			} else if (throwErrors) {
				throw new Exception('Table "${getName()}" contains a foreign key to nonexistent table "${fk.getForeignTableName()}"');
			}
			for(String colName in fk.getLocalColumns()) {
				Column col = getColumn(colName);
				if (col != null) {
					if (col.isPrimaryKey() && !getContainsForeignPK()) {
						setContainsForeignPK(true);
					}
				} else if (throwErrors) {
					throw new Exception('Table "${getName()}" contains a foreign key with nonexistent local column "${colName}"');
				}
			}
			for(String colName in fk.getForeignColumns()) {
				if (foreignTable == null) {
					return;
				}
				Column foreignCol = foreignTable.getColumn(colName);
				if (foreignCol != null) {
					if (!foreignCol.hasReferrer(fk)) {
						foreignCol.addReferrer(fk);
					}
				} else if (throwErrors) {
					throw new Exception('Table "${getName()}" contains a foreign key to table "${foreignTable.getName()}" with nonexistant column "${colName}"');
				}
			}

			if (getDatabase().getPlatform() is MysqlPlatform) {
				addExtraIndicies();
			}

		}
	}

	List<List<ForeignKey>> getCrossPks() {
		List<List<ForeignKey>> crossfks = new List<List<ForeignKey>>();
		for(ForeignKey fk in getReferrers()) {
			if (fk.getTable().getIsCrossRef()) {
				for(ForeignKey crossFk in fk.getOtherFKs()) {
					crossfks.add([fk, crossFk]);
				}
			}
		}
		return crossfks;
	}

	void setContainsForeignPK(bool b) {
		_containsForeignPK = b;
	}

	bool getContainsForeignPK() => _containsForeignPK != null && _containsForeignPK;

	List<String> getForeignTableNames() {
		if (_foreignTableNames == null) {
			_foreignTableNames = new List<String>();
		}
		return _foreignTableNames;
	}

	bool requiresTransactionInPostgres() => _needsTransactionInPostgres;

	IdMethodParameter addIdMethodParameter(Object data) {
		if (data is IdMethodParameter) {
			data.setTable(this);
			if (_idMethodParameters == null) {
				_idMethodParameters = new List<IdMethodParameter>();
			}
			_idMethodParameters.add(data);
			return data;
		}
		IdMethodParameter imp = new IdMethodParameter();
		imp.loadFromXML(data);
		return addIdMethodParameter(imp);
	}

	Index addIndex(Object data) {
		if (data is Index) {
			data.setTable(this);
			String name = data.getName();
			_indicies[name] = data;
			return data;
		}
		Index idx = new Index();
		idx.setTable(this);
		idx.loadFromXML(data);
		return addIndex(idx);
	}

	Unique addUnique(Object data) {
		if (data is Unique) {
			data.setTable(this);
			data.getName();
			_unices.add(data);
			return data;
		}

		Unique uniq = new Unique();
		uniq.setTable(this);
		uniq.loadFromXML(data);
		return addUnique(uniq);
	}

	Object getGeneratorConfig() => getDatabase().getAppData().getGeneratorConfig();

	Object addBehavior(Object data) {
		throw new UnimplementedError('Behaviors not implemented');
	}

	Map<String, Object> getBehaviors() => _behaviors;

	List<Object> getEarlyBehaviors() {
		throw new UnimplementedError('Behaviors not implemented');
	}

	bool hasBehavior(String name) => _behaviors.containsKey(name);

	Object getBehavior(String name) => _behaviors[name];

	bool hasAdditionalBuilders() {
		throw new UnimplementedError('Behaviors not implemented');
	}

	List<Object> getAdditionalBuilders() {
		throw new UnimplementedError('Behaviors not implemented');
	}

	String getName() {
		if (_schema != null && getDatabase() != null && getDatabase().getPlatform() != null && getDatabase().getPlatform().supportsSchemas()) {
			return "${_schema}.${_commonName}";
		}
		return _commonName;
	}

	String getDescription() => _description;

	bool hasDescription() => _description.isNotEmpty;

	void setDescription(String desc) {
		_description = desc;
	}

	String getDartName() {
		if (_dartName == null) {
			List<Object> inputs = new List<Object>();
			inputs.add(_getStdSeparatedName());
			inputs.add(_dartNamingMethod);
			_dartName = NameFactory.generateName(NameFactory.DART_GENERATOR, inputs);
		}
		return _dartName;
	}

	void setDartName(String v) {
		_dartName = v;
	}

	String buildDartName(String name) {
		return NameFactory.generateName(NameFactory.DART_GENERATOR, [name, _dartNamingMethod]);
	}

	String getStudlyDartName() {
		String name = getDartName();
		if (name.length > 1) {
			return "${name.substring(0,1).toLowerCase()}${name.substring(1)}";
		}
		return name.toLowerCase();
	}

	String getCommonName() => _commonName;

	void setCommonName(String v) {
		_commonName = v;
	}

	void setDefaultStringFormat(String format) {
		_defaultStringFormat = format;
	}

	String getDefaultStringFormat() {
		if (_defaultStringFormat == null && getDatabase() && getDatabase().getDefaultStringFormat()) {
			return getDatabase().getDefaultStringFormat();
		}
		return _defaultStringFormat;
	}

	String getIdMethod() {
		if (_idMethod == null) {
			return IDMethod.NO_ID_METHOD;
		}
		return _idMethod;
	}

	bool isAllowPkInsert() => _allowPkInsert;

	void setIdMethod(String method) {
		_idMethod = method;
	}

	bool isSkipSql() => _skipSql || isAlias() || isForReferenceOnly();

	bool isReadOnly() => _readOnly;

	void setSkipSql(bool v) {
		_skipSql = v;
	}

	bool isReloadOnUpdate() => _reloadOnUpdate;

	String getAlias() => _alias;

	bool isAlias() => _alias != null;

	void setAlias(String v) {
		_alias = v;
	}

	String getInterface() => _interface;

	void setInterface(String v) {
		_interface = v;
	}

	bool isAbstract() => _abstractValue;

	void setAbstract(bool v) {
		_abstractValue = v;
	}

	List<Column> getColumns() => _columnList;

	int getNumColumns() => _columnList.length;

	int getNumLazyLoadColumns() {
		int c = 0;
		for(Column col in _columnList) {
			if (col.isLazyLoad()) {
				++c;
			}
		}
		return c;
	}

	bool hasEnumColumns() {
		bool result = false;
		for(Column col in getColumns()) {
			if (col.isEnumType()) {
				result = true;
			}
		}
		return result;
	}

	List<Validator> getValidators() => _validatorList;

	List<ForeignKey> getForeignKeys() => _foreignKeys;

	List<IdMethodParameter> getIdMethodParamters() => _idMethodParameters;

	List<Index> getIndices() => _indicies.values.toList();

	List<Unique> getUnices() => _unices;

	bool hasColumn(Object col, [bool caseInsensitive = false]) {
		String name;
		if (col is Column) {
			name = col.getName();
		} else {
			name = col.toString();
		}
		if (caseInsensitive) {
			return _columnsByLowercaseName.containsKey(name.toLowerCase());
		}
		return _columnsByName.containsKey(name);
	}

	Column getColumn(String name, [bool caseInsensitive = false]) {
		if (hasColumn(name, caseInsensitive)) {
			if (caseInsensitive) {
				return _columnsByLowercaseName[name.toLowerCase()];
			} else {
				return _columnsByName[name];
			}
		}
		return null;
	}

	Column getColumnByDartName(String name) {
		if (_columnsByDartName.containsKey(name)) {
			return _columnsByDartName[name];
		}
		return null;
	}



	List<ForeignKey> getForeignKeysReferencingTable(String tableName) {
		return getForeignKeys().where((ForeignKey fk) => fk.getForeignTableName() == tableName);
	}

	List<ForeignKey> getColumnForeignKeys(String colName) {
		return getForeignKeys().where((ForeignKey fk) => fk.getLocalColumns().contains(colName));
	}

	Database getDatabase() => _database;

	void setDatabase(Database db) {
		_database = db;
	}

	bool isForReferenceOnly() => _forReferenceOnly;

	void setForReferenceOnly(bool v) {
		_forReferenceOnly = v;
	}

	String treeMode() => _treeMode;

	void setTreeMode(String v) {
		_treeMode = v;
	}

	@override
	void appendXml(XmlElement node) {
		XmlElement child = new XmlElement('table');

		child.attributes['name'] = getCommonName();

		if (getSchema() != null) {
			child.attributes['schema'] = getSchema();
		}

		if (_dartName != null) {
			child.attributes['dartName'] = _dartName;
		}

		if (_idMethod != null) {
			child.attributes['idMethod'] = _idMethod;
		}

		if (_skipSql != null) {
			child.attributes['skipSql'] = _skipSql.toString();
		}

		if (_readOnly != null) {
			child.attributes['readOnly'] = _readOnly.toString();
		}

		if (_treeMode != null) {
			child.attributes['treeMode'] = _treeMode;
		}

		if (_reloadOnInsert != null) {
			child.attributes['reloadOnInsert'] = _reloadOnInsert.toString();
		}

		if (_reloadOnUpdate != null) {
			child.attributes['reloadOnUpdate'] = _reloadOnUpdate.toString();
		}

		if (_forReferenceOnly != null) {
			child.attributes['forReferenceOnly'] = _forReferenceOnly.toString();
		}

		if (_abstractValue != null) {
			child.attributes['abstract'] = _abstractValue.toString();
		}

		if (_interface != null) {
			child.attributes['interface'] = _interface;
		}

		if (_description != null) {
			child.attributes['description'] = _description;
		}

		if (_baseClass != null) {
			child.attributes['baseClass'] = _baseClass;
		}

		if (_basePeer != null) {
			child.attributes['basePeer'] = _basePeer;
		}

		if (getIsCrossRef()) {
			child.attributes['isCrossRef'] = getIsCrossRef().toString();
		}

		for(Column c in _columnList)  {
			c.appendXml(child);
		};

		for(Validator v in _validatorList) {
			v.appendXml(child);
		}

		for(ForeignKey fk in _foreignKeys) {
			fk.appendXml(child);
		}

		for(IdMethodParameter p in _idMethodParameters) {
			p.appendXml(child);
		}

		for(Index v in _indicies.values) {
			v.appendXml(child);
		}

		for(Unique u in _unices) {
			u.appendXml(child);
		}

		for(VendorInfo vi in _vendorInfos.values) {
			vi.appendXml(child);
		}
		node.addChild(child);
	}

	List<Column> getPrimaryKey() {
		List<Column> pks = new List<Column>();
		for(Column c in _columnList) {
			if (c.isPrimaryKey()) {
				pks.add(c);
			}
		}
		return pks;
	}

	bool hasPrimaryKey() => getPrimaryKey().length > 0;

	bool hasCompositePrimaryKey() => getPrimaryKey().length > 1;

	bool hasAutoIncrementPrimaryKey() => getAutoIncrementPrimaryKey() != null;

	Column getAutoIncrementPrimaryKey() {
		Column pk;
		if(getIdMethod() != IDMethod.NO_ID_METHOD) {
			pk = getPrimaryKey().where((Column c) => c.isAutoIncrement()).first;
		}
		return pk;
	}

	bool getIsCrossRef() => _isCrossRef;

	void setIsCrossRef(bool v) {
		_isCrossRef = v;
	}



}
