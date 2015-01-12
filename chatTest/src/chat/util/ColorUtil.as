/**
 * Class name: ColorUtil.as
 * Description:
 * Author: caoqingshan
 * Create: 15-1-9 下午4:08
 */
package chat.util {
public class ColorUtil {
    //-----------------------------------------------------------------------------
    // Var
    //-----------------------------------------------------------------------------
    //道具装备品质颜色 黑白绿蓝紫黄橙
    public static const TEXTCOLOR:Array= ["#000000","#FFFFFF","#00ff78","#66b3fa","#cc63eb","#E67827","#f0a374"];
    public static const TEXTCOLOROX:Array= [0x000000,0xFFFFFF, 0x00ff78, 0x66b3fa, 0xcc63eb, 0xE67827, 0xf0a374];
    public function ColorUtil() {
    }

    //-----------------------------------------------------------------------------
    // Methods
    //-----------------------------------------------------------------------------

    //把颜色从数字型转成字符型,即#000000;
    public static function getColorStr(color:uint):String
    {
        var result:String = "#";
        result += color.toString(16);
        return result;
    }
}
}
