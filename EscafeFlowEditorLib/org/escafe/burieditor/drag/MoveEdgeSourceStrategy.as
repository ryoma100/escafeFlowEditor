package org.escafe.burieditor.drag
{
	import mx.core.UIComponent;
	import flash.geom.Point;
	import flash.display.Graphics;
	import org.escafe.burieditor.element.TransitionEdge;
	import org.escafe.graph.element.Edge;
	import org.escafe.graph.element.Node;
	import org.escafe.burieditor.component.BuriGraphEditor;
	import org.escafe.burieditor.element.ActivityNode;
	import org.escafe.burieditor.element.StartEndNode;
	import org.escafe.burieditor.element.StartEndEdge;
	import org.escafe.burieditor.BuriEditorConst;
	import org.escafe.graph.drag.AbstractScrollStrategy;
	import mx.containers.Canvas;
	
public class MoveEdgeSourceStrategy extends AbstractScrollStrategy
{
	private var _edge: Edge;
	
	/**
	 * @category initialize
	 */	
	public function MoveEdgeSourceStrategy(aGraph: BuriGraphEditor, aEdge: Edge): void {
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
		var targetPoint: Point = _edge.targetNode.getCenterPoint();
		
		var g: Graphics = graphEditor.dragStage.graphics;
		g.clear();
		g.lineStyle(1, 0x000000);
		g.beginFill(0x000000);
		g.moveTo(point.x, point.y);
		g.lineTo(targetPoint.x, targetPoint.y);
		g.endFill();
	}
	
	/**
	 * @category mouse dragging
	 */	
	override public function mouseUp(point: Point): void {
		super.mouseUp(point);
		graphEditor.dragStage.graphics.clear();
		var sourceNode: Node = graphEditor.findNode(point);
		if (sourceNode != null && sourceNode != _edge.targetNode && sourceNode != _edge.sourceNode) {
			var newEdge: Edge = sourceNode.createEdgeTo(_edge.targetNode);
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