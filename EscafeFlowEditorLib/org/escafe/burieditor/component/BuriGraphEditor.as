package org.escafe.burieditor.component
{
	import mx.events.FlexEvent;
	import mx.events.FlexMouseEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.escafe.graph.component.GraphEditor;
	import flash.geom.Point;
	import org.escafe.graph.element.Edge;
	import org.escafe.graph.element.Node;
	import org.escafe.burieditor.element.TransitionEdge;
	import org.escafe.burieditor.BuriEditorConst;
	import mx.managers.PopUpManager;
	import org.escafe.burieditor.element.ActivityNode;
	import org.escafe.burieditor.element.StartEndNode;
	import org.escafe.burieditor.drag.CreateEdgeStrategy;
	import org.escafe.burieditor.drag.ResizeNodeLeftStrategy;
	import org.escafe.burieditor.drag.ResizeNodeRightStrategy;
	import org.escafe.burieditor.drag.MoveEdgeTargetStrategy;
	import org.escafe.burieditor.drag.MoveEdgeSourceStrategy;
	import flash.utils.getTimer;
	import org.escafe.burieditor.dialog.ActivityDialog;
	import org.escafe.burieditor.dialog.TransitionDialog;
	import org.escafe.graph.element.Element;
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.controls.Alert;
	import flash.geom.Rectangle;
	import org.escafe.graph.drag.ScrollStrategy;
	import org.escafe.graph.drag.MoveNodeStrategy;
	import org.escafe.burieditor.object.Participant;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.containers.Canvas;
	import flash.events.ActivityEvent;
	import org.escafe.burieditor.element.CommentNode;
	import org.escafe.burieditor.dialog.CommentDialog;

public class BuriGraphEditor extends GraphEditor
{
	private var _toolbarId: String = BuriEditorConst.ID_POINT;
	private var _currentParticipant: Participant;

	private var _nextActivityXpdlId: int = 0;
	private var _nextTransitionXpdlId: int = 0;

	/**
	 * @category initialize
	 */
	public function BuriGraphEditor(): void {
		super();
		percentWidth = 100;
		percentHeight = 100;

		_nextActivityXpdlId = 0;
		_nextTransitionXpdlId = 0;
	}

	/**
	 * @category toolbar accessing
	 */
	public function set toolbarId(newId: String): void {
		_toolbarId = newId;
	}

	/**
	 * @category participant[s] accessing
	 */
	public function set currentParticipant(newParticipant: Participant): void {
		_currentParticipant = newParticipant;
	}
	
	public function setSelectParticipant(aParticipant: Participant): void {
		for each (var activity: ActivityNode in getActivityNodes()) {
			activity.selected = (activity.participant == _currentParticipant)
		}
	}
	
	/**
	 * @category element accessing
	 */
	public function getActivityNodes(): Array {
		var nodes: ArrayCollection = new ArrayCollection();
		for each (var node: Node in nodeStage.getChildren()) {
			if (node is ActivityNode) {
				nodes.addItem(node);
			}
		}
		return nodes.toArray();
	}

	/**
	 * @category xpdl id creation
	 */
	public function getNextActivityXpdlId(): String {
		var processId: String = (parent as BuriProcessEditor).xpdlId;
		var nextId: String;
		do {
			_nextActivityXpdlId++;
			nextId = processId + "_act" + _nextActivityXpdlId;
		} while (containsActivityXpdlId(nextId));
		return nextId;
	}

	/**
	 * @category xpdl id creation
	 */
	public function containsActivityXpdlId(xpdlId: String): Boolean {
		for each (var node: Node in nodeStage.getChildren()) {
			if (node is ActivityNode && (node as ActivityNode).xpdlId == xpdlId) {
				return true;
			}
		}
		return false;
	}

	/**
	 * @category xpdl id creation
	 */
	public function getNextTransitionXpdlId(): String {
		var processId: String = (parent as BuriProcessEditor).xpdlId;
		var nextId: String;
		do {
			_nextTransitionXpdlId++;
			nextId = processId + "_tra" + _nextTransitionXpdlId;
		} while (containsTransitionXpdlId(nextId));
		return nextId;
	}

	/**
	 * @category xpdl id creation
	 */
	private function containsTransitionXpdlId(xpdlId: String): Boolean {
		for each (var edge: Edge in edgeStage.getChildren()) {
			if (edge is TransitionEdge && (edge as TransitionEdge).xpdlId == xpdlId) {
				return true;
			}
		}
		return false;
	}

	/**
	 * @category mouse dragging
	 */
	override protected function mouseDoubleClick(event: MouseEvent): void {
		var currentElement: Element = findNode(getMousePoint());
		if (currentElement == null) {
			currentElement = findEdge(getMousePoint());
		}
		if (currentElement == null) {
			super.mouseDoubleClick(event);
		} else if (isOpenProperty(currentElement)) {
			openPropertyDialog(currentElement);
		}
	}
	
	/**
	 * @category mouse dragging
	 */
	override protected function mouseDown(event: MouseEvent): void {
		var currentPoint: Point = getMousePoint();
		var currentNode: Node = findNode(currentPoint);
		var currentEdge: Edge = findEdge(currentPoint);
	
		if (currentNode != null) {
			if (_toolbarId == BuriEditorConst.ID_TRANSITION_NORMAL) {
				dragStrategy = new CreateEdgeStrategy(this, currentNode);
			} else if (currentNode.containsLeftPoint(currentPoint)) {
				setSelectOneElementAndMoveUp(currentNode);
				dragStrategy = new ResizeNodeLeftStrategy(this, currentNode);
			} else if (currentNode.containsRightPoint(currentPoint)) {
				setSelectOneElementAndMoveUp(currentNode);
				dragStrategy = new ResizeNodeRightStrategy(this, currentNode);
			} else {
				if (event.shiftKey) {
					currentNode.selected = !currentNode.selected;
				} else if (currentNode.selected == false) {
					setSelectOneElementAndMoveUp(currentNode);
				}
				if (currentNode.selected) {
					dragStrategy = new MoveNodeStrategy(this);
				}
			}
		} else
		if (currentEdge != null) {
			setSelectOneElementAndMoveUp(currentEdge);
			if (currentEdge.containsTargetPoint(currentPoint)) {
				dragStrategy = new MoveEdgeTargetStrategy(this, currentEdge);
			} else
			if (currentEdge.containsSourcePoint(currentPoint)) {
				dragStrategy = new MoveEdgeSourceStrategy(this, currentEdge);
			}
		} else if (_toolbarId == BuriEditorConst.ID_TRANSITION_NORMAL || _toolbarId == BuriEditorConst.ID_TRANSITION_CONDITION) {
			// なにもしない
		} else if (_toolbarId != BuriEditorConst.ID_POINT) {
			createNode(_toolbarId);
		} else {
			super.mouseDown(event);
		}
		
		if (dragStrategy != null) {
			dragStrategy.mouseDown(currentPoint);
		}
	}

	/**
	 * @category mouse dragging
	 */
	private function createNode(newTypeId: String): void {
		var node: Node;
		switch (newTypeId) {
			case BuriEditorConst.ID_START_ACTIVITY:
			case BuriEditorConst.ID_STOP_ACTIVITY:
				node = new StartEndNode(newTypeId, new Point(mouseX - 15, mouseY - 15));
				break;
			case BuriEditorConst.ID_COMMENT_ACTIVITY:
				node = new CommentNode(new Point(mouseX - 15, mouseY - 15));
				break;
			default:
				node = new ActivityNode(newTypeId, new Point(mouseX - 80, mouseY - 45));
				(node as ActivityNode).xpdlId = getNextActivityXpdlId();
				(node as ActivityNode).participant = _currentParticipant;
				break;
		}
		addNode(node);
		setSelectOneElementAndMoveUp(node);
	}
	

	/**
	 * @category element property dialog
	 */
	public function isOpenProperty(element: Element): Boolean {
		return (element is ActivityNode || element is TransitionEdge || element is CommentNode);
	}

	/**
	 * @category element property dialog
	 */
	public function openPropertyDialog(element: Element): void {
		if (element is ActivityNode) {
			var activityDialog: ActivityDialog = PopUpManager.createPopUp(parent, ActivityDialog, true) as ActivityDialog;
			activityDialog.activityNode = element as ActivityNode;
			activityDialog.graphCanvas = this;
			PopUpManager.centerPopUp(activityDialog);
		} else if (element is TransitionEdge) {
			var transitionDialog: TransitionDialog = PopUpManager.createPopUp(parent, TransitionDialog, true) as TransitionDialog;
			transitionDialog.transitionEdge = element as TransitionEdge;
			PopUpManager.centerPopUp(transitionDialog);
		} else if (element is CommentNode) {
			var commentDialog: CommentDialog = PopUpManager.createPopUp(parent, CommentDialog, true) as CommentDialog;
			commentDialog.commentNode = element as CommentNode;
			PopUpManager.centerPopUp(commentDialog);
		}
	}

	/**
	 * @category find element
	 */
	public function searchActivityNode(xpdlId: String): ActivityNode {
		for each (var node: Node in nodeStage.getChildren()) {
			if (node is ActivityNode && (node as ActivityNode).xpdlId == xpdlId) {
				return node as ActivityNode
			}
		}
		return null;
	}
	
	/**
	 * @category find element
	 */
	public function searchParticipant(xpdlId: String): Participant {
		for each (var participant: Participant in getBuriProcessEditor().participants) {
			if (participant.xpdlId == xpdlId) {
				return participant;
			}
		}
		return null;
	}

	public function getBuriProcessEditor(): BuriProcessEditor {
		return parent as BuriProcessEditor;
	}

	/**
	 * @category join/split updating
	 */
	override protected function changedEdge(edge: Edge): void {
		if (edge.sourceNode is ActivityNode) {
			var sourceActivity: ActivityNode = edge.sourceNode as ActivityNode;
			switch (countSourceTransitionEdge(sourceActivity)) {
				case 0:
					sourceActivity.splitTypeId = BuriEditorConst.ID_NOT_SPLIT;
					break;
				case 1:
					sourceActivity.splitTypeId = BuriEditorConst.ID_ONE_SPLIT;
					break;
				default:
					if (sourceActivity.splitTypeId != BuriEditorConst.ID_AND_SPLIT) {
						sourceActivity.splitTypeId = BuriEditorConst.ID_XOR_SPLIT;
					}
					break;
			}
		}
		if (edge.targetNode is ActivityNode) {
			if (edge.targetNode is ActivityNode) {
				var targetActivity: ActivityNode = edge.targetNode as ActivityNode;
				switch (countTargetTransitionEdge(targetActivity)) {
					case 0:
						targetActivity.joinTypeId = BuriEditorConst.ID_NOT_JOIN;
						break;
					case 1:
						targetActivity.joinTypeId = BuriEditorConst.ID_ONE_JOIN;
						break;
					default:
						if (targetActivity.joinTypeId != BuriEditorConst.ID_AND_JOIN) {
							targetActivity.joinTypeId = BuriEditorConst.ID_XOR_JOIN;
						}
						break;
				}
			}
		}
	}

	/**
	 * @category join/split updating
	 */
	private function countSourceTransitionEdge(node: Node): int {
		var count: int = 0;
		for each (var edge: Edge in edgeStage.getChildren()) {
			if (edge is TransitionEdge && edge.sourceNode == node) {
				count++;
			}
		}
		return count;
	}
	
	/**
	 * @category join/split updating
	 */
	private function countTargetTransitionEdge(node: Node): int {
		var count: int = 0;
		for each (var edge: Edge in edgeStage.getChildren()) {
			if (edge is TransitionEdge && edge.targetNode == node) {
				count++;
			}
		}
		return count;
	}
}
}