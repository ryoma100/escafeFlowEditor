package org.escafe.burieditor.xpdl
{
	import org.escafe.burieditor.application.EmbeddedBuriEditor;

public class XpdlWriter
{
	private var _rootPackage: EmbeddedBuriEditor;
	
	/**
	 * @category initialize
	 */
	public function XpdlWriter(aRootPackage: EmbeddedBuriEditor): void {
		_rootPackage = aRootPackage;
	}

	/**
	 * @category xpdl writer
	 */
	public function writeXpdlString(): String {
		var xml: XML = <Package/>
		_rootPackage.writeXpdl(xml);
		
		var header: String = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>\n';
		header += '<Package xmlns="http://www.wfmc.org/2002/XPDL1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ';
		header += 'Id="' + _rootPackage.xpdlId + '" Name="' + _rootPackage.packageName+ '" xsi:schemaLocation="http://www.wfmc.org/2002/XPDL1.0 http://wfmc.org/standards/docs/TC-1025_schema_10_xpdl.xsd">\n';

		var string: String = xml.toString();
		string = string.substr(string.indexOf("<PackageHeader") - 2);
		string = header + string;
		return string;
	}
}
}