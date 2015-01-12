/**
 * Class name: ChatView.as
 * Description:
 * Author: caoqingshan
 * Create: 15-1-9 下午4:37
 */
package chat.view {
import assets.xgame.chat.ChatSkinAssets;

import chat.util.ChatConstants;
import chat.util.ChatUtil;
import chat.util.parse.msg.IconMsgParse;
import chat.vo.ChatMessageVO;
import chat.vo.ChatSendParam;

import com.hurlant.math.BigInteger;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextFormat;
import flash.utils.Dictionary;

import mx.utils.StringUtil;

import net.core.vo.EChannelType;
import net.core.vo.SShowInfo;

import org.rcSpark.tools.core.AsyncCallQuene;
import org.rcant.exTf.core.ExTextFieldInput;
import org.rcant.exTf.core.InlineGraphicItem;
import org.rcant.exTf.core.TextData;

public class ChatView extends Sprite {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------
    /**
     * 聊天输入框
     */
    public var chatInput:ExTextFieldInput;
    /**
     * 输入炫耀数据
     */
    public var chatInputShowInfo:Vector.<SShowInfo>;
    /**
     * 表情面板
     */
    private var facePanel:ChatFacePanel;
    /**
     * 聊天输出
     */
    private var textAreaDic:Dictionary = new Dictionary();

    private var lineHeight:int = 50;
    private var lineMax:int = 2;
    private var lineCount:int = 0;

    private var skinBridge:ChatSkinAssets;

    public function ChatView() {
        createChildren();
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------
    protected function createChildren():void {
//        var ChatNewSkinAssets:Class = getDefinitionByName("assets.xgame.chat.ChatSkinAssets") as Class;
        skinBridge = new ChatSkinAssets();	//桥接资源类
        addChild(skinBridge);

        skinBridge.faceBtn.addEventListener(MouseEvent.CLICK, faceBtnClickHandler);
        skinBridge.sendBtn.addEventListener(MouseEvent.CLICK, sendBtnClickHandler);

        chatInput = new ExTextFieldInput(skinBridge.inputer.width, skinBridge.inputer.height);
        chatInput.x = skinBridge.inputer.x;
        chatInput.y = skinBridge.inputer.y;
        this.addChild(chatInput);

        var textFormat:TextFormat = new TextFormat();
        textFormat.font = ChatUtil.chatFontName;
        textFormat.size = ChatUtil.chatFontSize;
        textFormat.color = 0xffffff;
        textFormat.leading = 2;
        textFormat.letterSpacing = 0;
        chatInput.textFormat = textFormat;
        chatInput.onSend = sendChatEnter;

        skinBridge.inputer.visible = false;

        this.addEventListener(MouseEvent.MOUSE_OVER, function (e:MouseEvent):void {
            skinBridge.bg.visible = true;
//            TweenMax.to(skinBridge.bg, 1, {alpha: 1})
        })
        this.addEventListener(MouseEvent.MOUSE_OUT, function (e:MouseEvent):void {
            skinBridge.bg.visible = false;
//            TweenMax.to(skinBridge.bg, 1, {alpha: 0})
        })


        var _channelList:Array = [];
        _channelList.push({label: EChannelType.getDescription(EChannelType.eChannelAll), data: EChannelType.eChannelAll});
        _channelList.push({label: EChannelType.getDescription(EChannelType.eChannelWorld), data: EChannelType.eChannelWorld});
        _channelList.push({label: EChannelType.getDescription(EChannelType.eChannelGuild), data: EChannelType.eChannelGuild});
        _channelList.push({label: EChannelType.getDescription(EChannelType.eChannelTeam), data: EChannelType.eChannelTeam});
        _channelList.push({label: EChannelType.getDescription(EChannelType.eChannelSys), data: EChannelType.eChannelSys});
        setChannelData(_channelList);
    }

    public function setHide(isHidew:Boolean):void {
        for each(var textArea:ChatTextArea  in  textAreaDic) {
            textArea.visible = false
        }
        var selectedItem:Object = skinBridge.channelBar.selectedItem;
        var data:int = selectedItem["data"];
        textAreaDic[data].visible = isHidew;
        skinBridge.bg.visible = isHidew
    }

    public function dispose():void {
        for each (var cta:ChatTextArea in textAreaDic) {
            removeChild(cta);
        }
    }

    public function setChannelData(data:Array):void {
        var i:int, len:uint = data.length;
        for (i = 0; i < len; i++) {
            var textArea:ChatTextArea = new ChatTextArea(300, 175);
            addChild(textArea);
            var index:int = data[i]["data"];
            textAreaDic[index] = textArea;
            textArea.x = 0;
            textArea.y = skinBridge.bg.y;
            textArea.visible = false;
            textArea.onLink = onLinkHandler;
        }
        textAreaDic[EChannelType.eChannelAll].visible = true;
    }

    public function insertElement(element:InlineGraphicItem):void {
        var str:String = StringUtil.trim(chatInput.text);
        if (str.length == 0 || str == ChatConstants.CHAT_INPUT_TIP) {
            chatInput.clearText();
        }
        chatInput.insertExpress(element);
        chatInput.getFocus();
    }

    public function insertShowInfo(s:SShowInfo):int {
        if (!chatInputShowInfo)
            chatInputShowInfo = new Vector.<SShowInfo>();
        var index:int = chatInputShowInfo.indexOf(s);
        if (index < 0)
            chatInputShowInfo.push(s);
        return chatInputShowInfo.indexOf(s);
    }

    public function appendMsg(channel:int, element:TextData):void {
        AsyncCallQuene.instance().asyncCallByTick(appendAsyncMsg, [channel, element])
    }

    private function appendAsyncMsg(channel:int, element:TextData):void {
        var textArea:ChatTextArea = ChatTextArea(textAreaDic[channel]);
        if (textArea) {
            textArea.appendMsg(element);
            //skinBridge.channelBar.showNewMsgTip(channel);
        }
    }

    private function appendShowMsg(element:TextData):void {
        var textArea:ChatTextArea = ChatTextArea(textAreaDic[skinBridge.channelBar.selectedItem["data"]]);
        if (textArea) {
            textArea.appendMsg(element);
        }
    }

    private function sendBtnClickHandler(event:MouseEvent):void {
//        if (updateCd() == false)return;
        sendChat();
    }

    //增加行高
    public function addLineHeight():void {
        var lineHeight:int = this.lineHeight;

        if (lineCount < 0) {
            lineCount = 0;
            setHide(true);
            return;
        }

        if (lineCount > lineMax) {
            lineHeight = -this.lineHeight * lineCount;
            lineCount = 0;
        } else {
            lineCount++;
        }

        for each (var t:ChatTextArea in textAreaDic) {
            t.y -= lineHeight;
            t.height += lineHeight;
        }
        skinBridge.bg.y -= lineHeight;
        skinBridge.bg.height += lineHeight;

        if (lineHeight < 0) {
            lineCount = -1;
            setHide(false);
        }
    }

    //选择心情按钮
    private function faceBtnClickHandler(event:MouseEvent):void {
        if (!facePanel)	//如果没有的话，就new出来一个
        {
            facePanel = new ChatFacePanel();
            facePanel.onSelectHandler = faceSelectedHandler;
            facePanel.initSp();
            facePanel.x = 100;
            facePanel.y = event.target.y - facePanel.getRect(null).height - 90;
        }

        if (this.contains(facePanel))	//再一次点击选择心情按钮时就要移除它
        {
            removeChild(facePanel);
        }
        else {
            addChild(facePanel);
        }
    }

    private function faceSelectedHandler(value:Object):void {
        var iconId:String = value.iconId;
        var str:String = StringUtil.trim(chatInput.text);
        var html:InlineGraphicItem = IconMsgParse.getFaceItem(iconId);
        if (str.length == 0 || str == ChatConstants.CHAT_INPUT_TIP) {
            chatInput.clearText();
        }
        chatInput.insertExpress(html);
        chatInput.getFocus()
        removeChild(facePanel);
    }

    private function onLinkHandler(linkText:String):void {
        trace(linkText);
//        var event:ChatViewEvent = new ChatViewEvent(ChatViewEvent.LINK, linkText);
//        dispatchEvent(event);
    }

    private function sendChatEnter():void {
//        if (updateCd() == false)return;
        if (skinBridge.sendBtn.mouseEnabled == false) return;
        sendChat();
    }

    /**发送聊天信息*/
    private function sendChat():void {
//        var channel:int = skinBridge.chanelComboBox.selectedItem["data"];
        var channel:int = EChannelType.eChannelAll;
        sendChannelChat(channel)
    }

    private function sendChannelChat(channel:int):void {
        var param:ChatSendParam = new ChatSendParam();
        param.channel = channel;
        param.content = chatInput.formatTextData;
        param.vShowInfos = chatInputShowInfo;

        if (StringUtil.trim(param.content) == "") {
            return;
        }

        var messageVO:ChatMessageVO = createMessageVO(param);

        var td:TextData = ChatUtil.importChatMsgToFlow(messageVO);
        appendMsg(messageVO.channelType, td);
        // TODO
        //dispatchEvent(new ChatViewEvent(ChatViewEvent.CHAT_SEND, param));
        chatInput.clearText();
        chatInputShowInfo = null;
    }

    private function createMessageVO(param:ChatSendParam):ChatMessageVO {
        var chatMessageVo:ChatMessageVO = new ChatMessageVO();
        chatMessageVo.channelType = param.channel;
        chatMessageVo.color = 0xfefefe;
        chatMessageVo.vecShowInfo = param.vShowInfos;
        chatMessageVo.strChatMsg = param.content;
        chatMessageVo.receiverID = new BigInteger(1);
        chatMessageVo.senderID = new BigInteger(1);
        chatMessageVo.senderName = "测试自己";
        return chatMessageVo;
    }

    public function getFocus():void {
        if (chatInput) {
            chatInput.getFocus();
        }
    }
}
}
