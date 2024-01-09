package org.escafe.burieditor.object
{
    public class XpdlApplication
    {

        private var _xpdlId:String;
        private var _applicationName:String;
        private var _attribute:Attribute;
        private var _isPackageLevel:Boolean = false;
        
        public function get xpdlId():String {
            return _xpdlId;
        }
        
        public function set xpdlId(newId:String): void {
            _xpdlId = newId;
        }

        public function get applicationName():String {
            return _applicationName;
        }
        
        public function set applicationName(newApplicationName:String): void {
            _applicationName = newApplicationName;
        }

        public function get attribute():Attribute {
            return _attribute;
        }
        
        public function set attribute(newAttribute:Attribute): void {
            _attribute = newAttribute;
        }
     
        public function get attributeName():String {
            if(attribute == null) {
                return "";
            }
            return attribute.name;
        }

        public function set attributeName(newAttributeName:String): void {
            if(attribute == null) {
                attribute = new Attribute();
            }
            attribute.name = newAttributeName;
        }

        public function get attributeValue():String {
            if(attribute == null) {
                return "";
            }
            return attribute.value;
        }

        public function set attributeValue(newAttributeValue:String): void {
            if(attribute == null) {
                attribute = new Attribute();
            }
            attribute.value = newAttributeValue;
        }

        public function get isPackageLevel():Boolean {
            return _isPackageLevel;
        }
        
        public function set isPackageLevel(newIsPackageLevel:Boolean): void {
            _isPackageLevel = newIsPackageLevel;
        }

        public function clone(): XpdlApplication {
            var newApplication: XpdlApplication = new XpdlApplication();
            newApplication.xpdlId = _xpdlId;
            newApplication.applicationName = _applicationName;
            newApplication.attribute = _attribute;
            newApplication.isPackageLevel = _isPackageLevel;
            return newApplication;
        }
     
        public function writeApplication(applications:XMLList):void {
            applications.appendChild(<Application Id={xpdlId} Name={_applicationName}/>);
            if(attribute != null) {
                var applicationXml:XMLList = applications.Application.(@Id==xpdlId);
                applicationXml.appendChild(<ExtendedAttributes/>);
                applicationXml.ExtendedAttributes.appendChild(<ExtendedAttribute Name={attribute.name}/>);
            }
        }
        
    }
}