package oecodes;

import flixel.FlxObject;
import haxe.Json;
import Reflect;
import backend.Mods;
#if TRANSLATIONS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end

class OeTools
{
    public static function centerXY(object:FlxObject, centerType:String, value:Int)//直接从我的引擎搬过来的(
    {
        if (centerType == 'x')
        {
            object.x = value - object.width / 2;
        }
        else
        {
            object.y = value - object.height / 2;
        }
    }

    public static var jsonPath:String;
	public static var jsonData:Dynamic;
    public static var jsonReturnData:Dynamic;
    public static function getJsonData(type:String, name:String, ?route:String)//直接从我的引擎搬过来的(
    {
        #if TRANSLATIONS_ALLOWED
		if (type == 'Main') 
		{
			jsonPath = 'data/languages/' + ClientPrefs.data.language + '/text/game.json';
			#if MODS_ALLOWED
			if(FileSystem.exists('mods/' + Mods.currentModDirectory + '/' + jsonPath))
			{
				jsonData = Json.parse(File.getContent('mods/' + Mods.currentModDirectory + '/' + jsonPath));
				if (Reflect.field(jsonData, name) != null)
				{
					jsonReturnData = Reflect.field(jsonData, name);
				}else{
					if(FileSystem.exists('assets/shared/' + jsonPath))
					{
						jsonData = Json.parse(Paths.getTextFromFile(jsonPath, true));
						if (Reflect.field(jsonData, name) != null)
						{
							jsonReturnData = Reflect.field(jsonData, name);
						}else{
							jsonReturnData = name;
						}
					}else{
						jsonReturnData = name;
					}
				}
			}else{
				if(FileSystem.exists('assets/shared/' + jsonPath))
				{
					jsonData = Json.parse(Paths.getTextFromFile(jsonPath, true));
					if (Reflect.field(jsonData, name) != null)
					{
						jsonReturnData = Reflect.field(jsonData, name);
					}else{
						jsonReturnData = name;
					}
				}else{
					jsonReturnData = name;
				}
			}
			#else
			if(FileSystem.exists('assets/shared/' + jsonPath))
			{
				jsonData = Json.parse(Paths.getTextFromFile(jsonPath, true));
				if (Reflect.field(jsonData, name) != null)
				{
					jsonReturnData = Reflect.field(jsonData, name);
				}else{
					jsonReturnData = name;
				}
			}else{
				jsonReturnData = name;
			}
			#end
		}
        else if (type == 'FreeplaySongName')
		{
			jsonPath = 'data/languages/${ClientPrefs.data.language}/text/songMeta.json';
			#if MODS_ALLOWED
			if(FileSystem.exists('mods/' + Mods.currentModDirectory + '/' + jsonPath))
			{
				jsonData = Json.parse(File.getContent('mods/' + Mods.currentModDirectory + '/' + jsonPath));
				if (Reflect.field(jsonData, name) != null)
				{
					var songJson:Dynamic = Reflect.field(jsonData, name);
					if (Reflect.field(songJson, "songName") != null)
					{
						jsonReturnData = Reflect.field(songJson, "songName");
					}else{
						if(FileSystem.exists('assets/shared/' + jsonPath))
						{
							jsonData = Json.parse(Paths.getTextFromFile(jsonPath, true));
							if (Reflect.field(jsonData, PlayState.SONG.song) != null)
							{
								var songJson:Dynamic = Reflect.field(jsonData, name);
								if (Reflect.field(songJson, "songName") != null)
								{
									jsonReturnData = Reflect.field(songJson, "songName");
								}else{
									jsonReturnData = name;
								}
							}else{
								jsonReturnData = name;
							}
						}else{
							jsonReturnData = name;
						}
					}
				}else{
					if(FileSystem.exists('assets/shared/' + jsonPath))
					{
						jsonData = Json.parse(Paths.getTextFromFile(jsonPath, true));
						if (Reflect.field(jsonData, name) != null)
						{
							var songJson:Dynamic = Reflect.field(jsonData, name);
							if (Reflect.field(songJson, "songName") != null)
							{
								jsonReturnData = Reflect.field(songJson, "songName");
							}else{
								jsonReturnData = name;
							}
						}else{
							jsonReturnData = name;
						}
					}else{
						jsonReturnData = name;
					}
				}
			}else{
				if(FileSystem.exists('assets/shared/' + jsonPath))
				{
					jsonData = Json.parse(Paths.getTextFromFile(jsonPath, true));
					if (Reflect.field(jsonData, name) != null)
					{
						var songJson:Dynamic = Reflect.field(jsonData, name);
						if (Reflect.field(songJson, "songName") != null)
						{
							jsonReturnData = Reflect.field(songJson, "songName");
						}else{
							jsonReturnData = name;
						}
					}else{
						jsonReturnData = name;
					}
				}else{
					jsonReturnData = name;
				}
			}
			#else
			if(FileSystem.exists('assets/shared/' + jsonPath))
			{
				jsonData = Json.parse(Paths.getTextFromFile(jsonPath, true));
				if (Reflect.field(jsonData, name) != null)
				{
					var songJson:Dynamic = Reflect.field(jsonData, name);
					if (Reflect.field(songJson, "songName") != null)
					{
						jsonReturnData = Reflect.field(songJson, "songName");
					}else{
						jsonReturnData = name;
					}
				}else{
					jsonReturnData = name;
				}
			}else{
				jsonReturnData = name;
			}
			#end
		}
		else if (type == 'FreeplayComposer')
		{
			jsonPath = 'data/languages/${ClientPrefs.data.language}/text/songMeta.json';
			#if MODS_ALLOWED
			if(FileSystem.exists('mods/' + Mods.currentModDirectory + '/' + jsonPath))
			{
				jsonData = Json.parse(File.getContent('mods/' + Mods.currentModDirectory + '/' + jsonPath));
				if (Reflect.field(jsonData, name) != null)
				{
					var songJson:Dynamic = Reflect.field(jsonData, name);
					if (Reflect.field(songJson, "composer") != null)
					{
						jsonReturnData = Reflect.field(songJson, "composer");
					}else{
						if(FileSystem.exists('assets/shared/' + jsonPath))
						{
							jsonData = Json.parse(Paths.getTextFromFile(jsonPath, true));
							if (Reflect.field(jsonData, PlayState.SONG.song) != null)
							{
								var songJson:Dynamic = Reflect.field(jsonData, name);
								if (Reflect.field(songJson, "composer") != null)
								{
									jsonReturnData = Reflect.field(songJson, "composer");
								}else{
									jsonReturnData = name;
								}
							}else{
								jsonReturnData = name;
							}
						}else{
							jsonReturnData = name;
						}
					}
				}else{
					if(FileSystem.exists('assets/shared/' + jsonPath))
					{
						jsonData = Json.parse(Paths.getTextFromFile(jsonPath, true));
						if (Reflect.field(jsonData, name) != null)
						{
							var songJson:Dynamic = Reflect.field(jsonData, name);
							if (Reflect.field(songJson, "composer") != null)
							{
								jsonReturnData = Reflect.field(songJson, "composer");
							}else{
								jsonReturnData = name;
							}
						}else{
							jsonReturnData = name;
						}
					}else{
						jsonReturnData = name;
					}
				}
			}else{
				if(FileSystem.exists('assets/shared/' + jsonPath))
				{
					jsonData = Json.parse(Paths.getTextFromFile(jsonPath, true));
					if (Reflect.field(jsonData, name) != null)
					{
						var songJson:Dynamic = Reflect.field(jsonData, name);
						if (Reflect.field(songJson, "composer") != null)
						{
							jsonReturnData = Reflect.field(songJson, "composer");
						}else{
							jsonReturnData = name;
						}
					}else{
						jsonReturnData = name;
					}
				}else{
					jsonReturnData = name;
				}
			}
			#else
			if(FileSystem.exists('assets/shared/' + jsonPath))
			{
				jsonData = Json.parse(Paths.getTextFromFile(jsonPath, true));
				if (Reflect.field(jsonData, name) != null)
				{
					var songJson:Dynamic = Reflect.field(jsonData, name);
					if (Reflect.field(songJson, "composer") != null)
					{
						jsonReturnData = Reflect.field(songJson, "composer");
					}else{
						jsonReturnData = name;
					}
				}else{
					jsonReturnData = name;
				}
			}else{
				jsonReturnData = name;
			}
			#end
		}
        #end
        return jsonReturnData;
    }
	public static function getLanguageImagePath(path:String, defPath:String):String {
		#if TRANSLATIONS_ALLOWED
			var lang:String = ClientPrefs.data.language;
			var basePaths:Array<String> = [];
			#if MODS_ALLOWED
				if (Mods.currentModDirectory != null) {
					basePaths.push('mods/${Mods.currentModDirectory}/data/languages/$lang/imagePath/path.txt');
				}
			#end
			basePaths.push('assets/shared/data/languages/$lang/imagePath/path.txt');

			for (filePath in basePaths) {
				if (FileSystem.exists(filePath)) {
					try {
						var content:String = File.getContent(filePath);
						var map:Map<String, String> = parsePathFile(content);
						if (map.exists(path)) {
							return map[path];
						}
					} catch (e:Dynamic) {

					}
				}
			}
		#end
		return defPath;
	}

	static function parsePathFile(content:String):Map<String, String> {
		var map = new Map<String, String>();
		for (line in content.split('\n')) {
			line = line.trim();
			if (line == '') continue;
			var parts = line.split('::');
			if (parts.length >= 2) {
				map[parts[0].trim()] = parts[1].trim();
			}
		}
		return map;
	}
}