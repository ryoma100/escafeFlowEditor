package org.escafe.burieditor.xpdl
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.collections.ArrayCollection;
	
	import org.escafe.burieditor.BuriEditorConst;
	import org.escafe.burieditor.application.EmbeddedBuriEditor;
	import org.escafe.burieditor.component.BuriProcessEditor;
	import org.escafe.burieditor.element.ActivityNode;
	import org.escafe.burieditor.element.CommentEdge;
	import org.escafe.burieditor.element.CommentNode;
	import org.escafe.burieditor.element.StartEndEdge;
	import org.escafe.burieditor.element.StartEndNode;
	import org.escafe.burieditor.element.TransitionEdge;
	import org.escafe.burieditor.object.Attribute;
	import org.escafe.burieditor.object.Participant;
	import org.escafe.burieditor.object.Tool;
	import org.escafe.burieditor.object.XpdlApplication;	

public class XpdlReader
{
	private var _rootPackage: EmbeddedBuriEditor;
	private var _packageLevelParticipants: ArrayCollection = new ArrayCollection();
    private var _packageLevelApplications: ArrayCollection = new ArrayCollection();
	
	public function XpdlReader(aRootPackage: EmbeddedBuriEditor): void {
		_rootPackage = aRootPackage;
	}

	public function readXpdlString(xpdlString: String): void {
		readPackage(xpdlString);
	}

	private function readPackage(xpdlString: String): void {
		var packageXml: XML = new XML(xpdlString);

		_rootPackage.xpdlId = packageXml.@Id;
		_rootPackage.packageName = packageXml.@Name;
		
		// <?xml ...?>があるとエラーになるので削除
		// <Package xsi:schemaLocation があるとnullになるので削除
		var index: int = xpdlString.indexOf("<PackageHeader");
		xpdlString = "<Package>" + xpdlString.substr(index);
		packageXml = new XML(xpdlString);

		for each (var participantXml: XML in packageXml.Participants.Participant) {
			var participant: Participant = new Participant();
			participant.xpdlId = participantXml.@Id;
			participant.participantName = participantXml.@Name;
			_packageLevelParticipants.addItem(participant);
		}

        for each (var applicationXml: XML in packageXml.Applications.Application) {
            var application: XpdlApplication = new XpdlApplication();
            application.xpdlId = applicationXml.@Id;
            application.applicationName = applicationXml.@Name;
        
            var attributeName:String = applicationXml.ExtendedAttributes.ExtendedAttribute.@Name;
            if(attributeName != null && attributeName != "") {
                var attribute:Attribute = new Attribute();
                attribute.name = attributeName;
                application.attribute = attribute;
            }

            _packageLevelApplications.addItem(application);
        }

		for each (var workflowProcessXml: XML in packageXml.WorkflowProcesses.WorkflowProcess) {
			var process: BuriProcessEditor = _rootPackage.addProcess();
			process.xpdlId = workflowProcessXml.@Id;
			process.processName = workflowProcessXml.@Name;
			process.participants.removeAll();
			readWorkflowProcess(workflowProcessXml, process);
		}
	}

	private function readWorkflowProcess(workflowProcessXml: XML, process: BuriProcessEditor): void {
		// TODO: パッケージParticipantを、プロセスへコピーする
		for each (var packageLevelParticipant: Participant in _packageLevelParticipants) {
			var participant: Participant = packageLevelParticipant.clone();
			participant.isPackageLevel = true;
			process.participants.addItem(participant);
		}

        for each (var packageLevelApplication: XpdlApplication in _packageLevelApplications) {
            var application: XpdlApplication = packageLevelApplication.clone();
            application.isPackageLevel = true;
            process.applications.addItem(application);
        }

        process.validDateFrom = "";
        var validDateFrom: String = workflowProcessXml.ProcessHeader.ValidFrom;
        if(validDateFrom != null && validDateFrom != "") {
            process.validDateFrom = validDateFrom;
        }

        process.validDateTo = "";
        var validDateTo: String = workflowProcessXml.ProcessHeader.ValidTo;
        if(validDateTo != null && validDateTo != "") {
            process.validDateTo = validDateTo;
        }

		for each (var participantXml: XML in workflowProcessXml.Participants.Participant) {
			readParticipant(participantXml, process);
		}
		for each (var applicationXml: XML in workflowProcessXml.Applications.Application) {
		    readApplication(applicationXml, process);
		}
		for each (var acrivityXml: XML in workflowProcessXml.Activities.Activity) {
			readActivity(acrivityXml, process);
		}
		for each (var transitionXml: XML in workflowProcessXml.Transitions.Transition) {
			readTransition(transitionXml, process);
		}
		for each (var acrivityXml: XML in workflowProcessXml.Activities.Activity) {
			readActivityTransition(acrivityXml, process);
		}
		for each (var extendedAttributeXml: XML in workflowProcessXml.ExtendedAttributes.ExtendedAttribute) {
			readExtendedAttribute(extendedAttributeXml, process);
		}
		
		// TODO: パッケージからプロセスへコピーしたParticipantのIdを重複しないように書き換える
		for each (var participant: Participant in process.participants) {
			if (participant.isPackageLevel) {
				participant.xpdlId = process.xpdlId + "__" + participant.xpdlId;
			}
		}
	}

	private function readParticipant(participantXml: XML, process: BuriProcessEditor): void {
		var participant: Participant = new Participant();
		participant.xpdlId = participantXml.@Id;
		participant.participantName = participantXml.@Name;
		process.participants.addItem(participant);
	}

    private function readApplication(applicationXml: XML, process: BuriProcessEditor): void {
        var application: XpdlApplication = new XpdlApplication();
        application.xpdlId = applicationXml.@Id;
        application.applicationName = applicationXml.@Name;
        
        var attributeName:String = applicationXml.ExtendedAttributes.ExtendedAttribute.@Name;
        if(attributeName != null && attributeName != "") {
            var attribute:Attribute = new Attribute();
            attribute.name = attributeName;
            application.attribute = attribute;
        }
        
        process.applications.addItem(application);
    }

	private function readActivity(activityXml: XML, process: BuriProcessEditor): void {
		var point: Point;
		var rectangle: Rectangle = null;

		var value: String = activityXml.ExtendedAttributes.ExtendedAttribute.(@Name == "BURI_GRAPH_RECTANGLE").@Value;
		if (value != null && value != "") {
			rectangle = parseRectangle(value);
			point = new Point(rectangle.x, rectangle.y);
		} else {
			value = activityXml.ExtendedAttributes.ExtendedAttribute.(@Name == "JaWE_GRAPH_OFFSET").@Value;
			point = parsePoint(value);
		}

		var activity: ActivityNode = new ActivityNode(BuriEditorConst.ID_MANUAL_ACTIVITY, point);
		activity.xpdlId = activityXml.@Id;
		activity.activityName = activityXml.@Name;
		activity.participant = process.searchParticipant(activityXml.Performer);
		if (rectangle != null) {
			activity.getActivityView().width = rectangle.width;
		}

		var limit: String = activityXml.Limit;
		if (activityXml.FinishMode.hasOwnProperty("Manual")) {
			if (limit != null && limit != "") {
				activity.typeId = BuriEditorConst.ID_MANUAL_TIMER_ACTIVITY;
				activity.limit = limit;
			} else {
				activity.typeId = BuriEditorConst.ID_MANUAL_ACTIVITY;
			}
		} else if (activityXml.FinishMode.hasOwnProperty("Automatic")) {
			if (limit != null && limit != "") {
				activity.typeId = BuriEditorConst.ID_AUTO_TIMER_ACTIVITY;
				activity.limit = limit;
			} else {
				activity.typeId = BuriEditorConst.ID_AUTO_ACTIVITY;
			}
		} else {
			activity.typeId = BuriEditorConst.ID_USER_ACTIVITY;
		}

        for each (var toolXml: XML in activityXml.Implementation.Tool) {
            var tool: Tool = new Tool();
            var toolXpdlId: String = toolXml.@Id;
            tool.xpdlId = toolXpdlId;
            var toolType:String = toolXml.@Type;
            tool.toolType = toolType;
            var toolName:String = toolXml.ExtendedAttributes.ExtendedAttribute.@Name;
            tool.toolName = toolName;
            var ognl: String = toolXml.ExtendedAttributes.ExtendedAttribute.@Value;
            tool.ognl = ognl;
            activity.tools.addItem(tool);
        }

		var participantId: String = activityXml.ExtendedAttributes.ExtendedAttribute.(@Name == "JaWE_GRAPH_PARTICIPANT_ID").@Value;
		var participant: Participant = process.searchParticipant(participantId);
		activity.participant = participant;

		process.getBuriGraphEditor().addNode(activity);
	}

	private function parsePoint(aString: String): Point {
		var nums: Array = aString.split(",");
		return new Point(Number(nums[0]), Number(nums[1]));
	}

	private function parseRectangle(aString: String): Rectangle {
		var nums: Array = aString.split(",");
		return new Rectangle(Number(nums[0]), Number(nums[1]), Number(nums[2]), Number(nums[3]));
	}

	private function readTransition(transitionXml: XML, process: BuriProcessEditor): void {
		var fromNode: ActivityNode = process.searchActivityNode(transitionXml.@From);
		var toNode: ActivityNode = process.searchActivityNode(transitionXml.@To);
		
		var transition: TransitionEdge = new TransitionEdge(fromNode, toNode);
		transition.xpdlId = transitionXml.@Id;
		if (transitionXml.hasOwnProperty("Condition")) {
			transition.centerLabel = transitionXml.Condition.toString();
			transition.typeId = BuriEditorConst.ID_TRANSITION_CONDITION;
		}

		process.getBuriGraphEditor().addEdge(transition);
	}

	private function readActivityTransition(activityXml: XML, process: BuriProcessEditor): void {
		var activity: ActivityNode = process.searchActivityNode(activityXml.@Id);
		
		var joinType: String = activityXml.TransitionRestrictions.TransitionRestriction.Join.@Type;
		switch (joinType) {
			case "XOR":
				activity.joinTypeId = BuriEditorConst.ID_XOR_JOIN;
				break;
			case "AND":
				activity.joinTypeId = BuriEditorConst.ID_AND_JOIN;
				break;
		}
		
		var splitType: String = activityXml.TransitionRestrictions.TransitionRestriction.Split.@Type;
		switch (splitType) {
			case "XOR":
				activity.splitTypeId = BuriEditorConst.ID_XOR_SPLIT;
				break;
			case "AND":
				activity.splitTypeId = BuriEditorConst.ID_AND_SPLIT;
				break;
		}
	}
	
	private function readExtendedAttribute(extendedAttributeXml: XML, process: BuriProcessEditor): void {
		var name: String = extendedAttributeXml.@Name.toString();
		var value: String = extendedAttributeXml.@Value.toString();
		switch (name) {
			case "JaWE_GRAPH_START_OF_WORKFLOW":
				var point: Point = parseOffset(value);
				var startNode: StartEndNode = new StartEndNode(BuriEditorConst.ID_START_ACTIVITY, point);
				process.getBuriGraphEditor().addNode(startNode);
				var targetActivityId: String = parseConnectingActivity(value);
				var targetActivity: ActivityNode = process.searchActivityNode(targetActivityId);
				var edge: StartEndEdge = new StartEndEdge(startNode, targetActivity);
				process.getBuriGraphEditor().addEdge(edge);
				break;
			case "JaWE_GRAPH_END_OF_WORKFLOW":
				var point: Point = parseOffset(value);
				var endNode: StartEndNode = new StartEndNode(BuriEditorConst.ID_STOP_ACTIVITY, point);
				process.getBuriGraphEditor().addNode(endNode);
				var sourceActivityId: String = parseConnectingActivity(value);
				var sourceActivity: ActivityNode = process.searchActivityNode(sourceActivityId);
				var edge: StartEndEdge = new StartEndEdge(sourceActivity, endNode);
				process.getBuriGraphEditor().addEdge(edge);
				break;
			case "BURI_GRAPH_COMMENT":
				var point: Point = parseOffset(value);
				var commentNode: CommentNode = new CommentNode(point);
				process.getBuriGraphEditor().addNode(commentNode);
				commentNode.getView().commentText.text = parseComment(value);
				var targetActivityId: String = parseConnectingActivity(value);
				var targetActivity: ActivityNode = process.searchActivityNode(targetActivityId);
				var commentEdge: CommentEdge = new CommentEdge(commentNode, targetActivity);
				process.getBuriGraphEditor().addEdge(commentEdge);
				break;
			default:
				if (name.indexOf("JaWE_") < 0 && name.indexOf("BURI_") < 0) {
					var attribute: Attribute = new Attribute();
					attribute.name = name;
					attribute.value = value;
					process.processAttributes.addItem(attribute);
				}
				break;
		}
	}
	
	private function parseOffset(aString: String): Point {
		var values: Array = aString.split(",");
		
		var x: String;
		var y: String;
		for each (var value: String in values) {
			var i: int = value.indexOf("X_OFFSET=");
			if (i >= 0) {
				x = value.substr(i + 9);
			}
			i = value.indexOf("Y_OFFSET=");
			if (i >= 0) {
				y = value.substr(i + 9);
			}
		}
		return new Point(Number(x), Number(y));
	}

	private function parseComment(aString: String): String {
		var i: int = aString.indexOf("COMMENT=");
		if (i >= 0) {
			return aString.substr(i + 8);
		}
		return "";
	}

	private function parseConnectingActivity(aString: String): String {
		var values: Array = aString.split(",");
		for each (var value: String in values) {
			var i: int = value.indexOf("CONNECTING_ACTIVITY_ID=");
			if (i >= 0) {
				return value.substr(i + 23);
			}
		}
		return null;
	}
}
}