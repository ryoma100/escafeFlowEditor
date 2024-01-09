package org.escafe.burieditor.element
{
	import org.escafe.graph.element.Node;
	import org.escafe.burieditor.BuriEditorConst;
	import org.escafe.graph.element.Edge;
	import flash.display.Graphics;
	import flash.geom.Point;
	import org.escafe.graph.geometry.GeomUtils;

public class CommentEdge extends Edge
{
	public function CommentEdge(newSourceNode: Node, newTargetNode: Node): void {
		super(newSourceNode, newTargetNode);
		typeId = BuriEditorConst.ID_COMMENT_EDGE;
	}

	/**
	 * @category drawing
	 */
	override public function draw(): void {
		var g: Graphics = this.graphics;
		g.clear();

		if (line != null) {
			var angle: Number = line.angle();
			var targetLeftPoint: Point = new Point(line.targetPoint.x - ARROW_SIZE, line.targetPoint.y - ARROW_SIZE / 2);
			var targetRightPoint: Point = new Point(line.targetPoint.x - ARROW_SIZE, line.targetPoint.y + ARROW_SIZE / 2);
			targetLeftPoint = GeomUtils.rotatePoint(line.targetPoint, angle, targetLeftPoint);
			targetRightPoint = GeomUtils.rotatePoint(line.targetPoint, angle, targetRightPoint);
	
			var thickness: int = (this.selected) ? 3 : 1;
			var color: int = (this.selected) ? 0x000000 : 0xC0C0C0;
			g.lineStyle(thickness, color);
			g.moveTo(line.sourcePoint.x, line.sourcePoint.y);
			g.lineTo(line.targetPoint.x, line.targetPoint.y);
			g.lineTo(targetLeftPoint.x, targetLeftPoint.y);
			g.moveTo(targetRightPoint.x, targetRightPoint.y);
			g.lineTo(line.targetPoint.x, line.targetPoint.y);
		}
	}
}
}