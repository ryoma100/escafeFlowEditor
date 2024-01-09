package org.escafe.graph.element
{
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import flash.geom.Point;
	import mx.skins.Border;
	import flash.geom.Rectangle;
	import mx.events.FlexEvent;
	import flash.events.Event;
	import mx.events.ResizeEvent;

public class Node extends Element
{
	private var _view: UIComponent;

	/**
	 * @category initialize
	 */
	public function Node(newView: UIComponent, point: Point): void {
		setStyle("borderStyle", "solid");
		setStyle("borderThickness", 2);

		view = newView;
		selected = false;
		move(point.x, point.y);
	}

	/**
	 * @category viwe accessing
	 */
	public function get view(): UIComponent {
		return _view;
	}
	
	/**
	 * @category viwe accessing
	 */
	public function set view(newView: UIComponent): void {
		if (_view != null) {
			removeChild(_view);
		}
		_view = newView;
		if (_view != null) {
			addChild(_view);
		}
	}

	/**
	 * @category point accessing
	 */
	public function getCenterPoint(): Point {
		return new Point(x + (width / 2), y + (height / 2));
	}
	
	/**
	 * @category point accessing
	 */
	public function setCenterPoint(point: Point): void {
		x = point.x - width / 2;
		y = point.y - height / 2;
	}
	
	/**
	 * @category point accessing
	 */
	public function getSourcePoint(): Point {
		return getCenterPoint();
	}

	/**
	 * @category point accessing
	 */
	public function getTargetPoint(): Point {
		return getCenterPoint();
	}

	/**
	 * @override
	 * @category edge creation
	 */
	public function createEdgeTo(targetNode: Node): Edge {
		return null;
	}
	
	/**
	 * @category selection
	 */
	override public function set selected(newSelected:Boolean): void
	{
		super.selected = newSelected;
		if (selected) {
			setStyle("borderColor", 0x000000);
		} else {
			setStyle("borderColor", 0xFFFFFF);
		}
	}
	
	/**
	 * @category edge drawing
	 */
	public function getRectangleForEdge(): Rectangle {
		const SIZE: int = 3;
		return new Rectangle(x - SIZE, y - SIZE, width + SIZE * 2, height + SIZE * 2);
	}

	/**
	 * @category drag point testing
	 */
	public function containsLeftPoint(point: Point): Boolean {
		var rect: Rectangle = new Rectangle(x - 5, y, 11, height);
		return rect.containsPoint(point);
	}

	/**
	 * @category drag point testing
	 */
	public function containsRightPoint(point: Point): Boolean {
		var rect: Rectangle = new Rectangle(x + width - 5, y, 11, height);
		return rect.containsPoint(point);
	}
}
}