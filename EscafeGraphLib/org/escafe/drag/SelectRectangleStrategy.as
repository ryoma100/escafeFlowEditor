package org.escafe.graph.drag
{
	import org.escafe.graph.component.GraphEditor;
	import flash.geom.Point;
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	import org.escafe.graph.element.Node;
	import org.escafe.graph.geometry.GeomUtils;
	
public class SelectRectangleStrategy extends AbstractScrollStrategy
{
	private var _startPoint: Point;
	
	/**
	 * @category initialize
	 */	
	public function SelectRectangleStrategy(newGraph: GraphEditor) {
		super(newGraph);
		graphEditor.clearSelectedElements();
	}

	/**
	 * @category mouse dragging
	 */	
	override public function mouseDown(point:Point):void {
		super.mouseDown(point);
		_startPoint = point;
	}

	/**
	 * @category mouse dragging
	 */	
	override public function mouseDrag(point:Point):void {
		super.mouseDrag(point);

		var dx: Number = Math.abs(point.x - _startPoint.x);
		var dy: Number = Math.abs(point.y - _startPoint.y);
		var rect: Rectangle = new Rectangle();
		rect.x = _startPoint.x - dx;
		rect.y = _startPoint.y - dy;
		rect.width = dx * 2;
		rect.height = dy * 2;
		
		var g: Graphics = graphEditor.dragStage.graphics;
		g.clear();
		g.lineStyle(1, 0x0000FF, 1);
		g.beginFill(0x0000C0, 0.1);
		g.drawRect(rect.x, rect.y, rect.width, rect.height);
		g.endFill();
		
		for each (var node: Node in graphEditor.nodeStage.getChildren()) {
			node.selected = node.getRect(graphEditor).intersects(rect);
		}
	}
	
	/**
	 * @category mouse dragging
	 */	
	override public function mouseUp(point:Point):void {
		super.mouseUp(point);
		
		var g: Graphics = graphEditor.dragStage.graphics;
		g.clear();
	}
}
}