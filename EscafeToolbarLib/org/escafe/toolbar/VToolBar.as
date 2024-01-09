package org.escafe.toolbar
{
	import mx.containers.VBox;
	import mx.events.FlexEvent;
	import flash.events.Event;
	import mx.controls.Button;
	import flash.events.MouseEvent;
	import mx.states.AddChild;
	import mx.events.CollectionEvent;

public class VToolBar extends VBox
{
	private var _buttonId: String;
	private var _func: Function;
	
	public function VToolBar(): void {
		super();
		addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
	}

	private function onCreationComplete(event: Event): void {
		var isFirstButton: Boolean = true;
		for each (var object: Object in getChildren()) {
			if (object is Button) {
				var button: Button = object as Button;
				button.toggle = true;
				button.selected = isFirstButton;
				isFirstButton = false;
				button.addEventListener(MouseEvent.CLICK, onButtonClick);
			}
		}
	}
	
	private function onButtonClick(event: MouseEvent): void {
		var button: Button = event.currentTarget as Button;
		buttonId = button.id;
	}
	
	public function get buttonId(): String {
		return _buttonId;
	}
	
	public function set buttonId(newId: String): void {
		for each (var object: Object in getChildren()) {
			if (object is Button) {
				var eachButton: Button = object as Button;
				eachButton.selected = (eachButton.id == newId);
			}
		}
		_buttonId = newId;
		if (_func != null) {
			_func.apply(this);
		}
	}
	
	public function set changeFunction(newFunc: Function): void {
		// TODO: addEventListener(FlexEvent.CHANGE, ...)に切り替えたい
		_func = newFunc;
	}
}
}