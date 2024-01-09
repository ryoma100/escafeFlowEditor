package org.escafe.burieditor.drag
{
	import mx.core.UIComponent;
	import flash.geom.Point;
	import flash.display.Graphics;
	import org.escafe.burieditor.element.TransitionEdge;
	import org.escafe.graph.element.Edge;
	import org.escafe.graph.element.Node;
	import org.escafe.burieditor.component.BuriGraphEditor;
	import org.escafe.burieditor.element.StartEndNode;
	import org.escafe.burieditor.element.StartEndEdge;
	import org.escafe.burieditor.BuriEditorConst;
	import org.escafe.graph.drag.AbstractScrollStrategy;

public class MoveEdgeTargetStrategy extends AbstractScrollStrategy
{
	private var _canvas: UIComponent;
	private var _edge: Edge;
	
	/**
	 * @category initialize
	 */	
	public function MoveEdgeTargetStrategy(aGraph: BuriGraphEditor, aEdge: Edge): void {
		super(aGraph);
		_edge = aEdge;
	}
	
	/**
	 * @category mouse dragging
	 */	
	override public function mouseDown(point: Point): void {
		super.mouseDown(point);
		_edge.visible = false;
		mouseDrag(point);
	}
	
	/**
	 * @category mouse dragging
	 */	
	override public function mouseDrag(point: Point): void {
		super.mouseDrag(point);
		var sourcePoint: Point = _edge.sourceNode.getCenterPoint();
		
		var g: Graphics = graphEditor.dragStage.graphics;
		g.clear();
		g.lineStyle(1, 0x000000);
		g.beginFill(0x000000);
		g.moveTo(sourcePoint.x, sourcePoint.y);
		g.lineTo(point.x, point.y);
		g.endFill();
	}
	
	/**
	 * @category mouse dragging
	 */	
	override public function mouseUp(point: Point): void {
		super.mouseUp(point);
		graphEditor.dragStage.graphics.clear();
		var targetNode: Node = graphEditor.findNode(point);
		if (targetNode != null && targetNode != _edge.sourceNode && targetNode != _edge.targetNode) {
			var newEdge: Edge = _edge.sourceNode.createEdgeTo(targetNode);
			if (newEdge != null && ! graphEditor.containsEdge(newEdge)) {
				graphEditor.removeEdge(_edge);
				graphEditor.addEdge(newEdge);
				graphEditor.setSelectOneElementAndMoveUp(newEdge);
				return;
			}
		}
		_edge.visible = true;
	}
}
}