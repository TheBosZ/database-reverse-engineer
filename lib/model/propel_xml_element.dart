part of database_reverse_engineer;

abstract class PropelXmlElement extends XmlElement {

	Map<String, VendorInfo> _vendorInfos = new Map<String, VendorInfo>();

	PropelXmlElement(String name) : super(name);

	void setupObject();

	void loadFromXML(Map<String, String> other) {
		this.attributes.clear();
		this.attributes.addAll(other);
		setupObject();
	}

	Map<String, String> getAttributes() {
		return attributes;
	}

	String getAttribute(String name, [String defaultValue = null]) {
		String key = name.toLowerCase();
		if (attributes.containsKey(key)) {
			return attributes[key];
		}
		return defaultValue;
	}

	bool _booleanValue(Object val) {
		if (val is num) {
			return val != 0;
		}
		if (val is String) {
			return ['true', 't', 'y', 'yes'].contains(val);
		}
		return false;
	}

	void appendXml(XmlElement node);

	VendorInfo addVendorInfo(Object data) {
		if (data is VendorInfo) {
			_vendorInfos[data.getType()] = data;
			return data;
		}
		VendorInfo vi = new VendorInfo();
		vi.loadFromXML(data);
		return addVendorInfo(vi);
	}

	VendorInfo getVendorInfoForType(String type) {
		if(_vendorInfos.containsKey(type)) {
			return _vendorInfos[type];
		}
		return new VendorInfo();
	}

	String toString() {
		XmlElement doc = new XmlElement('');
		appendXml(doc);
		return doc.toString();
	}
}
