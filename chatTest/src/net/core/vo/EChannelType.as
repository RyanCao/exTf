package net.core.vo {
/**
 * 通道类型
 */
public final class EChannelType {
    public static const eChannelNone:uint = 0; //None
    public static const eChannelAll:uint = 1; //综合
    public static const eChannelWorld:uint = 2; //世界
    public static const eChannelGuild:uint = 3; //帮派
    public static const eChannelSys:uint = 4; //系统
    public static const eChannelTeam:uint = 5; //组队
    public static const eChannelNoLabelSys:uint = 6; //无字系统消息
    public static const end:uint = eChannelNoLabelSys;


    /////////////////////以下为辅助函数/////////////////////

    public static function getDescription(value:uint):String {
        switch (value) {
            case eChannelNone:
                return EChannelTypeMSG.eChannelNone;
            case eChannelAll:
                return EChannelTypeMSG.eChannelAll;
            case eChannelWorld:
                return EChannelTypeMSG.eChannelWorld;
            case eChannelGuild:
                return EChannelTypeMSG.eChannelGuild;
            case eChannelSys:
                return EChannelTypeMSG.eChannelSys;
            case eChannelTeam:
                return EChannelTypeMSG.eChannelTeam;
            case eChannelNoLabelSys:
                return EChannelTypeMSG.eChannelNoLabelSys;
            default:
                return "Unknown Error";
        }
    }
}
}
