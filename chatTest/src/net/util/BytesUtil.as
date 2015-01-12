package net.util {
import com.hurlant.math.BigInteger;
import com.hurlant.math.bi_internal;

import flash.utils.ByteArray;
import flash.utils.Endian;

public class BytesUtil {
    private static var _negOne:BigInteger;

    private static function getNegOne():BigInteger {
        if (_negOne == null) {
            _negOne = new BigInteger();
            _negOne.bi_internal::fromInt(-1);
        }
        return _negOne;
    }

    public static function createByteArray():ByteArray {
        var bytes:ByteArray = new ByteArray();
        bytes.endian = Endian.LITTLE_ENDIAN;
        return bytes;
    }

    public static function createGateBytes(usrID:BigInteger, key:uint):ByteArray {
        var bytes:ByteArray = BytesUtil.createByteArray();
        bytes.writeByte(1);
        writeUInt64(bytes, usrID);
        bytes.writeUnsignedInt(key);
        return bytes;
    }

    public static function xor(bytes:ByteArray, key:uint):void {
        for (var i:int = 0; i < bytes.length; ++i) {
            var rem:int = i % 4;
            switch (rem) {
                case 0:
                    bytes[i] = bytes[i] ^ (key & 0xFF);
                    break;
                case 1:
                    bytes[i] = bytes[i] ^ (key >> 8 & 0xFF);
                    break;
                case 2:
                    bytes[i] = bytes[i] ^ (key >> 16 & 0xFF);
                    break;
                case 3:
                    bytes[i] = bytes[i] ^ (key >> 24 & 0xFF);
                    break;
            }
        }
    }

    public static function bytes2ReverseString(bytes:ByteArray):String {
        var str:String = "";
        for (var i:int = bytes.length - 1; i >= 0; --i)
            str += ("0" + bytes[i].toString(16)).substr(-2, 2) + " ";
        return str;
    }

    public static function bytes2String(bytes:ByteArray):String {
        var str:String = "";
        for (var i:int = 0; i < bytes.length; ++i)
            str += ("0" + bytes[i].toString(16)).substr(-2, 2) + " ";
        return str;
    }

    public static function readVectorLength(bytes:ByteArray):uint {
        var length:uint = bytes.readUnsignedByte();
        if ((length & 0x80) != 0) {
            var ext:uint = bytes.readUnsignedByte();
            length = ((length & 0x7F) << 8) + ext;
        }
        if (length > 0x7FFF)
            throw Error("Vector Size Too Large!");
        return length;
    }

    public static function writeVectorLength(bytes:ByteArray, length:uint):void {
        if (length > 0x7FFF)
            throw Error("Vector Size Too Large!");
        if (length > 0x7F)
            bytes.writeShort(length >> 8 | 0x80 | length << 8);
        else
            bytes.writeByte(length);
    }

    public static function readStringLength(bytes:ByteArray):uint {
        var length:uint = bytes.readUnsignedShort();
        if ((length & 0x8000) != 0) {
            var ext:uint = bytes.readUnsignedShort();
            length = ((length & 0x7FFF) << 16) + ext;
        }
        if (length > 0x7FFFFFFF)
            throw Error("String Length Too Large!");
        return length;
    }

    public static function writeStringLength(bytes:ByteArray, length:uint):void {
        if (length > 0x7FFFFFFF)
            throw Error("String Length Too Large!");
        if (length > 0x7FFF)
            bytes.writeUnsignedInt(length >> 16 | 0x8000 | length << 16);
        else
            bytes.writeShort(length);
    }

    //String
    public static function readString(bytes:ByteArray):String {
        var length:uint = readStringLength(bytes);
        return bytes.readUTFBytes(length);
    }

    public static function writeString(bytes:ByteArray, value:String):void {
        if (value.length < 5000) {
            bytes.writeUTF(value);
        }
        else {
            var strBytes:ByteArray = new ByteArray();
            strBytes.writeUTFBytes(value);
            writeBytes(bytes, strBytes);
        }
    }

    //ByteArray
    public static function readBytes(bytes:ByteArray):ByteArray {
        var newBytes:ByteArray = createByteArray();
        var length:uint = readStringLength(bytes);
        if (length > 0)
            bytes.readBytes(newBytes, 0, length);
        return newBytes;
    }

    public static function writeBytes(bytes:ByteArray, value:ByteArray):void {
        writeStringLength(bytes, value.length);
        bytes.writeBytes(value);
    }

    //INT64
    public static function readInt64(bytes:ByteArray):BigInteger {
        var bytesINT64:ByteArray = createByteArray();
        var negative:Boolean = false;
        bytes.readBytes(bytesINT64, 0, 8);
        if (bytesINT64[7] > 127) {
            negative = true;
            for (var i:int = 0; i < bytesINT64.length; ++i)
                bytesINT64[i] = ~bytesINT64[i];
        }
        var str:String = bytes2ReverseString(bytesINT64);
        var value:BigInteger = new BigInteger(str, 16);
        if (negative) {
            value = value.negate();
            value = value.add(getNegOne());
        }
        //trace("readInt64" + value.toString());
        return value;
    }

    public static function writeInt64(bytes:ByteArray, value:BigInteger):void {
        var tmpBytes:ByteArray = createByteArray();
        var valBytes:ByteArray = value.toByteArray();
        for (var i:int = valBytes.length - 1; i >= 0; --i)
            tmpBytes.writeBytes(valBytes, i, 1);
        for (i = 0; i < 8 - valBytes.length; ++i)
            tmpBytes.writeByte(0);
        bytes.writeBytes(tmpBytes, 0, 8);
    }

    //UINT64
    public static function readUInt64(bytes:ByteArray):BigInteger {
        var bytesINT64:ByteArray = createByteArray();
        var negative:Boolean = false;
        bytes.readBytes(bytesINT64, 0, 8);
        var value:BigInteger = new BigInteger(bytes2ReverseString(bytesINT64), 16);
        //trace("readUInt64" + value.toString());
        return value;
    }

    public static function writeUInt64(bytes:ByteArray, value:BigInteger):void {
        var tmpBytes:ByteArray = createByteArray();
        var valBytes:ByteArray = value.toByteArray();
        for (var i:int = valBytes.length - 1; i >= 0; --i)
            tmpBytes.writeBytes(valBytes, i, 1);
        for (i = 0; i < 8 - valBytes.length; ++i)
            tmpBytes.writeByte(0);
        bytes.writeBytes(tmpBytes, 0, 8);
    }

    //TVecINT8
    public static function readVecByte(bytes:ByteArray):Vector.<int> {
        var length:uint = readVectorLength(bytes);
        var vec:Vector.<int> = new Vector.<int>();
        for (var i:uint = 0; i < length; ++i) {
            var value:int = bytes.readByte();
            vec.push(value);
        }
        return vec;
    }

    public static function writeVecByte(bytes:ByteArray, vec:Vector.<int>):void {
        writeVectorLength(bytes, vec.length);
        for each(var value:int in vec)
            bytes.writeByte(value);
    }

    //TVecINT16
    public static function readVecShort(bytes:ByteArray):Vector.<int> {
        var length:uint = readVectorLength(bytes);
        var vec:Vector.<int> = new Vector.<int>();
        for (var i:uint = 0; i < length; ++i) {
            var value:int = bytes.readShort();
            vec.push(value);
        }
        return vec;
    }

    public static function writeVecShort(bytes:ByteArray, vec:Vector.<int>):void {
        writeVectorLength(bytes, vec.length);
        for each(var value:int in vec)
            bytes.writeShort(value);
    }

    //TVecINT32
    public static function readVecInt(bytes:ByteArray):Vector.<int> {
        var length:uint = readVectorLength(bytes);
        var vec:Vector.<int> = new Vector.<int>();
        for (var i:uint = 0; i < length; ++i) {
            var value:int = bytes.readInt();
            vec.push(value);
        }
        return vec;
    }

    public static function writeVecInt(bytes:ByteArray, vec:Vector.<int>):void {
        writeVectorLength(bytes, vec.length);
        for each(var value:int in vec)
            bytes.writeInt(value);
    }

    //TVecINT64
    public static function readVecInt64(bytes:ByteArray):Vector.<BigInteger> {
        var length:uint = readVectorLength(bytes);
        var vec:Vector.<BigInteger> = new Vector.<BigInteger>();
        for (var i:uint = 0; i < length; ++i) {
            var value:BigInteger = readInt64(bytes);
            vec.push(value);
        }
        return vec;
    }

    public static function writeVecInt64(bytes:ByteArray, vec:Vector.<BigInteger>):void {
        writeVectorLength(bytes, vec.length);
        for each(var value:BigInteger in vec)
            writeInt64(bytes, value);
    }

    //TVecUINT8
    public static function readVecUByte(bytes:ByteArray):Vector.<uint> {
        var length:uint = readVectorLength(bytes);
        var vec:Vector.<uint> = new Vector.<uint>();
        for (var i:uint = 0; i < length; ++i) {
            var value:uint = bytes.readUnsignedByte();
            vec.push(value);
        }
        return vec;
    }

    public static function writeVecUByte(bytes:ByteArray, vec:Vector.<uint>):void {
        writeVectorLength(bytes, vec.length);
        for each(var value:uint in vec)
            bytes.writeByte(value);
    }

    //TVecUINT16
    public static function readVecUShort(bytes:ByteArray):Vector.<uint> {
        var length:uint = readVectorLength(bytes);
        var vec:Vector.<uint> = new Vector.<uint>();
        for (var i:uint = 0; i < length; ++i) {
            var value:uint = bytes.readUnsignedShort();
            vec.push(value);
        }
        return vec;
    }

    public static function writeVecUShort(bytes:ByteArray, vec:Vector.<uint>):void {
        writeVectorLength(bytes, vec.length);
        for each(var value:uint in vec)
            bytes.writeShort(value);
    }

    //TVecUINT32
    public static function readVecUInt(bytes:ByteArray):Vector.<uint> {
        var length:uint = readVectorLength(bytes);
        var vec:Vector.<uint> = new Vector.<uint>();
        for (var i:uint = 0; i < length; ++i) {
            var value:uint = bytes.readUnsignedInt();
            vec.push(value);
        }
        return vec;
    }

    public static function writeVecUInt(bytes:ByteArray, vec:Vector.<uint>):void {
        writeVectorLength(bytes, vec.length);
        for each(var value:uint in vec)
            bytes.writeInt(value);
    }

    //TVecUINT64
    public static function readVecUInt64(bytes:ByteArray):Vector.<BigInteger> {
        var length:uint = readVectorLength(bytes);
        var vec:Vector.<BigInteger> = new Vector.<BigInteger>();
        for (var i:uint = 0; i < length; ++i) {
            var value:BigInteger = readUInt64(bytes);
            vec.push(value);
        }
        return vec;
    }

    public static function writeVecUInt64(bytes:ByteArray, vec:Vector.<BigInteger>):void {
        writeVectorLength(bytes, vec.length);
        for each(var value:BigInteger in vec)
            writeUInt64(bytes, value);
    }

    //TVecFloat
    public static function readVecFloat(bytes:ByteArray):Vector.<Number> {
        var length:uint = readVectorLength(bytes);
        var vec:Vector.<Number> = new Vector.<Number>();
        for (var i:uint = 0; i < length; ++i) {
            var value:Number = bytes.readFloat();
            vec.push(value);
        }
        return vec;
    }

    public static function writeVecFloat(bytes:ByteArray, vec:Vector.<Number>):void {
        writeVectorLength(bytes, vec.length);
        for each(var value:Number in vec)
            bytes.writeFloat(value);
    }

    //TVecDouble
    public static function readVecDouble(bytes:ByteArray):Vector.<Number> {
        var length:uint = readVectorLength(bytes);
        var vec:Vector.<Number> = new Vector.<Number>();
        for (var i:uint = 0; i < length; ++i) {
            var value:Number = bytes.readDouble();
            vec.push(value);
        }
        return vec;
    }

    public static function writeVecDouble(bytes:ByteArray, vec:Vector.<Number>):void {
        writeVectorLength(bytes, vec.length);
        for each(var value:Number in vec)
            bytes.writeDouble(value);
    }

    //TVecBool
    public static function readVecBoolean(bytes:ByteArray):Vector.<Boolean> {
        var length:uint = readVectorLength(bytes);
        var vec:Vector.<Boolean> = new Vector.<Boolean>();
        for (var i:uint = 0; i < length; ++i) {
            var value:Boolean = bytes.readBoolean();
            vec.push(value);
        }
        return vec;
    }

    public static function writeVecBoolean(bytes:ByteArray, vec:Vector.<Boolean>):void {
        writeVectorLength(bytes, vec.length);
        for each(var value:Boolean in vec)
            bytes.writeBoolean(value);
    }

    //TVecString
    public static function readVecString(bytes:ByteArray):Vector.<String> {
        var length:uint = readVectorLength(bytes);
        var vec:Vector.<String> = new Vector.<String>();
        for (var i:uint = 0; i < length; ++i) {
            var value:String = readString(bytes);
            vec.push(value);
        }
        return vec;
    }

    public static function writeVecString(bytes:ByteArray, vec:Vector.<String>):void {
        writeVectorLength(bytes, vec.length);
        for each(var value:String in vec)
            writeString(bytes, value);
    }
}
}