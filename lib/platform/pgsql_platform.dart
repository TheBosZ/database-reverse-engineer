part of database_reverse_engineer;

class PgsqlPlatform extends DefaultPlatform {

	void initialize() {
		super.initialize();
		setSchemaDomainMapping(new Domain(PropelTypes.BOOLEAN, "BOOLEAN"));
		setSchemaDomainMapping(new Domain(PropelTypes.TINYINT, "INT2"));
		setSchemaDomainMapping(new Domain(PropelTypes.SMALLINT, "INT2"));
		setSchemaDomainMapping(new Domain(PropelTypes.BIGINT, "INT8"));
		setSchemaDomainMapping(new Domain(PropelTypes.REAL, "FLOAT"));
		setSchemaDomainMapping(new Domain(PropelTypes.DOUBLE, "DOUBLE PRECISION"));
		setSchemaDomainMapping(new Domain(PropelTypes.FLOAT, "DOUBLE PRECISION"));
		setSchemaDomainMapping(new Domain(PropelTypes.LONGVARCHAR, "TEXT"));
		setSchemaDomainMapping(new Domain(PropelTypes.BINARY, "BYTEA"));
		setSchemaDomainMapping(new Domain(PropelTypes.VARBINARY, "BYTEA"));
		setSchemaDomainMapping(new Domain(PropelTypes.LONGVARBINARY, "BYTEA"));
		setSchemaDomainMapping(new Domain(PropelTypes.BLOB, "BYTEA"));
		setSchemaDomainMapping(new Domain(PropelTypes.CLOB, "TEXT"));
		setSchemaDomainMapping(new Domain(PropelTypes.OBJECT, "TEXT"));
		setSchemaDomainMapping(new Domain(PropelTypes.DART_ARRAY, "TEXT"));
		setSchemaDomainMapping(new Domain(PropelTypes.ENUM, "INT2"));
	}

	String getNativeIdMethod() => PropelPlatformInterface.SERIAL;

	String getAutoIncrement() => '';

	int getMaxColumnNameLength() => 32;

	String disconnectedEscapeText(String text) => super._disconnectedEscapeText(text);

	String getBooleanString(Object b) => super.getBooleanString(b) == '1' ? "'t'" : "'f'";

	bool supportsNativeDeleteTrigger() => true;

	String getSequenceName(Table table) {
		String result;

		if (table.getIdMethod() == IDMethod.NATIVE) {
			List<IdMethodParameter> idMethodParams = table.getIdMethodParamters();
			if (idMethodParams.isEmpty) {
				for (Column col in table.getColumns()) {
					if (col.isAutoIncrement()) {
						result = "${table.getName()}_${col.getName()}_seq";
						break;
					}
				}
			} else {
				result = idMethodParams.first.getValue();
			}
		}

		return result;
	}

	String getAddSequenceDDL(Table table) {
		if (table.getIdMethod() == IDMethod.NATIVE && table.getIdMethodParamters() != null) {
			return "\nCREATE SEQUENCE ${quoteIdentifier(getSequenceName(table).toLowerCase())};\n";
		}
		return '';
	}

	String getDropSequenceDDL(Table table) {
		if (table.getIdMethod() == IDMethod.NATIVE && table.getIdMethodParamters() != null) {
			return "\nDROP SEQUENCE ${quoteIdentifier(getSequenceName(table).toLowerCase())};\n";
		}
		return '';
	}

	String getAddSchemasDDL(Database database) {
		StringBuffer ret = new StringBuffer();
		List<String> usedSchemas = new List<String>();

		for (Table table in database.getTables()) {
			VendorInfo vi = table.getVendorInfoForType('pgsql');
			if (vi.hasParameter('schema') && !usedSchemas.contains(vi.getParameter('schema'))) {
				usedSchemas.add(vi.getParameter('schema'));
				ret.write(getAddSchemaDDL(table));
			}
		}
		return ret.toString();
	}

	String getAddSchemaDDL(Table table) {
		VendorInfo vi = table.getVendorInfoForType('pgsql');
		if (vi.hasParameter('schema')) {
			return "\nCREATE SCHEMA ${quoteIdentifier(vi.getParameter('schema'))};\n";
		}
		return '';
	}

	String getUseSchemaDDL(Table table) {
		VendorInfo vi = table.getVendorInfoForType('pgsql');
		if (vi.hasParameter('schema')) {
			return "\nSET search_path TO ${quoteIdentifier(vi.getParameter('schema'))};\n";
		}
		return '';
	}

	String getResetSchemaDDL(Table table) {
		VendorInfo vi = table.getVendorInfoForType('pgsql');
		if (vi.hasParameter('schema')) {
			return "\nSET search_path TO public;\n";
		}
		return '';
	}

	String getAddTablesDDL(Database database) {
		StringBuffer ret = new StringBuffer(getBeginDDL());
		ret.write(getAddSchemasDDL(database));
		for (Table table in database.getTablesForSql()) {
			ret.write(getCommentBlockDDL(table.getName()));
			ret.write(getDropTableDDL(table));
			ret.write(getAddTableDDL(table));
			ret.write(getAddIndicesDDL(table));
		}
		for (Table table in database.getTablesForSql()) {
			ret.write(getAddForeignKeysDDL(table));
		}
		ret.write(getEndDDL());
		return ret.toString();
	}

	String getAddTableDDL(Table table) {
		StringBuffer ret = new StringBuffer();

		ret.write(getUseSchemaDDL(table));
		ret.write(getAddSequenceDDL(table));

		List<String> lines = new List<String>();
		for (Column column in table.getColumns()) {
			lines.add(getColumnDDL(column));
		}

		if (table.hasPrimaryKey()) {
			lines.add(getPrimaryKeyDDL(table));
		}

		for (Unique unique in table.getUnices()) {
			lines.add(getUniqueDDL(unique));
		}

		ret.write("\nCREATE TABLE");
		ret.write(quoteIdentifier(table.getName()));
		ret.write("\n(\n\t");
		ret.write(lines.join(",\n\t"));
		ret.write(");\n");

		if (table.hasDescription()) {
			ret.write("\nCOMMENT ON TABLE ");
			ret.write(quoteIdentifier(table.getName()));
			ret.write(" IS ");
			ret.write(quote(table.getDescription()));
			ret.write(");\n");
		}

		ret.write(getAddColumnsComments(table));
		ret.write(getResetSchemaDDL(table));
		return ret.toString();
	}

	String getAddColumnsComments(Table table) {
		StringBuffer ret = new StringBuffer();
		for (Column column in table.getColumns()) {
			ret.write(getAddColumnComment(column));
		}
		return ret.toString();
	}

	String getAddColumnComment(Column column) {
		String description = column.getDescription();
		if (description.isNotEmpty) {
			return "\nCOMMENT ON COLUMN ${quoteIdentifier(column.getTable().getName())}.${column.getName()} is ${quote(description)};\n";
		}
		return '';
	}

	String getDropTableDDL(Table table) {
		StringBuffer ret = new StringBuffer();
		ret.write(getUseSchemaDDL(table));

		ret.write("\nDROP TABLE ${quoteIdentifier(table.getName())} CASCADE);\n");
		ret.write(getDropSequenceDDL(table));
		ret.write(getResetSchemaDDL(table));
		return ret.toString();
	}

	String getPrimaryKeyName(Table table) => "${table.getName()}_pkey";

	String getColumnDDL(Column col) {
		Domain domain = col.getDomain();

		List<String> ddl = new List<String>();
		ddl.add(quoteIdentifier(col.getName()));
		String sqlType = domain.getSqlType();
		Table table = col.getTable();

		if (col.isAutoIncrement() && table != null && table.getIdMethodParamters() == null) {
			sqlType = col.getType() == PropelTypes.BIGINT ? 'bigserial' : 'serial';
		}

		if (hasSize(sqlType)) {
			ddl.add("${sqlType}${domain.printSize()}");
		} else {
			ddl.add(sqlType);
		}

		String def = getColumnDefaultValueDDL(col);
		if (def != null && def.isNotEmpty) {
			ddl.add(def);
		}

		String notNull = getNullString(col.isNotNull());
		if (notNull != null && notNull.isNotEmpty) {
			ddl.add(notNull);
		}

		String autoIncrement = col.getAutoIncrementString();
		if (autoIncrement != null && autoIncrement.isNotEmpty) {
			ddl.add(autoIncrement);
		}

		return ddl.join(' ');
	}

	String getUniqueDDL(Unique unique) => "CONSTRAINT ${quoteIdentifier(unique.getName())} UNIQUE (${getColumnListDDL(unique.getColumns())})";

	bool supportsSchemas() => true;

	bool hasSize(String sqlType) => !["BYTEA", "TEXT", "DOUBLE PRECISION"].contains(sqlType);

	bool hasStreamBlobImpl() => true;

	String getModifyColumnDDL(PropelColumnDiff columnDiff) {
		StringBuffer ret = new StringBuffer();

		Map<String, List<String>> changedProperties = columnDiff.getChangedProperties();

		Column toColumn = columnDiff.getToColumn();
		Table table = toColumn.getTable();
		String quotedTable = quoteIdentifier(table.getName());

		String colName = quoteIdentifier(toColumn.getName());
		String alterColumn;
		for(String key in changedProperties.keys) {
			alterColumn = '';
			switch(key) {
				case 'defaultValueType':
					continue;
				case 'size':
				case 'type':
				case 'scale':
					String sqlType = toColumn.getDomain().getSqlType();
					if (toColumn.isAutoIncrement() && table != null && table.getIdMethodParamters() == null) {
						sqlType = toColumn.getType() == PropelTypes.BIGINT ? 'bigserial' : 'serial';
					}
					if (hasSize(sqlType)) {
						sqlType = "${sqlType}${toColumn.getDomain().printSize()}";
					}
					alterColumn = "${colName} TYPE ${sqlType}";
					break;
				case 'defaultValueValue':
					alterColumn = "${colName} SET ${getColumnDefaultValueDDL(toColumn)}";
					break;
				case 'notNull':
					String notNull = " DROP NOT NULL";
					if (changedProperties[key][1] != null) {
						notNull = " SET NOT NULL";
					}
					alterColumn = "${colName}${notNull}";
					break;
			}
			ret.write("\nALTER TABLE ");
			ret.write(quotedTable);
			ret.write(" ALTER COLUMN ");
			ret.write(alterColumn);
			ret.write(";\n");
		}

		return ret.toString();
	}

	String getModifyColumnsDDL(List<PropelColumnDiff> columnDiffs) {
		StringBuffer ret = new StringBuffer();
		for(PropelColumnDiff diff in columnDiffs) {
			ret.write(getModifyColumnDDL(diff));
		}
		return ret.toString();
	}

	String getAddColumnsDDL(List<Column> columns) {
		StringBuffer ret = new StringBuffer();
		for(Column column in columns) {
			ret.write(getAddColumnDDL(column));
		}
		return ret.toString();
	}

	String getDropIndexDDL(Index index) {
		if(index is Unique) {
			return "\nALTER TABLE ${quoteIdentifier(index.getTable().getName())} DROP CONSTRAINT ${index.getName()};\n";
		}
		return super.getDropIndexDDL(index);
	}

}
