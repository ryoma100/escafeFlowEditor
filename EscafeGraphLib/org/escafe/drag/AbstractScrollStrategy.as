package org.escafe.graph.drag
{
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.display.DisplayObject;
	import mx.core.Application;
	import mx.containers.Canvas;
	import org.escafe.graph.component.GraphEditor;
	import org.escafe.graph.element.Node;
	import org.escafe.graph.element.Edge;
	import org.escafe.graph.geometry.GeomUtils;
	import org.escafe.graph.geometry.Line;

public class AbstractScrollStrategy extends AbstractDragStrategy
{
	private var _scrollTimer: Timer;
	
	/**
	 * @override
	 * @category initialize
	 */	
	public function AbstractScrollStrategy(newGraph: GraphEditor): void {
		super(newGraph);
	}

	/**
	 * @override
	 * @category mouse dragging
	 */	
	override public function mouseDown(point:Point):void
	{
		Application.application.addEventListener(MouseEvent.MOUSE_UP, applicationMouseUp);
		Application.application.addEventListener(MouseEvent.MOUSE_MOVE, applicationMouseDrag);
		_scrollTimer = new Timer(100);
		_scrollTimer.addEventListener(TimerEvent.TIMER, scrollTimer);
	}
	
	/**
	 * @override
	 * @category mouse dragging
	 */	
	override public function mouseUp(point:Point):void
	{
		_scrollTimer.stop();
		_scrollTimer.removeEventListener(TimerEvent.TIMER, scrollTimer);
		Application.application.removeEventListener(MouseEvent.MOUSE_MOVE, applicationMouseDrag);
		Application.application.removeEventListener(MouseEvent.MOUSE_UP, applicationMouseUp);
	}
	
	/**
	 * @category scrollable mouse dragging
	 */	
	private function applicationMouseDrag(event: MouseEvent): void {
		if (event.buttonDown == false) {
			applicationMouseUp(event);
			return;
		}
		
		if (getGraphCanvasRectangle().containsPoint(getApplicationMousePoint())) {
			_scrollTimer.stop();
		} else {
			_scrollTimer.start();
		}
	}
	
	/**
	 * @category scrollable mouse dragging
	 */	
	private function applicationMouseUp(event: MouseEvent): void {
		var rect: Rectangle = getGraphCanvasRectangle();
		var centerPoint: Point = GeomUtils.centerPoint(rect);
		var line: Line = new Line(centerPoint, getApplicationMousePoint());
		var crossPoint: Point = line.intersectionWithRectangle(rect);
		mouseUp(graphEditor.globalToLocal(crossPoint));
	}

	/**
	 * @category scrollable mouse dragging
	 */	
	private function scrollTimer(event: TimerEvent): void {
		var point: Point = getApplicationMousePoint();
		if (getApplicationRectangle().containsPoint(point) == false) {
			return;
		}
		
		var rect: Rectangle = getGraphCanvasRectangle();
		var centerPoint: Point = GeomUtils.centerPoint(rect);
		var line: Line = new Line(centerPoint, point);
		var crossPoint: Point = line.intersectionWithRectangle(rect);
		var dx: Number = crossPoint.x - point.x;
		var dy: Number = crossPoint.y - point.y;
		if (isReverseScroll()) {
			dx = -dx;
			dy = -dy;
		}
		setScrollDelta(dx, dy);
		
		mouseDrag(graphEditor.globalToLocal(crossPoint));
	}

	/**
	 * @override
	 * @category scrollable mouse dragging
	 */	
	protected function isReverseScroll(): Boolean {
		return false;
	}

	/**
	 * @category scrollable mouse dragging
	 */	
	private function getApplicationMousePoint(): Point {
		return new Point(Application.application.mouseX, Application.application.mouseY);
	}

	/**
	 * @category scrollable mouse dragging
	 */	
	private function getApplicationRectangle(): Rectangle {
		return Application.application.getRect(Application.application as DisplayObject);
	}
	
	/**
	 * @category scrollable mouse dragging
	 */	
	private function getGraphCanvasRectangle(): Rectangle {
		var scrollCanvas: Canvas = graphEditor.getScrollCanvas();
		var rect: Rectangle = scrollCanvas.getRect(Application.application as DisplayObject);
		rect.width -= scrollCanvas.verticalScrollBar.width;
		rect.height -= scrollCanvas.horizontalScrollBar.height;
		return rect;
	}

	/**
	 * @category scrollable mouse dragging
	 */	
	protected function setScrollDelta(dx: Number, dy: Number): void {
		var scrollCanvas: Canvas = graphEditor.getScrollCanvas();
		scrollCanvas.horizontalScrollPosition -= dx;
		scrollCanvas.verticalScrollPosition -= dy;
	}
}
}