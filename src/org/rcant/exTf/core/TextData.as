package org.rcant.exTf.core {
import org.rcant.exTf.util.HtmlUtil;

public class TextData {

    private var _htmlText:String = "";
    private var _indexArray:Vector.<int>;
    private var _signArray:Vector.<InlineGraphicItem>;
    private var _placeholder:String = String.fromCharCode(0x3000);
    private var _color:String;

    /**
     * 消除HTML标记
     * @param content
     * @return
     */
    public static function removeHtml(content:String):String {
        var result:String = content.replace(/\<\/?[^\<\>]+\>/gmi, "");
        result = result.replace(/[\r\n ]+/g, "");
        return result;
    }

    public function TextData(hText:String = "", signs:Vector.<InlineGraphicItem> = null):void {
        _htmlText = hText;
        _signArray = signs;
    }

    public function set htmlText(_arg1:String):void {
        _htmlText = _arg1;
    }

    public function get htmlText():String {
        return _htmlText;
    }

    public function set indexArray(value:Vector.<int>):void {
        _indexArray = value;
    }

    public function get indexArray():Vector.<int> {
        if (!_indexArray || (_signArray && _signArray.length != _indexArray.length)) {
            initIndexArray();
        }
        return _indexArray;
    }

    private function initIndexArray():void {
        if (!_signArray || _signArray.length == 0)
            return;
        _indexArray = new Vector.<int>(_signArray.length);
        var text:String = removeHtml(_htmlText);
        var index:int = text.indexOf(_placeholder);
        var count:int = 0;
        while (index > -1) {
            _indexArray[count] = index - count;
            index = text.indexOf(_placeholder, index + 1);
            count++;
        }
        _htmlText = _htmlText.split(_placeholder).join("")
    }

    public function set signArray(value:Vector.<InlineGraphicItem>):void {
        _signArray = value;
    }

    public function get signArray():Vector.<InlineGraphicItem> {
        return _signArray;
    }

    public function set placeholder(value:String):void {
        _placeholder = value;
    }

    public function get placeholder():String {
        return _placeholder;
    }

    /**
     * 新加
     * @param td
     * @param gi
     */
    public function appendGraphic(gi:InlineGraphicItem):void {
        _htmlText += placeholder;
        if (!_signArray) {
            _signArray = new Vector.<InlineGraphicItem>();
        }
        _signArray.push(gi);
    }

    /**
     * 新加
     * @param td
     * @param gi
     */
    public function appendHtmlText(value:String):void {
        _htmlText += value;
    }

    /**
     * 新加
     * @param td
     * @param gi
     */
    public function appendText(value:String, color:String = "#ff0000"):void {
        _htmlText += HtmlUtil.colorOnly(value, color);
    }

    public function clearSign():void {
        _htmlText = _htmlText.split(_placeholder).join("");
        _signArray = new Vector.<InlineGraphicItem>();
        _indexArray = null;
    }

    public function clear():void {
        _htmlText = "";
        clearSign();
    }

    public function dispose():void {
        if (_signArray) {
            for (var i:int = 0, len:uint = _signArray.length; i < len; i++) {
                _signArray[i].dispose();
            }
        }
        clear();
    }

    //TODO
    private function formatToString():String {
        if (!_signArray || _signArray.length == 0)
            return _htmlText;
        var formatString:String = _htmlText;
        var i:int = 0 , len:uint = _signArray.length;
        for (; i < len; i++) {
            formatString = formatString.replace(_placeholder, _signArray[i].msg);
        }
        return formatString;
    }

    public function appendTextData(ele:TextData):void {
        _htmlText += HtmlUtil.colorOnly(ele._htmlText, ele._color);
        if (!_signArray)
            _signArray = new Vector.<InlineGraphicItem>();
        if (ele._signArray) {
            _signArray = _signArray.concat(ele._signArray);
        }
    }

    /**
     *
     * @param value
     */
    public function set color(value:String):void {
        _color = value;
    }
}
}

