package org.escafe.burieditor.component
{
    import mx.collections.ArrayCollection;
    import mx.containers.Canvas;
    import mx.containers.VBox;
    import mx.controls.ComboBox;
    import mx.controls.TextArea;
    
    import org.escafe.burieditor.BuriEditorConst;
    import org.escafe.burieditor.object.XpdlApplication;
    import org.escafe.burieditor.object.Tool;
    
    public class BuriOgnlEditor extends Canvas
    {

        private var _applications:ArrayCollection;
        private var _tool:Tool;

        public function BuriOgnlEditor(newTool:Tool,newApplications:ArrayCollection): void {
            _tool = newTool;
            _applications = newApplications;
            
            percentWidth = 100;
            percentHeight = 100;

            applicationCmb = new ComboBox();
            applicationCmb.dataProvider = _applications;
            for each(var application: XpdlApplication in _applications) {
                if(_tool.xpdlId == application.xpdlId) {
                    applicationCmb.selectedItem = application;
                    break;
                }
            }
            
            applicationCmb.labelField = "applicationName"
            applicationCmb.percentWidth = 100;
                    
            ognlTextArea = new TextArea();
            ognlTextArea.text = _tool.ognl;
            ognlTextArea.percentWidth = 100;
            ognlTextArea.percentHeight = 100;

            var vbox:VBox = new VBox();
            vbox.percentWidth = 100;
            vbox.percentHeight = 100;
                    
            vbox.addChild(applicationCmb);
            vbox.addChild(ognlTextArea);

            addChild(vbox);
        }

        public function getTool(): Tool {
            var tool:Tool = new Tool();

            var selectedApplication: XpdlApplication = applicationCmb.selectedItem as XpdlApplication;

            var xpdlId: String = selectedApplication.xpdlId;
            tool.xpdlId = xpdlId;
            tool.toolType = BuriEditorConst.ID_TOOL_TYPE_APPLICATION;
            tool.toolName = BuriEditorConst.ID_TOOL_NAME_OGNL;
            
            var ognl:String = ognlTextArea.text;
            tool.ognl = ognl;
            
            if(ognl == "") {
                return null;
            }
            
            return tool;
        }

        private var applicationCmb: ComboBox;
        private var ognlTextArea: TextArea;

    }
}