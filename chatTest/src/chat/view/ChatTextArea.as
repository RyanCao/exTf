/**
 * Class Name: ChatTextArea
 * Description:带滚动条的
 * Created by Ryan on 2014/12/25 14:56.
 */
package chat.view {
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import flash.text.TextFormat;

import org.rcant.exTf.core.ExTextField;
import org.rcant.exTf.core.TextData;

public class ChatTextArea extends Sprite {
    private var _scrollBar:RcScrollBar;
    private var textField:ExTextField;

    private var _maskRect:Rectangle;
    /**
     * 点击触发链接函数
     */
    private var _onLink:Function;

    //-----------------------------------------
    //Var
    //-----------------------------------------

    public function ChatTextArea(w:Number = 300, h:Number = 400) {
        super();
        initUI(w, h);
    }


    override public function set height(value:Number):void {
        super.height = value;
        if (_maskRect)
            _maskRect.height = value;
        if (_scrollBar)
            _scrollBar.height = value;
        if (textField) {
            textField.visualH = value;
            textField.scrollRect = _maskRect;
            textField.bottom();
        }
    }

    private function initUI(w:Number, h:Number):void {
        textField = new ExTextField(w - 16, h);
        addChild(textField);
        _maskRect = new Rectangle(0, 0, w - 16, h);
        textField.scrollRect = _maskRect;

        var textFormat:TextFormat = new TextFormat();
        textFormat.font = "SimSun";
        textFormat.size = 12;
        textFormat.color = 0xffffff;

        textFormat.leading = 3;
        textFormat.letterSpacing = 1;

        textField.textFormat = textFormat;

        //TODO
        //textField.enableMove = true;

        textField.onLink = onLinkHandler;
        textField.onLinkOver = onLinkOverHandler;
        textField.onLinkOut = onLinkOutHandler;
        textField.onSetLoc = onSetLocHandler;
        textField.onUpdate = onUpdateHandler;
        textField.x = 16;

        textField.filters = [new GlowFilter(0x000000, 1, 2, 2, 8)];

        _scrollBar = new RcScrollBar(this);

        _scrollBar.onScrollHandler = scrollHandler;
        _scrollBar.container.x = 0;
        _scrollBar.container.y = 0;

        _scrollBar.height = h;

        _scrollBar.maxScrollPosition = 1;
        _scrollBar.minScrollPosition = 1;
        _scrollBar.lineScrollSize = h;

    }

    private function scrollHandler(...args):void {
        _maskRect.y = args[2];
        textField.scrollRect = _maskRect;
    }

    private function onUpdateHandler():void {
        _scrollBar.maxScrollPosition = textField.totalH - textField.visualH;
    }

    private function onSetLocHandler(value:Number):void {
        _scrollBar.scrollPosition = -value;
        _maskRect.y = -value;
        textField.scrollRect = _maskRect;
    }


    //-----------------------------------------
    //Methods
    //-----------------------------------------
    private function onLinkHandler(key:String):void {
        if (_onLink != null) {
            _onLink.apply(this, [key]);
        }
    }

    //鼠标经过链接函数
    private function onLinkOverHandler(key:String):void {
    }

    //鼠标移出链接函数
    private function onLinkOutHandler():void {
    }

    public function clear():void {
        if (textField) {
            textField.clearText();
            textField.bottom();
        }
    }

    public function appendMsg(data:TextData):void {
        textField.addLine(data, 36);
    }

    public function dispose():void {
        textField.dispose();
        _scrollBar.dispose();
    }

    public function set onLink(onLink:Function):void {
        _onLink = onLink;
    }
}
}
