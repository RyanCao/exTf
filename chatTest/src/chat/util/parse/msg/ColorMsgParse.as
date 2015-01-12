package chat.util.parse.msg {

import chat.util.ColorUtil;

import org.rcant.exTf.core.TextData;
import org.rcant.exTf.util.HtmlUtil;

public class ColorMsgParse implements IMsgParse {
    public static const COLOR_REGEXP:RegExp = /color:.+/;
    private static const COLOR_REPLACE:RegExp = /color:\d:.+/;
    private static const REPLACE_REG:RegExp = /\{|\}/;
    private var msg:String;
    private var color:uint;

    public function ColorMsgParse() {
    }


    public function getMsg():String {
        return this.msg;
    }

    public function setMsg(m:String):void {
        this.msg = m;
    }

    /**
     * 取出物品id和品质值
     * @return
     */
    private function replaceFun2():String {
        var msg:String = arguments[0];
        var array:Array = msg.split(":");
        color = uint(array[1]);
        return String(array[2]);
    }

    public function getHTML():String {
        return msg.replace(COLOR_REPLACE, replaceFun);
    }

    private function replaceFun():String {
        var msg:String = arguments[0];
        var array:Array = msg.split(":");
        var color:uint = uint(array[1]);
        return HtmlUtil.colorOnly(array[2], ColorUtil.TEXTCOLOR[color]);
    }

    public static function test(mTag:String):Boolean {
        return Boolean(mTag.match(COLOR_REGEXP));
    }

    public function getTextData():TextData {
        var td:TextData = new TextData();
        td.appendText(msg.replace(COLOR_REPLACE, replaceFun2), ColorUtil.TEXTCOLOR[color]);
        return td;
    }
}
}
