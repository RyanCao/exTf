/**
 * Class name: ChatConstants.as
 * Description:
 * Author: caoqingshan
 * Create: 15-1-9 下午4:00
 */
package chat.util {
public class ChatConstants {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------
    /** 标签匹配的正则表达式 */
    public static const MSGTAG_REG:RegExp = /(\{[^\}]*\})/gm;
    /** 标签内容分割符 */
    public static const MSGTAG_CONTENT_SEPARATOR:String = "&";
    /**
     *  形如“{0}得到{1}x{2}”这样的字符串 分隔符
     */
    public static const LINK_CONTENT_DELI:String = ChatConstants.MSGTAG_CONTENT_SEPARATOR;
    public static const CHAT_INPUT_TIP:String = "输入"

}
}
