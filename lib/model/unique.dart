part of database_reverse_engineer;

class Unique extends Index {
	Unique([String name = null]): super('name');

	bool isUnique() => true;

	void appendXml(XmlElement node) {
		node.addChild(new XmlElement('unique'));
		node.attributes['name'] = getName();
		for(Column c in getColumns()) {
			String name = c.getName();
			XmlElement uniq = new XmlElement('unique-column');
			uniq.attributes['name'] = name;
			node.addChild(uniq);
		}

		_vendorInfos.forEach((String f, VendorInfo vi) {
			vi.appendXml(node);
		});
	}

}
