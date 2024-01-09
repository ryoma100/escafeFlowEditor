package org.escafe.graph.drag
{
	import org.escafe.graph.component.GraphEditor;
	import flash.geom.Point;
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	import org.escafe.graph.element.Node;
	
public class SelectStrategy extends AbstractScrollStrategy
{
	private var _startPoint: Point;
	
	/**
	 * @category initialize
	 */	
	public function SelectStrategy(newGraph: GraphEditor) {
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

		var rect: Rectangle = new Rectangle();
		rect.x = Math.min(_startPoint.x, point.x);
		rect.y = Math.min(_startPoint.y, point.y);
		rect.width = Math.max(point.x - _startPoint.x, _startPoint.x - point.x);
		rect.height = Math.max(point.y - _startPoint.y, _startPoint.y - point.y);
		
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