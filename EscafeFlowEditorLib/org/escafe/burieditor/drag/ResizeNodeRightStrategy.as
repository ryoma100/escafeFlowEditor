package org.escafe.burieditor.drag
{
	import flash.geom.Point;
	import org.escafe.graph.element.Node;
	import mx.controls.Text;
	import org.escafe.burieditor.component.BuriGraphEditor;
	import org.escafe.burieditor.element.ActivityNode;
	import mx.containers.VBox;
	import org.escafe.burieditor.view.ActivityView;
	import org.escafe.graph.drag.AbstractDragStrategy;

public class ResizeNodeRightStrategy extends AbstractDragStrategy
{
	private var _node: Node;
	private var _oldPoint: Point = null;

	/**
	 * @category initialize
	 */	
	public function ResizeNodeRightStrategy(aGraph: BuriGraphEditor, aNode: Node): void {
		super(aGraph);
		_node = aNode;
	}
	
	/**
	 * @category mouse dragging
	 */	
	override public function mouseDown(point:Point):void
	{
		_oldPoint = point;
	}
	
	/**
	 * @category mouse dragging
	 */	
	override public function mouseDrag(point:Point):void
	{
		var dx: int = point.x - _oldPoint.x;
		if (_node is ActivityNode) {
			var view: ActivityView = (_node as ActivityNode).getActivityView();
			if (view.minWidth <= view.width + dx) {
				view.width += dx;
				_oldPoint = point;
			}
		}
	}
}
}