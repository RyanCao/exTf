/**
 * Class name: LDGraphicItem.as
 * Description:
 * Author: caoqingshan
 * Create: 15-1-9 下午8:34
 */
package chat.core {
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.net.URLRequest;

import org.osflash.async.LoaderDeferred;
import org.osflash.async.ResFormat;
import org.rcSpark.binaryManager.loader.LoadLevel;
import org.rcSpark.binaryManager.util.URLCode;
import org.rcant.exTf.core.InlineGraphicItem;

public class LDGraphicItem extends InlineGraphicItem {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------
    //暂时注释
    protected var _promise:LoaderDeferred;

    public function LDGraphicItem() {
        super();
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------

    override protected function handleUrlSorce(parent:DisplayObjectContainer, pictURLReq:URLRequest):DisplayObject {
        /**
         * by cqs 寻找可替代加载类 暂时先注释
         */
        _promise = new LoaderDeferred();
        _promise.load(URLCode.encode(pictURLReq), ResFormat.LOADER, LoadLevel.ICON, 1, false).completes(function (e:*):void {
            setGraphic(_promise.data);
            okToUpdateHeightAndWidth = true;
            changeGraphicStatus(READY);
            if (graphic) {
                _measuredWidth = graphic.width;
                _measuredHeight = graphic.height;
                (graphic as InteractiveObject).mouseEnabled = false;
                (graphic as Sprite).mouseChildren = false;
                (graphic as Sprite).buttonMode = false;
                parent.addChild(graphic);
            }
        });
        return null;
    }

    override public function dispose():void {
        if (_promise) {
            _promise.dispose();
            _promise = null;
        }
        super.dispose();
    }

    override public function set x(value:Number):void {
        super.x = value;
        if (_promise) {
            _promise.completes(setPromiseX);
        }
    }

    override public function set y(value:Number):void {
        super.y = value;
        if (_promise) {
            _promise.completes(setPromiseY);
        }
    }

}
}
