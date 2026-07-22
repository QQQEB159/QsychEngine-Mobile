package options;

import oecodes.OeTools;

class GameplaySettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = OeTools.getJsonData('Main', 'titleText_gamePlay');
		rpcTitle = 'Gameplay Settings Menu'; //for Discord Rich Presence

		//I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option(OeTools.getJsonData('Main', 'option_downscroll'), //Name
			OeTools.getJsonData('Main', 'options_gameplay_downscroll_tip'), //Description
			'downScroll', //Save data variable name
			BOOL); //Variable type
		addOption(option);

		var option:Option = new Option(OeTools.getJsonData('Main', 'option_middlescroll'),
			OeTools.getJsonData('Main', 'options_gameplay_middlescroll_tip'),
			'middleScroll',
			BOOL);
		addOption(option);

		var option:Option = new Option(OeTools.getJsonData('Main', 'option_opponentstrums'),
			OeTools.getJsonData('Main', 'options_gameplay_opponent_notes_tip'),
			'opponentStrums',
			BOOL);
		addOption(option);
		
		var option:Option = new Option(OeTools.getJsonData('Main', 'option_autopause'),
			OeTools.getJsonData('Main', 'options_gameplay_autopause_tip'),
			'autoPause',
			BOOL);
		addOption(option);
		option.onChange = onChangeAutoPause;

		var option:Option = new Option(OeTools.getJsonData('Main', 'option_noreset'),
			OeTools.getJsonData('Main', 'options_gameplay_disable_reset_button_tip'),
			'noReset',
			BOOL);
		addOption(option);

		var option:Option = new Option(OeTools.getJsonData('Main', 'option_saon'),
			OeTools.getJsonData('Main', 'options_gameplay_saon_tip'),
			'guitarHeroSustains',
			BOOL);
		addOption(option);

		var option:Option = new Option(OeTools.getJsonData('Main', 'option_hitsound'),
			OeTools.getJsonData('Main', 'options_gameplay_hitsound_tip'),
			'hitsoundVolume',
			PERCENT);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = onChangeHitsoundVolume;

		var option:Option = new Option(OeTools.getJsonData('Main', 'option_ratingoffset'),
			OeTools.getJsonData('Main', 'options_gameplay_rating_offset_tip'),
			'ratingOffset',
			INT);
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		var option:Option = new Option(OeTools.getJsonData('Main', 'option_sickoffset'),
			OeTools.getJsonData('Main', 'options_gameplay_sick_offset_tip'),
			'sickWindow',
			FLOAT);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 15.0;
		option.maxValue = 45.0;
		option.changeValue = 0.1;
		addOption(option);

		var option:Option = new Option(OeTools.getJsonData('Main', 'option_goodoffset'),
			OeTools.getJsonData('Main', 'options_gameplay_good_offset_tip'),
			'goodWindow',
			FLOAT);
		option.displayFormat = '%vms';
		option.scrollSpeed = 30;
		option.minValue = 15.0;
		option.maxValue = 90.0;
		option.changeValue = 0.1;
		addOption(option);

		var option:Option = new Option(OeTools.getJsonData('Main', 'option_badoffset'),
			OeTools.getJsonData('Main', 'options_gameplay_bad_offset_tip'),
			'badWindow',
			FLOAT);
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = 15.0;
		option.maxValue = 135.0;
		option.changeValue = 0.1;
		addOption(option);

		var option:Option = new Option(OeTools.getJsonData('Main', 'option_safeframes'),
			OeTools.getJsonData('Main', 'options_gameplay_safe_frames_tip'),
			'safeFrames',
			FLOAT);
		option.scrollSpeed = 5;
		option.minValue = 2;
		option.maxValue = 10;
		option.changeValue = 0.1;
		addOption(option);

		super();
	}

	function onChangeHitsoundVolume()
		FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.data.hitsoundVolume);

	function onChangeAutoPause()
		FlxG.autoPause = ClientPrefs.data.autoPause;
}
