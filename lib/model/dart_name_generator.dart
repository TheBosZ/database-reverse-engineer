part of database_reverse_engineer;

class DartNameGenerator implements NameGenerator {

	@override
	String generateName(List<String> inputs) {
		String schemaName = inputs.elementAt(0);
		String method = inputs.elementAt(1);

		if(inputs.length > 2) {
			String prefix = inputs.elementAt(2);
			if(prefix != null && prefix.isNotEmpty && schemaName.substring(0, prefix.length) == prefix) {
				schemaName = schemaName.substring(prefix.length);
			}
		}

		String dartName;

		switch(method) {
			case NameGenerator.CONV_METHOD_CLEAN:
				dartName = _cleanMethod(schemaName);
				break;
			case NameGenerator.CONV_METHOD_DARTNAME:
				dartName = _dartnameMethod(schemaName);
				break;
			case NameGenerator.CONV_METHOD_NOCHANGE:
				dartName = _nochangeMethod(schemaName);
				break;
			case NameGenerator.CONV_METHOD_UNDERSCORE:
			default:
				dartName = _underscoreMethod(schemaName);
				break;
		}
		return dartName;
	}

	/**
	 * Converts a database schema name to php object name by Camelization.
	 * Removes <code>STD_SEPARATOR_CHAR</code>, capitilizes first letter
	 * of name and each letter after the <code>STD_SEPERATOR</code>,
	 * converts the rest of the letters to lowercase.
	 *
	 * This method should be named camelizeMethod() for clarity
	 *
	 * my_CLASS_name -> MyClassName
	 *
	 * @param      string $schemaName name to be converted.
	 * @return     string Converted name.
	 * @see        NameGenerator
	 * @see        #underscoreMethod()
	 */
	String _underscoreMethod(String schemaName) {
		List<String> tokens = schemaName.split(NameGenerator.STD_SEPARATOR_CHAR);
		return tokens.map((String t) => NameGenerator.ucFirst(t.toLowerCase())).join('');
	}

	/**
	 * Converts a database schema name to php object name.  Removes
	 * any character that is not a letter or a number and capitilizes
	 * first letter of the name, the first letter of each alphanumeric
	 * block and converts the rest of the letters to lowercase.
	 *
	 * T$NAMA$RFO_max => TNamaRfoMax
	 *
	 * @param      string $schemaName name to be converted.
	 * @return     string Converted name.
	 * @see        NameGenerator
	 * @see        #underscoreMethod()
	 */
	String _cleanMethod(String schemaName) {
		List<String> tokens = schemaName.split(new RegExp("[^A-Z0-9]", caseSensitive: false));
		if(tokens.length < 2) {
			return schemaName;
		}
		return tokens.map((String t) => NameGenerator.ucFirst(t.toLowerCase())).join('');
	}

	/**
	 * Converts a database schema name to php object name.  Operates
	 * same as underscoreMethod but does not convert anything to
	 * lowercase.
	 *
	 * my_CLASS_name -> MyCLASSName
	 *
	 * @param      string $schemaName name to be converted.
	 * @return     string Converted name.
	 * @see        NameGenerator
	 * @see        #underscoreMethod(String)
	 */
	String _dartnameMethod(String schemaName) {
		List<String> tokens = schemaName.split(NameGenerator.STD_SEPARATOR_CHAR);
        return tokens.map((String t) => NameGenerator.ucFirst(t)).join('');
	}

	/**
	 * Converts a database schema name to PHP object name.  In this
	 * case no conversion is made.
	 *
	 * @param      string $name name to be converted.
	 * @return     string The <code>name</code> parameter, unchanged.
	 */
	String _nochangeMethod(String name) {
		return name;
	}
}
