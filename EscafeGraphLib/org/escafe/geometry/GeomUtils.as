package org.escafe.graph.geometry
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

public class GeomUtils
{
	public static const ACCURACY: Number = 0.000000000001;

	/**
	 * @category geometric computing
	 */
	public static function rotatePoint(center: Point, angle: Number, target: Point): Point  {
		var rad: Number = (angle * Math.PI / 180.0);
		var dx: Number = target.x - center.x;
		var dy: Number = center.y - target.y;
		var dist: Number = Math.sqrt(dx * dx + dy * dy);
		if (dist != 0.0) {
			var drad: Number = Math.atan2(dy, dx);
			drad -= Math.PI / 2.0;
			drad += rad;
			var ddx: Number = Math.sin(drad) * dist;
			var ddy: Number = Math.cos(drad) * dist;
			dx = - Math.round(ddx);
			dy = Math.round(ddy);
		}
		return new Point(dx + center.x, center.y - dy);
	}
	
	/**
	 * @category geometric computing
	 */
	public static function centerPoint(rect: Rectangle): Point {
		return new Point(rect.x + rect.width / 2, rect.y + rect.height / 2);
	}
	
	/**
	 * @category geometric computing
	 */
	public static function pointLength(p1: Point, p2: Point): Number {
		return Math.sqrt((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y));
	}
}
}