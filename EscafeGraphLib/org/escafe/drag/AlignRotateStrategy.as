package org.escafe.graph.drag
{
	import flash.geom.Point;
	import org.escafe.graph.component.GraphEditor;
	import org.escafe.graph.element.Node;
	import org.escafe.graph.element.Element;
	import org.escafe.graph.geometry.GeomUtils;

public class AlignRotateStrategy extends AbstractScrollStrategy
{
	private var _basePoint: Point = null;
	private var _oldPoint: Point = null;

	/**
	 * @category initialize
	 */	
	public function AlignRotateStrategy(aGraph: GraphEditor): void {
		super(aGraph);
		_basePoint = getMousePoint();
		_oldPoint = _basePoint;
	}
	
	/**
	 * @category mouse dragging
	 */	
	override public function mouseDrag(point: Point): void {
		var dx: Number = point.x - _oldPoint.x;
		var dy: Number = point.y - _oldPoint.y;
		var delta: Number = (100 + dy) / 100;
		var angle: Number = - dx;

		var elements: Array = graphEditor.getSelectedElements();
		if (elements.length == 0) {
			elements = graphEditor.nodeStage.getChildren();
		}
		for each (var element: Element in elements) {
			if (element is Node) {
				var node: Node = element as Node;
				var centerPoint: Point = node.getCenterPoint();
				if (centerPoint.y > _basePoint.y) {
					node.y = _basePoint.y + (node.y - _basePoint.y) * delta;
				} else {
					node.y = _basePoint.y - (_basePoint.y - node.y) * delta;
				}
				if (centerPoint.x > _basePoint.x) {
					node.x = _basePoint.x + (node.x - _basePoint.x) * delta;
				} else {
					node.x = _basePoint.x - (_basePoint.x - node.x) * delta;
				}
				
				var rotatePoint: Point = GeomUtils.rotatePoint(_basePoint, angle, new Point(node.x, node.y));
				node.move(rotatePoint.x, rotatePoint.y);
			}
		}
		_oldPoint = point;
	}
}
}