package org.escafe.graph.drag
{
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import mx.containers.Canvas;
	import mx.core.Application;
	import org.escafe.graph.geometry.Line;
	import org.escafe.graph.component.GraphEditor;

public class ScrollStrategy extends AbstractScrollStrategy
{
	private var _oldPoint: Point;
	
	/**
	 * @category initialize
	 */	
	public function ScrollStrategy(aGraph: GraphEditor): void {
		super(aGraph);
	}
	
	/**
	 * @category mouse dragging
	 */	
	override public function mouseDown(point:Point):void
	{
		super.mouseDown(point);
		_oldPoint = getScrollCanvasMousePoint();
	}
	
	/**
	 * @category mouse dragging
	 */	
	override public function mouseDrag(point:Point):void
	{
		super.mouseDrag(point);

		var newPoint: Point = getScrollCanvasMousePoint();
		var dx: Number = newPoint.x - _oldPoint.x;
		var dy: Number = newPoint.y - _oldPoint.y;
		setScrollDelta(dx, dy);

		_oldPoint = newPoint;
	}

	/**
	 * @category mouse dragging
	 */	
	private function getScrollCanvasMousePoint(): Point {
		var scrollCanvas: Canvas = graphEditor.getScrollCanvas();
		return new Point(scrollCanvas.mouseX, scrollCanvas.mouseY);
	}

	/**
	 * @category scrollable mouse dragging
	 */	
	override protected function isReverseScroll(): Boolean {
		return true;
	}
}
}