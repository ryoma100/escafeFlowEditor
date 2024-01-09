package org.escafe.graph.element
{
	import flash.geom.Rectangle;
	import org.escafe.graph.geometry.Line;
	import flash.display.Graphics;
	import mx.containers.Canvas;
	import flash.geom.Point;
	import org.escafe.graph.geometry.GeomUtils;
	import mx.controls.Label;
	import flash.display.DisplayObject;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import flash.events.Event;
	
public class Edge extends Element
{
	public static const ARROW_SIZE: int = 10;

	private var _sourceNode: Node = null;
	private var _targetNode: Node = null;
	private var _centerLabel: Canvas = null;

	private var _line: Line = null;
	private var _sourceRectangle: Rectangle = null;
	private var _targetRectangle: Rectangle = null;
	
	/**
	 * @category initialize
	 */
	public function Edge(newSourceNode: Node, newTargetNode: Node): void {
		this.sourceNode = newSourceNode;
		this.targetNode = newTargetNode;
	}

	/**
	 * @category accessing
	 */
	override public function set typeId(newId: String): void {
		super.typeId = newId;
		draw();
	}

	/**
	 * @category accessing
	 */
	public function get sourceNode(): Node {
		return _sourceNode;
	}
	
	/**
	 * @category accessing
	 */
	public function set sourceNode(node: Node): void {
		_sourceNode = node;
		draw();
	}
	
	/**
	 * @category accessing
	 */
	public function get targetNode(): Node {
		return _targetNode;
	}
	
	/**
	 * @category accessing
	 */
	public function set targetNode(node: Node): void {
		_targetNode = node;
		draw();
	}
	
	/**
	 * @category label accessing
	 */
	public function get centerLabel(): String {
		if (_centerLabel != null) {
			return (_centerLabel.getChildAt(0) as Label).text;
		}
		return null;
	}
	
	/**
	 * @category label accessing
	 */
	public function set centerLabel(newLabel: String): void {
		if (_centerLabel != null) {
			removeAllChildren();
			_centerLabel = null;
		}
		if (newLabel != null && newLabel != "") {
			var label: Label = new Label();
			label.text = newLabel;
			_centerLabel = new Canvas();
			_centerLabel.setStyle("backgroundColor", 0xFFFFFF);
			_centerLabel.alpha = 0.75;
			_centerLabel.addChild(label);
			_centerLabel.addEventListener(FlexEvent.CREATION_COMPLETE, centerLabelCreationComplete);
			addChild(_centerLabel);
		}
	}

	/**
	 * @category label accessing
	 */
	private function centerLabelCreationComplete(event: Event): void {
		draw();
	}

	/**
	 * @category drag area testing
	 */
	public function containsSourcePoint(point: Point): Boolean {
		if (_sourceRectangle != null) {
			return _sourceRectangle.containsPoint(point);
		}
		return false;
	}

	/**
	 * @category drag area testing
	 */
	public function containsTargetPoint(point: Point): Boolean {
		if (_targetRectangle != null) {
			return _targetRectangle.containsPoint(point);
		}
		return false;
	}

	/**
	 * @category line computing
	 */
	public function get line(): Line {
		compute();
		return _line;
	}

	/**
	 * @category line computing
	 */
	private function compute(): void {
		_line = null;
		_sourceRectangle = null;
		_targetRectangle = null;
		var sourcePoint: Point;
		var targetPoint: Point;

		if (_sourceNode == null || _targetNode == null) {
			return;
		}
		if (_sourceNode.getRectangleForEdge().intersects(_targetNode.getRectangleForEdge())) {
			sourcePoint = _sourceNode.getCenterPoint();
			targetPoint = _targetNode.getCenterPoint();
		} else {
			var line: Line = new Line(_sourceNode.getSourcePoint(), _targetNode.getTargetPoint());
			var sourceRect: Rectangle = _sourceNode.getRectangleForEdge();
			sourcePoint = line.intersectionWithRectangle(sourceRect);
			var targetRect: Rectangle = _targetNode.getRectangleForEdge();
			targetPoint = line.intersectionWithRectangle(targetRect);
			if (sourcePoint == null || targetPoint == null) {
				// ここが呼ばれるのはバグ
				sourcePoint = _sourceNode.getSourcePoint();
				targetPoint = _targetNode.getTargetPoint();
			}
		}
		_line = new Line(sourcePoint, targetPoint);
		
		if (_centerLabel != null) {
			var centerPoint: Point = _line.labelPoint();
			_centerLabel.x = centerPoint.x - _centerLabel.width / 2;
			_centerLabel.y = centerPoint.y - _centerLabel.height / 2;
		}
		
		_sourceRectangle = new Rectangle(sourcePoint.x - ARROW_SIZE, sourcePoint.y - ARROW_SIZE, ARROW_SIZE * 2 + 1, ARROW_SIZE * 2 + 1);
		_targetRectangle = new Rectangle(targetPoint.x - ARROW_SIZE, targetPoint.y - ARROW_SIZE, ARROW_SIZE * 2 + 1, ARROW_SIZE * 2 + 1);
	}

	/**
	 * @category selection
	 */
	override public function set selected(newSelected:Boolean): void
	{
		super.selected = newSelected;
		draw();
	}

	/**
	 * @category drawing
	 */
	public function draw(): void {
		var g: Graphics = this.graphics;
		g.clear();

		if (line != null) {
			var angle: Number = line.angle();
			var targetLeftPoint: Point = new Point(line.targetPoint.x - ARROW_SIZE, line.targetPoint.y - ARROW_SIZE / 2);
			var targetRightPoint: Point = new Point(line.targetPoint.x - ARROW_SIZE, line.targetPoint.y + ARROW_SIZE / 2);
			targetLeftPoint = GeomUtils.rotatePoint(line.targetPoint, angle, targetLeftPoint);
			targetRightPoint = GeomUtils.rotatePoint(line.targetPoint, angle, targetRightPoint);
	
			var thickness: int = (this.selected) ? 3 : 1;
			var color: int = (this.selected) ? 0x000000 : 0x808080;
			g.lineStyle(thickness, color);
			g.beginFill(color);
			g.moveTo(line.sourcePoint.x, line.sourcePoint.y);
			g.lineTo(line.targetPoint.x, line.targetPoint.y);
			g.lineTo(targetLeftPoint.x, targetLeftPoint.y);
			g.lineTo(targetRightPoint.x, targetRightPoint.y);
			g.lineTo(line.targetPoint.x, line.targetPoint.y);
			g.endFill();
		}
	}
}
}