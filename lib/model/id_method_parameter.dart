part of database_reverse_engineer;

class IdMethodParameter extends PropelXmlElement {
	IdMethodParameter(): super('id-method-parameter');

	String _name;
	String _value;
	Table _parentTable;

	@override
	void _setupObject() {
		_name = getAttribute('name');
		_value = getAttribute('value');
	}

	String getName() => _name;

	void setName(String n) {
		_name = n;
	}

	String getValue() => _value;

	void setValue(String v) {
		_value = v;
	}

	void setTable(Table t) {
		_parentTable = t;
	}

	Table getTable() => _parentTable;

	@override
	void appendXml(XmlElement node) {
		XmlElement child = new XmlElement('id-method-parameter');

		if(getName() != null) {
			child.attributes['name'] = getName();
		}
		if(getValue() != null) {
			child.attributes['value'] = getValue();
		}
		node.addChild(child);
	}
}
