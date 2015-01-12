/**
 * Class name: MsgParse.as
 * Description:
 * Author: caoqingshan
 * Create: 14-7-18 上午10:36
 */
package chat.util.parse.msg {
import org.rcant.exTf.core.TextData;

public class MsgParse implements IMsgParse {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------
    private var item:String;

    //聊天内容是否为炫耀
    public static function test(content:String):Boolean {
        return false;
    }

    public function MsgParse() {
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------

    public function getMsg():String {
        return item;
    }

    public function setMsg(m:String):void {
        item = m;
    }

    public function getHTML():String {
        return item;
    }

    public function getTextData():TextData {
        var td:TextData = new TextData();
        td.appendHtmlText(item);
        return td;
    }
}
}
