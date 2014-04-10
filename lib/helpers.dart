part of database_reverse_engineer;

String addSlashes(String text) =>
	text.replaceAll(r'\', r'\\').replaceAll(r"'", r"\'").replaceAll(r'"', r'\"');