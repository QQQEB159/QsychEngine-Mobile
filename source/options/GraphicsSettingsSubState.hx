package options;

import objects.Character;
import oecodes.OeTools;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	var antialiasingOption:Int;
	var boyfriend:Character = null;
	public function new()
	{
		title = OeTools.getJsonData('Main', 'titleText_graphics');
		rpcTitle = 'Graphics Settings Menu'; //for Discord Rich Presence

		boyfriend = new Character(840, 170, 'bf', true);
		boyfriend.setGraphicSize(Std.int(boyfriend.width * 0.75));
		boyfriend.updateHitbox();
		boyfriend.dance();
		boyfriend.animation.finishCallback = function (name:String) boyfriend.dance();
		boyfriend.visible = false;

		//I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		var option:Option = new Option(OeTools.getJsonData('Main', 'option_lowQuality'), //Name
			OeTools.getJsonData('Main', 'options_graphics_low_quality_tip'), //Description
			'lowQuality', //Save data variable name
			BOOL); //Variable type
		addOption(option);

		var option:Option = new Option(OeTools.getJsonData('Main', 'option_antialiasing'),
			OeTools.getJsonData('Main', 'options_graphics_anti_aliasing_tip'),
			'antialiasing',
			BOOL);
		option.onChange = onChangeAntiAliasing; //Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);
		antialiasingOption = optionsArray.length-1;

		var option:Option = new Option(OeTools.getJsonData('Main', 'option_shader'), //Name
			OeTools.getJsonData('Main', 'options_graphics_shaders_tip'), //Description
			'shaders',
			BOOL);
		addOption(option);

		var option:Option = new Option(OeTools.getJsonData('Main', 'option_cacheOnGPU'), //Name
			OeTools.getJsonData('Main', 'options_graphics_gpu_tip'), //Description
			'cacheOnGPU',
			BOOL);
		addOption(option);

		#if !html5 //Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		var option:Option = new Option(OeTools.getJsonData('Main', 'option_framerate'),
			OeTools.getJsonData('Main', 'options_graphics_fps_tip'),
			'framerate',
			INT);
		addOption(option);

		final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
		option.minValue = 60;
		option.maxValue = 240;
		option.defaultValue = Std.int(FlxMath.bound(refreshRate, option.minValue, option.maxValue));
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		#end

		super();
		insert(1, boyfriend);
	}

	function onChangeAntiAliasing()
	{
		for (sprite in members)
		{
			var sprite:FlxSprite = cast sprite;
			if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
				sprite.antialiasing = ClientPrefs.data.antialiasing;
			}
		}
	}

	function onChangeFramerate()
	{
		if(ClientPrefs.data.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = ClientPrefs.data.framerate;
			FlxG.drawFramerate = ClientPrefs.data.framerate;
		}
		else
		{
			FlxG.drawFramerate = ClientPrefs.data.framerate;
			FlxG.updateFramerate = ClientPrefs.data.framerate;
		}
	}

	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);
		boyfriend.visible = (antialiasingOption == curSelected);
	}
}