package org.escafe.burieditor.object
{
    public class Tool
    {

        private var _xpdlId:String;
        private var _toolType:String;
        private var _toolName:String;
        private var _ognl:String;
        
        public function get xpdlId():String {
            return _xpdlId;
        }
        
        public function set xpdlId(newId:String): void {
            _xpdlId = newId;
        }

        public function get toolType():String {
            return _toolType;
        }
        
        public function set toolType(newToolType:String): void {
            _toolType = newToolType;
        }

        public function get toolName():String {
            return _toolName;
        }
        
        public function set toolName(newToolName:String): void {
            _toolName = newToolName;
        }

        public function get ognl():String {
            return _ognl;
        }
        
        public function set ognl(newOgnl:String): void {
            _ognl = newOgnl;
        }

    }
}