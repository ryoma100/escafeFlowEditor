package org.escafe.graph.drag
{
	import flash.geom.Point;
	import org.escafe.graph.component.GraphEditor;

public class AbstractDragStrategy
{
	private var _graphEditor: GraphEditor;

	/**
	 * @override
	 * @category initialize
	 */	
	public function AbstractDragStrategy(newGraph: GraphEditor): void {
		_graphEditor = newGraph;
	}

	/**
	 * @category accessing
	 */	
	protected function get graphEditor(): GraphEditor {
		return _graphEditor;
	}

	/**
	 * @category accessing
	 */	
	protected function getMousePoint(): Point {
		return new Point(_graphEditor.mouseX, _graphEditor.mouseY);
	}

	/**
	 * @override
	 * @category mouse dragging
	 */	
	public function mouseDown(point:Point):void
	{
	}
	
	/**
	 * @override
	 * @category mouse dragging
	 */	
	public function mouseDrag(point:Point):void
	{
	}
	
	/**
	 * @override
	 * @category mouse dragging
	 */	
	public function mouseUp(point:Point):void
	{
	}
}
}