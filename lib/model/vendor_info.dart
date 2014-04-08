part of database_reverse_engineer;

class VendorInfo extends PropelXmlElement {

	String _type;
	Map<String, String> _parameters = new Map<String, String>();

	VendorInfo([String this._type = null]) : super('VendorInfo');

	void _setupObject() {
		_type = attributes['type'];
	}

	void setType(String v) {
		_type = v;
	}

	String getType() {
		return _type;
	}

	void addParameter(Map<String, String> attrib) {
		_parameters[attrib['name'].toString()] = attrib['value'];
	}

	void setParameter(String name, String value) {
		_parameters[name] = value;
	}

	String getParameter(String name) {
		if(_parameters.containsKey(name)) {
			return _parameters[name];
		}
		return null;
	}

	bool hasParameter(String name) {
		return _parameters.containsKey(name);
	}

	void setParameters([Map<String, String> params = null]) {
		_parameters.clear();
		if(params != null) {
			_parameters.addAll(params);
		}
	}

	Map<String, String> getParameters() {
		return _parameters;
	}

	bool isEmpty() {
		return _parameters.isEmpty;
	}

	VendorInfo getMergedVendorInfo(VendorInfo merge) {
		Map<String, Object> params1 = getParameters();
		params1.addAll(merge.getParameters());
		VendorInfo newinfo = new VendorInfo(_type);
		newinfo.setParameters(params1);
		return newinfo;
	}

	void appendXml(XmlElement node) {
		node.addChild(new XmlElement("vendor"));
		node.attributes.addAll({'type': getType()});
		_parameters.forEach((String key, String value) {
			XmlElement par = new XmlElement('parameter');
			par.attributes['name'] = key;
			par.attributes['value'] = value;
			node.addChild(par);
		});
	}


}
