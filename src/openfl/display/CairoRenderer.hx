package openfl.display;


import lime.graphics.cairo.Cairo;
import lime.graphics.cairo.CairoOperator;
import lime.graphics.CairoRenderContext;
import lime.math.Matrix3;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

@:access(openfl.display.DisplayObject)
@:access(openfl.display.Graphics)
@:access(openfl.display.IBitmapDrawable)
@:access(openfl.display.Stage)
@:access(openfl.display.Stage3D)
@:allow(openfl._internal.renderer.cairo)
@:allow(openfl.display)


class CairoRenderer extends DisplayObjectRenderer {
	
	
	public var cairo:CairoRenderContext;
	
	private var __matrix:Matrix;
	private var __matrix3:Matrix3;
	
	
	private function new (cairo:Cairo) {
		
		super ();
		
		#if lime_cairo
		this.cairo = cairo;
		
		__matrix = new Matrix ();
		__matrix3 = new Matrix3 ();
		
		__type = CAIRO;
		#end
		
	}
	
	
	public function applyMatrix (transform:Matrix, cairo:Cairo = null):Void {
		
		if (cairo == null) cairo = this.cairo;
		
		__matrix.copyFrom (transform);
		
		if (this.cairo == cairo && __worldTransform != null) {
			
			__matrix.concat (__worldTransform);
			
		}
		
		__matrix3.a = __matrix.a;
		__matrix3.b = __matrix.b;
		__matrix3.c = __matrix.c;
		__matrix3.d = __matrix.d;
		
		if (__roundPixels) {
			
			__matrix3.tx = Math.round (__matrix.tx);
			__matrix3.ty = Math.round (__matrix.ty);
			
		} else {
			
			__matrix3.tx = __matrix.tx;
			__matrix3.ty = __matrix.ty;
			
		}
		
		cairo.matrix = __matrix3;
		
	}
	
	
	private override function __clear ():Void {
		
		if (cairo == null) return;
		
		cairo.identityMatrix ();
		
		if (__stage != null && __stage.__clearBeforeRender) {
			
			var cacheBlendMode = __blendMode;
			__setBlendMode (NORMAL);
			
			cairo.setSourceRGB (__stage.__colorSplit[0], __stage.__colorSplit[1], __stage.__colorSplit[2]);
			cairo.paint ();
			
			__setBlendMode (cacheBlendMode);
			
		}
		
	}
	
	
	private override function __popMask ():Void {
		
		cairo.restore ();
		
	}
	
	
	private override function __popMaskObject (object:DisplayObject, handleScrollRect:Bool = true):Void {
		
		if (!object.__isCacheBitmapRender && object.__mask != null) {
			
			__popMask ();
			
		}
		
		if (handleScrollRect && object.__scrollRect != null) {
			
			__popMaskRect ();
			
		}
		
	}
	
	
	private override function __popMaskRect ():Void {
		
		cairo.restore ();
		
	}
	
	
	private override function __pushMask (mask:DisplayObject):Void {
		
		cairo.save ();
		
		applyMatrix (mask.__renderTransform, cairo);
		
		cairo.newPath ();
		mask.__renderCairoMask (this);
		cairo.clip ();
		
	}
	
	
	private override function __pushMaskObject (object:DisplayObject, handleScrollRect:Bool = true):Void {
		
		if (handleScrollRect && object.__scrollRect != null) {
			
			__pushMaskRect (object.__scrollRect, object.__renderTransform);
			
		}
		
		if (!object.__isCacheBitmapRender && object.__mask != null) {
			
			__pushMask (object.__mask);
			
		}
		
	}
	
	
	private override function __pushMaskRect (rect:Rectangle, transform:Matrix):Void {
		
		cairo.save ();
		
		applyMatrix (transform, cairo);
		
		cairo.newPath ();
		cairo.rectangle (rect.x, rect.y, rect.width, rect.height);
		cairo.clip ();
		
	}
	
	
	private override function __render (object:IBitmapDrawable):Void {
		
		if (cairo == null) return;
		
		object.__renderCairo (this);
		
	}
	
	
	private override function __renderStage3D (stage:Stage):Void {
		
		if (cairo == null) return;
		
		for (stage3D in stage.stage3Ds) {
			
			stage3D.__renderCairo (stage, this);
			
		}
		
	}
	
	
	private override function __setBlendMode (value:BlendMode):Void {
		
		if (__blendMode == value) return;
		
		__blendMode = value;
		
		switch (value) {
			
			case ADD:
				
				cairo.operator = CairoOperator.ADD;
			
			//case ALPHA:
				
				//TODO;
			
			case DARKEN:
				
				cairo.operator = CairoOperator.DARKEN;
			
			case DIFFERENCE:
				
				cairo.operator = CairoOperator.DIFFERENCE;
			
			//case ERASE:
				
				//TODO;
			
			case HARDLIGHT:
				
				cairo.operator = CairoOperator.HARD_LIGHT;
			
			//case INVERT:
				
				//TODO
			
			case LAYER:
				
				cairo.operator = CairoOperator.OVER;
			
			case LIGHTEN:
				
				cairo.operator = CairoOperator.LIGHTEN;
			
			case MULTIPLY:
				
				cairo.operator = CairoOperator.MULTIPLY;
			
			case OVERLAY:
				
				cairo.operator = CairoOperator.OVERLAY;
			
			case SCREEN:
				
				cairo.operator = CairoOperator.SCREEN;
			
			//case SHADER:
				
				//TODO
			
			//case SUBTRACT:
				
				//TODO;
			
			default:
				
				cairo.operator = CairoOperator.OVER;
			
		}
		
	}
	
	
}