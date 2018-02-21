class Helpers_SkyrangerSkins extends Object config(SkyrangerSkins);

var localized string strCustomizeSkyranger;


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