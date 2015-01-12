/**
 * Class Name: ExTextFieldInput
 * Description:
 * Created by Ryan on 2014/12/25 12:02.
 */
package org.rcant.exTf.core {
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextLineMetrics;
import flash.ui.Keyboard;

public class ExTextFieldInput extends ExTextField {
    private var _onInFocus:Function;
    private var _onSend:Function;
    private var _onRenderChat:Function;
    private var _maskRect:Rectangle;
    /**
     * 当前有多少特殊字符
     */
    private var _expressCount:int = 0;
    /**
     * 最多支持 多少特殊字符
     */
    private var _maxExpressCount:int = 10;

    //TODO 此处不需要的 不依靠此处定位 graphic 而依靠_text.text中的特殊字符来定位
    private var _expressIndexs:Vector.<int> = new Vector.<int>();

    private var _begin:int = 0;
    private var _end:int = 0;
    private var _keyCode:uint;
    //记录原始串内容 用于删除
    private var _lastTextString:String;
    /**
     * 纯文字数量
     */
    private var _charCount:int = 0;
    private var _maxCharCount:int = 60;

    private static var defaultLetterSpacing:int = 0;
    //-----------------------------------------
    //Var
    //-----------------------------------------

    public function ExTextFieldInput(w:Number = 300, h:Number = 100) {
        _maskRect = new Rectangle(0, 0, w, h);
        super(w, h);
    }

    //-----------------------------------------
    //Methods
    //-----------------------------------------
    override protected function initText():void {
        _text.text = "";
        _text.height = 20;
        _text.wordWrap = true;
        _text.multiline = true;
        _text.mouseWheelEnabled = false;
        _text.restrict = "^" + _placeholder;
        _text.type = TextFieldType.INPUT;
        _text.autoSize = TextFieldAutoSize.LEFT;
        _text.defaultTextFormat = textFormat;

        _text.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverHandler);
        _text.addEventListener(Event.CHANGE, textChange);
        _text.addEventListener(FocusEvent.FOCUS_IN, inFocus);
        _text.addEventListener(FocusEvent.FOCUS_OUT, outFocus);
        _text.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
    }

    override protected function set visualW(value:Number):void {
        _text.width = value;
        _maskRect.width = value;
        scrollRect = _maskRect;
    }

    override public function set visualH(value:Number):void {
        _text.height = value;
        _maskRect.height = value;
        scrollRect = _maskRect;
    }

    override public function get visualH():Number {
        return _text.height;
    }

    private function set currentH(value:Number):void {
        _maskRect.y = value;
        scrollRect = _maskRect;
    }

    /**
     * 设置行数,主要用于记录聊天发送记录的
     * @param lines
     */
    private function setLine(lines:int):void {
        var line_h:Number = 0;
        var i:int = 0;
        while (i < lines) {
            var lineMetrics:TextLineMetrics = _text.getLineMetrics(i);
            line_h += lineMetrics.height;
            i++;
        }
        currentH = line_h;
    }

    /**
     * 调用发送函数
     */
    private function send():void {
        if (_onSend != null) {
            _onSend.apply(this);
        }
    }

    /**
     * 插入特殊符号
     */
    public function insertExpress(graphicItem:InlineGraphicItem):void {
        var i:int = 0;
        var begin:int = _begin;
        var end:int = _end;
        var textString:String = _text.text;
        if (begin != end) {
            //前面有选中操作，这里要删除前面有选中的表情
            i = end - 1;
            while (i >= begin) {
                if (textString.charAt(i) == _placeholder) {
                    deleteExpress(getExpressIndex(i));
                }
                i--;
            }
        }
        if (_expressCount == _maxExpressCount) {
            //超出了的表情不处理
            _text.setSelection(end, end);
            stage.focus = _text;
            return;
        }

        _text.replaceText(begin, end, _placeholder);
        graphicItem.applyElementUpdate(_expressSp);
        setPlaceFormat(begin, graphicItem.measuredWidth, graphicItem.measuredHeight);
        _text.height = (_text.textHeight + textFormat.leading + 5);
        _text.setSelection(begin + 1, begin + 1);
        stage.focus = _text;
        _end = _begin++;

        var len:uint = _expressArray.length;
        var index:int = -1;
        var j:int = 0;
        //判断是第几个
        while (j < len) {
            if (_expressIndexs[j] < begin) {
                index = j;
            }
            j++;
        }

        if (index == -1 || index == len - 1) {
            _expressArray.push(graphicItem);
            _expressIndexs.push(begin);
        } else {
            _expressArray.splice(index + 1, 0, graphicItem);
            _expressIndexs.splice(index + 1, 0, begin);
        }
        _expressCount++;
        renderExpress(begin);
        setLine(_text.getLineIndexOfChar(_text.selectionBeginIndex - 1));
        _lastTextString = _text.text;
    }

    /**
     * 删除表情 特殊组件
     * @param index
     */
    private function deleteExpress(index:int):void {
        var item:InlineGraphicItem = _expressArray[index];
        if (item && item.graphic && item.graphic.parent) {
            item.graphic.parent.removeChild(item.graphic);
        }
        item.dispose();
        _expressArray.splice(index, 1);
        _expressIndexs.splice(index, 1);
        _expressCount--;
    }

    /**
     * 更新 特殊标记索引位置
     * @param textIndex
     */
    private function updateExpressIndex(textIndex:int):void {
        var index:int = getExpressIndex(textIndex);
        if (index == -1) {
            return;
        }

        var len:int = _expressIndexs.length;
        var textString:String = _text.text;
        var j:int = textIndex;
        while (j < textString.length) {
            if (textString.charAt(j) == _placeholder) {
                _expressIndexs[index] = j;
                index++;
                if (len == index) {
                    break;
                }
            }
            j++;
        }
    }

    private function getExpressIndex(index:int):int {
        var len:int = _expressIndexs.length;
        var findIndex:int = -1;
        var i:int = 0;
        while (i < len) {
            if (_expressIndexs[i] >= index) {
                findIndex = i;
                break;
            }
            i++;
        }
        return findIndex;
    }

    private function renderExpress(value:int):void {
        var index:int = getExpressIndex(value);
        if (index == -1) {
            return;
        }
        updateExpressIndex(value);

        var xpos:Number = 0;
        var ypos:Number = 0;
        var linePos:Number = 0;
        var line_i:int = 0;
        while (line_i < _text.numLines) {
            var lineString:String = _text.getLineText(line_i);
            if (linePos + lineString.length > value) {
                xpos = 0;
                var i_last:int = 0;
                var i:int = 0;
                while (i < lineString.length) {
                    if (lineString.charAt(i) == _placeholder && (linePos + i) >= value) {
                        xpos += getStrBoundaries(linePos + i_last, linePos + i);
                        i_last = i;
                        var express:InlineGraphicItem = _expressArray[index];
                        if (express) {
                            express.x = int(xpos);
                            express.y = int(ypos);
                        }
                        index++;
                        if (index == _expressArray.length) {
                            return;
                        }
                    }
                    i++;
                }
            }
            var lineMetrics:TextLineMetrics = _text.getLineMetrics(line_i);
            ypos += lineMetrics.height;
            linePos += lineString.length;
            line_i++;
        }
    }

    /**
     * 具体数据返回
     */
    public function get formatTextData():String {
        if (!_expressArray || _expressArray.length == 0)
            return _text.text;
        var formatString:String = _text.text;
        var i:int = 0 , len:uint = _expressArray.length;
        for (; i < len; i++) {
            formatString = formatString.replace(_placeholder, _expressArray[i].msg);
        }
        return formatString;
    }

    /**
     * 简化信息返回 判断
     */
    public function get text():String {
        return _text ? _text.text : "";
    }

    /**
     * 清除文本
     */
    override public function clearText():void {
        _text.text = "";
        _text.defaultTextFormat = textFormat;

        _lastTextString = _text.text;
        _text.height = 20;
        _begin = 0;
        _end = 0;
        _expressCount = 0;

        while (_expressArray.length > 0) {
            var item:InlineGraphicItem = _expressArray.pop();
            if (item && item.graphic && _expressSp.contains(item.graphic)) {
                _expressSp.removeChild(item.graphic)
            }
            item.dispose();
        }
        _expressArray = new Vector.<InlineGraphicItem>();
        _expressIndexs = new Vector.<int>();

    }


    private function keyboardHandler(evt:KeyboardEvent):void {
        _begin = _text.selectionBeginIndex;
        _end = _text.selectionEndIndex;
        //记录按键信息
        _keyCode = evt.keyCode;

        switch (_keyCode) {
            case Keyboard.ENTER:
                send();
                break;
        }
        if (_begin == _end) {
            //是输入操作
            textFormat.letterSpacing = defaultLetterSpacing;
            _text.defaultTextFormat = textFormat;
            switch (_keyCode) {
                case Keyboard.LEFT:
                    setLine(_text.getLineIndexOfChar(_begin - 1));
                    break;
                case Keyboard.RIGHT:
                    if ((_begin + 1) > _text.length) {
                        return;
                    }
                    setLine(_text.getLineIndexOfChar(_begin));
                    break;
                case Keyboard.UP:
                    var upIndex1:int = _begin;
                    if (_begin + 1 > _text.length) {
                        upIndex1--;
                    }
                    if (_text.getLineIndexOfChar(upIndex1) == 0) {
                        setLine(0);
                    } else {
                        setLine((_text.getLineIndexOfChar(upIndex1) - 1));
                    }
                    break;
                case Keyboard.DOWN:
                    var downIndex1:int = _begin;
                    if (_begin + 1 > _text.length) {
                        downIndex1--;
                    }
                    if (_text.getLineIndexOfChar(downIndex1) == (_text.numLines - 1)) {
                        setLine(_text.numLines - 1);
                    } else {
                        setLine(_text.getLineIndexOfChar(downIndex1) + 1);
                    }
                    break;
            }
        } else {
            //是选中操作
            switch (_keyCode) {
                case Keyboard.LEFT:
                    setLine(_text.getLineIndexOfChar(_begin - 1));
                    break;
                case Keyboard.RIGHT:
                    if ((_end + 1) > _text.length) {
                        return;
                    }
                    setLine(_text.getLineIndexOfChar(_end));
                    break;
                case Keyboard.UP:
                    var upIndex2:int = _end;
                    if ((_end + 1) > _text.length) {
                        upIndex2--;
                    }
                    if (_text.getLineIndexOfChar(upIndex2) == 0) {
                        setLine(0);
                    } else {
                        setLine(_text.getLineIndexOfChar(upIndex2) - 1);
                    }
                    break;
                case Keyboard.DOWN:
                    var downIndex2:int = _end;
                    if ((_end + 1) > _text.length) {
                        downIndex2--;
                    }
                    if (_text.getLineIndexOfChar(downIndex2) == (_text.numLines - 1)) {
                        setLine(_text.numLines - 1);
                    } else {
                        setLine(_text.getLineIndexOfChar(downIndex2) + 1);
                    }
                    break;
                default:
                    textFormat.letterSpacing = defaultLetterSpacing;
                    _text.defaultTextFormat = textFormat;
                    break;
            }
        }
    }

    /**
     * 文本改变时候触发
     * @param evt
     */
    private function textChange(evt:Event):void {
        if (_begin == _end) {
            //是输入操作
            switch (_keyCode) {
                case Keyboard.BACKSPACE:
                    //向前删除
                    if (_lastTextString.charAt(_begin - 1) == _placeholder) {
                        var bsIndex:int = getExpressIndex(_begin - 1);
                        if (bsIndex != -1) {
                            deleteExpress(bsIndex);
                        }
                    }
                    if (_begin == 0) {
                        renderExpress(0);
                    } else {
                        renderExpress(_begin - 1);
                    }
                    break;
                case Keyboard.DELETE:
                    //向后删除
                    if (_lastTextString.charAt(_end) == _placeholder) {
                        var deleteIndex:int = getExpressIndex(_end);
                        if (deleteIndex != -1) {
                            deleteExpress(deleteIndex);
                        }
                    }
                    renderExpress(_begin);
                    break;
                default :
                    //输入具体文字
                    pureTxtChange();
                    break;
            }

        } else {
            //是选中操作
            var i:int = (_end - 1);
            while (i >= _begin) {
                var otherIndex:int = getExpressIndex(i);
                if (otherIndex != -1) {
                    deleteExpress(otherIndex);
                }
                i--;
            }
            pureTxtChange();
        }
        _lastTextString = _text.text;
        _charCount = _text.length - _expressCount;
        setLine(_text.getLineIndexOfChar(_text.selectionBeginIndex - 1));
        _keyCode = 0;
    }

    private function pureTxtChange():void {
        var textString:String = _text.text;
        var count:int = (textString.length - 1);
        while (count >= _begin) {
            if (textString.charAt(count) == "\r" || textString.charAt(count) == "\n") {
                _text.replaceText(count, count + 1, "");
            }
            count--;
        }
        if (_text.length - _expressCount > _maxCharCount) {
            _text.replaceText(_end + _maxCharCount - _charCount, _end + _text.length - _expressCount - _charCount, "");
            _text.setSelection(_end + _maxCharCount - _charCount, _end + _maxCharCount - _charCount);
        }
        renderExpress(_begin);
        _lastTextString = _text.text;

    }

    private function outFocus(e:Event):void {
        _begin = _text.selectionBeginIndex;
        _end = _text.selectionEndIndex;
//        if (Capabilities.hasIME) {
//        }
        if (_onRenderChat != null) {
            _onRenderChat.apply(this);
        }
    }

    private function inFocus(e:Event):void {
        if (_onInFocus != null) {
            _onInFocus.apply(this);
        }
    }

    public function isFocus():Boolean {
        if (stage.focus == _text) {
            return true;
        }
        return false;
    }

    public function set onRenderChat(value:Function):void {
        _onRenderChat = value;
    }

    public function set onInFocus(value:Function):void {
        _onInFocus = value;
    }

    public function set onSend(value:Function):void {
        _onSend = value;
    }

    /**
     * 清除内存
     */
    override public function dispose():void {
        clearText();

        _text.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOverHandler);
        _text.removeEventListener(Event.CHANGE, textChange);
        _text.removeEventListener(FocusEvent.FOCUS_IN, inFocus);
        _text.removeEventListener(FocusEvent.FOCUS_OUT, outFocus);
        _text.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
    }
}
}