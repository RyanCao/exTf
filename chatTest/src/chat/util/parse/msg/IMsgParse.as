/**
 * Class name: IMsgParse.as
 * Description:只解析文本结构体
 * Author: caoqingshan
 * Create: 14-7-18 上午10:21
 */
package chat.util.parse.msg {
import org.rcant.exTf.core.TextData;

public interface IMsgParse {
    /**
     * 获取要发送给服务器的文本，内部已封装
     * @param m
     */
    function getMsg():String;

    /**
     * 设置文本 ，内部解封装
     * @param m
     */
    function setMsg(m:String):void;

    /**
     * 出现在其他地方的显示文本
     * @return
     */
    function getHTML():String;

    function getTextData():TextData ;
}
}
