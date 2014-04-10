part of database_reverse_engineer;

class Inheritance extends PropelXmlElement {
	Inheritance(): super('inheritance');

	String _key;
	String _className;
	String _pkg;
	String _ancestor;
	Column _parent;

	@override
	void _setupObject() {
		_key = getAttribute('key');
		_className = getAttribute('class');
		_pkg = getAttribute('package');
		_ancestor = getAttribute('extends');
	}

	String getKey() => _key;

	void setKey(String k) {
		_key = k;
	}

	Column getColumn() => _parent;

	void setColumn(Column v) {
		_parent = v;
	}

	String getClassName() => _className;

	void setClassName(String v) {
		_className = v;
	}

	String getPackage() => _pkg;

	void setPackage(String v) {
		_pkg = v;
	}

	String getAncestor() => _ancestor;

	void setAncestor(String v) {
		_ancestor = v;
	}

	@override
	void appendXml(XmlElement node) {
		XmlElement child = new XmlElement('inheritance');
		child.attributes['key'] = _key;
		child.attributes['class'] = _className;
		if(_ancestor != null) {
			child.attributes['extends'] = _ancestor;
		}

		node.addChild(child);
	}
}
