package org.rcant.exTf.util {

import mx.utils.StringUtil;

public class HtmlUtil {
    public static const COLOR_GOLD_STRING:String = "#ff6c00";
    public static const COLOR_GREEN_STRING:String = "#00FE7A";

    public static function colorOnly(content:String, theColor:String = "#ffffff"):String {
        return "<font color='" + theColor + "'>" + content + "</font>";
    }

    public static function sizeOnly(content:String, fontSize:int):String {
        return "<font size='" + fontSize + "'>" + content + "</font>";
    }

    public static function p(content:String, align:String = "left"):String {
        return "<p align=\"" + align + "\">" + content + "</p>";
    }

    public static function u(content:String):String {
        return "<u>" + content + "</u>";
    }

    public static function clearColor(content:String):String {
        var colorPattern:RegExp = /color=\'#[0-9a-fA-F]{6}\'/g;
        return content.replace(colorPattern, "");
    }

    public static function replaceAllColor(content:String, color:String = "#ffffff"):String {
        var colorPattern:RegExp = /color=\'#[0-9a-fA-F]{6}\'/g;
        return content.replace(colorPattern, StringUtil.substitute("color='{0}'", color));
    }

    public static function customColor(content:String, theColor:String):String {
        return "&" + theColor + "&" + content;
    }

    public static function bold(content:String):String {
        return "<b>" + content + "</b>";
    }

    public static function leading(content:String, theLeading:int = 2):String {
        return StringUtil.substitute("<textformat leading=\"{0}\">{1}</textformat>", theLeading, content);
    }

    public static function autoBr(content:String, length:int = 15):String {
        return content;
    }

    public static function removeHtml(content:String):String {
        var result:String = content.replace(/\<\/?[^\<\>]+\>/gmi, "");
        result = result.replace(/[\r\n ]+/g, "");
        return result;
    }

    public static function addEventParameter(str:String, parameter:String):String {
        return "<a href=\"event:" + parameter + "\">" + str + "</a>";
    }

    public static function addUEventParameter(str:String, parameter:String):String {
        return addEventParameter(u(str), parameter);
    }

    public static function addURLParameter(str:String, parameter:String):String {
        return "<a href =\"" + parameter + "\">" + str + "</a>"
    }

    public static function addUParameter(str:String, parameter:String):String {
        return addURLParameter(u(str), parameter);
    }

    public static function taskFontColor(s:String, COLOR_GOLD_STRING:String):String {
        return "<font color='" + COLOR_GOLD_STRING + "'>" + s + "</font>";

    }

    public static function regExpReplace(content:String, regExp:RegExp):String {
        return content.replace(regExp, refun)
    }

    private static function refun(...args):String {
        return colorOnly(args[0], COLOR_GREEN_STRING);
    }

    public static function clearSize(content:String):String {
        var colorPattern:RegExp = /size=\'[0-9]+\'/g;
        return content.replace(colorPattern, "");
    }

    public static function getToolTipsHtmlText(context:String, toolTipsConText:String):String {
        return addEventParameter(u(context), toolTipsConText);
    }
}
}