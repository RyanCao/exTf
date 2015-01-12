/**
 * Class name: ChatSendParam.as
 * Description:
 * Author: caoqingshan
 * Create: 15-1-9 下午7:13
 */
package chat.vo {
import net.core.vo.SShowInfo;

public class ChatSendParam {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------
    public var channel:int;
    public var content:String;
    /**
     * 炫耀数据
     */
    public var vShowInfos : Vector.<SShowInfo>;
    public var time:uint;
    //TODO 私聊使用的
    //public var target:ChatTargetVO;
    //发送消息的时间
    public function ChatSendParam() {
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------

}
}
