/**
 * Class name: MsgParseUtil.as
 * Description:文本解析处理
 * Author: caoqingshan
 * Create: 14-7-18 上午10:51
 */
package chat.util {
import chat.util.parse.msg.ColorMsgParse;
import chat.util.parse.msg.IMsgParse;
import chat.util.parse.msg.IconMsgParse;
import chat.util.parse.msg.MsgParse;
import chat.util.parse.msg.ShowInfoMsgParse;
import chat.vo.ChatMessageVO;

import net.core.vo.EChannelType;

import net.core.vo.SShowInfo;

public class MsgParseUtil {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------

    public function MsgParseUtil() {
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------
    /**
     * 解析成HTML结构体
     * @param msg
     * @return
     */
    public static function parseToHtml(msg:String, vecShowInfo:Vector.<SShowInfo> = null):String {
        var tags:String = "";
        var mTag:String
        var parser:IMsgParse;
        if (msg) {
            var msgArray:Array = msg.split(ChatConstants.MSGTAG_REG);
            for each(var item:String in msgArray) {
                if (!item)
                    continue;
                var tmpA:Array = item.match(ChatConstants.MSGTAG_REG);
                if (tmpA && tmpA.length > 0) {
                    mTag = item.substr(1, item.length - 2);
                    parser = getParser(mTag);
                }
                else {
                    parser = new MsgParse();
                    mTag = item;
                }
                if (parser != null) {
                    //服务器  有可能 返回 {}
                    parser.setMsg(mTag)
                    if (parser is ShowInfoMsgParse) {
                        if (vecShowInfo)
                            (parser as ShowInfoMsgParse).setVecShowInfo(vecShowInfo);
                        else
                            (parser as ShowInfoMsgParse).setVecShowInfo(new Vector.<SShowInfo>());
                    }
                    tags += parser.getHTML();
                }
            }
        }
        return  tags;
    }

    /**
     * 解析成IMsgParse结构体
     * @param chatVO
     * @return
     */
    public static function parse(chatVO:ChatMessageVO):Vector.<IMsgParse> {
        var msg:String = chatVO.strChatMsg;
        var tags:Vector.<IMsgParse> = new Vector.<IMsgParse>();
        var parser:IMsgParse;
        var mTag:String = ""
        if (msg) {
            var msgArray:Array = msg.split(ChatConstants.MSGTAG_REG);
            for each(var item:String in msgArray) {
                if (!item)
                    continue;
                var tmpA:Array = item.match(ChatConstants.MSGTAG_REG);
                if (tmpA && tmpA.length > 0) {
                    mTag = item.substr(1, item.length - 2);
                    parser = getParser(mTag);
                }
                else {
                    if (!isSys(chatVO.channelType) && chatVO.senderID != null) {
                        //TODO 屏蔽字库处理
                        //item = WordsFilter.filterText(item);
                    }
                    parser = new MsgParse()
                    mTag = item
                }

                if (parser != null) {
                    //服务器  有可能 返回 {}
                    parser.setMsg(mTag);
                    if (parser is ShowInfoMsgParse) {
                        (parser as ShowInfoMsgParse).setVecShowInfo(chatVO.vecShowInfo);
                    }
                    tags.push(parser);
                }
            }
        }
        return tags;
    }

    private static function isSys(channelType:uint):Boolean {
        if (channelType == EChannelType.eChannelSys)
            return true;
        return false;
    }

    /**
     * 获取应该使用的解析器
     * @param mTag
     * @return
     */
    private static function getParser(mTag:String):IMsgParse {
        var parser:IMsgParse;
        if (MsgParse.test(mTag)) {
            parser = new MsgParse();
        } else if (IconMsgParse.test(mTag)) {
            parser = new IconMsgParse();
        } else if (ShowInfoMsgParse.test(mTag)) {
            parser = new ShowInfoMsgParse();
        } else if (ColorMsgParse.test(mTag)) {
            parser = new ColorMsgParse();
        }
        return parser;
    }
}
}
