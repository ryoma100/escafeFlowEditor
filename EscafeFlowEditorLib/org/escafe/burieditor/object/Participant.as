package org.escafe.burieditor.object
{
	import mx.collections.ArrayCollection;
	import flash.events.EventDispatcher;
	
public class Participant extends EventDispatcher
{
	private var _xpdlId: String;
	private var _participantName: String;
	private var _isPackageLevel: Boolean = false;
	
	public function get xpdlId(): String {
		return _xpdlId;
	}
	
	public function set xpdlId(newId: String): void {
		_xpdlId = newId;
	}
	
	public function get participantName(): String {
		return _participantName;
	}
	
	[Bindable]
	public function set participantName(newName: String): void {
		_participantName = newName;
	}
	
	public function get isPackageLevel(): Boolean {
		return _isPackageLevel;
	}
	
	public function set isPackageLevel(anIsPackageLevel: Boolean): void {
		_isPackageLevel = anIsPackageLevel;
	}
	
	public function clone(): Participant {
		var newParticipant: Participant = new Participant();
		newParticipant.xpdlId = _xpdlId;
		newParticipant.participantName = _participantName;
		newParticipant.isPackageLevel = _isPackageLevel;
		return newParticipant;
	}
	
	public function writeParticipant(participantsXml: XMLList): void {
		participantsXml.appendChild(<Participant Id={_xpdlId} Name={_participantName}/>);
		var participantXml: XMLList = participantsXml.Participant.(@Id==xpdlId);
		participantXml.appendChild(<ParticipantType Type="ROLE"/>);
	}
}
}