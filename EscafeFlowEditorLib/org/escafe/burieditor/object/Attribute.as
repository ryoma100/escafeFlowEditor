package org.escafe.burieditor.object
{
	
public class Attribute
{
	private var _name: String;
	private var _value: String;
	
	public function get name(): String {
		return _name;
	}
	
	public function set name(newName: String): void {
		_name = newName;
	}
	
	public function get value(): String {
		return _value;
	}
	
	public function set value(newValue: String): void {
		_value = newValue;
	}
}
}