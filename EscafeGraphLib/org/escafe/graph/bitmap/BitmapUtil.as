package org.escafe.graph.bitmap
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import mx.core.UIComponent;
	import mx.graphics.codec.PNGEncoder;
	
public class BitmapUtil
{
	/**
	 * @category image creation
	 */
	public static function createBitmap(ui: UIComponent, rect: Rectangle): BitmapData {
		var bitmap:BitmapData = new BitmapData(rect.width, rect.height);
		bitmap.draw(ui, new Matrix());
		return bitmap;
	}
	
	/**
	 * @category image creation
	 */
	public static function createPng(ui: UIComponent, rect: Rectangle): ByteArray {
		var pngEncoder:PNGEncoder = new PNGEncoder();
		var bytes:ByteArray = pngEncoder.encode(createBitmap(ui, rect));
		return bytes;
	}
}
}