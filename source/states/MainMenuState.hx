//北屿DwD的留言: 自学的Haxe代码写的很烂>_<, 望谅解
package states;

import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;
import oecodes.OeTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '1.0.4';
	var bg:FlxSprite;
	var fnfBar:FlxSprite;
	var engineButton:FlxSprite;
	var playButton:FlxSprite;
	var settingsButton:FlxSprite;
	var creditsButton:FlxSprite;
	var magenta:FlxSprite;
	var char:FlxSprite;
	var charList:Array<String> = ['miku', 'teto'];
	var itemList:Array<FlxSprite> = [];
	var mouse:FlxSprite;
	var whiteBarUp:FlxSprite;
	var whiteBarDown:FlxSprite;
	override function create()
	{
		super.create();

		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite().loadGraphic(Paths.image('menu/BG', 'vocaloid'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.setGraphicSize(FlxG.width + 100);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);
		//bg.y -= 100;
		//FlxTween.tween(bg, {y:0}, 0.8, {ease: FlxEase.quartOut});

		magenta = new FlxSprite().loadGraphic(Paths.image('menu/menuBGMagenta', 'vocaloid'));
		magenta.antialiasing = ClientPrefs.data.antialiasing;
		magenta.screenCenter();
		magenta.setGraphicSize(FlxG.width + 80);
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		add(magenta);
		//magenta.y += 10;

		fnfBar = new FlxSprite().loadGraphic(Paths.image('menu/FNFBG', 'vocaloid'));
		fnfBar.antialiasing = ClientPrefs.data.antialiasing;
		fnfBar.setGraphicSize(FlxG.width);
		fnfBar.updateHitbox();
		fnfBar.screenCenter();
		add(fnfBar);

		engineButton = new FlxSprite(520, -30);
		engineButton.frames = Paths.getSparrowAtlas('menu/psychVer', 'vocaloid');
		engineButton.animation.addByPrefix('idle', 'idle', 24, true);
		engineButton.animation.addByPrefix('selected', 'selected', 24, true);
		engineButton.animation.play('idle');
		engineButton.scale.x = 0.8;
		engineButton.scale.y = 0.8;
		engineButton.updateHitbox();
		engineButton.antialiasing = ClientPrefs.data.antialiasing;
		add(engineButton);
		//engineButton.y -= 100;
		//FlxTween.tween(engineButton, {y:-30}, 0.8, {ease: FlxEase.quartOut});

		playButton = new FlxSprite(700, 180);
		playButton.frames = Paths.getSparrowAtlas(OeTools.getLanguageImagePath('menu_freeplay', 'menu/play'), 'vocaloid');
		playButton.animation.addByPrefix('idle', 'freeplay idle', 24, true);
		playButton.animation.addByPrefix('selected', 'freeplay selected', 24, true);
		playButton.animation.play('idle');
		playButton.scale.x = 0.4;
		playButton.scale.y = 0.4;
		playButton.updateHitbox();
		playButton.antialiasing = ClientPrefs.data.antialiasing;
		add(playButton);

		settingsButton = new FlxSprite(1050, 550);
		settingsButton.frames = Paths.getSparrowAtlas('menu/options', 'vocaloid');
		settingsButton.animation.addByPrefix('idle', 'menu_options idle', 24, true);
		settingsButton.animation.addByPrefix('selected', 'menu_options selected', 24, true);
		settingsButton.animation.play('idle');
		settingsButton.scale.x = 0.170;
		settingsButton.scale.y = 0.170;
		settingsButton.updateHitbox();
		settingsButton.antialiasing = ClientPrefs.data.antialiasing;
		add(settingsButton);

		creditsButton = new FlxSprite(600, 520);
		creditsButton.frames = Paths.getSparrowAtlas(OeTools.getLanguageImagePath('credits', 'menu/credits'), 'vocaloid');
		creditsButton.animation.addByPrefix('idle', 'menu_credits idle', 24, true);
		creditsButton.animation.play('idle');
		creditsButton.scale.x = 0.7;
		creditsButton.scale.y = 0.7;
		creditsButton.updateHitbox();
		creditsButton.antialiasing = ClientPrefs.data.antialiasing;
		add(creditsButton);

		char = new FlxSprite(/*-300*/100, /*-300*/110).loadGraphic(Paths.image('menu/' + charList[FlxG.random.int(0, charList.length-1)], 'vocaloid'));
		char.antialiasing = ClientPrefs.data.antialiasing;
		char.scale.x = 0.5;
		char.scale.y = 0.5;
		char.updateHitbox();
		add(char);
		//FlxTween.tween(char, {x:100, y:110}, 1, {ease: FlxEase.quartOut});

		whiteBarUp = new FlxSprite(0, /*-770*/0).makeGraphic(FlxG.width, 50, FlxColor.WHITE);
		whiteBarUp.screenCenter(X);
		add(whiteBarUp);

		whiteBarDown = new FlxSprite(0, /*-50*/0).makeGraphic(FlxG.width, 50, FlxColor.WHITE);
		whiteBarDown.screenCenter(X);
		add(whiteBarDown);
		whiteBarDown.y = FlxG.height - whiteBarDown.height;

		//FlxTween.tween(whiteBarUp, {y:0}, 1, {ease: FlxEase.quartOut});
		//FlxTween.tween(whiteBarDown, {y:FlxG.height - whiteBarDown.height}, 1, {ease: FlxEase.quartOut});

		mouse = new FlxSprite().loadGraphic(Paths.image('menu/cursor', 'vocaloid'));
		mouse.antialiasing = ClientPrefs.data.antialiasing;
		mouse.updateHitbox();
		add(mouse);

		/*var psychVer:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		psychVer.scrollFactor.set();
		psychVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(psychVer);
		var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);*/

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end
		
		addTouchPad('NONE', 'B');
	}

	var selectedSomethin:Bool = false;
	var wasOverlaped1:Bool = false;
	var wasOverlaped2:Bool = false;
	var wasOverlaped3:Bool = false;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume = Math.min(FlxG.sound.music.volume + 0.5 * elapsed, 0.8);

		if (mouse != null)
		{
			mouse.x = FlxG.mouse.x;
			mouse.y = FlxG.mouse.y;
		}

		if (!selectedSomethin)
		{
			if (controls.BACK)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new states.TitleState());
				FlxG.sound.play(Paths.returnSound('sounds/cancelMenu', 'vocaloid'));
			}
			if (FlxG.mouse.overlaps(playButton))
			{
				if (!wasOverlaped1)
				{
					FlxG.sound.play(Paths.returnSound('sounds/scrollMenu', 'vocaloid'));
				}
				wasOverlaped1 = true;
				playButton.animation.play('selected');
				if (FlxG.mouse.justPressed){
					selectedSomethin = true;
					FlxG.sound.play(Paths.returnSound('sounds/confirmMenu', 'vocaloid'));
					mouse.visible = false;
					FlxTween.tween(settingsButton, {alpha:0}, 0.5);
					FlxTween.tween(creditsButton, {alpha:0}, 0.5);
					if (ClientPrefs.data.flashing)
					{
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);
						FlxFlicker.flicker(fnfBar, 1.1, 0.15, false);
					}

					FlxFlicker.flicker(playButton, 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						MusicBeatState.switchState(new states.FreeplayState());
					});
				}
			}
			else
			{
				wasOverlaped1 = false;
				playButton.animation.play('idle');
			}	

			if (FlxG.mouse.overlaps(settingsButton))
			{
				if (!wasOverlaped2)
				{
					FlxG.sound.play(Paths.returnSound('sounds/scrollMenu', 'vocaloid'));
				}
				wasOverlaped2 = true;
				settingsButton.animation.play('selected');
				if (FlxG.mouse.justPressed){
					selectedSomethin = true;
					FlxG.sound.play(Paths.returnSound('sounds/confirmMenu', 'vocaloid'));
					mouse.visible = false;
					FlxTween.tween(playButton, {alpha:0}, 0.5);
					FlxTween.tween(creditsButton, {alpha:0}, 0.5);
					if (ClientPrefs.data.flashing)
					{
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);
						FlxFlicker.flicker(fnfBar, 1.1, 0.15, false);
					}

					FlxFlicker.flicker(settingsButton, 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						MusicBeatState.switchState(new options.OptionsState());
					});
				}
			}
			else
			{
				wasOverlaped2 = false;
				settingsButton.animation.play('idle');
			}

			if (FlxG.mouse.overlaps(creditsButton))
			{
				if (!wasOverlaped3)
				{
					FlxG.sound.play(Paths.returnSound('sounds/scrollMenu', 'vocaloid'));
				}
				wasOverlaped3 = true;
				if (FlxG.mouse.justPressed){
					selectedSomethin = true;
					FlxG.sound.play(Paths.returnSound('sounds/confirmMenu', 'vocaloid'));
					mouse.visible = false;
					FlxTween.tween(playButton, {alpha:0}, 0.5);
					FlxTween.tween(settingsButton, {alpha:0}, 0.5);
					if (ClientPrefs.data.flashing)
					{
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);
						FlxFlicker.flicker(fnfBar, 1.1, 0.15, false);
					}

					FlxFlicker.flicker(creditsButton, 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						MusicBeatState.switchState(new states.CreditsState());
					});
				}
			}
			else
			{
				wasOverlaped3 = false;
			}

			#if desktop
			if (controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				FlxG.mouse.visible = false;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
	}
}
