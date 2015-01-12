package chat.view {
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;

import org.osflash.async.LoaderDeferred;
import org.osflash.async.ResFormat;
import org.rcSpark.binaryManager.loader.LoadLevel;

public class ChatFaceRenderer extends Sprite {
    public function ChatFaceRenderer() {
        super();

        createChildren();

        this.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
        this.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
        this.addEventListener(MouseEvent.CLICK, clickHandler);	//鼠标单击事件
    }

    private var overSkin:Sprite;
    public var _data:Object;
    private var faceInstance:MovieClip;
    //TODO by Cqs
//    private var load:LoaderDeferred;
    private var load:*;
    /**
     * 点击回调函数
     */
    private var _onSelectHandler:Function;

    public function get url():String {
        //TODO by Cqs
        return "../assets/"+data.@icon.toString();
    }

    public function get data():Object {
        return _data;
    }

    public function set data(value:Object):void {
        if (value == _data)
            return;
        _data = value;
        clearLoader();
        //TODO by Cqs
        load = new LoaderDeferred();
        load.load(url, ResFormat.LOADER, LoadLevel.ICON)
        load.completes(onComplete);
    }

    //Methods
    protected function createChildren():void {
        overSkin = new Sprite();
        overSkin.graphics.lineStyle(3, 0x00ff00);
        overSkin.graphics.drawRect(0, 0, 25, 25);
        overSkin.graphics.endFill();
        addChild(overSkin);
        overSkin.visible = false;
    }

    public function dispose():void {
        clearMc();
        clearLoader();
        this.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
        this.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
        this.removeEventListener(MouseEvent.CLICK, clickHandler);
    }

    //Event Handler
    private function rollOverHandler(event:MouseEvent):void {
        overSkin.visible = true;
    }

    private function rollOutHandler(event:MouseEvent):void {
        overSkin.visible = false;
    }

    private function clickHandler(event:MouseEvent):void {
        if (_onSelectHandler!=null) {
            _onSelectHandler.apply(this, [
                {iconId: data.@id, url: data.@icon}
            ]);
        }
    }

    private function clearLoader():void {
        if (load) {
            load.dispose();
            load = null;
        }
    }

    private function clearMc():void {
        if (faceInstance) {
            faceInstance.stop();
            if (faceInstance.parent) {
                faceInstance.parent.removeChild(faceInstance);
            }
            faceInstance = null;
        }
    }

    private function onComplete(loadInfo:*):void {
        clearMc();
        faceInstance = loadInfo.data as MovieClip;
        faceInstance.x = faceInstance.y = 2;
        faceInstance.width = data.@w;
        faceInstance.height = data.@h;
        addChild(faceInstance);
    }

    /**
     * 设置 选中回调函数
     * @param value
     */
    public function set onSelectHandler(value:Function):void {
        _onSelectHandler = value;
    }
}
}
