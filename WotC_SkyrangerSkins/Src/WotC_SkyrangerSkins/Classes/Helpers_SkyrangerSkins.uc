class Helpers_SkyrangerSkins extends Object;

delegate SelectorOnPreviewDelegate(int Idx);
delegate SelectorOnSetDelegate(int Idx);


static function bool IsCHHLMinVersionInstalled(int iMajor, int iMinor)
{
	local X2StrategyElementTemplate VersionTemplate;

	VersionTemplate = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().FindStrategyElementTemplate('CHXComGameVersion');
	if (VersionTemplate == none)
	{
		return false;
	}
	else
	{
		// DANGER TERRITORY: if this runs without the CHHL or equivalent installed, it crashes
		// SemVer: A change in major version introduces breaking changes. However, since only one version of the Highlander can be run at a time,
		// it is far more inconvenient if this mod stopped working for no reason than if the breaking changes broke it. Hence, we allow major versions > target
		return CHXComGameVersionTemplate(VersionTemplate).MajorVersion > iMajor ||  (CHXComGameVersionTemplate(VersionTemplate).MajorVersion == iMajor && CHXComGameVersionTemplate(VersionTemplate).MinorVersion >= iMinor);
	}
}

// Ugly and slow, but works
static function FindMeshes(out array<MeshComponent> Exts, out array<MeshComponent> Ints)
{
	local WorldInfo WI;
	local SkeletalMeshActor S;
	local StaticMeshActor A;
	WI = class'WorldInfo'.static.GetWorldInfo();
	foreach WI.DynamicActors(class'SkeletalMeshActor', S)
	{
		if (InStr(PathName(S), "CIN_PostMission1", false, true) != INDEX_NONE || InStr(PathName(S), "CIN_SkyrangerIntros", false, true) != INDEX_NONE || InStr(PathName(S), "CIN_PreMission", false, true) != INDEX_NONE)
		{
			if (S.Name == 'SkeletalMeshActor_0')
			{
				Ints.AddItem(S.SkeletalMeshComponent);
			}
			else if (S.Name == 'SkeletalMeshActor_8')
			{
				Exts.AddItem(S.SkeletalMeshComponent);
			}
		}
		else if (InStr(PathName(S), "AVG_Armory", false, true) != INDEX_NONE || InStr(PathName(S), "AVG_HuntersLodge", false, true) != INDEX_NONE)
		{
			if (S.Name == 'SkeletalMeshActor_0')
			{
				Exts.AddItem(S.SkeletalMeshComponent);
			}
			else if (S.Name == 'SkeletalMeshActor_1')
			{
				Ints.AddItem(S.SkeletalMeshComponent);
			}
		}
	}
// TODO: Do we actually want this? There's also a door mesh involved here, so it doesn't work particularly great
/*
	foreach WI.AllActors(class'StaticMeshActor', A)
	{
		// This doesn't work this way for some reason
		//if (InStr(PathName(A), "CIN_Loading_Interior", false, true) != INDEX_NONE)
		if (InStr(PathName(A), "Level_", false, true) != INDEX_NONE)
		{
			if (A.Name == 'StaticMeshActor_3')
			{
				Exts.AddItem(A.StaticMeshComponent);
			}
			else if (A.Name == 'StaticMeshActor_2')
			{
				Ints.AddItem(A.StaticMeshComponent);
			}
		}
	}
*/

}

// COLORS: There is an implicit 000000 at index 0... or whatever we pass here

static function array<string> GetFlashColorList(optional string noneColor = "0x000000")
{
	local XComLinearColorPalette Palette;
	local array<string> Colors; 
	local int i; 
	
	Palette = `CONTENT.GetColorPalette(ePalette_ArmorTint);
	for( i = 0; i < Palette.Entries.length; i++ )
	{
		Colors.AddItem(class'UIUtilities_Colors'.static.LinearColorToFlashHex(Palette.Entries[i].Primary, class'XComCharacterCustomization'.default.UIColorBrightnessAdjust));
	}
	Colors.InsertItem(0, noneColor);
	return Colors;
}

static function string GetDisplayColorHTML(int ColorIndex, optional string noneColor = "0x000000")
{
	local XComLinearColorPalette Palette;

	Palette = `CONTENT.GetColorPalette(ePalette_ArmorTint);
	
	if (ColorIndex >= 0 && Palette != none)
	{
		return class'UIUtilities_Colors'.static.LinearColorToFlashHex(Palette.Entries[ColorIndex].Primary, class'XComCharacterCustomization'.default.UIColorBrightnessAdjust);
	}
	else if (ColorIndex == -1)
	{
		return noneColor;
	}
}