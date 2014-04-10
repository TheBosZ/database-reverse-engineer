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

	String _position;
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
	String _referrers;
	bool _isPrimaryString = false;

	String _inheritanceType;
	bool _isInheritance;
	String _isEnumeratedClasses;
	List<Inheritance> _inheritanceList;
	String _needsTransactionInPostgres;

	List<String> _valueset = new List<String>();

	Domain _domain;

	Column(String this._name): super('column');



	@override
	void appendXml(XmlElement node) {
		// TODO: implement appendXml
	}

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
		if(getAttribute('size') == null && getDomain().getType() == 'VARCHAR' && getAttribute('sqlType') == null) {
			size = 255;
		} else {
			size = getAttribute('size');
		}
		getDomain().replaceSize(size);
		getDomain().replaceScale(getAttribute('scale'));

		String defValue = getAttribute('defaultValue', getAttribute('default'));
		if(defValue != null && defValue.toLowerCase() != 'null') {
			getDomain().setDefaultValue(new ColumnDefaultValue(defValue, ColumnDefaultValue.TYPE_VALUE));
		} else if(getAttribute('defaultExpr') != null) {
			getDomain().setDefaultValue(new ColumnDefaultValue(getAttribute('defaultExpr'), ColumnDefaultValue.TYPE_EXPR));
		}

		if(getAttribute('valueSet', null) != null) {
			List<String> valueSet = getAttribute('valueSet').split(',');
			_valueset = valueSet.map((String s) => s.trim()).toList();
		}

		_inheritanceType = getAttribute('inheritance');
		_isInheritance = _inheritanceType != null && _inheritanceType != null;
	}

	Domain getDomain() {
		if(_domain == null) {
			_domain = new Domain();
		}
		return _domain;
	}

	void setDomain(Domain d) {
		_domain = d;
	}
}
