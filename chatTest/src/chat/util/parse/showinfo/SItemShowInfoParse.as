/**
 * Class name: SItemShowInfoParse.as
 * Description:
 * Author: caoqingshan
 * Create: 14-7-18 下午3:18
 */
package chat.util.parse.showinfo {
import chat.util.ChatConstants;
import chat.util.ChatLinkType;
import chat.util.ColorUtil;

import com.hurlant.util.Hex;

import flash.text.TextField;
import flash.utils.ByteArray;
import flash.utils.Endian;

import net.core.vo.ESShowInfoType;
import net.core.vo.EType_SItem;
import net.core.vo.SItem;
import net.core.vo.SShowInfo;

import org.rcant.exTf.core.InlineGraphicItem;
import org.rcant.exTf.util.HtmlUtil;

public class SItemShowInfoParse implements ISShowInfoParse {
    /**
     * 装备信息
     */
    private var _vo:SItem;

    private var _s:SShowInfo;
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------
    public static function test(ba:ByteArray):Boolean {
        ba.position = 0;
        var firstByte:uint = ba.readUnsignedByte();
        ba.position = 0;
        return firstByte == ESShowInfoType.eFlauntGood;
    }

    public function SItemShowInfoParse() {
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------

    public function getShowInfo():SShowInfo {
        var s:SShowInfo = new SShowInfo();
        s.qwInstID = _vo.sItemInfo.qwInstID;
        s.strShowInfo = new ByteArray();
        s.strShowInfo.endian = Endian.LITTLE_ENDIAN;
        s.strShowInfo.writeByte(ESShowInfoType.eFlauntGood);
        vo.superToByteArray(s.strShowInfo);
        return s;
    }

    public function setShowInfo(s:SShowInfo):void {
        _s = s;
        s.strShowInfo.position = 0;
        s.strShowInfo.readByte();
        vo = SItem.superFromByteArray(s.strShowInfo);
        s.strShowInfo.position = 0;
    }

    private function getNameString(vo:SItem):String {
        return vo.sItemInfo.wItemID.toString();
    }

    private function getLinkType(vo:SItem):uint {
        var linkType:uint = ChatLinkType.FLAUNT_GOOD;
        switch (vo.getClassType()) {
            case EType_SItem.eType_SItem:
                linkType = ChatLinkType.FLAUNT_GOOD;
                break;
            case EType_SItem.eType_SStack:
                linkType = ChatLinkType.FLAUNT_GOOD;
                break;
            case EType_SItem.eType_SEquip:
                linkType = ChatLinkType.FLAUNT_EQ;
                break;
            case EType_SItem.eType_SCitta:
                linkType = ChatLinkType.FLAUNT_CITTA;
                break;
            case EType_SItem.eType_STrump:
                linkType = ChatLinkType.FLAUNT_TRUMP;
                break;
            case EType_SItem.eType_SFashion:
                linkType = ChatLinkType.FLAUNT_FASHION;
                break;
            case EType_SItem.eType_SZodTrump:
                linkType = ChatLinkType.FLAUNT_ZODTRUMP;
                break;
        }
        return linkType;
    }


    public function getHTML():String {
        var nameString:String = getNameString(vo);
        return  HtmlUtil.colorOnly("[" + nameString + "]", ColorUtil.TEXTCOLOR[1]);
    }

    public function get vo():SItem {
        return _vo;
    }

    public function set vo(value:SItem):void {
        _vo = value;
    }

    public function getInputItem():InlineGraphicItem {
        var nBa:ByteArray = new ByteArray();
        nBa.endian = Endian.LITTLE_ENDIAN;
        vo.toByteArray(nBa);

        var nameString:String = getNameString(vo);

        var uiText:TextField = new TextField();
        uiText.htmlText = HtmlUtil.colorOnly("[" + nameString + "]", ColorUtil.TEXTCOLOR[1]);
        uiText.height = uiText.textHeight + 4;
        uiText.width = uiText.textWidth + 4;

        var img:InlineGraphicItem = new InlineGraphicItem();
        img.source = uiText;
        return img;
    }

    public function getItem():InlineGraphicItem {
        var flauntLink:InlineGraphicItem = new InlineGraphicItem();

        var nBa:ByteArray = new ByteArray();
        nBa.endian = Endian.LITTLE_ENDIAN;
        vo.toByteArray(nBa);

        var linkType:uint = getLinkType(vo);
        var nameString:String = getNameString(vo);

        var para:String = [linkType, Hex.fromArray(nBa)].join(ChatConstants.LINK_CONTENT_DELI);
        var mainTxt:String = HtmlUtil.colorOnly("[" + HtmlUtil.u(nameString) + "]", ColorUtil.TEXTCOLOR[1]);
        flauntLink.source = HtmlUtil.addEventParameter(mainTxt, para);
        flauntLink.type = 1;
        flauntLink.msg = "";
        return flauntLink;
    }
}
}
