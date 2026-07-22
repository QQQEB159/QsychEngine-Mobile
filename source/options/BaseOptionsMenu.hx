package options;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepadManager;

import objects.CheckboxThingie;
import objects.AttachedText;
import options.Option;
import backend.InputFormatter;

import oecodes.OeTools;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

class BaseOptionsMenu extends MusicBeatSubstate
{
	private var curOption:Option = null;
	private var curSelected:Int = 0;
	private var optionsArray:Array<Option>;

	private var grpOptions:FlxTypedGroup</*Alphabet*/FlxText>;
	private var checkboxGroup:FlxTypedGroup<CheckboxThingie>;

	private var descBox:FlxSprite;
	private var descText:FlxText;

	public var title:String;
	public var rpcTitle:String;

	public var bg:FlxSprite;
	var songBGList:FlxTypedGroup<FlxSprite>;
	public static var tweenList:Array<FlxTween> = [];
	public function new()
	{
		super();

		if(title == null) title = 'Options';
		if(rpcTitle == null) rpcTitle = 'Options Menu';
		
		#if DISCORD_ALLOWED
		DiscordClient.changePresence(rpcTitle, null);
		#end
		
		bg = new FlxSprite().loadGraphic(Paths.image('menu/menuBG', 'vocaloid'));
		//bg.color = 0xFFea71fd;
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0xA6C7C7C7, 0x0));
		grid.velocity.set(-40, -40);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 0.5}, 1, {ease: FlxEase.quadOut});
		add(grid);

		// avoids lagspikes while scrolling through menus!
		songBGList = new FlxTypedGroup<FlxSprite>();
		add(songBGList);

		grpOptions = new FlxTypedGroup</*Alphabet*/FlxText>();
		add(grpOptions);

		checkboxGroup = new FlxTypedGroup<CheckboxThingie>();
		add(checkboxGroup);

		descBox = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		descBox.alpha = 0.6;
		add(descBox);

		/*var titleText:Alphabet = new Alphabet(75, 45, title, true);
		titleText.setScale(0.6);
		titleText.alpha = 0.4;
		add(titleText);*/

		var bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0.6;
		add(bottomBG);

		var leText:String = title;
		var size:Int = 16;
		var bottomText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, leText, size);
		bottomText.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER);
		bottomText.scrollFactor.set();
		add(bottomText);

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		for (i in 0...optionsArray.length)
		{
			var bg:FlxSprite = new FlxSprite();
			bg.frames = Paths.getSparrowAtlas('freeplay/button', 'vocaloid');
			bg.animation.addByPrefix('idle', 'button_deselected', 24, true);
			bg.animation.addByPrefix('selected', 'button_selected', 24, true);
			bg.animation.play('idle');
			bg.updateHitbox();
			bg.screenCenter(X);
			bg.antialiasing = ClientPrefs.data.antialiasing;
			songBGList.add(bg);

			var optionText:FlxText = new FlxText(220, 260, 0, optionsArray[i].name, 40);
			optionText.setFormat(Paths.font('vcr.ttf'), 40, FlxColor.BLACK, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
			optionText.y = i - curSelected;
			optionText.antialiasing = ClientPrefs.data.antialiasing;
			if (optionsArray[i].getValue() == 'true' || optionsArray[i].getValue() == 'false') 
			{
				optionText.text = optionsArray[i].name + ': ' + ((optionsArray[i].getValue()) == 'true' ? OeTools.getJsonData('Main', 'option_on') : OeTools.getJsonData('Main', 'option_off'));
			}
			else
			{
				optionText.text = optionsArray[i].name + ': ' + optionsArray[i].getValue();
			}
			optionText.screenCenter(X);
			grpOptions.add(optionText);

			if(optionsArray[i].type == BOOL)
			{
				var checkbox:CheckboxThingie = new CheckboxThingie(optionText.x - 105, optionText.y - 30, Std.string(optionsArray[i].getValue()) == 'true');
				checkbox.sprTracker = optionText;
				checkbox.ID = i;
				checkbox.visible = false;
				checkboxGroup.add(checkbox);
			}
			else
			{

			}
			//optionText.snapToPosition(); //Don't ignore me when i ask for not making a fucking pull request to uncomment this line ok
			updateTextFrom(optionsArray[i]);
		}

		changeSelection();
		reloadCheckboxes();
		
		addTouchPad('LEFT_FULL', 'A_B_C');
	}

	public function addOption(option:Option) {
		if(optionsArray == null || optionsArray.length < 1) optionsArray = [];
		optionsArray.push(option);
		return option;
	}

	var nextAccept:Int = 5;
	var holdTime:Float = 0;
	var holdValue:Float = 0;

	var bindingKey:Bool = false;
	var holdingEsc:Float = 0;
	var bindingBlack:FlxSprite;
	var bindingText:Alphabet;
	var bindingText2:Alphabet;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (songBGList != null && grpOptions != null)
		{
			for (i in 0...songBGList.members.length)
			{
				songBGList.members[i].y = grpOptions.members[i].y - 18;

				songBGList.members[i].animation.play('idle');
				songBGList.members[curSelected].animation.play('selected');
			}
		}

		if(bindingKey)
		{
			bindingKeyUpdate(elapsed);
			return;
		}

		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.BACK) {
			close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}

		if(nextAccept <= 0)
		{
			switch(curOption.type)
			{
				case BOOL:
					if(controls.ACCEPT)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						curOption.setValue((curOption.getValue() == true) ? false : true);
						curOption.change();
						grpOptions.members[curSelected].text = optionsArray[curSelected].name + ': ' + ((curOption.getValue()) == true ? OeTools.getJsonData('Main', 'option_on') : OeTools.getJsonData('Main', 'option_off'));
						grpOptions.members[curSelected].screenCenter(X);
						reloadCheckboxes();
					}

				case KEYBIND:
					if(controls.ACCEPT)
					{
						bindingBlack = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
						bindingBlack.scale.set(FlxG.width, FlxG.height);
						bindingBlack.updateHitbox();
						bindingBlack.alpha = 0;
						FlxTween.tween(bindingBlack, {alpha: 0.6}, 0.35, {ease: FlxEase.linear});
						add(bindingBlack);
	
						bindingText = new Alphabet(FlxG.width / 2, 160, Language.getPhrase('controls_rebinding', 'Rebinding {1}', [curOption.name]), false);
						bindingText.alignment = CENTERED;
						add(bindingText);
						
						bindingText2 = new Alphabet(FlxG.width / 2, 340, Language.getPhrase('controls_rebinding2', 'Hold ESC to Cancel\nHold Backspace to Delete'), true);
						bindingText2.alignment = CENTERED;
						add(bindingText2);
	
						bindingKey = true;
						holdingEsc = 0;
						ClientPrefs.toggleVolumeKeys(false);
						FlxG.sound.play(Paths.sound('scrollMenu'));
					}

				default:
					if(controls.UI_LEFT || controls.UI_RIGHT)
					{
						var pressed = (controls.UI_LEFT_P || controls.UI_RIGHT_P);
						if(holdTime > 0.5 || pressed)
						{
							if(pressed)
							{
								var add:Dynamic = null;
								if(curOption.type != STRING)
									add = controls.UI_LEFT ? -curOption.changeValue : curOption.changeValue;
		
								switch(curOption.type)
								{
									case INT, FLOAT, PERCENT:
										holdValue = curOption.getValue() + add;
										if(holdValue < curOption.minValue) holdValue = curOption.minValue;
										else if (holdValue > curOption.maxValue) holdValue = curOption.maxValue;
		
										if(curOption.type == INT)
										{
											holdValue = Math.round(holdValue);
											curOption.setValue(holdValue);
											grpOptions.members[curSelected].text = optionsArray[curSelected].name + ': ' + curOption.getValue();
											grpOptions.members[curSelected].screenCenter(X);
										}
										else
										{
											holdValue = FlxMath.roundDecimal(holdValue, curOption.decimals);
											curOption.setValue(holdValue);
											grpOptions.members[curSelected].text = optionsArray[curSelected].name + ': ' + curOption.getValue();
											grpOptions.members[curSelected].screenCenter(X);
										}
		
									case STRING:
										var num:Int = curOption.curOption; //lol
										if(controls.UI_LEFT_P) --num;
										else num++;
		
										if(num < 0)
											num = curOption.options.length - 1;
										else if(num >= curOption.options.length)
											num = 0;
		
										curOption.curOption = num;
										curOption.setValue(curOption.options[num]);
										grpOptions.members[curSelected].text = optionsArray[curSelected].name + ': ' + curOption.getValue();
										grpOptions.members[curSelected].screenCenter(X);
										//trace(curOption.options[num]);

									default:
								}
								updateTextFrom(curOption);
								curOption.change();
								FlxG.sound.play(Paths.sound('scrollMenu'));
							}
							else if(curOption.type != STRING)
							{
								holdValue += curOption.scrollSpeed * elapsed * (controls.UI_LEFT ? -1 : 1);
								if(holdValue < curOption.minValue) holdValue = curOption.minValue;
								else if (holdValue > curOption.maxValue) holdValue = curOption.maxValue;
		
								switch(curOption.type)
								{
									case INT:
										curOption.setValue(Math.round(holdValue));
										grpOptions.members[curSelected].text = optionsArray[curSelected].name + ': ' + curOption.getValue();
										grpOptions.members[curSelected].screenCenter(X);
									
									case PERCENT:
										curOption.setValue(FlxMath.roundDecimal(holdValue, curOption.decimals));
										grpOptions.members[curSelected].text = optionsArray[curSelected].name + ': ' + curOption.getValue();
										grpOptions.members[curSelected].screenCenter(X);

									default:
								}
								updateTextFrom(curOption);
								curOption.change();
							}
						}
		
						if(curOption.type != STRING)
							holdTime += elapsed;
					}
					else if(controls.UI_LEFT_R || controls.UI_RIGHT_R)
					{
						if(holdTime > 0.5) FlxG.sound.play(Paths.sound('scrollMenu'));
						holdTime = 0;
					}
			}

			if(controls.RESET || touchPad.buttonC.justPressed)
			{
				var leOption:Option = optionsArray[curSelected];
				if(leOption.type != KEYBIND)
				{
					leOption.setValue(leOption.defaultValue);
					if(leOption.type != BOOL)
					{
						if(leOption.type == STRING) leOption.curOption = leOption.options.indexOf(leOption.getValue());
						updateTextFrom(leOption);
					}
				}
				else
				{
					leOption.setValue(!Controls.instance.controllerMode ? leOption.defaultKeys.keyboard : leOption.defaultKeys.gamepad);
					updateBind(leOption);
				}
				leOption.change();
				if (optionsArray[curSelected].getValue() == 'true' || optionsArray[curSelected].getValue() == 'false') 
				{
					grpOptions.members[curSelected].text = optionsArray[curSelected].name + ': ' + ((optionsArray[curSelected].getValue()) == 'true' ? OeTools.getJsonData('Main', 'option_on') : OeTools.getJsonData('Main', 'option_off'));
				}
				else
				{
					grpOptions.members[curSelected].text = optionsArray[curSelected].name + ': ' + optionsArray[curSelected].getValue();
				}
				grpOptions.members[curSelected].screenCenter(X);
				FlxG.sound.play(Paths.sound('cancelMenu'));
				reloadCheckboxes();
			}
		}

		if(nextAccept > 0) {
			nextAccept -= 1;
		}
	}

	function bindingKeyUpdate(elapsed:Float)
	{
		if(FlxG.keys.pressed.ESCAPE || FlxG.gamepads.anyPressed(B))
		{
			holdingEsc += elapsed;
			if(holdingEsc > 0.5)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				closeBinding();
			}
		}
		else if (FlxG.keys.pressed.BACKSPACE || FlxG.gamepads.anyPressed(BACK))
		{
			holdingEsc += elapsed;
			if(holdingEsc > 0.5)
			{
				if (!controls.controllerMode) curOption.keys.keyboard = NONE;
				else curOption.keys.gamepad = NONE;
				updateBind(!controls.controllerMode ? InputFormatter.getKeyName(NONE) : InputFormatter.getGamepadName(NONE));
				FlxG.sound.play(Paths.sound('cancelMenu'));
				closeBinding();
			}
		}
		else
		{
			holdingEsc = 0;
			var changed:Bool = false;
			if(!controls.controllerMode)
			{
				if(FlxG.keys.justPressed.ANY || FlxG.keys.justReleased.ANY)
				{
					var keyPressed:FlxKey = cast (FlxG.keys.firstJustPressed(), FlxKey);
					var keyReleased:FlxKey = cast (FlxG.keys.firstJustReleased(), FlxKey);

					if(keyPressed != NONE && keyPressed != ESCAPE && keyPressed != BACKSPACE)
					{
						changed = true;
						curOption.keys.keyboard = keyPressed;
					}
					else if(keyReleased != NONE && (keyReleased == ESCAPE || keyReleased == BACKSPACE))
					{
						changed = true;
						curOption.keys.keyboard = keyReleased;
					}
				}
			}
			else if(FlxG.gamepads.anyJustPressed(ANY) || FlxG.gamepads.anyJustPressed(LEFT_TRIGGER) || FlxG.gamepads.anyJustPressed(RIGHT_TRIGGER) || FlxG.gamepads.anyJustReleased(ANY))
			{
				var keyPressed:FlxGamepadInputID = NONE;
				var keyReleased:FlxGamepadInputID = NONE;
				if(FlxG.gamepads.anyJustPressed(LEFT_TRIGGER))
					keyPressed = LEFT_TRIGGER; //it wasnt working for some reason
				else if(FlxG.gamepads.anyJustPressed(RIGHT_TRIGGER))
					keyPressed = RIGHT_TRIGGER; //it wasnt working for some reason
				else
				{
					for (i in 0...FlxG.gamepads.numActiveGamepads)
					{
						var gamepad:FlxGamepad = FlxG.gamepads.getByID(i);
						if(gamepad != null)
						{
							keyPressed = gamepad.firstJustPressedID();
							keyReleased = gamepad.firstJustReleasedID();
							if(keyPressed != NONE || keyReleased != NONE) break;
						}
					}
				}

				if(keyPressed != NONE && keyPressed != FlxGamepadInputID.BACK && keyPressed != FlxGamepadInputID.B)
				{
					changed = true;
					curOption.keys.gamepad = keyPressed;
				}
				else if(keyReleased != NONE && (keyReleased == FlxGamepadInputID.BACK || keyReleased == FlxGamepadInputID.B))
				{
					changed = true;
					curOption.keys.gamepad = keyReleased;
				}
			}

			if(changed)
			{
				var key:String = null;
				if(!controls.controllerMode)
				{
					if(curOption.keys.keyboard == null) curOption.keys.keyboard = 'NONE';
					curOption.setValue(curOption.keys.keyboard);
					key = InputFormatter.getKeyName(FlxKey.fromString(curOption.keys.keyboard));
				}
				else
				{
					if(curOption.keys.gamepad == null) curOption.keys.gamepad = 'NONE';
					curOption.setValue(curOption.keys.gamepad);
					key = InputFormatter.getGamepadName(FlxGamepadInputID.fromString(curOption.keys.gamepad));
				}
				updateBind(key);
				FlxG.sound.play(Paths.sound('confirmMenu'));
				closeBinding();
			}
		}
	}

	final MAX_KEYBIND_WIDTH = 320;
	function updateBind(?text:String = null, ?option:Option = null)
	{
		if(option == null) option = curOption;
		if(text == null)
		{
			text = option.getValue();
			if(text == null) text = 'NONE';

			if(!controls.controllerMode)
				text = InputFormatter.getKeyName(FlxKey.fromString(text));
			else
				text = InputFormatter.getGamepadName(FlxGamepadInputID.fromString(text));
		}

		var bind:AttachedText = cast option.child;
		var attach:AttachedText = new AttachedText(text, bind.offsetX);
		attach.sprTracker = bind.sprTracker;
		attach.copyAlpha = true;
		attach.ID = bind.ID;
		playstationCheck(attach);
		attach.scaleX = Math.min(1, MAX_KEYBIND_WIDTH / attach.width);
		attach.x = bind.x;
		attach.y = bind.y;

		option.child = attach;
		bind.destroy();
	}

	function playstationCheck(alpha:Alphabet)
	{
		if(!controls.controllerMode) return;

		var gamepad:FlxGamepad = FlxG.gamepads.firstActive;
		var model:FlxGamepadModel = gamepad != null ? gamepad.detectedModel : UNKNOWN;
		var letter = alpha.letters[0];
		if(model == PS4)
		{
			switch(alpha.text)
			{
				case '[', ']': //Square and Triangle respectively
					letter.image = 'alphabet_playstation';
					letter.updateHitbox();
					
					letter.offset.x += 4;
					letter.offset.y -= 5;
			}
		}
	}

	function closeBinding()
	{
		bindingKey = false;
		bindingBlack.destroy();
		remove(bindingBlack);

		bindingText.destroy();
		remove(bindingText);

		bindingText2.destroy();
		remove(bindingText2);
		ClientPrefs.toggleVolumeKeys(true);
	}

	function updateTextFrom(option:Option) {
		if(option.type == KEYBIND)
		{
			updateBind(option);
			return;
		}

		var text:String = option.displayFormat;
		var val:Dynamic = option.getValue();
		if(option.type == PERCENT) val *= 100;
		var def:Dynamic = option.defaultValue;
		option.text = text.replace('%v', val).replace('%d', def);
	}
	
	function changeSelection(change:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, optionsArray.length - 1);

		descText.text = optionsArray[curSelected].description;
		descText.screenCenter(Y);
		descText.y += 270;

		var bullShit:Int = 0;
		if(tweenList != null) {
			for (i in tweenList)
			{
				i.cancel();
			}
		}
		tweenList = [];

		/*for (num => item in grpOptions.members)
		{
			item.targetY = num - curSelected;
			item.alpha = 0.6;
			if (item.targetY == 0) item.alpha = 1;
		}*/
		for (i in 0...grpOptions.members.length)
		{
			grpOptions.members[i].alpha = 0.6;
			var tween:FlxTween = FlxTween.tween(grpOptions.members[i],{y:180 - (-(bullShit - curSelected) * 125)},0.25,{ease: FlxEase.expoOut});
			tweenList.push(tween);
			bullShit++;
		}
		grpOptions.members[curSelected].alpha = 1;

		descBox.setPosition(descText.x - 10, descText.y - 10);
		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();

		curOption = optionsArray[curSelected]; //shorter lol
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function reloadCheckboxes()
		for (checkbox in checkboxGroup)
			checkbox.daValue = Std.string(optionsArray[checkbox.ID].getValue()) == 'true'; //Do not take off the Std.string() from this, it will break a thing in Mod Settings Menu
}