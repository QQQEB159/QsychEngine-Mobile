package mobile.options;

import flixel.input.keyboard.FlxKey;
import options.BaseOptionsMenu;
import options.Option;

import oecodes.OeTools;

class MobileOptionsSubState extends BaseOptionsMenu
{
	#if android
	var storageTypes:Array<String> = ["EXTERNAL_DATA", "EXTERNAL_OBB", "EXTERNAL_MEDIA", "EXTERNAL"];
	var externalPaths:Array<String> = StorageUtil.checkExternalPaths(true);
	final lastStorageType:String = ClientPrefs.data.storageType;
	#end
	final exControlTypes:Array<String> = ["NONE", "SINGLE", "DOUBLE"];
	final hintOptions:Array<String> = ["No Gradient", "No Gradient (Old)", "Gradient", "Hidden"];
	var option:Option;

	public function new()
	{
		#if android if (!externalPaths.contains('\n'))
			storageTypes = storageTypes.concat(externalPaths); #end
		title = 'Mobile Options';
		rpcTitle = 'Mobile Options Menu'; // for Discord Rich Presence, fuck it

		option = new Option(OeTools.getJsonData('Main', 'option_controlsAlpha'),
			OeTools.getJsonData('Main', 'option_controlsAlpha_tip'), PERCENT);
		option.scrollSpeed = 1;
		option.minValue = 0.001;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = () ->
		{
			touchPad.alpha = curOption.getValue();
			ClientPrefs.toggleVolumeKeys();
		};
		addOption(option);

		#if mobile
		option = new Option(OeTools.getJsonData('Main', 'option_screensaver'),
			OeTools.getJsonData('Main', 'option_screensaver_tip'), 'screensaver', BOOL);
		option.onChange = () -> lime.system.System.allowScreenTimeout = curOption.getValue();
		addOption(option);
		#end

		if (MobileData.mode == 3)
		{
			option = new Option(OeTools.getJsonData('Main', 'option_hitboxType'), OeTools.getJsonData('Main', 'option_hitboxType_tip'), 'hitboxType', STRING, hintOptions);
			addOption(option);

			/* option = new Option(OeTools.getJsonData('Main', 'option_hitboxPos'), OeTools.getJsonData('Main', 'option_hitboxPos_tip'),
				'hitboxPos', BOOL);
			addOption(option); */
		}

		/* option = new Option(OeTools.getJsonData('Main', 'option_dynamicColors'),
			OeTools.getJsonData('Main', 'option_dynamicColors_tip'), 'dynamicColors',
			BOOL);
		addOption(option); */

		#if android
		option = new Option(OeTools.getJsonData('Main', 'option_storageType'), OeTools.getJsonData('Main', 'option_storageType_tip'), 'storageType', STRING,
			storageTypes);
		addOption(option);
		#end

		super();
	}

	#if android
	function onStorageChange():Void
	{
		File.saveContent(lime.system.System.applicationStorageDirectory + 'storagetype.txt', ClientPrefs.data.storageType);

		var lastStoragePath:String = StorageType.fromStrForce(lastStorageType) + '/';

		try
		{
			if (ClientPrefs.data.storageType != "EXTERNAL")
				Sys.command('rm', ['-rf', lastStoragePath]);
		}
		catch (e:haxe.Exception)
			trace('Failed to remove last directory. (${e.message})');
	}
	#end

	override public function destroy()
	{
		super.destroy();
		#if android
		if (ClientPrefs.data.storageType != lastStorageType)
		{
			onStorageChange();
			CoolUtil.showPopUp(Language.getPhrase('storage_type_change_message', 'Storage Type has been changed and you need restart the game!!\nPress OK to close the game.'), Language.getPhrase('mobile_notice', 'Notice!'));
			lime.system.System.exit(0);
		}
		#end
	}
}