/**
 * Class name: IconMsgParse.as
 * Description:
 * Author: caoqingshan
 * Create: 14-7-23 下午7:46
 */
package chat.util.parse.msg {
import chat.core.LDGraphicItem;
import chat.util.ChatUtil;

import mx.utils.StringUtil;

import org.rcant.exTf.core.InlineGraphicItem;
import org.rcant.exTf.core.TextData;

public class IconMsgParse implements IMsgParse {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------
    public static var iconReg:RegExp = /\!\d{2}/;

    public var item:String;

    static public function test(mTag:String):Boolean {
        return Boolean(mTag.match(iconReg)) && int(String(mTag).slice(1, 3)) <= 40;
    }

    public function IconMsgParse() {
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------

    public function getMsg():String {
        return StringUtil.substitute("{!{0}}", item);
    }

    public function setMsg(m:String):void {
        this.item = m;
    }

    public function getHTML():String {
        return "";
    }

    /**
     * 获取表情InlineGraphicElement
     */
    public static function getFaceItem(imgId:String, defaultWidth:int = 20, defaultHight:int = 20):InlineGraphicItem {
        //60fps
        //TODO 获取表情 地址
        var iconXml:XMLList = ChatUtil.faceXML.item;
        var iconIdxml:XMLList = iconXml.(@id == imgId);
        if (iconIdxml == null)
            return null;
        if (iconIdxml.length() == 0)
            return null;

        var img:InlineGraphicItem = new LDGraphicItem();
        var url:String = "../assets/" + iconIdxml.@icon.toString();
        img.source = url;
        img.msg = "{!" + imgId + "}";
        if (iconIdxml == null) {
            img.measuredWidth = defaultWidth;
            img.measuredHeight = defaultHight;
        }
        else {
            img.measuredWidth = iconIdxml.@w;
            img.measuredHeight = iconIdxml.@h;
        }
        return img;
    }

    public function getTextData():TextData {
        var td:TextData = new TextData();
        var faceIconID:String = String(item).slice(1, 3);
        var faceIcon:InlineGraphicItem = getFaceItem(faceIconID);
        td.appendGraphic(faceIcon);
        return td;
    }
}
}
