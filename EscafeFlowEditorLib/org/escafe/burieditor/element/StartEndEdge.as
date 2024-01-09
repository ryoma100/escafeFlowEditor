package org.escafe.burieditor.element
{
	import org.escafe.graph.element.Node;
	import org.escafe.burieditor.BuriEditorConst;
	import org.escafe.graph.element.Edge;

public class StartEndEdge extends Edge
{
	public function StartEndEdge(newSourceNode: Node, newTargetNode: Node): void {
		super(newSourceNode, newTargetNode);
		typeId = BuriEditorConst.ID_START_END_EDGE;
	}
}
}