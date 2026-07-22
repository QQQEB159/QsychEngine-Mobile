package states;

import openfl.filters.BlurFilter;
import oecodes.OeTools;

class ReadySongState extends MusicBeatState
{
    var camBG:FlxCamera;
    var camUI:FlxCamera;
    var bg:FlxSprite;
    var songImage:FlxSprite;
    var songName:FlxText;
    var pressAnyKey:FlxText;
    public static var bgPath:String = '';
    public static var songNamePath:String = '';
    public static var composerPath:String = '';
    override function create()
    {
        camBG = initPsychCamera();
        camUI = new FlxCamera();
		camUI.bgColor.alpha = 0;
		FlxG.cameras.add(camUI, false);

        bg = new FlxSprite().loadGraphic(Paths.image('week/' + bgPath));
		bg.antialiasing = ClientPrefs.data.antialiasing;
        bg.setGraphicSize(FlxG.width + 100);
		bg.updateHitbox();
		bg.screenCenter();
        bg.alpha = 0.5;
        bg.cameras = [camBG];
        add(bg);

        songImage = new FlxSprite().loadGraphic(Paths.image('week/' + bgPath));
        songImage.setGraphicSize(300);
        songImage.updateHitbox();
        songImage.screenCenter();
        songImage.cameras = [camUI];
        add(songImage);

        songName = new FlxText(0, songImage.y + songImage.height + 20, FlxG.width, songNamePath + '\n' + composerPath, 32);
		songName.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        songName.screenCenter(X);
        songName.cameras = [camUI];
		add(songName);

        pressAnyKey = new FlxText(0, FlxG.height - 80, FlxG.width, OeTools.getJsonData("Main", 'readySongTips'), 32);
		pressAnyKey.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        pressAnyKey.screenCenter(X);
        pressAnyKey.cameras = [camUI];
		add(pressAnyKey);

        var blurFilter:BlurFilter = new BlurFilter(20, 20, 1);
        camBG.filters = [blurFilter];
        super.create();
    }

    override function update(time:Float)
    {
        if (FlxG.keys.justPressed.ANY || TouchUtil.justPressed)
        {
            LoadingState.prepareToSong();
			MusicBeatState.switchState(new PlayState());
        }
        super.update(time);
    }
}