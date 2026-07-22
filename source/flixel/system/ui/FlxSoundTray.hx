package flixel.system.ui;

#if FLX_SOUND_SYSTEM
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.utils.Assets;
#if flash
import openfl.text.AntiAliasType;
import openfl.text.GridFitType;
#end

class FlxSoundTray extends Sprite
{
	public var active:Bool;
	var _timer:Float;
	var _bars:Array<Bitmap>;
	var _width:Int = 80;
	var _defaultScale:Float = 2.0;
	public var volumeUpSound:String = "flixel/sounds/beep";
	public var volumeDownSound:String = 'flixel/sounds/beep';
	public var silent:Bool = false;

	var _useCustom:Bool = true;
	var backingBar:Bitmap;
	var oldVolume:Float = 0;
	var fakeTrayY:Float = 0;
	var fakeTrayAlpha:Float = 0;
	var trayLerpY:Float = 0;
	var trayAlphaTarget:Float = 0;

	@:keep
	public function new()
	{
		super();

		visible = false;
		scaleX = _defaultScale;
		scaleY = _defaultScale;
		var tmp:Bitmap = new Bitmap(new BitmapData(_width, 30, true, 0x7F000000));
		screenCenter();
		addChild(tmp);

		var text:TextField = new TextField();
		text.width = tmp.width;
		text.height = tmp.height;
		text.multiline = true;
		text.wordWrap = true;
		text.selectable = false;
		#if flash
		text.embedFonts = true;
		text.antiAliasType = AntiAliasType.NORMAL;
		text.gridFitType = GridFitType.PIXEL;
		#end
		var dtf:TextFormat = new TextFormat(FlxAssets.FONT_DEFAULT, 10, 0xffffff);
		dtf.align = TextFormatAlign.CENTER;
		text.defaultTextFormat = dtf;
		addChild(text);
		text.text = "VOLUME";
		text.y = 16;

		var bx:Int = 10;
		var by:Int = 14;
		_bars = new Array();
		for (i in 0...10)
		{
			tmp = new Bitmap(new BitmapData(4, i + 1, false, FlxColor.WHITE));
			tmp.x = bx;
			tmp.y = by;
			addChild(tmp);
			_bars.push(tmp);
			bx += 6;
			by--;
		}

		y = -height;
		visible = false;

		initCustomSkin();
	}

	function initCustomSkin():Void
	{
		if (!_useCustom) return;

		var graphicScale:Float = 0.3;

		var i:Int = 1;
		for (bar in _bars) {
			var g = loadBitmapData("soundtray/bars_" + i);
			if (g != null) {
				bar.bitmapData = g;
			}
			bar.x = 9;
			bar.y = 5;
			bar.scaleX = graphicScale;
			bar.scaleY = graphicScale;
			bar.smoothing = true;
			i++;
		}

		var bg:Bitmap = cast(getChildAt(0), Bitmap);
		var g = loadBitmapData("soundtray/volumebox");
		if (g != null) bg.bitmapData = g;
		bg.scaleX = graphicScale;
		bg.scaleY = graphicScale;
		bg.smoothing = true;

		var text = getChildAt(1);
		text.visible = false;

		backingBar = new Bitmap();
		var bgBar = loadBitmapData("soundtray/bars_10");
		if (bgBar != null) backingBar.bitmapData = bgBar;
		backingBar.scaleX = graphicScale;
		backingBar.scaleY = graphicScale;
		backingBar.x = 9;
		backingBar.y = 5;
		backingBar.alpha = 0.4;
		addChildAt(backingBar, 1);

		screenCenter();

		fakeTrayY = y;
		fakeTrayAlpha = alpha;
		oldVolume = FlxG.sound.volume;
	}

	function loadBitmapData(path:String):BitmapData
	{
		var paths = [
			"assets/shared/images/" + path + ".png",
			"assets/images/" + path + ".png",
			path + ".png"
		];
		for (p in paths) {
			if (Assets.exists(p)) {
				return Assets.getBitmapData(p);
			}
		}
		return null;
	}

	public function update(MS:Float):Void
	{
		if (!_useCustom) {
			if (_timer > 0) _timer -= (MS / 1000);
			else if (y > -height) {
				y -= (MS / 1000) * height * 0.5;
				if (y <= -height) {
					visible = false;
					active = false;
					#if FLX_SAVE
					if (FlxG.save.isBound) {
						FlxG.save.data.mute = FlxG.sound.muted;
						FlxG.save.data.volume = FlxG.sound.volume;
						FlxG.save.flush();
					}
					#end
				}
			}
			return;
		}

		if (active && visible) {
			for (bar in _bars) {
				bar.x = 9;
				bar.y = 5;
			}

			if (_timer > 0) {
				_timer -= (MS / 1000);
			}

			if (_timer > 0) {
				trayAlphaTarget = 1;
				trayLerpY = 0;
			} else {
				trayLerpY = -this.height - 10;
				trayAlphaTarget = 0;
			}

			fakeTrayY = FlxMath.lerp(fakeTrayY, trayLerpY, 0.1 * FlxG.elapsed * 60);
			fakeTrayAlpha = FlxMath.lerp(fakeTrayAlpha, trayAlphaTarget, 0.25 * FlxG.elapsed * 60);
			this.y = fakeTrayY;
			this.alpha = fakeTrayAlpha;

			var globalVolume:Int = (FlxG.sound.muted ? 0 : Math.round(FlxG.sound.volume * 10));
			var i:Int = 1;
			for (bar in _bars) {
				bar.visible = (i == globalVolume);
				i++;
			}

			if (FlxG.sound.volume != oldVolume || (FlxG.keys.anyJustPressed(FlxG.sound.volumeUpKeys) && FlxG.sound.volume >= 1)) {
				if (oldVolume > FlxG.sound.volume) FlxG.sound.play(Paths.sound('soundtray/Voldown'));
				else FlxG.sound.play(Paths.sound('soundtray/Vol' + (FlxG.sound.volume < 1 ? 'up' : 'MAX')));
				oldVolume = FlxG.sound.volume;
			}

			if (_timer <= 0 && y <= -height) {
				visible = false;
				active = false;
			}
		}
	}

	public function show(up:Bool = false):Void
	{
		if (!silent) {
			var sound = FlxAssets.getSound(up ? volumeUpSound : volumeDownSound);
			//if (sound != null) FlxG.sound.load(sound).play();
		}

		_timer = 1;
		y = 0;
		visible = true;
		active = true;
		fakeTrayY = 0;
		fakeTrayAlpha = 1;
		alpha = 1;

		if (!_useCustom) {
			var globalVolume:Int = Math.round(FlxG.sound.volume * 10);
			if (FlxG.sound.muted) globalVolume = 0;
			for (i in 0..._bars.length) {
				_bars[i].alpha = (i < globalVolume) ? 1 : 0.5;
			}
		}
	}

	public function screenCenter():Void
	{
		scaleX = _defaultScale;
		scaleY = _defaultScale;
		x = (0.5 * (Lib.current.stage.stageWidth - _width * _defaultScale) - FlxG.game.x);
	}

	public function destroy():Void
	{
		if (!_useCustom) return;
		this.silent = false;
		if (backingBar != null && backingBar.parent != null) {
			removeChild(backingBar);
			backingBar = null;
		}
		var bg:Bitmap = cast(getChildAt(0), Bitmap);
		bg.bitmapData = new BitmapData(80, 30, true, 0x7f000000);
		bg.scaleX = 1;
		bg.scaleY = 1;
		var text = getChildAt(1);
		text.visible = true;
		var i:Int = 0;
		for (bar in _bars) {
			bar.bitmapData = new BitmapData(4, i + 1, false, 0xFFFFFF);
			bar.x = 10 + i * 6;
			bar.y = 14 - i;
			bar.scaleX = 1;
			bar.scaleY = 1;
			bar.smoothing = false;
			bar.visible = true;
			i++;
		}
		this.screenCenter();
		this.alpha = 1;
		_useCustom = false;
	}
}
#end