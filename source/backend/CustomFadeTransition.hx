package backend;

class CustomFadeTransition extends MusicBeatSubstate {
	public static var finishCallback:Void->Void;
	var blackInAndOut:FlxSprite;
	var isTransIn:Bool = false;
	var duration:Float;

	public function new(duration:Float, isTransIn:Bool)
	{
		this.duration = duration;
		this.isTransIn = isTransIn;
		super();
	}

	override function create()
	{
		blackInAndOut = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackInAndOut.screenCenter(Y);
		blackInAndOut.scrollFactor.set();
		add(blackInAndOut);

		if (!isTransIn)
		{
			//blackInAndOut.x = FlxG.width;
			//FlxTween.tween(blackInAndOut, {x:0}, duration-0.2, {ease: FlxEase.cubeInOut, onComplete:function(twn:FlxTween)
			//{
				if(finishCallback != null)
				{
					finishCallback();
					finishCallback = null;
				}
			//}});
		}
		else
		{
			//blackInAndOut.x = 0;
			FlxTween.tween(blackInAndOut, {x:-FlxG.width}, duration-0.2, {ease: FlxEase.cubeInOut, onComplete:function(twn:FlxTween)
			{
				if(finishCallback != null)
				{
					finishCallback();
					finishCallback = null;
				}
				close();
			}});
		}

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];

		super.create();
	}

	// Don't delete this
	override function close():Void
	{
		super.close();

		if(finishCallback != null)
		{
			finishCallback();
			finishCallback = null;
		}
	}
}
