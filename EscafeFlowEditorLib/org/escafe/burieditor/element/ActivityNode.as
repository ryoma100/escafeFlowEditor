package org.escafe.burieditor.element
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Image;
	import mx.events.PropertyChangeEvent;
	
	import org.escafe.burieditor.BuriEditorConst;
	import org.escafe.burieditor.component.BuriGraphEditor;
	import org.escafe.burieditor.object.Participant;
	import org.escafe.burieditor.object.Tool;
	import org.escafe.burieditor.view.ActivityView;
	import org.escafe.graph.element.Edge;
	import org.escafe.graph.element.Node;

public class ActivityNode extends Node
{
	private var _joinTypeId: String = BuriEditorConst.ID_ONE_JOIN;
	private var _splitTypeId: String = BuriEditorConst.ID_ONE_SPLIT;
	private var _limit:String;
	private var _xpdlId: String;
	private var _participant: Participant;
	private var _tools: ArrayCollection = new ArrayCollection();

	public function ActivityNode(newTypeId: String, point: Point) {
		super(new ActivityView(), point);
		this.typeId = newTypeId;
	}
	
	/**
	 * @category initialize and release
	 */
	override protected function onRemovedFromStage(event: Event): void {
		if (_participant != null) {
			_participant.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onParticipantChange);
		}
	}

	public function getActivityView(): ActivityView {
		return view as ActivityView;
	}
	
	public function get xpdlId(): String {
		return _xpdlId;
	}
	
	public function set xpdlId(newId: String): void {
		_xpdlId = newId;
	}

	override public function set typeId(newTypeId: String): void {
		super.typeId = newTypeId;
		for each (var image: Image in getActivityView().activities.getChildren()) {
			image.visible = (image.id == newTypeId);
		}
	}
	
	public function get joinTypeId(): String {
		return _joinTypeId;
	}
	
	public function set joinTypeId(newTypeId: String): void {
		_joinTypeId = newTypeId;
		getActivityView().joinTypeId = _joinTypeId;
	}
	
	public function get splitTypeId(): String {
		return _splitTypeId;
	}
	
	public function set splitTypeId(newTypeId: String): void {
		_splitTypeId = newTypeId;
		getActivityView().splitTypeId = _splitTypeId;
	}
	
	public function get participant(): Participant {
		return _participant;
	}

    public function get tools(): ArrayCollection {
        return _tools;
    }

	public function set participant(newParticipant: Participant): void {
		if (_participant != null) {
			_participant.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onParticipantChange);
		}
		_participant = newParticipant;
		onParticipantChange(null);
		if (_participant != null) {
			_participant.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onParticipantChange);
		}
	}

	private function onParticipantChange(event: PropertyChangeEvent): void {
		var participantName: String = (_participant != null) ? _participant.participantName : "";
		getActivityView().paticipantName.text = participantName;
	}
	
	public function get activityName(): String {
		return getActivityView().activityName.text;
	}

	public function set activityName(newName: String): void {
		getActivityView().activityName.text = newName;
	}
	
    public function get limit(): String {
      return _limit;
    }
    
    public function set limit(newLimit: String): void {
      _limit = newLimit;
    }
	
	override public function getSourcePoint(): Point {
		return new Point(this.x + this.width - getActivityView().split.width, this.y + (this.height / 2));
	}

	override public function getTargetPoint(): Point {
		return new Point(this.x + getActivityView().join.width, this.y + (this.height / 2));
	}
	
	override public function createEdgeTo(targetNode: Node): Edge {
		if (targetNode is ActivityNode) {
			var newEdge: TransitionEdge = new TransitionEdge(this, targetNode);
			newEdge.xpdlId = (getGraph() as BuriGraphEditor).getNextTransitionXpdlId();
			return newEdge;
		}
		if (targetNode.typeId == BuriEditorConst.ID_STOP_ACTIVITY) {
			for each (var edge: Edge in getGraph().edgeStage.getChildren()) {
				if (edge.visible == true && edge.targetNode == targetNode) {
					return null;
				}
			}
			return new StartEndEdge(this, targetNode);
		}
		return null;
	}
	
	public function writeActivity(activitiesXml: XMLList, graph: BuriGraphEditor): void {
		activitiesXml.appendChild(<Activity Id={xpdlId} Name={activityName}/>);
		var activityXml: XMLList = activitiesXml.Activity.(@Id==xpdlId);

		var isImplementationWrite:Boolean = writeTool(activityXml,graph);
		
		writeLimit(activityXml, graph);
		if(isImplementationWrite == false) {
		  activityXml.appendChild(<Implementation><No/></Implementation>);
		}
		activityXml.appendChild(<Performer>{participant.xpdlId}</Performer>);
		writeFinishMode(activityXml, graph);
		if (isJoinWritable() || isSplitWritable()) {
			writeTransitionRestrictions(activityXml, graph);
		}
		writeExtendedAttributes(activityXml, graph);
	}
	
	private function isOgnlEmpty():Boolean {
		if(limit != null && limit != "") {
			return false;
		}
		return true;
	}
	
	private function writeTool(activityXml: XMLList, graph: BuriGraphEditor): Boolean {
	    var isImplementationWrite:Boolean = false;
		switch(typeId) {
			case BuriEditorConst.ID_AUTO_ACTIVITY:
            case BuriEditorConst.ID_AUTO_TIMER_ACTIVITY:
            case BuriEditorConst.ID_MANUAL_TIMER_ACTIVITY:
                if(_tools.length == 0) {
                     activityXml.appendChild(<Implementation><No/></Implementation>);
                     isImplementationWrite = true;
                     break;
                }
			    if(_tools.length > 0) {
			         activityXml.appendChild(<Implementation/>);
			         isImplementationWrite = true;
			    }
				for each(var tool: Tool in _tools) {
				    var toolXml:XML = <Tool Id={tool.xpdlId} Type={tool.toolType}/>
				    toolXml.appendChild(<ExtendedAttributes/>);
				    var ognlConverted:String = tool.ognl.replace(/\r\n|\r/g,"\n");
                    toolXml.ExtendedAttributes.appendChild(<ExtendedAttribute Name={tool.toolName} Value={ognlConverted}/>);    
                    activityXml.Implementation.appendChild(toolXml);
				}
				break;
		}
		return isImplementationWrite;
	}
	
	private function writeLimit(activityXml: XMLList, graph: BuriGraphEditor): void {
		switch (typeId) {
			case BuriEditorConst.ID_AUTO_TIMER_ACTIVITY:
			case BuriEditorConst.ID_MANUAL_TIMER_ACTIVITY:
				if (isOgnlEmpty == true) {
					return;
				}
				activityXml.appendChild(<Limit>{limit}</Limit>);
				break;
		}
	}

	private function writeFinishMode(activityXml: XMLList, graph: BuriGraphEditor): void {
		switch (typeId) {
			case BuriEditorConst.ID_AUTO_ACTIVITY:
			case BuriEditorConst.ID_AUTO_TIMER_ACTIVITY:
				activityXml.appendChild(<FinishMode><Automatic/></FinishMode>);
				break;
			case BuriEditorConst.ID_MANUAL_ACTIVITY:
			case BuriEditorConst.ID_MANUAL_TIMER_ACTIVITY:
				activityXml.appendChild(<FinishMode><Manual/></FinishMode>);
				break;
			case BuriEditorConst.ID_USER_ACTIVITY:
				// 何も書かない
				break;
		}
	}
	
	private function writeTransitionRestrictions(activityXml: XMLList, graph: BuriGraphEditor): void {
		activityXml.appendChild(<TransitionRestrictions><TransitionRestriction/></TransitionRestrictions>);
		var transitionRestrictionXml: XMLList = activityXml.TransitionRestrictions.TransitionRestriction;

		if (isJoinWritable()) {
			var type: String = (joinTypeId == BuriEditorConst.ID_XOR_JOIN) ? "XOR" : "AND";
			transitionRestrictionXml.appendChild(<Join Type={type}><TransitionRefs/></Join>);
			for each (var edge: Edge in graph.edgeStage.getChildren()) {
				if (edge is TransitionEdge && edge.targetNode == this) {
					var sourceNode: ActivityNode = edge.sourceNode as ActivityNode;
					transitionRestrictionXml.Join.TransitionRefs.appendChild(<TransitionRef Id={sourceNode.xpdlId}/>);
				}
			}
		}
		
		if (isSplitWritable()) {
			var type: String = (splitTypeId == BuriEditorConst.ID_XOR_SPLIT) ? "XOR" : "AND";
			transitionRestrictionXml.appendChild(<Split Type={type}><TransitionRefs/></Split>);
			for each (var edge: Edge in graph.edgeStage.getChildren()) {
				if (edge is TransitionEdge && edge.sourceNode == this) {
					var targetNode: ActivityNode = edge.targetNode as ActivityNode;
					transitionRestrictionXml.Split.TransitionRefs.appendChild(<TransitionRef Id={targetNode.xpdlId}/>);
				}
			}
		}
		
	}

	private function writeExtendedAttributes(activityXml: XMLList, graph: BuriGraphEditor): void {
		activityXml.appendChild(<ExtendedAttributes/>);
		var extendedAttributesXml: XMLList = activityXml.ExtendedAttributes;
		extendedAttributesXml.appendChild(<ExtendedAttribute Name="JaWE_GRAPH_PARTICIPANT_ID" Value={participant.xpdlId}/>);
		var string: String = Math.round(x) + "," + Math.round(y);
		extendedAttributesXml.appendChild(<ExtendedAttribute Name="JaWE_GRAPH_OFFSET" Value={string}/>);
		string = Math.round(x) + "," + Math.round(y) + "," + Math.round(width) + "," + Math.round(height);
		extendedAttributesXml.appendChild(<ExtendedAttribute Name="BURI_GRAPH_RECTANGLE" Value={string}/>);
	}
	
	private function isJoinWritable(): Boolean {
		switch (joinTypeId) {
			case BuriEditorConst.ID_XOR_JOIN:
			case BuriEditorConst.ID_AND_JOIN:
				return true;
		}
		return false;
	}

	private function isSplitWritable(): Boolean {
		switch (splitTypeId) {
			case BuriEditorConst.ID_XOR_SPLIT:
			case BuriEditorConst.ID_AND_SPLIT:
				return true;
		}
		return false;
	}
}
}