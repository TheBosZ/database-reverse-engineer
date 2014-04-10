part of database_reverse_engineer;

class Column extends PropelXmlElement {


	static const String DEFAULT_TYPE = "VARCHAR";
	static const String DEFAULT_VISIBILITY = 'public';
	static final List<String> valid_visibilities = ['public', 'protected', 'private'];

	String _name;
	String _description;
	String _dartName = null;
	String _dartNamingMethod;
	bool _isNotNull = false;
	String _size;
	String _namePrefix;
	String _accessorVisibility;
	String _mutatorVisibility;

	String _peerName;

	String _dartType;

	Table _parentTable;

	int _position;
	bool _isPrimaryKey = false;
	bool _isNodeKey = false;
	String _nodeKeySep;
	bool _isNestedSetLeftKey = false;
	bool _isNestedSetRightKey = false;
	bool _isTreeScopeKey = false;
	bool _isUnique = false;
	bool _isAutoIncrement = false;
	bool _isLazyLoad = false;
	String _defaultValue;
	List<ForeignKey> _referrers;
	bool _isPrimaryString = false;

	String _inheritanceType;
	bool _isInheritance;
	bool _isEnumeratedClasses;
	List<Inheritance> _inheritanceList;
	bool _needsTransactionInPostgres;

	List<String> _valueset = new List<String>();

	Domain _domain;

	Column([String this._name]): super('column');

	@override
	void _setupObject() {
		String dom = getAttribute('domain');
		if (dom != null) {
			getDomain().copy(getTable().getDatabase().getDomain(dom));
		} else {
			String type = getAttribute('type').toUpperCase();
			PropelPlatformInterface platform = getPlatform();
			if (type == null) {
				type = Column.DEFAULT_TYPE;
			}
			if (platform != null) {
				getDomain().copy(getPlatform().getDomainForType(type));
			} else {
				setDomain(new Domain(type));
			}
		}

		_name = getAttribute('name');
		_dartName = getAttribute('dartName');
		_dartType = getAttribute('dartType');

		if (getAttribute('prefix', null) != null) {
			_namePrefix = getAttribute('prefix');
		} else if (getTable().getAttribute('columnPrefix', null) != null) {
			_namePrefix = getTable().getAttribute('columnPrefix');
		} else {
			_namePrefix = '';
		}

		if (getAttribute('accessorVisibility', null) != null) {
			setAccessorVisibility(getAttribute('accessorVisibility'));
		} else if (getTable().getAttribute('defaultAccessorVisibility', null) != null) {
			setAccessorVisibility(getTable().getAttribute('defaultAccessorVisibility'));
		} else if (getTable().getDatabase().getAttribute('defaultAccessorVisibility', null) != null) {
			setAccessorVisibility(getTable().getDatabase().getAttribute('defaultAccessorVisibility'));
		} else {
			setAccessorVisibility(Column.DEFAULT_VISIBILITY);
		}

		if (getAttribute('mutatorVisibility', null) != null) {
			setMutatorVisibility(getAttribute('mutatorVisibility'));
		} else if (getTable().getAttribute('mutatorVisibility', null) != null) {
			setMutatorVisibility(getTable().getAttribute('mutatorVisibility'));
		} else if (getTable().getDatabase().getAttribute('mutatorVisibility', null) != null) {
			setMutatorVisibility(getTable().getDatabase().getAttribute('mutatorVisibility'));
		} else {
			setMutatorVisibility(Column.DEFAULT_VISIBILITY);
		}

		_peerName = getAttribute('peerName');

		_dartNamingMethod = getAttribute('dartNamingMethod', _parentTable.getDatabase().getDefaultDartNamingMethod());

		_isPrimaryString = _booleanValue(getAttribute('primaryString'));

		_isPrimaryKey = _booleanValue(getAttribute('primaryKey'));

		_isNodeKey = _booleanValue(getAttribute('nodeKey'));

		_nodeKeySep = getAttribute('nodeKeySep', '.');

		_isNestedSetLeftKey = _booleanValue(getAttribute('nestedSetLeftKey'));

		_isNestedSetRightKey = _booleanValue(getAttribute('nestedSetRightKey'));

		_isTreeScopeKey = _booleanValue(getAttribute('treeScopeKey'));

		_isNotNull = _booleanValue(getAttribute('required')) || _isPrimaryKey;

		_isAutoIncrement = _booleanValue(getAttribute('autoIncrement'));

		_isLazyLoad = _booleanValue(getAttribute('lazyLoad'));

		getDomain().replaceSqlType(getAttribute('sqlType'));
		int size;
		if (getAttribute('size') == null && getDomain().getType() == 'VARCHAR' && getAttribute('sqlType') == null) {
			size = 255;
		} else {
			size = int.parse(getAttribute('size'));
		}
		getDomain().replaceSize(size);
		getDomain().replaceScale(int.parse(getAttribute('scale')));

		String defValue = getAttribute('defaultValue', getAttribute('default'));
		if (defValue != null && defValue.toLowerCase() != 'null') {
			getDomain().setDefaultValue(new ColumnDefaultValue(defValue, ColumnDefaultValue.TYPE_VALUE));
		} else if (getAttribute('defaultExpr') != null) {
			getDomain().setDefaultValue(new ColumnDefaultValue(getAttribute('defaultExpr'), ColumnDefaultValue.TYPE_EXPR));
		}

		if (getAttribute('valueSet', null) != null) {
			List<String> valueSet = getAttribute('valueSet').split(',');
			_valueset = valueSet.map((String s) => s.trim()).toList();
		}

		_inheritanceType = getAttribute('inheritance');
		_isInheritance = _inheritanceType != null && _inheritanceType != null;
	}

	Domain getDomain() {
		if (_domain == null) {
			_domain = new Domain();
		}
		return _domain;
	}

	void setDomain(Domain d) {
		_domain = d;
	}

	String getFullyQualifiedName() => "${_parentTable.getName()}.${getName().toUpperCase()}";

	String getName() => _name;

	void setName(String s) {
		_name = s;
	}

	bool isNamePlurarl() => getSingularName() != _name;

	String getSingularName() {
		String name = _name.trim();
		if (name.endsWith('s')) {
			name = name.substring(0, name.lastIndexOf('s'));
		}
		return name;
	}

	String getDescription() => _description;

	void setDescription(String s) {
		_description = s;
	}

	String getDartName() {
		if (_dartName == null) {
			setDartName();
		}
		return _dartName;
	}

	void setDartName([String dartName = null]) {
		if (dartName == null) {
			_dartName = Column.generateDartName(_name, _dartNamingMethod, _namePrefix);
		} else {
			_dartName = dartName;
		}
	}

	String getStudlyDartName() {
		String name = getDartName();
		if (name.length > 1) {
			return "${name.substring(0,1).toLowerCase()}${name.substring(1)}";
		}
		return name.toLowerCase();
	}

	String getAccessorVisibility() => _accessorVisibility != null ? _accessorVisibility : Column.DEFAULT_VISIBILITY;

	void setAccessorVisibility(String newVis) {
		if (Column.valid_visibilities.contains(newVis)) {
			_accessorVisibility = newVis;
		} else {
			_accessorVisibility = Column.DEFAULT_VISIBILITY;
		}
	}

	String getMutatorVisibility() => _mutatorVisibility != null ? _mutatorVisibility : Column.DEFAULT_VISIBILITY;

	void setMutatorVisibility(String newVis) {
		if (Column.valid_visibilities.contains(newVis)) {
			_mutatorVisibility = newVis;
		} else {
			_mutatorVisibility = Column.DEFAULT_VISIBILITY;
		}
	}

	String getConstantName() => "${getTable().getDartName()}.${getConstantColumnName()}";

	String getConstantColumnName() => getPeerName() != null ? getPeerName().toUpperCase() : getName().toUpperCase();

	String getPeerName() => _peerName;

	void setPeerName(String v) {
		_peerName = v;
	}

	String getDartType() => _dartType != null ? _dartType : getDartNative();

	int getPosition() => _position;

	void setPosition(int v) {
		_position = v;
	}

	void setTable(Table parent) {
		_parentTable = parent;
	}

	Table getTable() => _parentTable;

	String getTableName() => _parentTable.getName();

	Inheritance addInheritance(Object data) {
		if (data is Inheritance) {
			data.setColumn(this);
			if (_inheritanceList == null) {
				_inheritanceList = new List<Inheritance>();
				_isEnumeratedClasses = true;
			}
			_inheritanceList.add(data);
			return data;
		}
		Inheritance inh = new Inheritance();
		inh.loadFromXML(data);
		return addInheritance(inh);
	}

	List<Inheritance> getChildren() => _inheritanceList;

	bool isInheritance() => _isInheritance;

	bool isEnumeratedClasses() => _isEnumeratedClasses;

	bool isNotNull() => _isNotNull;

	void setNotNull(bool s) {
		_isNotNull = s;
	}

	String getNotNullString() => getTable().getDatabase().getPlatform().getNullString(isNotNull());

	void setPrimaryString(bool v) {
		_isPrimaryString = v;
	}

	bool isPrimaryString() => _isPrimaryString;

	void setPrimaryKey(bool v) {
		_isPrimaryKey = v;
	}

	bool isPrimaryKey() => _isPrimaryKey;

	void setNodeKey(bool k) {
		_isNodeKey = k;
	}

	bool isNodeKey() => _isNodeKey;

	void setNodeKeySep(String sep) {
		_nodeKeySep = sep;
	}

	String getNodeKeySep() => _nodeKeySep;

	void setNestedSetLeftKey(bool k) {
		_isNestedSetLeftKey = k;
	}

	bool isNestedSetLeftKey() => _isNestedSetLeftKey;

	void setNestedSetRightKey(bool k) {
		_isNestedSetRightKey = k;
	}

	bool isNestedSetRightKey() => _isNestedSetRightKey;

	void setTreeScopeKey(bool k) {
		_isTreeScopeKey = k;
	}

	bool isTreeScopeKey() => _isTreeScopeKey;

	void setUnique(bool u) {
		_isUnique = u;
	}

	bool isUnique() => _isUnique;

	bool requiresTransactionInPostgres() => _needsTransactionInPostgres;

	bool isForeignKey() => getForeignKeys().length > 0;

	bool hasMultipleFK() => getForeignKeys().length > 1;

	List<ForeignKey> getForeignKeys() => _parentTable.getColumnForeignKeys(_name);

	void addReferrer(ForeignKey fk) {
		if (_referrers == null) {
			_referrers = new List<ForeignKey>();
		}
		_referrers.add(fk);
	}

	List<ForeignKey> getReferrers() {
		if (_referrers == null) {
			_referrers = new List<ForeignKey>();
		}
		return _referrers;
	}

	bool hasReferrers() => _referrers != null && _referrers.isNotEmpty;

	bool hasReferrer(ForeignKey fk) => hasReferrers() && _referrers.contains(fk);

	void clearReferrers() {
		_referrers = null;
	}

	void setDomainForType(String propelType) {
		getDomain().copy(getPlatform().getDomainForType(propelType));
	}

	void setType(String propelType) {
		getDomain().setType(propelType);
		if (propelType == PropelTypes.VARBINARY || propelType == PropelTypes.LONGVARBINARY || propelType == PropelTypes.BLOB) {
			_needsTransactionInPostgres = true;
		}
	}

	String getType() => getDomain().getType();

	String getDDOType() => PropelTypes.getDDOType(getType());

	String getPropelType() => getType();

	bool isLobType() => PropelTypes.isLobType(getType());

	bool isTextType() => PropelTypes.isTextType(getType());

	bool isNumericType() => PropelTypes.isNumericType(getType());

	bool isBooleanType() => PropelTypes.isBooleanType(getType());

	bool isTemporalType() => PropelTypes.isTemporalType(getType());

	bool isEnumType() => getType() == PropelTypes.ENUM;

	void setValueSet(List<String> vs) {
		_valueset = vs;
	}

	List<String> getValueSet() => _valueset;

	@override
	void appendXml(XmlElement node) {
		XmlElement child = new XmlElement('column');

		child.attributes['name'] = _name;

		if (_dartName != null) {
			child.attributes['dartName'] = _dartName;
		}

		child.attributes['type'] = getType();

		Domain domain = getDomain();

		if (domain.getSize() != null) {
			child.attributes['size'] = domain.getSize().toString();
		}

		if (domain.getScale() != null) {
			child.attributes['scale'] = domain.getScale().toString();
		}

		if (_description != null) {
			child.attributes['description'] = _description;
		}

		if (_isPrimaryKey) {
			child.attributes['primaryKey'] = _isPrimaryKey.toString();
		}

		if (_isAutoIncrement) {
			child.attributes['autoIncrement'] = _isAutoIncrement.toString();
		}

		child.attributes['required'] = _isNotNull ? 'true' : 'false';

		if (domain.getDefaultValue() != null) {
			ColumnDefaultValue def = domain.getDefaultValue();
			child.attributes[def.isExpression() ? 'defaultExpr' : 'defaultValue'] = def.getValue();
		}

		if (_isInheritance) {
			child.attributes['inheritance'] = _inheritanceType;
			_inheritanceList.forEach((Inheritance i) {
				i.appendXml(child);
			});
		}

		if (_isNodeKey) {
			child.attributes['nodeKey'] = 'true';
			if (getNodeKeySep() != null) {
				child.attributes['nodeKeySep'] = getNodeKeySep();
			}
		}

		_vendorInfos.forEach((String k, VendorInfo vi) {
			vi.appendXml(child);
		});

		node.addChild(child);
	}

	int getSize() => getDomain().getSize();

	void setSize(int s) {
		getDomain().setSize(s);
	}

	int getScale() => getDomain().getScale();

	void setScale(int v) {
		getDomain().setScale(v);
	}

	String printSize() => getDomain().printSize();

	String getDefaultValueString() {
		ColumnDefaultValue def = getDefaultValue();
		String result = 'null';
		if(def != null) {
			if(isNumericType()) {
				result = def.getValue();
			} else if(isTextType() || getDefaultValue().isExpression()) {
				result = "'${def.getValue().replaceAll(r"'", r"\'")}'";
			} else if(getType() == PropelTypes.BOOLEAN) {
				result = _booleanValue(def.getValue()) ? 'true' : 'false';
			} else {
				result = "'${def.getValue()}'";
			}
		}
		return result;
	}

	void setDefaultValue(Object def) {
		ColumnDefaultValue t;
		if(def is ColumnDefaultValue) {
			t = def;
		} else {
			t = new ColumnDefaultValue(def.toString(), ColumnDefaultValue.TYPE_VALUE);
		}
		getDomain().setDefaultValue(t);
	}

	ColumnDefaultValue getDefaultValue() => getDomain().getDefaultValue();

	Object getDartDefaultValue() => getDomain().getDartDefaultValue();

	bool isAutoIncrement() => _isAutoIncrement;

	bool isLazyLoad() => _isLazyLoad;

	String getAutoIncrementString() {
		if(_isAutoIncrement) {
			return getPlatform().getAutoIncrement();
		}
		return '';
	}

	String getDartNative() => PropelTypes.getDartNative(getType());


	bool isDartPrimitiveType() => PropelTypes.isDartPrimitiveType(getDartType());

	bool isDartPrimitiveNumericType() => PropelTypes.isDartPrimitiveNumericType(getDartType());

	bool isDartObjectType() => PropelTypes.isDartObjectType(getDartType());

	PropelPlatformInterface getPlatform() => getTable().getDatabase().getPlatform();

	Validator getValidator() {
		Validator result;
		getTable().getValidators().forEach((Validator v){
			if(v.getColumn() == this) {
				result = v;
			}
		});
		return result;
	}

	static String generateDartName(String name, [String dartNamingMethod = null, String prefix = null]) {
		return NameFactory.generateName(NameFactory.DART_GENERATOR, [name, dartNamingMethod != null ? dartNamingMethod : NameGenerator.CONV_METHOD_CLEAN, prefix ]);
	}
}
