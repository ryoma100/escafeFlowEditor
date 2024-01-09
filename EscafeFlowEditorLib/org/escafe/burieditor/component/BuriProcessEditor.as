package org.escafe.burieditor.component
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.core.ScrollPolicy;
	
	import org.escafe.burieditor.application.EmbeddedBuriEditor;
	import org.escafe.burieditor.element.ActivityNode;
	import org.escafe.burieditor.element.CommentNode;
	import org.escafe.burieditor.element.StartEndNode;
	import org.escafe.burieditor.element.TransitionEdge;
	import org.escafe.burieditor.object.Attribute;
	import org.escafe.burieditor.object.Participant;
	import org.escafe.burieditor.object.XpdlApplication;
	import org.escafe.graph.element.Edge;
	import org.escafe.graph.element.Node;

public class BuriProcessEditor extends Canvas
{
	private var _nextParticipantXpdlId: int = 0;
	private var _participants: ArrayCollection = new ArrayCollection();

	private var _packageId: String;
	private var _xpdlId: String;
	private var _processName: String;
	private var _processAttributes: ArrayCollection = new ArrayCollection();
	
	private var _rootPackage: EmbeddedBuriEditor;
	private var _buriGraphEditor: BuriGraphEditor = new BuriGraphEditor();

    private var _applications: ArrayCollection = new ArrayCollection();

    private var _validDateFrom: String;
    private var _validDateTo: String;

	/**
	 * @category initialize and release
	 */
	public function BuriProcessEditor(xpdlId:String): void {
	    _xpdlId = xpdlId;
	    
		addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);

		verticalScrollPolicy = ScrollPolicy.ON;
		horizontalScrollPolicy = ScrollPolicy.ON;
		verticalScrollPosition = 0;
		horizontalScrollPosition = 0;

		addChild(_buriGraphEditor);

		addParticipant();
		getBuriGraphEditor().currentParticipant = _participants.getItemAt(0) as Participant;
	}

	/**
	 * @category initialize and release
	 */
	public function onRemoveFromStage(event: Event): void {
		// 親への循環参照を解除して、ガベコレの対象にする
		_rootPackage = null;
	}

	public function set rootPackage(aPackage: EmbeddedBuriEditor): void {
		_rootPackage = aPackage;
	}

	/**
	 * @category accessing
	 */
	public function get xpdlId(): String {
		return _xpdlId;
	}

	/**
	 * @category accessing
	 */
	public function set xpdlId(newId: String): void {
		_xpdlId = newId;
	}
	
	/**
	 * @category accessing
	 */
	public function get processName(): String {
		return _processName;
	}

	/**
	 * @category accessing
	 */
	[Bindable]
	public function set processName(newName: String): void {
		_processName = newName;
	}
	
	/**
	 * @category accessing
	 */
	public function get processAttributes(): ArrayCollection {
		return _processAttributes;
	}

	/**
	 * @category accessing
	 */
	public function getBuriGraphEditor(): BuriGraphEditor {
		return _buriGraphEditor;
	}

	/**
	 * @category participant accessing
	 */
	public function get participants(): ArrayCollection {
		return _participants;
	}

    /**
     * @category application accessing
     */
    public function get applications(): ArrayCollection {
        return _applications;
    }

    /**
     * @category Process ValidDate(From) accessing
     */
    public function get validDateFrom(): String {
        return _validDateFrom;
    }

    /**
     * @category Process ValidDate(From) accessing
     */
    public function set validDateFrom(newValidDateFrom: String): void {
        _validDateFrom = newValidDateFrom;
    }

    /**
     * @category Process ValidDate(To) accessing
     */
    public function get validDateTo(): String {
        return _validDateTo;
    }

    /**
     * @category Process ValidDate(To) accessing
     */
    public function set validDateTo(newValidDateTo: String): void {
        _validDateTo = newValidDateTo;
    }

	/**
	 * @category participant accessing
	 */
	public function addParticipant(): void {
		var participant: Participant = new Participant();
		participant.xpdlId = getNextParticipantXpdlId();
		participant.participantName = "アクター" + _nextParticipantXpdlId;
		_participants.addItem(participant);
	}
	
	public function isUsedParticipant(aParticipant: Participant): Boolean {
		for each (var activity: ActivityNode in _buriGraphEditor.getActivityNodes()) {
			if (activity.participant == aParticipant) {
				return true;
			}
		}
		return false;
	}
	
	/**
	 * @category participant accessing
	 */
	public function removeParticipant(index: int): void {
		var aParticipant: Participant = _participants.getItemAt(index) as Participant;
		if (_rootPackage.isUsedParticipant(aParticipant)) {
			Alert.show("このアクターの仕事が残っているので、削除できません。");
			return;
		}
		
		if (_participants.length >= 2) {
			_participants.removeItemAt(index);
		} else {
			Alert.show("アクターを全て削除することは出来ません。");
		}
	}
	
	/**
	 * @category xpdl id creation
	 */
	public function getNextParticipantXpdlId(): String {
		var nextId: String;
		do {
			_nextParticipantXpdlId++;
			nextId = _xpdlId + "_par" + _nextParticipantXpdlId;
		} while (containsParticipantXpdlId(nextId));
		return nextId;
	}

	/**
	 * @category xpdl id creation
	 */
	private function containsParticipantXpdlId(xpdlId: String): Boolean {
		for each (var participant: Participant in participants) {
			if (participant.xpdlId == xpdlId) {
				return true;
			}
		}
		return false;
	}

	/**
	 * @category xpdl writer
	 */
	public function writeWorkflowProcess(processesXml: XMLList): void {
		processesXml.appendChild(<WorkflowProcess Id={xpdlId} Name={processName}/>);
		var processXml: XMLList = processesXml.WorkflowProcess.(@Id==xpdlId);

		var created: String = new Date().toString();
		processXml.appendChild(<ProcessHeader><Created>{created}</Created></ProcessHeader>);

        if(validDateFrom != null && validDateFrom != "") {
            processXml.ProcessHeader.appendChild(<ValidFrom>{validDateFrom}</ValidFrom>);
        }

        if(validDateTo != null && validDateTo != "") {
            processXml.ProcessHeader.appendChild(<ValidTo>{validDateTo}</ValidTo>);
        }

		processXml.appendChild(<Participants/>);
		for each (var participant: Participant in _participants) {
			participant.writeParticipant(processXml.Participants);
		}
		
		processXml.appendChild(<Applications/>);
		for each (var application: XpdlApplication in _applications) {
		    application.writeApplication(processXml.Applications);
		}
		
		processXml.appendChild(<Activities/>);
		for each (var node: Node in _buriGraphEditor.nodeStage.getChildren()) {
			if (node is ActivityNode) {
				(node as ActivityNode).writeActivity(processXml.Activities, _buriGraphEditor);
			}
		}
		
		processXml.appendChild(<Transitions/>);
		for each (var edge: Edge in _buriGraphEditor.edgeStage.getChildren()) {
			if (edge is TransitionEdge) {
				(edge as TransitionEdge).writeTransition(processXml.Transitions, _buriGraphEditor);
			}
		}

		processXml.appendChild(<ExtendedAttributes/>);
		for each (var node: Node in _buriGraphEditor.nodeStage.getChildren()) {
			if (node is StartEndNode) {
				(node as StartEndNode).writeExtendedAttribute(processXml.ExtendedAttributes, _buriGraphEditor);
			}
			if (node is CommentNode) {
				(node as CommentNode).writeExtendedAttribute(processXml.ExtendedAttributes, _buriGraphEditor);
			}
		}
		processXml.ExtendedAttributes.appendChild(<ExtendedAttribute Name="JaWE_GRAPH_WORKFLOW_PARTICIPANT_ORDER" Value={createParticipantOrder()}/>);
		for each (var attribute: Attribute in _processAttributes) {
			processXml.ExtendedAttributes.appendChild(<ExtendedAttribute Name={attribute.name} Value={attribute.value}/>);
		}
	}

	private function createParticipantOrder(): String {
		var order: String = "";
		for each (var aParticipant: Participant in _participants) {
			if (order != "") {
				order += ";";
			}
			order += aParticipant.xpdlId;
		}
		return order;
	}

	/**
	 * @category xpdl reader
	 */
	public function searchActivityNode(xpdlId: String): ActivityNode {
		for each (var node: Node in _buriGraphEditor.nodeStage.getChildren()) {
			if (node is ActivityNode && (node as ActivityNode).xpdlId == xpdlId) {
				return node as ActivityNode
			}
		}
		return null;
	}
	
	/**
	 * @category xpdl reader
	 */
	public function searchParticipant(xpdlId: String): Participant {
		for each (var participant: Participant in _participants) {
			if (participant.xpdlId == xpdlId) {
				return participant;
			}
		}
		return null;
	}
}
}