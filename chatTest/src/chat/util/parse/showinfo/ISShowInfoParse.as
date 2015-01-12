/**
 * Class name: ISShowInfoParse.as
 * Description:解析SShowInfo 炫耀结构体的
 * Author: caoqingshan
 * Create: 14-7-18 上午10:22
 */
package chat.util.parse.showinfo {
import net.core.vo.SShowInfo;

import org.rcant.exTf.core.InlineGraphicItem;

public interface ISShowInfoParse {
    /**
     * 获取要发送给服务器炫耀结构
     * @param m
     */
    function getShowInfo():SShowInfo;

    /**
     * 设置炫耀结构数据
     * @param m
     */
    function setShowInfo(s:SShowInfo):void;

    /**
     * 出现在其他地方的显示文本
     * @return
     */
    function getHTML():String;

    /**
     * 如果出现在聊天输出口的显示
     * @return
     */
    function getInputItem():InlineGraphicItem;

    /**
     * 如果出现在聊天面板的显示
     * @return
     */
    function getItem():InlineGraphicItem;
}
}
