// ActionScript file
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;

import org.escafe.burieditor.BuriEditorConst;
import org.escafe.burieditor.component.BuriProcessEditor;
import org.escafe.burieditor.dialog.DenpyouDialog;
import org.escafe.burieditor.dialog.PackageDialog;
import org.escafe.burieditor.dialog.ParticipantDialog;
import org.escafe.burieditor.dialog.ProcessDialog;
import org.escafe.burieditor.dialog.XpdlOpenDialog;
import org.escafe.burieditor.dialog.XpdlSaveDialog;
import org.escafe.burieditor.object.Participant;
import org.escafe.burieditor.xpdl.XpdlReader;
import org.escafe.burieditor.xpdl.XpdlWriter;
import org.escafe.graph.element.Element;

private function keyUp(event: KeyboardEvent): void {
		case Keyboard.DELETE:
			getCurrentProcess().getBuriGraphEditor().removeSelectedElement();
		case Keyboard.ESCAPE:
			toolbar.buttonId = BuriEditorConst.ID_POINT;
			break;
			}
	}
}