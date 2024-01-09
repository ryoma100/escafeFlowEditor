package org.escafe.graph.drag
{
	import org.escafe.graph.component.GraphEditor;
	import flash.geom.Point;
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	import org.escafe.graph.element.Node;
	import org.escafe.graph.geometry.GeomUtils;
	
public class SelectCircleStrategy extends AbstractScrollStrategy
{
	private var _startPoint: Point;
	
	/**
	 * @category initialize
	 */	
	public function SelectCircleStrategy(newGraph: GraphEditor) {
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

		var radius: Number = GeomUtils.pointLength(_startPoint, point);
		
		var g: Graphics = graphEditor.dragStage.graphics;
		g.clear();
		g.lineStyle(1, 0x0000FF, 1);
		g.beginFill(0x0000C0, 0.1);
		g.drawCircle(_startPoint.x, _startPoint.y, radius);
		g.endFill();
		
		for each (var node: Node in graphEditor.nodeStage.getChildren()) {
			node.selected = (minLengthOfPointToRect(_startPoint, node.getRect(graphEditor)) < radius);
		}
	}
	
	/**
	 * @category mouse dragging
	 */	
	private function minLengthOfPointToRect(point: Point, rect: Rectangle): Number {
		var radius: Number = GeomUtils.pointLength(_startPoint, rect.topLeft);
		radius = Math.min(radius, GeomUtils.pointLength(_startPoint, new Point(rect.right, rect.top)));
		radius = Math.min(radius, GeomUtils.pointLength(_startPoint, rect.bottomRight));
		radius = Math.min(radius, GeomUtils.pointLength(_startPoint, new Point(rect.left, rect.bottom)));
		return radius;
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