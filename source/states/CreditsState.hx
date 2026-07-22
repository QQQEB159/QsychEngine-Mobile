package states;

import objects.AttachedSprite;
import oecodes.OeTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = 0;
	var tweenList:Array<FlxTween> = [];
	var creditList:Array<Array<String>> = [['没东西啊', 'air', '啥都木有', 'https://www.bilibili.com', '0xFF42CBE4', '100']];
	var bg:FlxSprite;
	var characterText:FlxText;
	var desBG:FlxSprite;
	var desText:FlxText;
	var characterIconList:Array<FlxSprite> = [];
	var characterIconXList:Array<Float> = [];
	var offset:Int = 1000;
	var intendedColor:FlxColor;

	override function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Menus", null);
		#end
		persistentUpdate = true;

		trace(ClientPrefs.data.languages);
		if (FileSystem.exists('assets/shared/data/languages/' + ClientPrefs.data.language + '/text/credits.txt'))
		{
			creditList = [];
			var content = File.getContent('assets/shared/data/languages/' + ClientPrefs.data.language + '/text/credits.txt');
            var lines = content.split('\n');
			for (line in lines) {
                var trimmed = StringTools.trim(line);
                if (trimmed == '') continue;
                var parts = trimmed.split('::');
                if (parts.length < 5) {
                    continue;
                }
                creditList.push([parts[0], parts[1], parts[2], parts[3], parts[4], parts[5]]);
            }
		}

		bg = new FlxSprite().loadGraphic(Paths.image('menu/menuDesat', 'vocaloid'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();

		characterText = new FlxText(0, 100, FlxG.width, '', 38);
		characterText.setFormat(Paths.font('vcr.ttf'), 38, FlxColor.BLACK, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		characterText.screenCenter(X);
		add(characterText);

		for (i in 0...creditList.length)
		{
			trace(creditList[i][1]);
			var icon:FlxSprite = new FlxSprite(565 + (i * offset), 200).loadGraphic(Paths.image('credits/' + creditList[i][1], 'vocaloid'));
			icon.antialiasing = ClientPrefs.data.antialiasing;
			icon.setGraphicSize(150);
        	icon.updateHitbox();
			add(icon);
			characterIconList.push(icon);
			characterIconXList.push(icon.x);
		}

		desBG = new FlxSprite(0, 400).makeGraphic(1, 1, 0xFF85E1F1);
		desBG.screenCenter(X);
		desBG.alpha = 0.5;
		add(desBG);

		desText = new FlxText(0, 400, FlxG.width, '', 26);
		desText.setFormat(Paths.font('vcr.ttf'), 26, FlxColor.BLACK, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		desText.screenCenter(X);
		add(desText);

		var bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0.6;
		add(bottomBG);

		var leText:String = OeTools.getJsonData("Main", "credits_tips");
		var size:Int = 16;
		var bottomText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, leText, size);
		bottomText.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER);
		bottomText.scrollFactor.set();
		add(bottomText);

		FlxG.sound.play(Paths.returnSound('sounds/scrollMenu', 'vocaloid'));
		characterText.text = creditList[curSelected][0];
		desText.text = creditList[curSelected][2];
		desText.screenCenter(X);
		desBG.setGraphicSize(Std.parseFloat(creditList[curSelected][5]), desText.height + 10);
		desBG.updateHitbox();
		desBG.y = desText.y-5;
		desBG.screenCenter(X);
		var newColor:FlxColor = CoolUtil.colorFromString(creditList[curSelected][4]);
		if(newColor != intendedColor)
		{
			intendedColor = newColor;
			FlxTween.cancelTweensOf(bg);
			FlxTween.color(bg, 0.2, bg.color, intendedColor);
		}
		super.create();
		
		addTouchPad('LEFT_RIGHT', 'A_B');
	}
	override function update(time:Float)
	{
		if (controls.BACK)
		{
			persistentUpdate = false;
			MusicBeatState.switchState(new states.MainMenuState());
		}
		if (controls.UI_LEFT_P || FlxG.mouse.wheel >= 1)
		{
			if (creditList != null){
				if (curSelected > 0){
					FlxG.sound.play(Paths.returnSound('sounds/scrollMenu', 'vocaloid'));
					curSelected -= 1;
				}else{
					FlxG.sound.play(Paths.returnSound('sounds/scrollMenu', 'vocaloid'));
					curSelected = creditList.length-1;
				}
			}
			if(tweenList != null) {
				for (i in tweenList)
				{
					i.cancel();
				}
			}
			tweenList = [];
			for (i in 0...characterIconList.length)
			{
				var tween:FlxTween = FlxTween.tween(characterIconList[i],{x:((characterIconXList[i]) - ((curSelected) * offset))},0.7,{ease: FlxEase.expoOut});
				tweenList.push(tween);
			}
			characterText.text = creditList[curSelected][0];
			characterText.screenCenter(X);
			var newColor:FlxColor = CoolUtil.colorFromString(creditList[curSelected][4]);
			if(newColor != intendedColor)
			{
				intendedColor = newColor;
				FlxTween.cancelTweensOf(bg);
				FlxTween.color(bg, 0.2, bg.color, intendedColor);
			}
			desText.text = creditList[curSelected][2];
			desText.screenCenter(X);
			desBG.setGraphicSize(Std.parseFloat(creditList[curSelected][5]), desText.height + 10);
			desBG.updateHitbox();
			desBG.y = desText.y-5;
			desBG.screenCenter(X);
		}
		if (controls.UI_RIGHT_P || FlxG.mouse.wheel <= -1)
		{
			if (creditList != null){
				if (curSelected < (creditList.length-1)){
					FlxG.sound.play(Paths.returnSound('sounds/scrollMenu', 'vocaloid'));
					curSelected += 1;
				}else{
					FlxG.sound.play(Paths.returnSound('sounds/scrollMenu', 'vocaloid'));
					curSelected = 0;
				}
			}
			if(tweenList != null) {
				for (i in tweenList)
				{
					i.cancel();
				}
			}
			tweenList = [];
			for (i in 0...characterIconList.length)
			{
				var tween:FlxTween = FlxTween.tween(characterIconList[i],{x:((characterIconXList[i]) - ((curSelected) * offset))},0.7,{ease: FlxEase.expoOut});
				tweenList.push(tween);
			}
			characterText.text = creditList[curSelected][0];
			characterText.screenCenter(X);
			var newColor:FlxColor = CoolUtil.colorFromString(creditList[curSelected][4]);
			if(newColor != intendedColor)
			{
				intendedColor = newColor;
				FlxTween.cancelTweensOf(bg);
				FlxTween.color(bg, 0.2, bg.color, intendedColor);
			}
			desText.text = creditList[curSelected][2];
			desText.screenCenter(X);
			desBG.setGraphicSize(Std.parseFloat(creditList[curSelected][5]), desText.height + 10);
			desBG.updateHitbox();
			desBG.y = desText.y-5;
			desBG.screenCenter(X);
		}
		if (controls.ACCEPT)
		{
			CoolUtil.browserLoad(creditList[curSelected][3]);
		}
		super.update(time);
	}
}
