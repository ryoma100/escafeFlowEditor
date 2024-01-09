package org.escafe.burieditor.element
{
	import org.escafe.graph.element.Node;
	import flash.geom.Point;
	import org.escafe.burieditor.BuriEditorConst;
	import mx.core.UIComponent;
	import org.escafe.burieditor.component.BuriGraphEditor;
	import org.escafe.graph.element.Edge;
	import org.escafe.burieditor.view.StartView;
	import org.escafe.burieditor.view.StopView;

public class StartEndNode extends Node
{
	public function StartEndNode(newTypeId: String, point: Point): void {
		this.typeId = newTypeId;
		var view: UIComponent;
		if (newTypeId == BuriEditorConst.ID_START_ACTIVITY) {
			view = new StartView();
		} else {
			view = new StopView();
		}
		super(view, point);
	}

	override public function createEdgeTo(targetNode: Node): Edge {
		if (typeId == BuriEditorConst.ID_START_ACTIVITY && targetNode is ActivityNode) {
			for each (var edge: Edge in getGraph().edgeStage.getChildren()) {
				if (edge.sourceNode == this) {
					return null;
				}
			}
			return new StartEndEdge(this, targetNode);
		}
		return null;
	}

	public function writeExtendedAttribute(extendedAttributesXml: XMLList, graph: BuriGraphEditor): void {
		extendedAttributesXml.appendChild(<ExtendedAttribute Name={createName()} Value={createValue(graph)}/>);
	}

	private function createName(): String {
		if (typeId == BuriEditorConst.ID_START_ACTIVITY) {
			return "JaWE_GRAPH_START_OF_WORKFLOW";
		} else {
			return "JaWE_GRAPH_END_OF_WORKFLOW";
		}
	}

	private function createValue(graph: BuriGraphEditor): String {
		if (typeId == BuriEditorConst.ID_START_ACTIVITY) {
			return createStartValue(graph);
		} else {
			return createEndValue(graph);
		}
	}

	private function createStartValue(graph: BuriGraphEditor): String {
		var value: String;
		for each (var edge: Edge in graph.edgeStage.getChildren()) {
			if (edge is StartEndEdge && edge.sourceNode == this) {
				value = "JaWE_GRAPH_PARTICIPANT_ID=" + (edge.targetNode as ActivityNode).participant.xpdlId;
				value += ",CONNECTING_ACTIVITY_ID=" + (edge.targetNode as ActivityNode).xpdlId;
				break;
			}
		}
		value += ",X_OFFSET=" + Math.round(x);
		value += ",Y_OFFSET=" + Math.round(y);
		value += ",JaWE_GRAPH_TRANSITION_STYLE=" + "SIMPLE_ROUTING_BEZIER";
		value += ",TYPE=" + "START_DEFAULT";
		return value;
	}

	private function createEndValue(graph: BuriGraphEditor): String {
		var value: String;
		for each (var edge: Edge in graph.edgeStage.getChildren()) {
			if (edge is StartEndEdge && edge.targetNode == this) {
				value = "JaWE_GRAPH_PARTICIPANT_ID=" + (edge.sourceNode as ActivityNode).participant.xpdlId;
				value += ",CONNECTING_ACTIVITY_ID=" + (edge.sourceNode as ActivityNode).xpdlId;
				break;
			}
		}
		value += ",X_OFFSET=" + Math.round(x);
		value += ",Y_OFFSET=" + Math.round(y);
		value += ",JaWE_GRAPH_TRANSITION_STYLE=" + "SIMPLE_ROUTING_BEZIER";
		value += ",TYPE=" + "END_DEFAULT";
		return value;
	}
}
}