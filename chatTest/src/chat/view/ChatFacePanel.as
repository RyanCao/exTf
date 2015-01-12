package chat.view {
import chat.util.ChatUtil;

import flash.display.Sprite;

public class ChatFacePanel extends Sprite {

    private var _onSelectHandler:Function;

    public function ChatFacePanel() {
        super();
    }

    public function initSp():void {
        //60fps
        var w:int = 180;
        var h:int = 128;

        graphics.beginFill(0x0,0.3)
        graphics.drawRect(0,0,w,h);
        graphics.endFill();

        var coloum:int = int(w / 25);
        var row:int = int(h / 25);

        var dataProvider:Array = xmlListToArray(ChatUtil.faceXML.item);
        for (var i:int = 0; i < dataProvider.length; i++)	//这里是各种表情
        {
            var cell:ChatFaceRenderer = new ChatFaceRenderer();
            cell.data = dataProvider[i];
            cell.x = int(i % coloum) * 25;
            cell.y = int(i / coloum) * 25;
            cell.onSelectHandler = _onSelectHandler;
            addChild(cell);
        }
    }

    public function xmlListToArray(xl:XMLList):Array {
        var a:Array = []
        var i:String;
        for (i in xl) {
            a[i] = xl[i]
        }
        return a;
    }

    public function set onSelectHandler(value:Function):void {
        _onSelectHandler = value;
    }
}
}
