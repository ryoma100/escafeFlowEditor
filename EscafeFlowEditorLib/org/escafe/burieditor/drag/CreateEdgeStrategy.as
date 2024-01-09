package org.escafe.burieditor.drag
{
	import flash.geom.Point;
	import mx.core.UIComponent;
	import flash.display.Graphics;
	import org.escafe.graph.element.Edge;
	import org.escafe.burieditor.element.TransitionEdge;
	import org.escafe.graph.element.Node;
	import org.escafe.burieditor.component.BuriGraphEditor;
	import org.escafe.burieditor.element.ActivityNode;
	import org.escafe.burieditor.element.StartEndEdge;
	import org.escafe.burieditor.element.StartEndNode;
	import org.escafe.burieditor.BuriEditorConst;
	import org.escafe.graph.drag.AbstractScrollStrategy;

public class CreateEdgeStrategy extends AbstractScrollStrategy
{
	private var _sourceNode: Node;
	
	public function CreateEdgeStrategy(aGraph: BuriGraphEditor, node: Node): void {
		super(aGraph);
		_sourceNode = node;
	}
	
	override public function mouseDown(point: Point): void {
		super.mouseDown(point);
		mouseDrag(point);
	}
	
	override public function mouseDrag(point: Point): void {
		super.mouseDrag(point);
		var sourcePoint: Point = _sourceNode.getCenterPoint();
		var g: Graphics = graphEditor.dragStage.graphics;
		g.clear();
		g.lineStyle(1, 0x000000);
		g.beginFill(0x000000);
		g.moveTo(sourcePoint.x, sourcePoint.y);
		g.lineTo(point.x, point.y);
		g.endFill();
	}
	
	override public function mouseUp(point: Point): void {
		super.mouseUp(point);
		graphEditor.dragStage.graphics.clear();
		var targetNode: Node = graphEditor.findNode(point);
		if (targetNode != null && targetNode != _sourceNode) {
			var edge: Edge = _sourceNode.createEdgeTo(targetNode);
			if (edge != null && graphEditor.containsEdge(edge) == false) {
				graphEditor.addEdge(edge);
			}
		}
	}
}
}