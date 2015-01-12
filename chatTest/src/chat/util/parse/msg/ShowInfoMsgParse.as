/**
 * Class name: ShowInfoMsgParse.as
 * Description:
 * Author: caoqingshan
 * Create: 14-7-23 下午7:58
 */
package chat.util.parse.msg {
import chat.util.ShowInfoParseUtil;
import chat.util.parse.showinfo.ISShowInfoParse;

import mx.utils.StringUtil;

import net.core.vo.SShowInfo;

import org.rcant.exTf.core.InlineGraphicItem;
import org.rcant.exTf.core.TextData;

public class ShowInfoMsgParse implements IMsgParse {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------
    public static const showInfoReg:RegExp = /\!!si/;

    public static const SHOWINFO_FLAG:String = "!!si";

    static public function test(mTag:String):Boolean {
        return Boolean(mTag.match(showInfoReg));
    }

    public function ShowInfoMsgParse() {
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------
    /**
     * 炫耀数据在结构体中位置
     */
    public var showInfoPos:uint = 0;
    /**
     * 炫耀数据体
     */
    private var _vecShowInfo:Vector.<SShowInfo>;

    public function getMsg():String {
        return StringUtil.substitute("{{0}{1}}", SHOWINFO_FLAG, showInfoPos.toString());
    }

    public function setMsg(m:String):void {
        showInfoPos = int(m.replace("{", "").replace("}", "").replace(SHOWINFO_FLAG, ""));
    }

    public function getTextData():TextData {
        var td:TextData = new TextData();
        if (showInfoPos < 0)
            return td;
        if (_vecShowInfo && _vecShowInfo.length > showInfoPos) {
            var itemG:InlineGraphicItem = ShowInfoMsgParse.getItem(_vecShowInfo[showInfoPos]);
            if (itemG.type == 1) {
                td.appendHtmlText(String(itemG.source));
            } else {
                td.appendGraphic(itemG);
            }

        }
        return td;
    }

    public function getHTML():String {
        if (showInfoPos < 0)
            return "";
        var ishowParse:ISShowInfoParse;
        if (_vecShowInfo && _vecShowInfo.length > showInfoPos) {
            ishowParse = ShowInfoParseUtil.parseShowInfo(_vecShowInfo[showInfoPos]);
        }
        if (ishowParse)
            return ishowParse.getHTML();
        return "";
    }

    public function setVecShowInfo(vecShowInfo:Vector.<SShowInfo>):void {
        _vecShowInfo = vecShowInfo;
    }

    /**
     * 获取炫耀展示
     */
    public static function getInputItem(sShowInfo:SShowInfo, pos:int = -1):InlineGraphicItem {
        var ishowParse:ISShowInfoParse = ShowInfoParseUtil.parseShowInfo(sShowInfo);
        if (ishowParse) {
            var element:InlineGraphicItem = ishowParse.getInputItem();
            element.msg = "{" + SHOWINFO_FLAG + pos + "}";
            return element;
        }
        return null;
    }

    /**
     * 获取炫耀展示
     */
    public static function getItem(sShowInfo:SShowInfo, pos:int = -1):InlineGraphicItem {
        var ishowParse:ISShowInfoParse = ShowInfoParseUtil.parseShowInfo(sShowInfo);
        if (ishowParse) {
            var element:InlineGraphicItem = ishowParse.getItem();
            element.msg = "{" + SHOWINFO_FLAG + pos + "}";
            return element;
        }
        return null;
    }
}
}
