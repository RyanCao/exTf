/**
 * Class Name: InlineGraphicItem
 * Description:
 * Created by Ryan on 2014/12/25 21:43.
 */
package org.rcant.exTf.core {
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.system.Capabilities;
import flash.utils.Dictionary;

public class InlineGraphicItem {
    //准备
    public static const PENDING:uint = 0;
    //加载中
    public static const LOADING:uint = 1;
    //完成
    public static const READY:uint = 2;
    //出错
    public static const ERROR:uint = 3;

    private static var isMac:Boolean = (Capabilities.os.search("Mac OS") > -1);
    /**
     * 可以是显示对象，也可以是URL，URL加载上来的只能是bitmap与movieclip
     */
    private var _source:Object;

    /**
     * 真正的显示对象
     */
    private var _graphic:DisplayObject;

    /**
     * 设置msg,携带数据者
     */
    public var msg:String = "";
    /**
     * 点击以后外发的字串
     */
    public var linkText:String = "";
    /**
     * 是否可以被点击
     */
    public var enableLink:Boolean = false;

    private var status:uint = PENDING;
    /**
     * 已获得确认的长宽
     */
    protected var okToUpdateHeightAndWidth:Boolean = false;

    protected var _measuredWidth:Number;
    protected var _measuredHeight:Number;

    private var _x:Number;
    private var _y:Number;

    protected var _id:Number = 0;
    private static var __indexID:int = 0;
    public static var __dic:Dictionary = new Dictionary(true);

    /**
     * 类型为0的时候  表现为图像 <br>
     * 类型为1的时候  表现为文字
     */
    public var type:int = 0;
    //-----------------------------------------
    //Var
    //-----------------------------------------
    public function InlineGraphicItem() {
        _id = __indexID++;
        __dic[_id] = this;

    }

    //-----------------------------------------
    //Methods
    //-----------------------------------------
    /**
     * 更改状态时候要做什么
     * @param _status
     */
    protected function changeGraphicStatus(_status:uint):void {
        status = _status;
    }

    /**
     * 重载此方法来解决加载问题
     * @param parent
     * @param pictURLReq
     * @return
     */
    protected function handleUrlSorce(parent:DisplayObjectContainer, pictURLReq:URLRequest):DisplayObject {
        var sp:Shape = new Shape();
        sp.graphics.beginFill(0xff2200);
        sp.graphics.drawRect(0, 0, 20, 20);
        sp.graphics.endFill();
        changeGraphicStatus(READY);
        return sp;
        /**
         * by cqs 寻找可替代加载类 暂时先注释
         */
//        _promise = new LoaderDeferred();
//        _promise.load(URLCode.encode(pictURLReq), ResFormat.LOADER, LoadLevel.ICON, false).completes(function (e:*) {
//            setGraphic(_promise.data);
//            okToUpdateHeightAndWidth = true;
//            changeGraphicStatus(READY);
//            if (graphic) {
//                _measuredWidth = graphic.width;
//                _measuredHeight = graphic.height;
//                (graphic as InteractiveObject).mouseEnabled = false;
//                (graphic as Sprite).mouseChildren = false;
//                (graphic as Sprite).buttonMode = false;
//                parent.addChild(graphic);
//            }
//        });
    }

    /**
     * 在TextField刷新的时候，执行
     * @param parent
     */
    public function applyElementUpdate(parent:DisplayObjectContainer, __x:Number = 0, __y:Number = 0):void {
        if (status == PENDING) {
            var source:Object = _source;
            var elem:DisplayObject;
            if (source is String || source is URLRequest) {
                if (source is String) {
                    var myPattern:RegExp = /\\/g;
                    var src:String = source as String;
                    src = src.replace(myPattern, "/");
                    var pictURLReq:URLRequest;
                    if (isMac) {
                        pictURLReq = new URLRequest(encodeURI(src));
                    }
                    else {
                        pictURLReq = new URLRequest(src);
                    }
                }
                changeGraphicStatus(LOADING);
                elem = handleUrlSorce(parent, pictURLReq);
            }
            else if (_source is Class)	// value is class --> it is an Embed
            {
                var cls:Class = source as Class;
                elem = DisplayObject(new cls());
                changeGraphicStatus(READY);
            }
            else if (_source is DisplayObject) {
                elem = DisplayObject(source);
                changeGraphicStatus(READY);
            }
            else {
                elem = new Shape();
                changeGraphicStatus(READY);
            }

            if (status != LOADING) {
                okToUpdateHeightAndWidth = true;
                _measuredWidth = elem ? elem.width : 0;
                _measuredHeight = elem ? elem.height : 0;
                setGraphic(elem);
            }
            if (graphic) {
                parent.addChild(graphic);
                if (enableLink) {
                    if (graphic is InteractiveObject) {
                        (graphic as InteractiveObject).mouseEnabled = true;
                    }
                    if (graphic is Sprite) {
                        (graphic as Sprite).mouseChildren = false;
                        (graphic as Sprite).buttonMode = true;
                    }
                    if (!graphic.hasEventListener(MouseEvent.CLICK))
                        graphic.addEventListener(MouseEvent.CLICK, onGraphicLinkHandler);
                } else {
                    if (graphic is InteractiveObject) {
                        (graphic as InteractiveObject).mouseEnabled = false;
                    }
                    if (graphic is Sprite) {
                        (graphic as Sprite).mouseChildren = false;
                        (graphic as Sprite).buttonMode = false;
                    }
                    if (graphic.hasEventListener(MouseEvent.CLICK))
                        graphic.removeEventListener(MouseEvent.CLICK, onGraphicLinkHandler);
                }
                x = __x;
                y = __y;
            }
        }
    }

    private function onGraphicLinkHandler(event:MouseEvent):void {
        graphic.dispatchEvent(new DynamicEvent(DynamicEvent.LINK_TEXT, linkText));
    }

    private function loadCompleteHandler(e:Event):void {
        removeDefaultLoadHandlers(graphic as Loader);
        okToUpdateHeightAndWidth = true;

        var g:DisplayObject = graphic;
        _measuredWidth = g.width;
        _measuredHeight = g.height;

        if (e is IOErrorEvent)
            changeGraphicStatus(ERROR);
        else
            changeGraphicStatus(READY);
    }

    private function addDefaultLoadHandlers(loader:Loader):void {
        var loaderInfo:LoaderInfo = loader.contentLoaderInfo;
        loaderInfo.addEventListener(Event.COMPLETE, loadCompleteHandler, false, 0, true);
        loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadCompleteHandler, false, 0, true);
    }

    private function removeDefaultLoadHandlers(loader:Loader):void {
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadCompleteHandler);
        loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadCompleteHandler);
    }

    private function stop():void {
        if (graphic.hasEventListener(MouseEvent.CLICK))
            graphic.removeEventListener(MouseEvent.CLICK, onGraphicLinkHandler);
        recursiveShutDownGraphic(graphic);
        setGraphic(null);

    }

    // searches through the graphic and stops any playing grpahics
    private static function recursiveShutDownGraphic(graphic:DisplayObject):void {
        if (graphic is Loader)
            Loader(graphic).unloadAndStop();
        else if (graphic) {
            var container:DisplayObjectContainer = graphic as DisplayObjectContainer;
            if (container) {
                for (var idx:int = 0; idx < container.numChildren; idx++) {
                    recursiveShutDownGraphic(container.getChildAt(idx));
                }
            }
            if (graphic is MovieClip)
                MovieClip(graphic).stop();
        }
    }

    public function dispose():void {
        stop();
        if (source is DisplayObject) {
            source = null;
        }
        delete __dic[_id];
    }

    public function get graphic():DisplayObject {
        return _graphic;
    }

    public function setGraphic(value:DisplayObject):void {
        _graphic = value;
    }

    public function get source():Object {
        return _source;
    }

    public function set source(value:Object):void {
        _source = value;
    }

    public function get measuredWidth():Number {
        return _measuredWidth;
    }

    public function set measuredWidth(value:Number):void {
        _measuredWidth = value;
    }

    public function get measuredHeight():Number {
        return _measuredHeight;
    }

    public function set measuredHeight(value:Number):void {
        _measuredHeight = value;
    }

    public function cloneSource():InlineGraphicItem {
        var ilg:InlineGraphicItem = new InlineGraphicItem();
        ilg.source = this.source;
        ilg.measuredWidth = this.measuredWidth;
        ilg.measuredHeight = this.measuredHeight;
        ilg.msg = this.msg;
        ilg.linkText = this.linkText;
        ilg.enableLink = this.enableLink;
        return ilg;
    }

    public static function getSimpleGraphic(color:uint = 0x00ff00):InlineGraphicItem {
        var sp1:Sprite = new Sprite();
        var sp:Shape = new Shape();
        sp.graphics.beginFill(color);
        sp.graphics.drawRect(0, 0, 20, 20);
        sp.graphics.endFill();
        sp1.addChild(sp);
        var ing:InlineGraphicItem = new InlineGraphicItem();
        ing.source = sp1;
        return ing;
    }

    public function set x(value:Number):void {
        _x = value;
        if(_graphic){
            setPromiseX();
        }
    }

    protected function setPromiseX(e:* = null):void {
        _graphic.x = int(_x);
    }


    public function set y(value:Number):void {
        _y = value;
        if(_graphic){
            setPromiseY();
        }

    }

    protected function setPromiseY(e:* = null):void {
        _graphic.y = int(_y);
    }

    public function get y():Number {
        return _y;
    }
}
}
