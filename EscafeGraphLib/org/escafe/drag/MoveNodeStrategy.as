package org.escafe.graph.drag
{
	import flash.geom.Point;
	import org.escafe.graph.component.GraphEditor;
	import org.escafe.graph.element.Node;

public class MoveNodeStrategy extends AbstractScrollStrategy
{
	private var _oldPoint: Point = null;

	/**
	 * @category initialize
	 */	
	public function MoveNodeStrategy(aGraph: GraphEditor): void {
		super(aGraph);
		_oldPoint = getMousePoint();
	}
	
	/**
	 * @category mouse dragging
	 */	
	override public function mouseDrag(point: Point): void {
		var dx: Number = _oldPoint.x - point.x;
		var dy: Number = _oldPoint.y - point.y;
		for each (var node: Node in graphEditor.nodeStage.getChildren()) {
			if (node.selected) {
				node.move(node.x - dx, node.y - dy);
			}
		}
		_oldPoint = point;
	}
}
}