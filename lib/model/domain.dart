part of database_reverse_engineer;

class Domain extends PropelXmlElement {
	Domain([String this._propelType = null, String this._sqlType = null, int this._size = null, int this._scale = null]): super('domain') {
		_sqlType = _sqlType != null ? _sqlType : _propelType;
	}

	/**
	 * @var        string The name of this domain
	 */
	String _name;

	/**
	 * @var        string Description for this domain.
	 */
	String _description;

	/**
	 * @var        int Size
	 */
	int _size;

	/**
	 * @var        int Scale
	 */
	int _scale;

	/**
	 * @var        String Propel type from schema
	 */
	String _propelType;

	/**
	 * @var        string The SQL type to use for this column
	 */
	String _sqlType;

	/**
	 * @var        ColumnDefaultValue A default value
	 */
	ColumnDefaultValue _defaultValue;

	/**
	 * @var        Database
	 */
	Database _database;

	void copy(Domain other) {
		_defaultValue = other.getDefaultValue();
		_description = other.getDescription();
		_name = other.getName();
		_scale = other.getScale();
		_size = other.getSize();
		_sqlType = other.getSqlType();
		_propelType = other.getType();
	}




	@override
	void _setupObject() {
		String schemaType = getAttribute('type').toUpperCase();
		copy(getDatabase().getPlatform().getDomainForType(schemaType));

		_name = getAttribute('name');

		String defValue = getAttribute('defaultValue', getAttribute('default'));
		if(defValue != null) {
			setDefaultValue(new ColumnDefaultValue(defValue, ColumnDefaultValue.TYPE_VALUE));
		} else if(getAttribute('defaultExpr') != null) {
			setDefaultValue(new ColumnDefaultValue(getAttribute('defaultExpr'), ColumnDefaultValue.TYPE_EXPR));
		}

		_size = int.parse(getAttribute('size'));
		_scale = int.parse(getAttribute('scale'));
		_description = getAttribute('description');
	}

	void setDatabase(Database dbase) {
		_database = dbase;
	}

	Database getDatabase() => _database;

	String getDescription() => _description;

	void setDescription(String desc) {
		_description = desc;
	}

	String getName() => _name;

	void setName(String v) {
		_name = v;
	}

	int getScale() => _scale;

	void setScale(int v) {
		_scale = v;
	}

	void replaceScale(int v) {
		if(v != null) {
			_scale = v;
		}
	}

	int getSize() => _size;

	void setSize(int v) {
		_size = v;
	}

	void replaceSize(int v) {
		if(v != null) {
			_size = v;
		}
	}

	String getType() => _propelType;

	void setType(String t) {
		_propelType = t;
	}

	void replaceType(String t) {
		if(t != null) {
			_propelType = t;
		}
	}

	ColumnDefaultValue getDefaultValue() => _defaultValue;

	Object getDartDefaultValue() {
		if(_defaultValue == null) {
			return null;
		}
		if(_defaultValue.isExpression()) {
			throw new Exception('Cannot get Dart version of default value for Expressions');
		}
		if(PropelTypes.BOOLEAN == _propelType || PropelTypes.BOOLEAN_EMU == _propelType) {
			return _booleanValue(_defaultValue.getValue());
		}
		return _defaultValue.getValue();
	}

	void setDefaultValue(ColumnDefaultValue val) {
		_defaultValue = val;
	}

	void replaceDefaultValue([ColumnDefaultValue val = null]) {
		if(val != null) {
			_defaultValue = val;
		}
	}

	String getSqlType() => _sqlType;

	void setSqlType(String t) {
		_sqlType = t;
	}

	void replaceSqlType(String t) {
		if(t != null) {
			_sqlType = t;
		}
	}

	String printSize() {
		if(_size != null && _scale != null) {
			return "(${_size.toString()},${_scale.toString()})";
		}
		if(_size != null) {
			return "(${_size.toString()})";
		}
		return "";
	}

	@override
    	void appendXml(XmlElement node) {
    		XmlElement child = new XmlElement('domain');

    		child.attributes['type'] = getType();
    		child.attributes['name'] = getName();

    		if(_sqlType != getType()) {
    			child.attributes['sqlType'] = _sqlType;
    		}

    		ColumnDefaultValue def = getDefaultValue();
    		if(def != null) {
    			if(def.isExpression()) {
    				child.attributes['defaultExpr'] = def.getValue();
    			} else {
    				child.attributes['defaultValue'] = def.getValue();
    			}
    		}

    		if(_size != null) {
    			child.attributes['size'] = _size.toString();
    		}

    		if(_scale != null) {
    			child.attributes['scale'] = _scale.toString();
    		}

    		if(_description != null) {
    			child.attributes['description'] = _description;
    		}

    		node.addChild(child);
    	}
}
