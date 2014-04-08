part of database_reverse_engineer;

abstract class ScopedElement extends PropelXmlElement {
	/**
	 * The package for the generated OM.
	 *
	 * @var       string
	 */
	String _pkg;

	/**
	 * Whether the package was automatically overridden.
	 * If propel.schema.autoPackage or propel.namespace.AutoPackage is true.
	 */
	bool _pkgOverridden = false;

	/**
	 * Namespace for the generated OM.
	 *
	 * @var       string
	 */
	String _namespace;

	/**
	 * Schema this element belongs to.
	 *
	 * @var       string
	 */
	String _schema;

	ScopedElement(String name): super(name);

	/**
	 * retrieves a build property.
	 *
	 * @param unknown_type $name
	 */
	Object getBuildProperty($name);

	/**
	 * Sets up the Rule object based on the attributes that were passed to loadFromXML().
	 * @see       parent::loadFromXML()
	 */
	void setupObject() {
		setPackage(getAttribute("package", _pkg));
		setSchema(getAttribute("schema", _schema));
		setNamespace(getAttribute("namespace", _namespace));
	}

	/**
	 * Get the value of the namespace.
	 * @return     value of namespace.
	 */
	String getNamespace() => _namespace;

	/**
	 * Set the value of the namespace.
	 * @param      v  Value to assign to namespace.
	 */
	void setNamespace(String v) {
		if (v == _namespace) {
			return;
		}
		_namespace = v;
		if (v != null && (_pkg != null || _pkgOverridden) && getBuildProperty('namespaceAutoPackage') != null) {
			_pkg = v.replaceAll('\\', '.');
			_pkgOverridden = true;
		}
	}

	/**
	 * Get the value of package.
	 * @return     value of package.
	 */
	String getPackage() {
		return _pkg;
	}

	/**
	 * Set the value of package.
	 * @param      v  Value to assign to package.
	 */
	void setPackage(String v) {
		if (v == _pkg) {
			return;
		}
		_pkg = v;
		_pkgOverridden = false;
	}

	/**
	 * Get the value of schema.
	 * @return     value of schema.
	 */
	String getSchema() => _schema;

	/**
	 * Set the value of schema.
	 * @param      v  Value to assign to schema.
	 */
	void setSchema(String v) {
		if (v == _schema) {
			return;
		}
		_schema = v;
		if (v != null && _pkg != null && getBuildProperty('schemaAutoPackage') != null) {
			_pkg = v;
			_pkgOverridden = true;
		}
		if (v != null && _namespace != null && getBuildProperty('schemaAutoNamespace') != null) {
			_namespace = v;
		}
	}
}
