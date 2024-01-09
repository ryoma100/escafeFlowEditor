package org.escafe.graph.geometry
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.display.Graphics;
	import mx.utils.GraphicsUtil;

public class Line
{
	public static const ARROW_SIZE: int = 10;

	private var _sourcePoint: Point = null;
	private var _targetPoint: Point = null;
	private var _rectangle: Rectangle = null;
	
	/**
	 * @category initialize
	 */
	public function Line(newStartPoint: Point, newEndPoint: Point): void {
		this.sourcePoint = newStartPoint;
		this.targetPoint = newEndPoint;
	}
	
	/**
	 * @category accessing
	 */
	public function get sourcePoint(): Point {
		return _sourcePoint;
	}
	
	/**
	 * @category accessing
	 */
	public function set sourcePoint(newPoint: Point): void {
		_sourcePoint = newPoint;
		refresh();
	}
	
	/**
	 * @category accessing
	 */
	public function get targetPoint(): Point {
		return _targetPoint;
	}
	
	/**
	 * @category accessing
	 */
	public function set targetPoint(newPoint: Point): void {
		_targetPoint = newPoint;
		refresh();
	}
	
	/**
	 * @category geometric computing
	 */
	public function angle():Number {
		if (_sourcePoint.equals(_targetPoint)) {
			return 0.0;
		}

		var dx: Number = _targetPoint.x - _sourcePoint.x;
		var dy: Number = _sourcePoint.y - _targetPoint.y;
		var rad: Number = Math.atan2(dy, dx);
		var angle: Number = rad / Math.PI * 180.0;

		return angle;
	}	
	
	/**
	 * @category geometric computing
	 */
	private function refresh(): void {
		if (_sourcePoint == null || _targetPoint == null) {
			_rectangle = null;
			return;
		}
		var width: Number = _targetPoint.x - _sourcePoint.x;
		var height: Number = _targetPoint.y - _sourcePoint.y;
		_rectangle = new Rectangle(_sourcePoint.x, _sourcePoint.y, width, height);
	}
	
	/**
	 * @category geometric computing
	 */
	public function labelPoint(): Point {
		var x: Number = (targetPoint.x - sourcePoint.x) / 4 + sourcePoint.x;
		var y: Number = (targetPoint.y - sourcePoint.y) / 4 + sourcePoint.y;
		return new Point(x, y);
	}
	
	/**
	 * @category geometric computing
	 */
	public function distanceWithPoint(point: Point): Number {
		var dx: Number = _targetPoint.x - _sourcePoint.x;
		var dy: Number = _targetPoint.y - _sourcePoint.y;
		var a: Number = (dx * dx) + (dy * dy);
		if (a == 0.0) {
			return Math.sqrt((_sourcePoint.x - point.x) * (_sourcePoint.x - point.x) + (_sourcePoint.y - point.y) * (_sourcePoint.y - point.y));
		}
		var b : Number = dx * (_sourcePoint.x - point.x) + dy * (_sourcePoint.y - point.y);
		var t : Number = - (b / a);
		if (t < 0.0) {
			t = 0.0;
		}
		if (t > 1.0) {
			t = 1.0;
		}
		var x : Number = t * dx + _sourcePoint.x;
		var y : Number = t * dy + _sourcePoint.y;
		return Math.sqrt((x - point.x) * (x - point.x) + (y - point.y) * (y - point.y));
	}
	
	/**
	 * @category geometric computing
	 */
	public function intersectionWithLine(line: Line): Point {
		var a1: Point = this.sourcePoint;
		var a2: Point = this.targetPoint;
		var b1: Point = line.sourcePoint;
		var b2: Point = line.targetPoint;

		// ax+by=c
		var a: Number = a1.y - a2.y;
		var b: Number = a2.x - a1.x;
		var c: Number = a2.x * a1.y - a2.y * a1.x;

		// dx+ey=f
		var d: Number = b1.y - b2.y;
		var e: Number = b2.x - b1.x;
		var f: Number = b2.x * b1.y - b2.y * b1.x;

		var denominator: Number = b * d - a * e;
		if (Math.abs(denominator) < GeomUtils.ACCURACY) {
			return null;
		}
		var x: Number = (b * f - c * e) / denominator;
		var y: Number = (c * d - a * f) / denominator;

		// line segment check
		if (x < Math.min(a1.x, a2.x) || Math.max(a1.x, a2.x) < x) {
			return null;
		}
		if (x < Math.min(b1.x, b2.x) || Math.max(b1.x, b2.x) < x) {
			return null;
		}
		if (y < Math.min(a1.y, a2.y) || Math.max(a1.y, a2.y) < y) {
			return null;
		}
		if (y < Math.min(b1.y, b2.y) || Math.max(b1.y, b2.y) < y) {
			return null;
		}

		return new Point(x, y);
	}

	/**
	 * @category geometric computing
	 */
	public function intersectionWithRectangle(rect: Rectangle): Point {
		var topLeft: Point = new Point(rect.x, rect.y);
		var topRight: Point = new Point(rect.x + rect.width - 1, rect.y);
		var bottomLeft: Point = new Point(rect.x, rect.y + rect.height - 1);
		var bottomRight: Point = new Point(rect.x + rect.width - 1, rect.y + rect.height - 1);

		var lines: Array = new Array(4);
		lines[0] = new Line(topLeft, topRight);
		lines[1] = new Line(topRight, bottomRight);
		lines[2] = new Line(bottomLeft, bottomRight);
		lines[3] = new Line(topLeft, bottomLeft);

		for each (var line: Line in lines) {
			var point: Point = intersectionWithLine(line);
			if (point != null) {
				return point;
			}
		}

		return null;
	}

	/**
	 * @category geometric drawing
	 */
	public function draw(g: Graphics): void {
		g.clear();
		g.lineStyle(1, 0x000000);
		g.beginFill(0x000000);

		// エッジの線分を描画
		g.moveTo(_sourcePoint.x, _sourcePoint.y);
		g.lineTo(_targetPoint.x, _targetPoint.y);

		// ターゲットの矢印を描画
		var angle: Number = this.angle();
		var targetLeftPoint: Point = new Point(_targetPoint.x - ARROW_SIZE, _targetPoint.y - ARROW_SIZE / 2);
		var targetRightPoint: Point = new Point(_targetPoint.x - ARROW_SIZE, _targetPoint.y + ARROW_SIZE / 2);
		targetLeftPoint = GeomUtils.rotatePoint(_targetPoint, angle, targetLeftPoint);
		targetRightPoint = GeomUtils.rotatePoint(_targetPoint, angle, targetRightPoint);
		g.lineTo(targetLeftPoint.x, targetLeftPoint.y);
		g.lineTo(targetRightPoint.x, targetRightPoint.y);
		g.lineTo(_targetPoint.x, _targetPoint.y);

		g.endFill();
	}
}
}