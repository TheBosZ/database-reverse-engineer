part of database_reverse_engineer;

String addSlashes(String text) =>
	text.replaceAll(r'\', r'\\').replaceAll(r"'", r"\'").replaceAll(r'"', r'\"');

bool isInt(String str) {
	try {
		int.parse(str);
		return true;
	} catch(e) {
		return false;
	}
}