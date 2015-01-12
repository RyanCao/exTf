/**
 * Class name: RcScrollBar.as
 * Description:
 * Author: caoqingshan
 * Create: 15-1-8 下午10:36
 */
package chat.view {
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.MouseEvent;

public class RcScrollBar {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------

    /**
     * ScrollBar的父容器
     */
    protected var rootContainer:DisplayObjectContainer;

    /**
     * ScrollBar的容器
     */
    public var container:DisplayObjectContainer;
    /**
     * 向上箭头
     */
    protected var upArrow:Sprite;

    /**
     * 向下箭头
     */
    protected var downArrow:Sprite;
    /**
     * 按钮
     */
    protected var thumb:Sprite;
    /**
     * 背景
     */
    protected var track:Sprite;

    /**
     * 当前坐标
     */
    private var _scrollPosition:Number;
    /**
     * ScrollBar 最大值
     */
    private var _maxScrollPosition:Number;
    /**
     * ScrollBar 最小值
     */
    private var _minScrollPosition:Number;
    /**
     * 点击Scroll 上下按钮 单次移动的距离
     */
    private var _lineScrollSize:Number = 10;

    private var inDrag:Boolean = false;

    private var thumbScrollOffset:Number;
    /**
     * 滚动条方向
     */
    private var _direction:String = "vertical";
    /**
     * 按钮大小
     */
    private var ARROW_SIZE:uint = 16;

    /**
     *滚条厚度
     */
    private var TRUMB_THICKNESS:uint = 12;
    /**
     * 滚动条厚度
     */
    private var SCROLL_THICKNESS:uint = 16;
    /**
     * 宽度
     */
    private var _w:Number;
    /**
     * 高度
     */
    private var _h:Number;
    /**
     * 回调函数
     */
    private var _onScrollHandler:Function;

    public function RcScrollBar(root:DisplayObjectContainer) {
        rootContainer = root;
        configUI();
        if (_direction == "vertical") {
            _h = rootContainer.height;
        } else {
            _w = rootContainer.width;
        }
        drawScroll()
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------
    public function get scrollPosition():Number {
        return _scrollPosition;
    }

    /**
     *  @private
     */
    public function set scrollPosition(value:Number):void {
        _scrollPosition = value;
        if (isScrolling)
            return;
        if (!thumb)
            return;
        updateThumb();
    }

    protected function configUI():void {
        container = new Sprite();

        track = new Sprite();
        track.graphics.beginFill(0x555555, 1);
        track.graphics.drawRect(0, 0, 10, 10);
        track.graphics.endFill();
        container.addChild(track);

        thumb = new Sprite();
        thumb.graphics.beginFill(0xfe3400, 1);
        thumb.graphics.drawRect(0, 0, 10, 10);
        thumb.graphics.endFill();
        container.addChild(thumb);

        downArrow = new Sprite();
        downArrow.graphics.beginFill(0x3400fe, 1);
        downArrow.graphics.drawRect(0, 0, 10, 10);
        downArrow.graphics.endFill();
        container.addChild(downArrow);

        upArrow = new Sprite();
        upArrow.graphics.beginFill(0x3400fe, 1);
        upArrow.graphics.drawRect(0, 0, 10, 10);
        upArrow.graphics.endFill();
        container.addChild(upArrow);

        /**
         * 触发点击事件
         */
        upArrow.addEventListener(MouseEvent.CLICK, scrollPressHandler, false, 0, true);
        downArrow.addEventListener(MouseEvent.CLICK, scrollPressHandler, false, 0, true);

        //TODO 暂时禁止
        // track.addEventListener(MouseEvent.CLICK, scrollPressHandler, false, 0, true);
        /**
         * 触发拖拽事件
         */
        thumb.addEventListener(MouseEvent.MOUSE_DOWN, thumbPressHandler, false, 0, true);

        rootContainer.addChild(container);

    }

    private function drawScroll():void {
        if (_direction == "vertical") {
            //竖排滚动条
            upArrow.width = SCROLL_THICKNESS;
            upArrow.height = ARROW_SIZE;


            track.width = SCROLL_THICKNESS;
            track.height = _h - ARROW_SIZE * 2;
            track.y = ARROW_SIZE;

            downArrow.width = SCROLL_THICKNESS;
            downArrow.height = ARROW_SIZE;
            downArrow.y = _h - ARROW_SIZE;

            thumb.width = TRUMB_THICKNESS;
            thumb.x = Math.round((SCROLL_THICKNESS - TRUMB_THICKNESS) / 2);
            if (thumb.y < ARROW_SIZE)
                thumb.y = ARROW_SIZE;
        } else {
            //横排滚动条
            upArrow.height = SCROLL_THICKNESS;
            upArrow.width = ARROW_SIZE;

            track.x = ARROW_SIZE;
            track.width = _w - ARROW_SIZE * 2;
            track.height = SCROLL_THICKNESS;

            downArrow.width = ARROW_SIZE;
            downArrow.height = SCROLL_THICKNESS;
            downArrow.x = _w - ARROW_SIZE;

            thumb.height = TRUMB_THICKNESS;
            thumb.y = Math.round((SCROLL_THICKNESS - TRUMB_THICKNESS) / 2);
            if (thumb.x < ARROW_SIZE)
                thumb.x = ARROW_SIZE;
        }
    }

    public function set height(value:Number):void {
        if (_h == value)
            return;
        _h = value;
        drawScroll();
    }

    public function get height():Number {
        return _h;
    }

    public function set width(value:Number):void {
        if (_w == value)
            return;
        _w = value;
        drawScroll();
    }

    public function get width():Number {
        return _w;
    }

    protected function scrollPressHandler(event:MouseEvent):void {
        event.stopImmediatePropagation();
        if (event.currentTarget == upArrow) {
            setScrollPosition(_scrollPosition - _lineScrollSize);
        }
        else if (event.currentTarget == downArrow) {
            setScrollPosition(_scrollPosition + _lineScrollSize);
        }
        else {
            var mousePosition:Number = (track.mouseY) / track.height * (_maxScrollPosition - _minScrollPosition) + _minScrollPosition;
            var pgScroll:Number = (_lineScrollSize == 0) ? 1 : _lineScrollSize;
            if (_scrollPosition < mousePosition) {
                setScrollPosition(Math.min(mousePosition, _scrollPosition + pgScroll));
            }
            else if (_scrollPosition > mousePosition) {
                setScrollPosition(Math.max(mousePosition, _scrollPosition - pgScroll));
            }
        }
    }

    protected function thumbPressHandler(event:MouseEvent):void {
        inDrag = true;

        thumbScrollOffset = container.mouseY - thumb.y;

        container.mouseChildren = false;

        if (container) {
            container.stage.addEventListener(MouseEvent.MOUSE_MOVE, handleThumbDrag, false, 0, true);
            container.stage.addEventListener(MouseEvent.MOUSE_UP, thumbReleaseHandler, false, 0, true);
        }
    }

    protected function handleThumbDrag(event:MouseEvent):void {
        var pos:Number = Math.max(0, Math.min(track.height - thumb.height, container.mouseY - track.y - thumbScrollOffset));
        setScrollPosition(pos / (track.height - thumb.height) * (_maxScrollPosition - _minScrollPosition) + _minScrollPosition);
    }

    protected function thumbReleaseHandler(event:MouseEvent):void {
        inDrag = false;

        container.mouseChildren = true;

        if (container) {
            container.stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleThumbDrag);
            container.stage.removeEventListener(MouseEvent.MOUSE_UP, thumbReleaseHandler);
        }

    }

    private function setScrollPosition(newScrollPosition:Number, fireEvent:Boolean = true):void {
        var oldPosition:Number = scrollPosition;
        _scrollPosition = Math.max(_minScrollPosition, Math.min(_maxScrollPosition, newScrollPosition));
        if (oldPosition == _scrollPosition) {
            return;
        }
        if (fireEvent) {
            onScrollupdate(scrollPosition - oldPosition, scrollPosition)
        }
        updateThumb();
    }

    /**
     * 更新消息到外部
     * @param addPostion
     * @param postion
     */
    private function onScrollupdate(addPostion:Number, postion:Number):void {
        if (_onScrollHandler!=null) {
            _onScrollHandler.apply(this, [direction, addPostion, postion]);
        }
    }

    protected function updateThumb():void {
        if (_maxScrollPosition <= _minScrollPosition) {
            thumb.visible = false;
        } else {
            thumb.visible = true;
        }

        if (_direction == "vertical") {
            //改变y值
            thumb.y = track.y + (track.height - thumb.height) * ((_scrollPosition - _minScrollPosition) / (_maxScrollPosition - _minScrollPosition));
        } else {
            //改变x值
            thumb.x = track.y + (track.width - thumb.width) * ((_scrollPosition - _minScrollPosition) / (_maxScrollPosition - _minScrollPosition));
        }
    }

    public function dispose():void {
        upArrow.removeEventListener(MouseEvent.CLICK, scrollPressHandler, false);
        downArrow.removeEventListener(MouseEvent.CLICK, scrollPressHandler, false);
        //track.removeEventListener(MouseEvent.CLICK, scrollPressHandler, false);

        thumb.removeEventListener(MouseEvent.MOUSE_DOWN, thumbPressHandler, false);
    }

    private function drawThump():void {
        if (_maxScrollPosition < _minScrollPosition) {
            //如果最大值小与最小值返回
            return;
        }
        if (!thumb) {
            //组件未绘制 返回
            return;
        }
        if (_direction == "vertical") {
            thumb.height = Math.round(_lineScrollSize / (_lineScrollSize + _maxScrollPosition - _minScrollPosition) * track.height);
        } else {
            thumb.width = Math.round(_lineScrollSize / (_lineScrollSize + _maxScrollPosition - _minScrollPosition) * track.width);
        }

    }

    public function get maxScrollPosition():Number {
        return _maxScrollPosition;
    }

    public function set maxScrollPosition(value:Number):void {
        if (value < 1)
            value = 1;
        if (value == _maxScrollPosition)
            return;
        _maxScrollPosition = value;
        //重绘 由最大值，最小值，步调 来确定滚动条的大小
        drawThump();
        updateThumb();
    }

    public function get minScrollPosition():Number {
        return _minScrollPosition;
    }

    public function set minScrollPosition(value:Number):void {
        if (value < 1)
            value = 1;
        if (value == _minScrollPosition)
            return;
        _minScrollPosition = value;
        //ScrollPosition最小值
        drawThump();
        updateThumb();
    }

    public function get lineScrollSize():Number {
        return _lineScrollSize;
    }

    public function set lineScrollSize(value:Number):void {
        if (value == _lineScrollSize)
            return;
        _lineScrollSize = value;
        //TODO 重绘 滚动条大小  或者位置
        drawThump();
    }

    /**
     * 是否在移动滚动条
     */
    public function get isScrolling():Boolean {
        return inDrag == true;
    }

    public function get direction():String {
        return _direction;
    }

    public function set direction(value:String):void {
        if (value == _direction)
            return;
        _direction = value;
        drawScroll();
    }

    public function set onScrollHandler(value:Function):void {
        _onScrollHandler = value
    }
}
}
