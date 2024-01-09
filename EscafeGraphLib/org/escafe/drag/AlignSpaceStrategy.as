package org.escafe.graph.drag
{
	import flash.geom.Point;
	import org.escafe.graph.component.GraphEditor;
	import org.escafe.graph.element.Node;
	import org.escafe.graph.element.Element;

public class AlignSpaceStrategy extends AbstractScrollStrategy
{
	private var _basePoint: Point = null;
	private var _oldPoint: Point = null;

	/**
	 * @category initialize
	 */	
	public function AlignSpaceStrategy(aGraph: GraphEditor): void {
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

		var elements: Array = graphEditor.getSelectedElements();
		if (elements.length == 0) {
			elements = graphEditor.nodeStage.getChildren();
		}
		for each (var element: Element in elements) {
			if (element is Node) {
				var node: Node = element as Node;
				var centerPoint: Point = node.getCenterPoint();
				node.x += (centerPoint.x > _basePoint.x) ? dx : -dx;
				node.y += (centerPoint.y > _basePoint.y) ? dy : -dy;
			}
		}
		_oldPoint = point;
	}
}
}