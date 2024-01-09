package org.escafe.burieditor.element
{
	import flash.display.Graphics;
	import flash.geom.Point;
	import org.escafe.graph.element.Node;
	import org.escafe.graph.geometry.GeomUtils;
	import org.escafe.graph.element.Edge;
	import org.escafe.burieditor.BuriEditorConst;
	import org.escafe.burieditor.component.BuriGraphEditor;

public class TransitionEdge extends Edge
{
	private var _xpdlId: String;

	public function TransitionEdge(newSourceNode: Node, newTargetNode: Node): void {
		super(newSourceNode, newTargetNode);
		this.typeId = BuriEditorConst.ID_TRANSITION_NORMAL;
	}
	
	public function get xpdlId(): String {
		return _xpdlId;
	}

	public function set xpdlId(newId: String): void {
		_xpdlId = newId;
	}

	override public function draw(): void {
		super.draw();

		if (line != null && _typeId == BuriEditorConst.ID_TRANSITION_CONDITION) {
			var g: Graphics = this.graphics;
			var angle: Number = line.angle();
			var targetLeftPoint: Point = new Point(line.targetPoint.x - ARROW_SIZE - 4, line.targetPoint.y - ARROW_SIZE / 2);
			var targetRightPoint: Point = new Point(line.targetPoint.x - ARROW_SIZE - 4, line.targetPoint.y + ARROW_SIZE / 2);
			targetLeftPoint = GeomUtils.rotatePoint(line.targetPoint, angle, targetLeftPoint);
			targetRightPoint = GeomUtils.rotatePoint(line.targetPoint, angle, targetRightPoint);
			g.moveTo(targetLeftPoint.x, targetLeftPoint.y);
			g.lineTo(targetRightPoint.x, targetRightPoint.y);

			targetLeftPoint = new Point(line.targetPoint.x - ARROW_SIZE - 8, line.targetPoint.y - ARROW_SIZE / 2);
			targetRightPoint = new Point(line.targetPoint.x - ARROW_SIZE - 8, line.targetPoint.y + ARROW_SIZE / 2);
			targetLeftPoint = GeomUtils.rotatePoint(line.targetPoint, angle, targetLeftPoint);
			targetRightPoint = GeomUtils.rotatePoint(line.targetPoint, angle, targetRightPoint);
			g.moveTo(targetLeftPoint.x, targetLeftPoint.y);
			g.lineTo(targetRightPoint.x, targetRightPoint.y);
		}
	}

	public function getSourceActivity(): ActivityNode {
		return sourceNode as ActivityNode;
	}
	
	public function getTargetActivity(): ActivityNode {
		return targetNode as ActivityNode;
	}

	public function writeTransition(transitionsXml: XMLList, graph: BuriGraphEditor): void {
		transitionsXml.appendChild(<Transition From={getSourceActivity().xpdlId} Id={xpdlId} To={getTargetActivity().xpdlId}/>);
		var transitionXml: XMLList = transitionsXml.Transition.(@Id==xpdlId);
		
		if (centerLabel != null && centerLabel != "") {
			transitionXml.appendChild(<Condition Type="CONDITION">{centerLabel}</Condition>);
		}
		
		transitionXml.appendChild(<ExtendedAttributes/>);
		transitionXml.ExtendedAttributes.appendChild(<ExtendedAttribute Name="JaWE_GRAPH_TRANSITION_STYLE" Value="NO_ROUTING_SPLINE"/>);
	}
}
}