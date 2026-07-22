package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import objects.HealthIcon;
import objects.MusicPlayer;

import options.GameplayChangersSubstate;
import substates.ResetScoreSubState;

import flixel.math.FlxMath;
import flixel.util.FlxDestroyUtil;

import openfl.utils.Assets;

import haxe.Json;

import oecodes.OeTools;
import flixel.FlxSubState;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var lerpSelected:Float = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = Difficulty.getDefault();

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<FlxText>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	var bottomString:String;
	var bottomText:FlxText;
	var bottomBG:FlxSprite;

	var player:MusicPlayer;

	var songBGList:FlxTypedGroup<FlxSprite>;
	public static var tweenList:Array<FlxTween> = [];
	var tetoa:FlxSprite;
	var tetoaAngleTween:FlxTween;
	var tetoaNextAngle:Int = 0;
	var songImage:FlxSprite;
	var songImageTween:FlxTween;
	var scoreJsonData:String = OeTools.getJsonData("Main", "freeplay_score");

	override function create()
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if(WeekData.weeksList.length < 1)
		{
			FlxTransitionableState.skipNextTransIn = true;
			persistentUpdate = false;
			MusicBeatState.switchState(new states.ErrorState("NO WEEKS ADDED FOR FREEPLAY\n\nPress ACCEPT to go to the Week Editor Menu.\nPress BACK to return to Main Menu.",
				function() MusicBeatState.switchState(new states.editors.WeekEditorState()),
				function() MusicBeatState.switchState(new states.MainMenuState())));
			return;
		}

		for (i in 0...WeekData.weeksList.length)
		{
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]), leWeek.image);
			}
		}

		bg = new FlxSprite().loadGraphic(Paths.image('menu/menuDesat', 'vocaloid'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();

		tetoa = new FlxSprite(1000, 0).loadGraphic(Paths.image('freeplay/tetoa', 'vocaloid'));
		tetoa.antialiasing = ClientPrefs.data.antialiasing;
		tetoa.screenCenter(Y);
		add(tetoa);

		songImage = new FlxSprite(100, 80);
		songImage.antialiasing = ClientPrefs.data.antialiasing;
		add(songImage);

		songBGList = new FlxTypedGroup<FlxSprite>();
		add(songBGList);

		grpSongs = new FlxTypedGroup<FlxText>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var bg:FlxSprite = new FlxSprite();
			bg.frames = Paths.getSparrowAtlas('freeplay/button', 'vocaloid');
			bg.animation.addByPrefix('idle', 'button_deselected', 24, true);
			bg.animation.addByPrefix('selected', 'button_selected', 24, true);
			bg.animation.play('idle');
			bg.updateHitbox();
			bg.antialiasing = ClientPrefs.data.antialiasing;
			songBGList.add(bg);

			var songText:FlxText = new FlxText(900, 320 + (i * 70), 0, OeTools.getJsonData('FreeplaySongName', songs[i].songName), 38);
			songText.setFormat(Paths.font('vcr.ttf'), 38, FlxColor.BLACK, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
			songText.y = i - curSelected;
			songText.alpha = 0;
			songText.antialiasing = ClientPrefs.data.antialiasing;
			OeTools.centerXY(songText, 'x', 910);
			grpSongs.add(songText);

			Mods.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);
		}
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);


		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;
		lerpSelected = curSelected;

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0.6;
		add(bottomBG);

		var leText:String = OeTools.getJsonData("Main", "freeplay_tips");
		bottomString = leText;
		var size:Int = 16;
		bottomText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, leText, size);
		bottomText.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER);
		bottomText.scrollFactor.set();
		add(bottomText);
		
		player = new MusicPlayer(this);
		add(player);
		
		changeSelection();
		updateTexts();
		super.create();
		
		addTouchPad('LEFT_FULL', 'A_B_C_X_Y_Z');
	}

	override function closeSubState()
	{
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
		removeTouchPad();
		addTouchPad('LEFT_FULL', 'A_B_C_X_Y_Z');
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, songImage:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color, songImage));
	}

	function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	public static var opponentVocals:FlxSound = null;
	var holdTime:Float = 0;

	var stopMusicPlay:Bool = false;
	override function update(elapsed:Float)
	{
		if(WeekData.weeksList.length < 1)
			return;

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * elapsed;

		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
		lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) //No decimals, add an empty space
			ratingSplit.push('');
		
		while(ratingSplit[1].length < 2) //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT || touchPad.buttonZ.pressed) shiftMult = 3;

		if (!player.playingMusic)
		{
			scoreText.text = scoreJsonData + lerpScore + " (" + ratingSplit.join('.') + "%)";
			positionHighscore();
			
			if(songs.length > 1)
			{
				if(FlxG.keys.justPressed.HOME)
				{
					curSelected = 0;
					changeSelection();
					holdTime = 0;	
				}
				else if(FlxG.keys.justPressed.END)
				{
					curSelected = songs.length - 1;
					changeSelection();
					holdTime = 0;	
				}
				if (controls.UI_UP_P)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (controls.UI_DOWN_P)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
				}

				if(FlxG.mouse.wheel != 0)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
					changeSelection(-shiftMult * FlxG.mouse.wheel, false);
				}
			}

			if (controls.UI_LEFT_P)
			{
				changeDiff(-1);
				_updateSongLastDifficulty();
			}
			else if (controls.UI_RIGHT_P)
			{
				changeDiff(1);
				_updateSongLastDifficulty();
			}
		}

		if (controls.BACK)
		{
			if (player.playingMusic)
			{
				FlxG.sound.music.stop();
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				instPlaying = -1;

				player.playingMusic = false;
				player.switchPlayMusic();

				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);
			}
			else 
			{
				persistentUpdate = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
		}

		if((FlxG.keys.justPressed.CONTROL || touchPad.buttonC.justPressed && touchPad != null) && !player.playingMusic)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
			removeTouchPad();
		}
		else if(FlxG.keys.justPressed.SPACE || touchPad.buttonX.justPressed && touchPad != null)
		{
			if(instPlaying != curSelected && !player.playingMusic)
			{
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;

				Mods.currentModDirectory = songs[curSelected].folder;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				if (PlayState.SONG.needsVoices)
				{
					vocals = new FlxSound();
					try
					{
						var playerVocals:String = getVocalFromCharacter(PlayState.SONG.player1);
						var loadedVocals = Paths.voices(PlayState.SONG.song, (playerVocals != null && playerVocals.length > 0) ? playerVocals : 'Player');
						if(loadedVocals == null) loadedVocals = Paths.voices(PlayState.SONG.song);
						
						if(loadedVocals != null && loadedVocals.length > 0)
						{
							vocals.loadEmbedded(loadedVocals);
							FlxG.sound.list.add(vocals);
							vocals.persist = vocals.looped = true;
							vocals.volume = 0.8;
							vocals.play();
							vocals.pause();
						}
						else vocals = FlxDestroyUtil.destroy(vocals);
					}
					catch(e:Dynamic)
					{
						vocals = FlxDestroyUtil.destroy(vocals);
					}
					
					opponentVocals = new FlxSound();
					try
					{
						//trace('please work...');
						var oppVocals:String = getVocalFromCharacter(PlayState.SONG.player2);
						var loadedVocals = Paths.voices(PlayState.SONG.song, (oppVocals != null && oppVocals.length > 0) ? oppVocals : 'Opponent');
						
						if(loadedVocals != null && loadedVocals.length > 0)
						{
							opponentVocals.loadEmbedded(loadedVocals);
							FlxG.sound.list.add(opponentVocals);
							opponentVocals.persist = opponentVocals.looped = true;
							opponentVocals.volume = 0.8;
							opponentVocals.play();
							opponentVocals.pause();
							//trace('yaaay!!');
						}
						else opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
					}
					catch(e:Dynamic)
					{
						//trace('FUUUCK');
						opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
					}
				}

				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.8);
				FlxG.sound.music.pause();
				instPlaying = curSelected;

				player.playingMusic = true;
				player.curTime = 0;
				player.switchPlayMusic();
				player.playingSongName = OeTools.getJsonData('FreeplaySongName', songs[curSelected].songName);
				player.playingComposer = OeTools.getJsonData('FreeplayComposer', songs[curSelected].songName);
				player.pauseOrResume(true);
			}
			else if (instPlaying == curSelected && player.playingMusic)
			{
				player.pauseOrResume(!player.playing);
			}
		}
		else if (controls.ACCEPT && !player.playingMusic)
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);

			try
			{
				Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			}
			catch(e:haxe.Exception)
			{
				trace('ERROR! ${e.message}');

				var errorStr:String = e.message;
				if(errorStr.contains('There is no TEXT asset with an ID of')) errorStr = 'Missing file: ' + errorStr.substring(errorStr.indexOf(songLowercase), errorStr.length-1); //Missing chart
				else errorStr += '\n\n' + e.stack;

				missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
				missingText.screenCenter(Y);
				missingText.visible = true;
				missingTextBG.visible = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));

				updateTexts(elapsed);
				super.update(elapsed);
				return;
			}

			@:privateAccess
			if(PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
			{
				trace('CHANGED MOD DIRECTORY, RELOADING STUFF');
				Paths.freeGraphicsFromMemory();
			}
			ReadySongState.bgPath = songs[curSelected].image;
			ReadySongState.songNamePath = OeTools.getJsonData('FreeplaySongName', songs[curSelected].songName);
			ReadySongState.composerPath = OeTools.getJsonData('FreeplayComposer', songs[curSelected].songName);
			MusicBeatState.switchState(new ReadySongState());
			#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
			stopMusicPlay = true;

			destroyFreeplayVocals();
			#if (MODS_ALLOWED && DISCORD_ALLOWED)
			DiscordClient.loadModRPC();
			#end
		}
		else if((controls.RESET || touchPad.buttonY.justPressed && touchPad != null) && !player.playingMusic)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			removeTouchPad();
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		updateTexts(elapsed);
		super.update(elapsed);

		if (songBGList != null && grpSongs != null && iconArray != null)
		{
			for (i in 0...songBGList.members.length)
			{
				OeTools.centerXY(songBGList.members[i], 'x', 905);
				songBGList.members[i].y = grpSongs.members[i].y - 25;

				songBGList.members[i].animation.play('idle');
				songBGList.members[curSelected].animation.play('selected');
				grpSongs.members[i].color = FlxColor.BLACK;
				grpSongs.members[i].borderColor = FlxColor.WHITE;
				grpSongs.members[curSelected].color = FlxColor.WHITE;
				grpSongs.members[curSelected].borderColor = FlxColor.WHITE;
			}
			for (i in iconArray)
			{
				OeTools.centerXY(i, 'x', 1180);
			}
		}
	}
	
	function getVocalFromCharacter(char:String)
	{
		try
		{
			var path:String = Paths.getPath('data/characters/$char.json', TEXT);
			#if MODS_ALLOWED
			var character:Dynamic = Json.parse(File.getContent(path));
			#else
			var character:Dynamic = Json.parse(Assets.getText(path));
			#end
			return character.vocals_file;
		}
		catch (e:Dynamic) {}
		return null;
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) vocals.stop();
		vocals = FlxDestroyUtil.destroy(vocals);

		if(opponentVocals != null) opponentVocals.stop();
		opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
	}

	function changeDiff(change:Int = 0)
	{
		if (player.playingMusic)
			return;

		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, Difficulty.list.length-1);
		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		lastDifficultyName = Difficulty.getString(curDifficulty, false);
		var displayDiff:String = Difficulty.getString(curDifficulty);
		if (Difficulty.list.length > 1)
			diffText.text = '< ' + displayDiff.toUpperCase() + ' >';
		else
			diffText.text = displayDiff.toUpperCase();

		positionHighscore();
		missingText.visible = false;
		missingTextBG.visible = false;
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if (player.playingMusic)
			return;

		curSelected = FlxMath.wrap(curSelected + change, 0, songs.length-1);
		_updateSongLastDifficulty();
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor)
		{
			intendedColor = newColor;
			FlxTween.cancelTweensOf(bg);
			FlxTween.color(bg, 0.5, bg.color, intendedColor);
		}

		var bullShit:Int = 0;
		if(tweenList != null) {
			for (i in tweenList)
			{
				i.cancel();
			}
		}
		tweenList = [];

		for (i in 0...grpSongs.members.length)
		{
			grpSongs.members[i].alpha = 0.6;
			var icon:HealthIcon = iconArray[i];
			icon.alpha = 0.6;
			var tween:FlxTween = FlxTween.tween(grpSongs.members[i],{y:180 - (-(bullShit - curSelected) * 125)},0.25,{ease: FlxEase.expoOut});
			tweenList.push(tween);
			bullShit++;
		}
		grpSongs.members[curSelected].alpha = 1;
		iconArray[curSelected].alpha = 1;

		if (tetoa != null)
		{
			if (tetoaAngleTween != null)
			{
				tetoaAngleTween.cancel();
				tetoaAngleTween = null;
			}
			tetoaNextAngle += 90;
			tetoaAngleTween = FlxTween.tween(tetoa, {angle:tetoa.angle+tetoaNextAngle}, 0.3, {ease: FlxEase.quartOut, onComplete:function(twn:FlxTween)
			{
				tetoaNextAngle = 0;
				tetoaAngleTween = null;
			}});
		}
		
		Mods.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;
		Difficulty.loadFromWeek();

		if (songImageTween != null)
		{
			songImageTween.cancel();
			songImageTween = null;
		}

		songImageTween = FlxTween.tween(songImage, {alpha:0}, 0.2, {onComplete:function(twn:FlxTween)
		{
			if(Paths.image('week/' + songs[curSelected].image) != null)
			{
				songImage.loadGraphic(Paths.image('week/' + songs[curSelected].image));
			}else{
				songImage.loadGraphic(Paths.image('nonono'));
			}
			songImage.setGraphicSize(370);
			songImage.updateHitbox();
			songImageTween = null;
			songImageTween = FlxTween.tween(songImage, {alpha:1}, 0.2, {onComplete:function(twn:FlxTween)
			{
				songImageTween = null;
			}});
		}});
		
		var savedDiff:String = songs[curSelected].lastDifficulty;
		var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
		if(savedDiff != null && !Difficulty.list.contains(savedDiff) && Difficulty.list.contains(savedDiff))
			curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
		else if(lastDiff > -1)
			curDifficulty = lastDiff;
		else if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		changeDiff();
		_updateSongLastDifficulty();
	}

	inline private function _updateSongLastDifficulty()
		songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty, false);

	private function positionHighscore()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}

	var _drawDistance:Int = 4;
	var _lastVisibles:Array<Int> = [];
	public function updateTexts(elapsed:Float = 0.0)
	{
		lerpSelected = FlxMath.lerp(curSelected, lerpSelected, Math.exp(-elapsed * 9.6));
		for (i in _lastVisibles)
		{
			grpSongs.members[i].visible = grpSongs.members[i].active = false;
			iconArray[i].visible = iconArray[i].active = false;
		}
		_lastVisibles = [];
	}

	override function destroy():Void
	{
		super.destroy();

		FlxG.autoPause = ClientPrefs.data.autoPause;
		if (!FlxG.sound.music.playing && !stopMusicPlay)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
	}	
	override function openSubState(SubState:FlxSubState)
	{
		if(tweenList != null) {
			for (i in tweenList)
			{
				i.active = false;
			}
		}
		super.openSubState(SubState);
	}
	public static function closeSub()
	{
		if(tweenList != null) {
			for (i in tweenList)
			{
				i.active = true;
			}
		}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var image:String = 'teto';
	public var folder:String = "";
	public var lastDifficulty:String = null;

	public function new(song:String, week:Int, songCharacter:String, color:Int, image:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.image = image;
		this.folder = Mods.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}