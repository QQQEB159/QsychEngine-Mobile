package options;

import haxe.Json;
import oecodes.OeTools;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

class LanguagesState extends MusicBeatState
{
    var bg:FlxSprite;
    var langImage:FlxSprite;
    var langText:FlxText;
	var curLang:Int = 0;
    var intendedColor:FlxColor;
	public static var languageList:Array<Array<String>> = [
		['zh_cn', 'zh_cn', 'all.ttf', '简体中文 (中国大陆)', '0xFFFF0000'],
		['en_us', 'en_us', 'mc.ttf', 'English (US)', '0xFF00FFFF']
	];
	public static var jsonData:Dynamic;
	override public function create()
	{
		super.create();

        loadLanguage();
        curLang = checkLanguagesNum();

        bg = new FlxSprite().loadGraphic(Paths.image('menu/menuDesat', 'vocaloid'));
		bg.color = CoolUtil.colorFromString(languageList[curLang][4]);
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0xA6C7C7C7, 0x0));
		grid.velocity.set(-40, -40);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 0.5}, 1, {ease: FlxEase.quadOut});
		add(grid);

        langImage = new FlxSprite().loadGraphic(Paths.getPath('data/languages/' + languageList[curLang][1] + '/icon.png', IMAGE, 'shared', false));
        langImage.setGraphicSize(300, 200);
        langImage.updateHitbox();
        langImage.screenCenter();
        add(langImage);

        langText = new FlxText(0, 100, FlxG.width, languageList[curLang][3], 32);
		langText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        langText.screenCenter(X);
		add(langText);

        var bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0.6;
		add(bottomBG);

		var leText:String = OeTools.getJsonData("Main", "languages_tips");
		var size:Int = 16;
		var bottomText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, leText, size);
		bottomText.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER);
		bottomText.scrollFactor.set();
		add(bottomText);
		
		addTouchPad('LEFT_RIGHT', 'A_B');
	}
    override public function update(time:Float)
    {
        super.update(time);
        if (controls.BACK)
		{
			MusicBeatState.switchState(new options.OptionsState());
		}
		if (controls.UI_LEFT_P || FlxG.mouse.wheel >= 1)
		{
			if (languageList != null){
				if (curLang > 0){
					FlxG.sound.play(Paths.returnSound('sounds/scrollMenu', 'vocaloid'));
					curLang -= 1;
				}else{
					FlxG.sound.play(Paths.returnSound('sounds/scrollMenu', 'vocaloid'));
					curLang = languageList.length-1;
				}
			}
            langImage.loadGraphic(Paths.getPath('data/languages/' + languageList[curLang][1] + '/icon.png', IMAGE, 'shared', false));
            langImage.setGraphicSize(300, 200);
            langImage.updateHitbox();
            langImage.screenCenter();
			langText.text = languageList[curLang][3];
			langText.screenCenter(X);
			var newColor:FlxColor = CoolUtil.colorFromString(languageList[curLang][4]);
			if(newColor != intendedColor)
			{
				intendedColor = newColor;
				FlxTween.cancelTweensOf(bg);
				FlxTween.color(bg, 0.2, bg.color, intendedColor);
			}
		}
        if (controls.UI_RIGHT_P || FlxG.mouse.wheel <= -1)
		{
			if (languageList != null){
				if (curLang < languageList.length-1){
					FlxG.sound.play(Paths.returnSound('sounds/scrollMenu', 'vocaloid'));
					curLang += 1;
				}else{
					FlxG.sound.play(Paths.returnSound('sounds/scrollMenu', 'vocaloid'));
					curLang = 0;
				}
			}
            langImage.loadGraphic(Paths.getPath('data/languages/' + languageList[curLang][1] + '/icon.png', IMAGE, 'shared', false));
            langImage.setGraphicSize(300, 200);
            langImage.updateHitbox();
            langImage.screenCenter();
			langText.text = languageList[curLang][3];
			langText.screenCenter(X);
			var newColor:FlxColor = CoolUtil.colorFromString(languageList[curLang][4]);
			if(newColor != intendedColor)
			{
				intendedColor = newColor;
				FlxTween.cancelTweensOf(bg);
				FlxTween.color(bg, 0.2, bg.color, intendedColor);
			}
		}
        if (controls.ACCEPT)
        {
            ClientPrefs.data.language = languageList[curLang][0];
            MusicBeatState.switchState(new options.OptionsState());
        }
    }
	public static function loadLanguage()
	{
		if(FileSystem.exists('assets/shared/data/languages/languageList.json'))
		{
			jsonData = Json.parse(File.getContent('assets/shared/data/languages/languageList.json'));
			languageList = [];

			var keys = Reflect.fields(jsonData);
			for (key in keys)
			{
				var entry = Reflect.field(jsonData, key);
				var file = Reflect.field(entry, 'file');
				var font = Reflect.field(entry, 'fontFile');
				var name = Reflect.field(entry, 'name');
                var color = Reflect.field(entry, 'color');
				languageList.push([key, file, font, name, color]);
			}
		}
	}
    function checkLanguagesNum()
	{
		var returnData:Int = 0;
		for (i in 0...languageList.length)
		{
			if (ClientPrefs.data.language == languageList[i][1])
			{
				returnData = i;
				break;
			}
		}
		return returnData;
	}
}
