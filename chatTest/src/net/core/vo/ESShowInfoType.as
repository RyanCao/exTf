package net.core.vo {
/**
 * 炫耀类型
 */
public final class ESShowInfoType {
    public static const eFlauntGood:uint = 0; //物品，使用SItem解析
    public static const eFlauntHero:uint = 1; //散仙，使用SFlauntHero解析
    public static const eFlauntPet:uint = 2; //阵灵，使用SFlauntPet解析
    public static const eFlauntHorse:uint = 3; //坐骑，使用SFlauntHorse解析
    public static const end:uint = eFlauntHorse;

    /////////////////////以下为辅助函数/////////////////////

    public static function getDescription(value:uint):String {
        switch (value) {
//				case eFlauntGood:
//					return ProtocolMessageProt28.eFlauntGood;
//				case eFlauntHero:
//					return ProtocolMessageProt28.eFlauntHero;
//				case eFlauntPet:
//					return ProtocolMessageProt28.eFlauntPet;
//				case eFlauntHorse:
//					return ProtocolMessageProt28.eFlauntHorse;
            default:
                return "Unknown Error";
        }
    }
}
}
