/**
 * Class name: ShowInfoParseUtil.as
 * Description:炫耀解析处理
 * Author: caoqingshan
 * Create: 14-7-18 上午10:51
 */
package chat.util {
import chat.util.parse.showinfo.ISShowInfoParse;
import chat.util.parse.showinfo.SItemShowInfoParse;

import flash.utils.ByteArray;

import net.core.vo.SShowInfo;

public class ShowInfoParseUtil {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------

    public function ShowInfoParseUtil() {
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------
    /**
     * 解析成HTML结构体
     * @param msg
     * @return
     */
    public static function parseToHtml(vShowInfos:Vector.<SShowInfo>):String {
        var tags:String = ""
        var parser:ISShowInfoParse;
        if (vShowInfos) {
            for (var i:int = 0; i < vShowInfos.length; i++) {
                parser = getParser(vShowInfos[i].strShowInfo);
                parser.setShowInfo(vShowInfos[i]);
                tags += parser.getHTML();
            }
        }
        return "<font color='#ff0000'>" + tags + "</font>";
    }

    /**
     * 解析成ISShowInfoParse结构体
     * @param chatVO
     * @return
     */
    public static function parse(vShowInfos:Vector.<SShowInfo>):Vector.<ISShowInfoParse> {
        var tags:Vector.<ISShowInfoParse> = new Vector.<ISShowInfoParse>();
        var parser:ISShowInfoParse;
        if (vShowInfos) {
            for (var i:int = 0; i < vShowInfos.length; i++) {
                parser = getParser(vShowInfos[i].strShowInfo);
                parser.setShowInfo(vShowInfos[i]);
                tags.push(parser);
            }
        }
        return tags;
    }

    /**
     * 解析成ISShowInfoParse结构体
     * @param chatVO
     * @return
     */
    public static function parseShowInfo(sShowInfo:SShowInfo):ISShowInfoParse {
        var parser:ISShowInfoParse = getParser(sShowInfo.strShowInfo);
        parser.setShowInfo(sShowInfo);
        return parser;
    }


    /**
     * 获取应该使用的解析器
     * @param mTag
     * @return
     */
    private static function getParser(ba:ByteArray):ISShowInfoParse {
        var parser:ISShowInfoParse;
        if (SItemShowInfoParse.test(ba)) {
            parser = new SItemShowInfoParse();
        }
        return parser;
    }

}
}
