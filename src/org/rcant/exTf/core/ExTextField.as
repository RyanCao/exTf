/**
 * Class Name: ExTextField
 * Description:对TextField的扩展，主要是实现简单的图文混排，而不使用大组件TLF
 * Created by Ryan on 2014/12/23 23:46.
 */
package org.rcant.exTf.core {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TextEvent;
import flash.geom.Rectangle;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextLineMetrics;
import flash.ui.Mouse;
import flash.ui.MouseCursor;

public class ExTextField extends Sprite {
    //-----------------------------------------
    //Var
    //-----------------------------------------
    //全角空格 作为关键字符
    protected static var _placeholder:String = String.fromCharCode(0x3000);

    //纯文本的内容
    protected var _text:TextField;
    //图片或其他显示对象容器
    protected var _expressSp:Sprite;
    //所有特殊的显示对象
    protected var _expressAllArray:Vector.<InlineGraphicItem> = new Vector.<InlineGraphicItem>();
    //单次显示对象列表
    protected var _expressArray:Vector.<InlineGraphicItem> = new Vector.<InlineGraphicItem>();

    private var _visualW:Number;
    private var _visualH:Number;

    private var _textHeights:Vector.<Number> = new Vector.<Number>();

    //点击有链接的文字触发
    private var _onLink:Function;
    //鼠标划过链接触发
    private var _onLinkOver:Function;
    //鼠标划出链接触发
    private var _onLinkOut:Function;
    //更新时触发
    private var _onUpdate:Function;
    //设置位置时触发
    private var _onSetLoc:Function;

    //_text 行数
    private var _lineNumbers:int;
    //_text 字符数
    private var _count:int;
    //_text 高度 用来决定Icon的大小
    private var _heights:Number;
    //
    private var _rect:Rectangle;

    /**
     * 最多保留信息数
     */
    private var _maxLine:int = 40;

    //当前文本的格式化规则
    protected var _textFormat:TextFormat;

    private var _enableMove:Boolean = false;

    private static var defaultTextFormat:TextFormat = new TextFormat("SimSun", 12, 0xFFFFFF, null, null, null, null, null, null, null, null, null, 5);

    private static var defaultLetterSpacing:int = 2;

    public function ExTextField(w:Number = 300, h:Number = 100) {
        super();
        initUI();
        initText();
        visualW = w;
        visualH = h;
    }

    protected function initUI():void {
        _text = new TextField();
        addChild(_text);

        _expressSp = new Sprite();
        addChild(_expressSp);
        _expressSp.mouseEnabled = false;
    }

    protected function initText():void {
        _text.text = "";
        _text.height = 20;
        //禁止自动换行
        _text.wordWrap = false;
        _text.selectable = false;
        //多行显示
        _text.multiline = true;
        _text.mouseWheelEnabled = true;

        _text.restrict = "^" + _placeholder;
        _text.type = TextFieldType.DYNAMIC;
        _text.defaultTextFormat = textFormat;

        _text.antiAliasType = AntiAliasType.ADVANCED;
        _text.sharpness = 100;

        _text.addEventListener(TextEvent.LINK, link);
        _text.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverHandler);
    }

    protected function onMouseOverHandler(event:MouseEvent):void {
        Mouse.cursor = MouseCursor.AUTO;
    }

    public function set enableMove(value:Boolean):void {
        _enableMove = value;
        if (_enableMove) {
            if (!_text.hasEventListener(MouseEvent.MOUSE_MOVE))
                _text.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandler);
        } else {
            if (_text.hasEventListener(MouseEvent.MOUSE_MOVE))
                _text.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandler);
        }
    }

    public function get enableMove():Boolean {
        return _enableMove;
    }

    private function onMouseMoveHandler(event:MouseEvent):void {
        var textMouseX:uint = _text.mouseX < 0 ? 1 : _text.mouseX;
        var textMouseY:uint = _text.mouseY < 0 ? 1 : _text.mouseY;
        var startIndex:uint = _text.getCharIndexAtPoint(textMouseX, textMouseY);
        if (startIndex >= _text.length - 1) {
            linkout();
            return;
        }
        var url:String = _text.getTextFormat(startIndex).url;
        if (url) {
            linkover(url);
        } else {
            linkout();
        }
    }

    private function initFormat():void {
        _textFormat = cloneTextFormat(defaultTextFormat);
        _textFormat.letterSpacing = defaultLetterSpacing;
    }

    /**
     * 克隆tf
     * @param value
     * @return
     */
    protected function cloneTextFormat(value:TextFormat):TextFormat {
        _textFormat = new TextFormat(
                value.font, value.size,
                value.color, value.bold,
                value.italic, value.underline,
                value.url, value.target,
                value.align, value.leftMargin,
                value.rightMargin, value.indent,
                value.leading);
        _textFormat.letterSpacing = value.letterSpacing;
        return _textFormat;
    }

    public function set textFormat(value:TextFormat):void {
        _textFormat = value;
        if (_text) {
            _text.defaultTextFormat = _textFormat;
        }
    }

    public function get textFormat():TextFormat {
        if (!_textFormat) {
            initFormat();
        }
        return _textFormat;
    }

    override public function set filters(value:Array):void {
        if (_text) {
            _text.filters = value;
        }
    }

    override public function get filters():Array {
        return _text ? _text.filters : null;
    }

    private function link(event:TextEvent):void {
        event.stopImmediatePropagation();
        event.stopPropagation();
        if (_onLink != null) {
            var _uriString:String = event.text;
            if (_uriString != null) {
                if (_uriString.length > 6 && _uriString.substr(0, 6) == "event:") {
                    _uriString = _uriString.substring(6);
                }
                _onLink.apply(this, [_uriString]);
            }
        }
    }

    private function linkover(url:String):void {
        if (_onLinkOver != null) {
            _onLinkOver.apply(this, [url]);
        }
    }

    private function linkout():void {
        if (_onLinkOut != null) {
            _onLinkOut.apply(this);
        }
    }


    //-----------------------------------------
    //Methods
    //-----------------------------------------
    /**
     *重绘 图像原件
     */
    private function renderExpress():void {
        if (_expressArray.length == 0) {
            return;
        }
        var xPos:Number;
        var _expressIndex:int = 0;
        var linePos:int = _count;
        var yPos:Number = _heights;
        var lineCount:int = _lineNumbers - 1;
        while (lineCount <= (_text.numLines - 1)) {
            var lineString:String = _text.getLineText(lineCount);
            xPos = 0;
            var lineIndex:int = 0;
            var lastChatIndex:int = 0;
            while (lineIndex < lineString.length) {
                if (lineString.charAt(lineIndex) == _placeholder) {
                    xPos = xPos + getStrBoundaries(linePos + lastChatIndex, linePos + lineIndex);
                    lastChatIndex = lineIndex;
                    var express:InlineGraphicItem = _expressArray[_expressIndex];
                    if (express) {
                        express.x = int(xPos);
                        express.y = int(yPos);
                    }
                    _expressIndex++;
                    if (_expressIndex == _expressArray.length) {
                        return;
                    }
                }
                lineIndex++;
            }
            var lineMetrics:TextLineMetrics = _text.getLineMetrics(lineCount);
            yPos += lineMetrics.height;
            linePos += lineString.length;
            lineCount++;
        }
    }

    /**
     * 获取两个字符间宽度
     * @param sIndex
     * @param eIndex
     * @return
     */
    protected function getStrBoundaries(sIndex:int, eIndex:int):Number {
        var rect:Rectangle;
        var strWidth:Number = 0;
        while (sIndex < eIndex) {
            rect = _text.getCharBoundaries(sIndex);
            if (rect == null) {
                return strWidth;
            }
            strWidth = strWidth + rect.width;
            sIndex++;
        }
        return strWidth;
    }

    /**
     * 通过设置tf来获取一个空位置
     * @param index
     * @param w
     * @param h
     */
    protected function setPlaceFormat(index:int, w:Number = 30, h:Number = 20):void {
        var format:TextFormat = textFormat;
        format.letterSpacing = w - 13;
        try {
            _text.setTextFormat(format, index, index + 1);
        } catch (e:*) {

        }
    }

    /**
     * 设置聊天文本样式
     * @param sIndex
     * @param eIndex
     * @param isChat
     */
    private function setChatFormat(sIndex:int, eIndex:int, isChat:Boolean):void {
        var tf:TextFormat = _text.getTextFormat(sIndex, eIndex);
        //TODO 单独文字要不要处理
//        tf.font = (isChat) ? "Tahoma" : "Arial Black";
//        tf.size = (isChat) ? 11 : 12;
        _text.setTextFormat(tf, sIndex, eIndex);
    }

    /**
     * 添加新文本
     * @param _txtData
     * @param _indentation
     */
    public function addLine(_txtData:TextData, _indentation:Number = 0):void {
        var lastIsChat:Boolean = false;
        var unicode:Number = NaN;
        var isChat:Boolean = false;

        var txtData:TextData = _txtData;
        var indentation:int = _indentation;
        var indexArray:Vector.<int> = txtData.indexArray;
        var signArray:Vector.<InlineGraphicItem> = txtData.signArray;
        _lineNumbers = _text.numLines;
        _count = _text.length;
        _expressArray = new Vector.<InlineGraphicItem>();
        var isBottom:Boolean = false;
        if (scrollRect) {
            _rect = scrollRect;
            if ((totalH < visualH && _rect.y == 0) || _rect.y == (totalH - visualH)) {
                isBottom = true;
            }
        }

        if (_text.numLines < 3) {
            //特殊判断
            _heights = _text.textHeight - 2;
        } else {
            _heights = _text.textHeight + _textFormat.leading - 2;
        }

        //txtData.htmlText = txtData.htmlText.split("\n").join("")
        _text.htmlText = _text.htmlText + txtData.htmlText;

        var lastIndex:int = -1;
        var text:String = _text.text;
        var len:int = text.length;
        var j:int = _count;
        while (j < len) {
            unicode = text.charCodeAt(j);
            isChat = unicode < 0xFF;
            if (lastIndex == -1) {
                lastIndex = j;
                lastIsChat = isChat;
            }
            if (lastIsChat != isChat) {
                setChatFormat(lastIndex, j, lastIsChat);
                lastIndex = -1;
                j--;
            } else {
                if (j == (len - 1) && !(lastIndex == -1)) {
                    setChatFormat(lastIndex, len, lastIsChat);
                }
            }
            j++;
        }

        len = signArray ? signArray.length : 0;
        var i:int = (len - 1);
        while (i >= 0) {
            var express:InlineGraphicItem = signArray[i];
            express.applyElementUpdate(_expressSp);
            if (express.enableLink && express.graphic && !express.graphic.hasEventListener(DynamicEvent.LINK_TEXT)) {
                express.graphic.addEventListener(DynamicEvent.LINK_TEXT, onGraphicHandler);
            }
            _expressArray.splice(0, 0, express);
            _expressAllArray.push(express);
            _text.replaceText(indexArray[i] + _count, indexArray[i] + _count, _placeholder);
            setPlaceFormat(indexArray[i] + _count, express.measuredWidth, express.measuredHeight);
            i--;
        }

        renderText(indentation);
        renderExpress();
        if (_text.numLines > maxLine) {
            //文本行数超出最大行数时调用
            minusLine();
        }
        update();

        if (isBottom && totalH > visualH) {
            setLoc(visualH - totalH);
        }
    }

    private function onGraphicHandler(e:DynamicEvent):void {
        if (_onLink != null) {
            _onLink.apply(this, [e.data]);
        }
    }

    /**
     * 设置滚动位置
     * @param value
     */
    private function setLoc(value:Number):void {
        if (_onSetLoc != null) {
            _onSetLoc.apply(this, [value]);
        }
    }

    /**
     * 重绘文本
     * @param _indentation
     */
    private function renderText(_indentation:Number):void {
        var format:TextFormat = _textFormat;
        format.letterSpacing = _indentation - 5;
        format.underline = false;
        //当前行位置
        var thisLinePos:int = 0;
        //第几行
        var lineIndex:int = 1;
        var indexs:Vector.<int> = new Vector.<int>();
        _text.height = _text.textHeight;
        var linePos:int = _count;
        while (linePos < _text.length) {
            var rect:Rectangle = _text.getCharBoundaries(linePos);
            if (rect == null) {
                thisLinePos = (thisLinePos + 0);
            } else {
                thisLinePos = (thisLinePos + rect.width);
            }
            if (thisLinePos > (_text.width - 5)) {
                indexs.push(linePos);
                //换行
                lineIndex++;
                //换行从_indentation位置开始
                thisLinePos = _indentation;
                linePos--;
            }
            linePos++;
        }
        var i:int = (indexs.length - 1);
        while (i >= 0) {
            _text.replaceText(indexs[i], indexs[i], "\n ");
            _text.setTextFormat(format, (indexs[i] + 1), (indexs[i] + 2));
            i--;
        }
        _text.replaceText(_text.length, _text.length, "\n");
        _text.height = _text.textHeight + format.leading + 5;
        _textHeights.push(lineIndex);
    }

    /**
     * 判断聊天内容是否超出
     * 超出部分截断
     */
    public function minusLine():void {
        var i:int;
        var chatCounts:int = 0;
        var ypos:Number = 0;
        while (_text.numLines > _maxLine) {
            if(_textHeights.length<1)
                break;
            i = 0;
            while (i < _textHeights[0]) {
                chatCounts += _text.getLineLength(i);
                var lineMetrics:TextLineMetrics = _text.getLineMetrics(i);
                ypos += lineMetrics.height;
                i++;
            }
            _text.replaceText(0, chatCounts, "");
            _textHeights.splice(0, 1);
            chatCounts = 0;
        }
        _text.height = ((_text.textHeight + _textFormat.leading) + 5);

        var j:int = _expressAllArray.length - 1;
        while (j >= 0) {
            var express:InlineGraphicItem = _expressAllArray[j];
            if (express.y >= ypos - 5) {
                express.y = express.y - ypos;
            } else {
                //TODO 是否需要移除  查找到具体对象
                if (express.graphic) {
                    if (express.graphic.hasEventListener(DynamicEvent.LINK_TEXT)) {
                        express.graphic.removeEventListener(DynamicEvent.LINK_TEXT, onGraphicHandler);
                    }
                    if (_expressSp.contains(express.graphic)) {
                        _expressSp.removeChild(express.graphic);
                    }
                }
                _expressAllArray.splice(j, 1);
                express.dispose();
            }
            j--;
        }
    }


    /**
     * 获取焦点
     */
    public function getFocus():void {
        stage.focus = _text;
    }

    /**
     * 获取最大函数
     */
    public function get maxLine():int {
        return _maxLine + 20;
    }

    /**
     * 设置文本显示宽度
     * */
    protected function set visualW(value:Number):void {
        _visualW = value;
        _text.width = value;
    }

    /**
     * 获取文本真实高度
     * 与 visualH 值不同
     */
    public function get totalH():Number {
        return _text.height;
    }

    /**
     * 设置文本显示高度
     */
    public function set visualH(value:Number):void {
        _visualH = value;
        update();
    }

    /**
     * 获取文本显示高度
     */
    public function get visualH():Number {
        return _visualH;
    }

    /**
     * 触发更新函数
     */
    private function update():void {
        if (_onUpdate != null) {
            _onUpdate.apply(this);
        }
    }

    /**
     * 跳转到文本最底部
     */
    public function bottom():void {
        if (visualH < totalH) {
            setLoc(visualH - totalH);
        } else {
            setLoc(0);
        }
    }

    /**
     * 清除文本
     */
    public function clearText():void {
        _text.text = "";
        _text.height = 20;

        while (_expressAllArray.length > 0) {
            var item:InlineGraphicItem = _expressAllArray.pop();
            if (item.graphic && item.graphic.hasEventListener(DynamicEvent.LINK_TEXT)) {
                item.graphic.removeEventListener(DynamicEvent.LINK_TEXT, onGraphicHandler);
            }
            item.dispose();
        }

        _expressArray.length = 0;
        _expressAllArray.length = 0;

        while (_expressSp.numChildren >= 0) {
            var displayObj:DisplayObject = _expressSp.getChildAt(0) as DisplayObject;
            if (_expressSp.contains(displayObj)) {
                _expressSp.removeChild(displayObj);
            }
        }
        update();
    }

    /**
     * 清除内存
     */
    public function dispose():void {
        clearText();
        enableMove = false;
        _text.removeEventListener(TextEvent.LINK, link);
        _text.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOverHandler);
    }


    public function set onLink(value:Function):void {
        _onLink = value;
    }

    public function set onLinkOver(value:Function):void {
        _onLinkOver = value;
    }

    public function set onLinkOut(value:Function):void {
        _onLinkOut = value;
    }

    public function set onUpdate(value:Function):void {
        _onUpdate = value;
    }

    public function set onSetLoc(value:Function):void {
        _onSetLoc = value;
    }

    public function get rect():Rectangle {
        return _rect;
    }
}
}
