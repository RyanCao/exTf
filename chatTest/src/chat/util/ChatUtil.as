/**
 * Class name: ChatUtil.as
 * Description:
 * Author: caoqingshan
 * Create: 14-12-30 下午1:33
 */
package chat.util {
import chat.util.parse.msg.IMsgParse;
import chat.vo.ChatMessageVO;

import flash.text.TextFormat;

import lang.LangCommonTxt;

import net.core.vo.EChannelType;

import org.rcant.exTf.core.TextData;
import org.rcant.exTf.util.HtmlUtil;

public class ChatUtil {
    public static const chatFontName:String = "SimSun";
    public static const chatFontSize:uint = 12;
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------
    public static var textFormat:TextFormat = new TextFormat(chatFontName, chatFontSize);

    public function ChatUtil() {
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------

    public static function importSystemTextToFlow(s:String):TextData {
        var td:TextData = new TextData();
        td.htmlText = s;
        return td;
    }

    public static function importChatMsgToFlow(chatVO:ChatMessageVO):TextData {
        var td:TextData = new TextData();
        if (chatVO == null)//如果传入的一个聊天记录为空
        {
            td.appendText("没有返回", "#ff0000");
            return td;
        }
        var channelType:int = chatVO.channelType;	//频道
        if (channelType != EChannelType.eChannelSys && chatVO.senderName != null) {
            var iconString:String = getChannelHTML(channelType);	//图标显示控制类
            if (iconString) {
                td.appendHtmlText(iconString);
            }
            //发送者名字
            if (LangCommonTxt.SYSTEM != chatVO.senderName) {
                //非系统消息 才显示发送者名字
//                if (chatVO.platformVo) {//平台vip图标
                //txvip 增加
//                    var txVipIcon:InlineGraphicItem = new InlineGraphicItem();
//                    txVipIcon.source = QQPtUtil.getDiamandInstance(chatVO.platformVo);
//                    txVipIcon.enableLink = true;
//                    txVipIcon.linkText = "";
//                    td.appendGraphic(txVipIcon);
//                }
//                if (chatVO.byVIPType) {//御剑图标
                //txvip 增加
//                    var vipIcon:InlineGraphicItem = new InlineGraphicItem();
//                    vipIcon.source = VipUtil.getVipLevelIcon(chatVO.byVIPType);
//                    vipIcon.enableLink = true;
//                    vipIcon.linkText = "";
//                    td.appendGraphic(vipIcon);
//                }
                var eventName:String = chatVO.getWhisperEvent(true)//  getWhisperEvent(chatVO,true);
                var titleInfo:Array = null;	//
                var titleName:String = "";
                var splitSymbol:String = "[";
                var rsplitSymbol:String = "]";
                if (titleInfo)
                    splitSymbol = "-";
                if (!chatVO.isLocal) {
                    td.appendText(splitSymbol, ColorUtil.getColorStr(ColorUtil.TEXTCOLOROX[1]));
                    if (titleInfo) {
                        titleName = HtmlUtil.colorOnly(titleInfo[0], ColorUtil.getColorStr(ColorUtil.TEXTCOLOROX[titleInfo[1] - 1]));
                        td.appendHtmlText(HtmlUtil.addUParameter(titleName, eventName));
                    }
                    td.appendHtmlText(HtmlUtil.addUParameter(chatVO.senderName, eventName));
                    td.appendText(rsplitSymbol, ColorUtil.getColorStr(ColorUtil.TEXTCOLOROX[1]));
                }
                else {
                    td.appendText(splitSymbol, ColorUtil.getColorStr(ColorUtil.TEXTCOLOROX[1]));

                    if (titleInfo) {
                        titleName = HtmlUtil.colorOnly(titleInfo[0], ColorUtil.getColorStr(ColorUtil.TEXTCOLOROX[titleInfo[1] - 1]));
                        td.appendHtmlText(HtmlUtil.addUParameter(titleName, eventName));
                    }
                    td.appendHtmlText(HtmlUtil.addUParameter(chatVO.senderName, eventName));
                    td.appendText(rsplitSymbol, ColorUtil.getColorStr(ColorUtil.TEXTCOLOROX[1]));
                }
                td.appendText(":", ColorUtil.getColorStr(chatVO.color));
            }
        }

        //系统
        if (channelType == EChannelType.eChannelSys) {
            var iconString2:String = getChannelHTML(channelType);	//图标显示控制类
            if (iconString2) {
                td.appendHtmlText(iconString2);
            }
        }

        var charMsgArr:Vector.<IMsgParse> = MsgParseUtil.parse(chatVO)
        for (var i:int = 0; i < charMsgArr.length; i++) {
            //如果有文本炫耀信息 加入文本炫耀信息
            var msg:IMsgParse = charMsgArr[i];
            var ele:TextData = msg.getTextData();
            ele.color = ColorUtil.getColorStr(chatVO.color);
            td.appendTextData(ele);
        }
        return td;
    }

    public static function getChannelHTML(channelType:int):String {
        var channelString:String = "";
        var colorString:uint = 0;
        switch (channelType) {
            case EChannelType.eChannelWorld:
                channelString = "[世界]";
                colorString = 0x518f90;
                break;
            case EChannelType.eChannelSys:
                channelString = "[系统]";
                colorString = 0xc23459;
                break;
            case EChannelType.eChannelGuild:
                channelString = "[帮派]";
                colorString = 0x66b3fa;
                break;
            case EChannelType.eChannelTeam:
                channelString = "[组队]";
                colorString = 0x66b3fa;
                break;
            case EChannelType.eChannelAll:
                channelString = "[综合]";
                colorString = 0xaecbce;
                break;
            case EChannelType.eChannelNone:
                channelString = "";
                break;
            default:
                channelString = "";
                break;
        }
        if (channelString.length > 0)
            return HtmlUtil.colorOnly(channelString, ColorUtil.getColorStr(colorString));
        return null;
    }

    public static function get faceXML():XML {
        return    <face>
            <item icon="face/f1.swf" id="01" w="22" h="23"/>
            <item icon="face/f2.swf" id="02" w="21" h="21"/>
            <item icon="face/f3.swf" id="03" w="21" h="22"/>
            <item icon="face/f4.swf" id="04" w="20" h="20"/>
            <item icon="face/f5.swf" id="05" w="21" h="21"/>
            <item icon="face/f6.swf" id="06" w="21" h="20"/>
            <item icon="face/f7.swf" id="07" w="21" h="20"/>
            <item icon="face/f8.swf" id="08" w="21" h="20"/>
            <item icon="face/f9.swf" id="09" w="21" h="21"/>
            <item icon="face/f10.swf" id="10" w="21" h="21"/>
            <item icon="face/f11.swf" id="11" w="22" h="21"/>
            <item icon="face/f12.swf" id="12" w="20" h="20"/>
            <item icon="face/f13.swf" id="13" w="21" h="22"/>
            <item icon="face/f14.swf" id="14" w="20" h="20"/>
            <item icon="face/f15.swf" id="15" w="20" h="20"/>
            <item icon="face/f16.swf" id="16" w="20" h="20"/>
            <item icon="face/f17.swf" id="17" w="20" h="20"/>
            <item icon="face/f18.swf" id="18" w="20" h="20"/>
            <item icon="face/f19.swf" id="19" w="23" h="22"/>
            <item icon="face/f20.swf" id="20" w="20" h="20"/>
            <item icon="face/f21.swf" id="21" w="21" h="21"/>
            <item icon="face/f22.swf" id="22" w="20" h="20"/>
            <item icon="face/f23.swf" id="23" w="21" h="21"/>
            <item icon="face/f24.swf" id="24" w="21" h="21"/>
            <item icon="face/f25.swf" id="25" w="21" h="21"/>
            <item icon="face/f26.swf" id="26" w="21" h="21"/>
            <item icon="face/f27.swf" id="27" w="21" h="20"/>
            <item icon="face/f28.swf" id="28" w="21" h="21"/>
            <item icon="face/f29.swf" id="29" w="21" h="21"/>
            <item icon="face/f30.swf" id="30" w="21" h="20"/>
            <item icon="face/f31.swf" id="31" w="21" h="20"/>
            <item icon="face/f32.swf" id="32" w="20" h="20"/>
            <item icon="face/f33.swf" id="33" w="23" h="22"/>
            <item icon="face/f34.swf" id="34" w="21" h="20"/>
            <item icon="face/f35.swf" id="35" w="21" h="20"/>
        </face>;
    }

}
}
