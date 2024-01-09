package org.escafe.graph.element
{
	import mx.containers.Canvas;
	import flash.events.Event;
	import mx.events.FlexEvent;
	import org.escafe.graph.component.Graph;

public class Element extends Canvas
{
	protected var _typeId: String;
	private var _selected: Boolean = false;

	/**
	 * @category initialize and release
	 */
	public function Element(): void {
		addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
	}

	/**
	 * @override
	 * @category initialize and release
	 */
	protected function onCreationComplete(event: Event): void {
		// 表示時にプロパティメソッドを起動させる
		typeId = _typeId;
		selected = _selected;
	}

	/**
	 * @override
	 * @category initialize and release
	 */
	protected function onRemovedFromStage(event: Event): void {
	}

	/**
	 * @category accessing
	 */
	public function get typeId(): String {
		return _typeId;
	}
	
	/**
	 * @override
	 * @category accessing
	 */
	public function set typeId(newId: String): void {
		_typeId = newId;
	}

	/**
	 * @category selection
	 */
	public function get selected(): Boolean {
		return _selected;
	}
	
	/**
	 * @override
	 * @category selection
	 */
	public function set selected(newSelected: Boolean): void {
		_selected = newSelected;
	}
	
	/**
	 * @category graph accessing
	 */
	protected function getGraph(): Graph {
		return parent.parent as Graph;
	}
}
}