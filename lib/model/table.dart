part of database_reverse_engineer;

class Table extends ScopedElement implements IDMethod {
	Table([String this._commonName = null]): super('Table');

	String _commonName;

	@override
	void appendXml(XmlElement node) {
		// TODO: implement appendXml
	}

	@override
	Object getBuildProperty($name) {
		// TODO: implement getBuildProperty
	}
}
