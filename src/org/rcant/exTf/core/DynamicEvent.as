/**
 * Class Name: DynamicEvent
 * Description:
 * Created by Ryan on 2014/12/25 23:40.
 */
package org.rcant.exTf.core {
import flash.events.Event;

public class DynamicEvent extends Event {
    private var _data:Object;
    //-----------------------------------------
    //Var
    //-----------------------------------------
    public static const LINK_TEXT:String = "linkText";

    public function DynamicEvent(type:String, data:* = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        _data = data;
    }

    //-----------------------------------------
    //Methods
    //-----------------------------------------

    public function get data():Object {
        return _data;
    }
}
}
