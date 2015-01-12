/**
 * Class name: ChatMessageVO.as
 * Description:
 * Author: caoqingshan
 * Create: 15-1-9 下午4:15
 */
package chat.vo {
import chat.util.ChatConstants;
import chat.util.ChatLinkType;

import com.hurlant.math.BigInteger;

import net.core.vo.SShowInfo;

public class ChatMessageVO {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------
    public var byVIPType:uint;
    public var channelType:uint;	//EChannelType频道类型
    public var senderID:BigInteger;//发送者ID

    public var senderLv:uint;		//发送者等级

    public var senderSex:uint;		//EGender性别
    public var senderCareer:uint; //ECareerType职业
    public var senderName:String;	//发送方姓名
    public var receiverID:BigInteger; //接受者ID

    public var strChatMsg:String;	//聊天内容，关键性东西！！！
    public var eCampType:uint; //阵营信息

    public var isLocal:Boolean = false;	//ERoleCampType
    public var color:uint = 0xffffff;

    public var vecShowInfo:Vector.<SShowInfo>;//聊天炫耀物品


    public function ChatMessageVO() {
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------
    /**
     * 获取聊天名
     * @return
     */
    public function getWhisperEvent(isSelf:Boolean):String {
        return "event:" + ChatLinkType.USER + ChatConstants.LINK_CONTENT_DELI +
                senderName + ChatConstants.LINK_CONTENT_DELI +
                senderID.toString() + ChatConstants.LINK_CONTENT_DELI +
                senderSex + ChatConstants.LINK_CONTENT_DELI +
                senderLv + ChatConstants.LINK_CONTENT_DELI +
                senderCareer + ChatConstants.LINK_CONTENT_DELI +
                byVIPType + ChatConstants.LINK_CONTENT_DELI;
    }
}
}
