package backend;

import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.Assets;
import openfl.display.Sprite;

import flixel.util.FlxStringUtil;
import flixel.FlxG;

/**
 * A FL Sprite that displays the current FPS and GC memory
 */
class DebugDisplay extends Sprite
{
	public static var instance:Null<DebugDisplay> = null;
	
	/**
	 * Creates a DebugDisplay instance
	 * 
	 * Use after your FlxGame is initiated.
	 */
	public static function init()
	{
		if (FlxG.game?.parent == null || instance != null) return;
		
		instance = new DebugDisplay(10, 3, 0xFFFFFF);
		instance.visible = true;
		
		FlxG.game.parent.addChild(instance);
	}
	
	/**
	 * The visualized text showing the current fps
	 */
	final textField:TextField;
	
	/**
	 * The bg for the text
	 */
	public final textUnderlay:Bitmap;
	
	/**
	 * If disabled, the fps counter will no longer update visually
	 */
	var canUpdate:Bool = true;
	
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int = 0;
	
	/**
		The current memory usage of the garbage collector.
	**/
	public var gcMemory(get, never):Float;
	
	/**
	 * The current memory usage of the entire program.
	 * 
	 * Only supported on `Windows` currently
	 */
	public var taskMemory(get, never):Float;
	
	var times:Array<Float> = [];
	
	var deltaTimeout:Float = 0.0;
	
	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();
		
		textUnderlay = new Bitmap();
		textUnderlay.bitmapData = new BitmapData(1, 1, true, 0x6F000000);
		
		final textFormat = new TextFormat(Assets.getFont("assets/fonts/aller.ttf").fontName, 14, color);
		textFormat.leading = 5;
		
		textField = new TextField();
		textField.selectable = false;
		textField.mouseEnabled = false;
		textField.defaultTextFormat = textFormat;
		textField.autoSize = LEFT;
		textField.multiline = true;
		textField.text = "FPS: ";
		
		addChild(textUnderlay);
		addChild(textField);
		
		this.x = x;
		this.y = y;
	}
	
	// Event Handlers
	override function __enterFrame(deltaTime:Float):Void
	{
		final now:Float = haxe.Timer.stamp() * 1000;
		times.push(now);
		while (times[0] < now - 1000)
			times.shift();
		
		// prevents the overlay from updating every frame, why would you need to anyways @crowplexus
		if (deltaTimeout < 100)
		{
			deltaTimeout += deltaTime;
			return;
		}
		
		currentFPS = times.length;
		updateText();
		textUnderlay.width = textField.width + 3;
		textUnderlay.height = textField.height + -5;
		
		deltaTimeout = 0.0;
	}
	
	// rebind this function to set a custom fps counter
	public dynamic function updateText():Void
	{
		__updateText();
	}
	
	function __updateText()
	{
		if (!canUpdate) return;
		
		#if cpp
		var str = 'FPS: $currentFPS • [GC: ${FlxStringUtil.formatBytes(gcMemory)} | Task: ${FlxStringUtil.formatBytes(taskMemory)}]';
		#else
		var str = 'FPS: $currentFPS • GC: ${FlxStringUtil.formatBytes(gcMemory)}';
		#end
		
		textField.text = str;
	}
	
	inline function get_gcMemory():Float
	{
		#if cpp
		return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);
		#elseif hl
		return hl.Gc.stats().currentMemory;
		#else
		return (cast openfl.system.System.totalMemoryNumber : UInt);
		#end
	}
	
	inline function get_taskMemory():Float
	{
		return external.Native.getTaskMemory();
	}
	
	inline function positionFPS(X:Float, Y:Float, ?scale:Float = 1)
	{
 		scaleX = scaleY = #if mobile (scale > 1 ? scale : 1) #else (scale < 1 ? scale : 1) #end;
 		x = FlxG.game.x + X;
 		y = FlxG.game.y + Y;
	}
}