package org.escafe.burieditor.element
{
	import org.escafe.graph.element.Node;
	import flash.geom.Point;
	import org.escafe.burieditor.view.CommentView;
	import org.escafe.burieditor.BuriEditorConst;
	import org.escafe.graph.element.Edge;
	import org.escafe.burieditor.component.BuriGraphEditor;

public class CommentNode extends Node
{
	public function CommentNode(point: Point): void {
		typeId = BuriEditorConst.ID_COMMENT_ACTIVITY;
		var view: CommentView = new CommentView();
		super(view, point);
	}

	override public function createEdgeTo(targetNode: Node): Edge {
		if (targetNode is ActivityNode) {
			for each (var edge: Edge in getGraph().edgeStage.getChildren()) {
				if (edge.visible == true && edge.sourceNode == this) {
					return null;
				}
			}
			return new CommentEdge(this, targetNode);
		}
		return null;
	}
	
	public function getView(): CommentView {
		return view as CommentView;
	}

	public function writeExtendedAttribute(extendedAttributesXml: XMLList, graph: BuriGraphEditor): void {
		extendedAttributesXml.appendChild(<ExtendedAttribute Name="BURI_GRAPH_COMMENT" Value={createValue(graph)}/>);
	}

	private function createValue(graph: BuriGraphEditor): String {
		var value: String;
		for each (var edge: Edge in graph.edgeStage.getChildren()) {
			if (edge is CommentEdge && edge.sourceNode == this) {
				value = "JaWE_GRAPH_PARTICIPANT_ID=" + (edge.targetNode as ActivityNode).participant.xpdlId;
				value += ",CONNECTING_ACTIVITY_ID=" + (edge.targetNode as ActivityNode).xpdlId;
				break;
			}
		}
		value += ",X_OFFSET=" + Math.round(x);
		value += ",Y_OFFSET=" + Math.round(y);
		
		// 何が入るか分からないので、最後にする
		value += ",COMMENT=" + getView().commentText.text;
		return value;
	}
}
}