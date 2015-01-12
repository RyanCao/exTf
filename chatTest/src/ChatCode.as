package {

import chat.view.ChatView;

import flash.display.Sprite;
import flash.events.Event;

[SWF(width=800, height=600, backgroundColor=0x666666)]
public class ChatCode extends Sprite {
    public function ChatCode() {
        if (stage) {
            onAddtoStageHandler(null);
        } else {
            addEventListener(Event.ADDED_TO_STAGE, onAddtoStageHandler);
        }
    }

    private function onAddtoStageHandler(event:Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, onAddtoStageHandler);

        var view:ChatView = new ChatView();
        addChild(view);
        view.y = stage.stageHeight;
    }

}
}
