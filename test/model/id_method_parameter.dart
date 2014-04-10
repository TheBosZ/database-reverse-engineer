import 'package:database_reverse_engineer/database_reverse_engineer.dart';
import 'package:unittest/unittest.dart';

void main() {
	IdMethodParameter obj = new IdMethodParameter();

	XmlElement node = new XmlElement('base');
	obj.appendXml(node);
	test('append empty IMP', () {
		expect(node.children.length, equals(1));
		expect(node.toString(), equals('\r<base>\r   <id-method-parameter></id-method-parameter>\r</base>'));
	});

	test('append named IMP', () {
		node = new XmlElement('base');
    	obj = new IdMethodParameter();
    	obj.setName('test');
    	obj.appendXml(node);
    	expect(node.children.length, equals(1));
    	expect(node.toString(), equals('\r<base>\r   <id-method-parameter name="test"></id-method-parameter>\r</base>'));
	});

}