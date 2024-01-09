package org.escafe.graph.component
{
	import mx.containers.Canvas;
	import mx.states.SetStyle;
	import mx.events.ResizeEvent;
	import org.escafe.graph.element.Edge;
	import org.escafe.graph.element.Node;
	import mx.events.MoveEvent;
	import org.escafe.graph.element.Element;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import mx.core.ScrollPolicy;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	import org.escafe.graph.bitmap.BitmapUtil;
	import flash.events.MouseEvent;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import org.escafe.graph.drag.AbstractDragStrategy;
	import org.escafe.graph.drag.ScrollStrategy;
	import org.escafe.graph.drag.SelectStrategy;
	import mx.collections.ArrayCollection;
	import org.escafe.graph.drag.SelectCircleStrategy;
	import org.escafe.graph.drag.AlignSpaceStrategy;
	import org.escafe.graph.drag.SelectRectangleStrategy;
	import org.escafe.graph.drag.AlignRotateStrategy;

public class Graph extends Canvas
{
	public static const ID_NODE_STAGE: String = "nodeStage";
	public static const ID_EDGE_STAGE: String = "edgeStage";
	public static const ID_DRAG_STAGE: String = "dragStage";
	
	private var _nodeStage: Canvas = new Canvas();
	private var _edgeStage: Canvas = new Canvas();
	private var _dragStage: Canvas = new Canvas();

	/**
	 * @category initialize
	 */
	public function Graph(): void {
		setStyle("backgroundColor", 0xFFFFFF);
		horizontalScrollPolicy = ScrollPolicy.OFF;
		verticalScrollPolicy = ScrollPolicy.OFF;
		minWidth = 4000;
		minHeight = 3000;
		
		initializeChildState(_nodeStage, ID_NODE_STAGE);
		initializeChildState(_edgeStage, ID_EDGE_STAGE);
		initializeChildState(_dragStage, ID_DRAG_STAGE);
	}
	
	/**
	 * @category initialize
	 */
	private function initializeChildState(stage: Canvas, newId: String): void {
		stage.id = newId;
		stage.setStyle("top", 0);
		stage.setStyle("bottom", 0);
		stage.setStyle("left", 0);
		stage.setStyle("right", 0);
		stage.verticalScrollPolicy = ScrollPolicy.OFF;
		stage.horizontalScrollPolicy = ScrollPolicy.OFF;
		addChild(stage);
	}
	
	/**
	 * @category stage accessing
	 */
	public function get nodeStage(): Canvas {
		return _nodeStage;
	}

	/**
	 * @category stage accessing
	 */
	public function get edgeStage(): Canvas {
		return _edgeStage;
	}

	/**
	 * @category stage accessing
	 */
	public function get dragStage(): Canvas {
		return _dragStage;
	}
	
	/**
	 * @category node accessing
	 */
	public function addNode(node: Node): void {
		_nodeStage.addChild(node);
		node.addEventListener(MoveEvent.MOVE, nodeMoveListener);
		node.addEventListener(ResizeEvent.RESIZE, nodeResizeListener);
	}

	/**
	 * @category node accessing
	 */
	public function removeNode(node: Node): void {
		node.removeEventListener(ResizeEvent.RESIZE, nodeResizeListener);
		node.removeEventListener(MoveEvent.MOVE, nodeMoveListener);
		_nodeStage.removeChild(node);

		// 関連するエッジを削除
		for each (var edge: Edge in _edgeStage.getChildren().reverse()) {
			if (edge.sourceNode == node || edge.targetNode == node) {
				_edgeStage.removeChild(edge);
				changedEdge(edge);
			}
		}
	}
	
	/**
	 * @category node displaying
	 */
	private function nodeResizeListener(event: ResizeEvent): void {
		drawLinkedEdge(event.currentTarget as Node);
	}
	
	/**
	 * @category node displaying
	 */
	private function nodeMoveListener(event: MoveEvent): void {
		var node: Node = event.currentTarget as Node;

		node.x = Math.max(0, node.x);
		node.x = Math.min(node.x, width - node.width);
		node.y = Math.max(0, node.y);
		node.y = Math.min(node.y, height - node.height);

		drawLinkedEdge(event.currentTarget as Node);
	}
	
	/**
	 * @category node displaying
	 */
	private function drawLinkedEdge(node: Node): void {
		for each (var edge: Edge in _edgeStage.getChildren()) {
			if (edge.sourceNode == node || edge.targetNode == node) {
				edge.draw();
			}
		}
	}

	/**
	 * @category edge accessing
	 */
	public function addEdge(edge: Edge): void {
		_edgeStage.addChild(edge);
		edge.draw();
		changedEdge(edge);
	}
	
	/**
	 * @category edge accessing
	 */
	public function removeEdge(edge: Edge): void {
		_edgeStage.removeChild(edge);
		changedEdge(edge);
	}

	/**
	 * @override
	 * @category edge changing
	 */
	protected function changedEdge(edge: Edge): void {
	}

	/**
	 * @category searching
	 */
	public function findNode(point: Point): Node {
		for each (var node: Node in _nodeStage.getChildren().reverse()) {
			var rect: Rectangle = node.getRect(_nodeStage);
			if (rect.containsPoint(point)) {
				return node;
			}
		}
		return null;
	}
	
	/**
	 * @category searching
	 */
	public function findEdge(point: Point): Edge {
		for each (var edge: Edge in _edgeStage.getChildren().reverse()) {
			if (edge.line != null && edge.line.distanceWithPoint(point) < 3) {
				return edge;
			}
		}
		return null;
	}

	/**
	 * @category searching
	 */
	public function containsEdge(edge: Edge): Boolean {
		for each (var eachEdge: Edge in _edgeStage.getChildren()) {
			if (eachEdge.sourceNode == edge.sourceNode && eachEdge.targetNode == edge.targetNode) {
				return true;
			}
		}
		return false;
	}

	/**
	 * @category image creation
	 */
	public function createPngImage(): ByteArray {
		return BitmapUtil.createPng(this, computeImageRectangle());
	}

	/**
	 * @category image creation
	 */
	private function computeImageRectangle(): Rectangle {
		var rect: Rectangle = new Rectangle();
		for each (var node: Node in nodeStage.getChildren()) {
			var nodeRect: Rectangle = node.getRect(this);
			if (rect.width < nodeRect.x + nodeRect.width) {
				rect.width = nodeRect.x + nodeRect.width;
			}
			if (rect.height < nodeRect.y + nodeRect.height) {
				rect.height = nodeRect.y + nodeRect.height;
			}
		}
		rect.width += 50;
		rect.height += 50;
		if (rect.width > this.width) {
			rect.width = this.width;
		}
		if (rect.height > this.height) {
			rect.height = this.height;
		}
		return rect;
	}
}
}