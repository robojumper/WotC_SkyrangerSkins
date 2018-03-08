class UICustomizeSkyranger_Main extends UICustomizeSkyranger;

// Simple state tracking so we don't end up triggering events multiple times (or skip them)
var enum ESkyrangerCustomizeScreenState
{
	eSCSS_Starting,
	eSCSS_Running,
	eSCSS_Ending,
} ScreenState;



simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	Customization = new class'XComSkyrangerCustomization';
	Customization.Init();
	super.InitScreen(InitController, InitMovie, InitName);
	`log("Title:" @ class'Helpers_SkyrangerSkins'.default.strCustomizeSkyranger);
	SetTitle(class'Helpers_SkyrangerSkins'.default.strCustomizeSkyranger);

}


simulated function OnInit()
{
	super.OnInit();
	InitKismet();
	`XCOMGRI.DoRemoteEvent('CIN_StartSkyrangerCustomization');
	ScreenState = eSCSS_Starting;
	`log("Set State to starting");
}





simulated function UpdateData()
{
	local int i;

	ResetMechaListItems();
	super.UpdateData();

	Customization.SkyrangerState.ValidateAppearance();
	Customization.PreviewVisuals();

	i = 0;

	// Material. Show only if more than one material available
	if (Customization.HasMaterialOptions())
	{
		GetListItem(i++).UpdateDataValue("Materials",
			Customization.SkyrangerState.GetMaterialsTemplate().DisplayName, OnCustomizeMaterials);
	}

	if (Customization.SkyrangerState.GetMaterialsTemplate().AllowMaterialPrimaryTinting)
	{
		GetListItem(i++).UpdateDataColorChip("Primary Color",
			class'Helpers_SkyrangerSkins'.static.GetDisplayColorHTML(Customization.SkyrangerState.PrimaryColor), OnCustomizePrimaryColor);
	}

	if (Customization.SkyrangerState.GetMaterialsTemplate().AllowMaterialSecondaryTinting)
	{
		GetListItem(i++).UpdateDataColorChip("Secondary Color",
			class'Helpers_SkyrangerSkins'.static.GetDisplayColorHTML(Customization.SkyrangerState.SecondaryColor), OnCustomizeSecondaryColor);
	}

	`log(Customization.SkyrangerState.GetMaterialsTemplate().DataName @ "allows pattern?" @ Customization.SkyrangerState.GetMaterialsTemplate().AllowPattern);
	if (Customization.SkyrangerState.GetMaterialsTemplate().AllowPattern && Customization.HasPatternOptions())
	{
		`log("Added Patterns option");
		GetListItem(i++).UpdateDataValue("Pattern",
			Customization.SkyrangerState.GetPatternTemplate().DisplayName, OnCustomizePattern);
	}

	if (Customization.SkyrangerState.GetMaterialsTemplate().AllowDecal)
	{
		if (Customization.HasDecalOptions())
		{
			GetListItem(i++).UpdateDataValue("Decal",
				Customization.SkyrangerState.GetDecalTemplate().DisplayName, OnCustomizeDecal);
		}

		if (Customization.SkyrangerState.GetDecalTemplate().AllowDecalTinting)
		{
			GetListItem(i++).UpdateDataColorChip("Decal Color",
				class'Helpers_SkyrangerSkins'.static.GetDisplayColorHTML(Customization.SkyrangerState.DecalColor), OnCustomizeDecalColor);
		}
	}
}




simulated function OnCustomizeMaterials()
{
	local array<X2SkyrangerCustomizationTemplate> Materials;
	local array<name> MaterialNames;
	local array<string> MaterialStrings;
	local int i;
	
	class'X2SkyrangerCustomizationTemplateManager'.static.GetSkyrangerCustomizationTemplateManager().GetFilteredTemplates('Material', none, Materials);

	for (i = 0; i < Materials.Length; i++)
	{
		MaterialNames.AddItem(Materials[i].DataName);
		MaterialStrings.AddItem(Materials[i].DisplayName);
	}

	GetSelector(class'UIListSelector', MaterialStrings, PreviewMaterial, SetMaterial, MaterialNames.Find(Customization.SkyrangerState.MaterialsName), MaterialNames);
}

simulated function SetMaterial(int idx)
{
	Customization.SkyrangerState.MaterialsName = UIListSelector(Selector).GetNames()[idx];
	UpdateData();
}

simulated function PreviewMaterial(int idx)
{
	Customization.SkyrangerState.MaterialsName = UIListSelector(Selector).GetNames()[idx];
	Customization.PreviewVisuals();
}

simulated function OnCustomizePrimaryColor()
{
	GetSelector(class'UIColorSelectorWithInterface', class'Helpers_SkyrangerSkins'.static.GetFlashColorList(), PreviewPrimaryColor, SetPrimaryColor, Customization.SkyrangerState.PrimaryColor + 1);
}

simulated function SetPrimaryColor(int idx)
{
	Customization.SkyrangerState.PrimaryColor = idx - 1;
	UpdateData();
}

simulated function PreviewPrimaryColor(int idx)
{
	Customization.SkyrangerState.PrimaryColor = idx - 1;
	Customization.PreviewVisuals();
}

simulated function OnCustomizeSecondaryColor()
{
	GetSelector(class'UIColorSelectorWithInterface', class'Helpers_SkyrangerSkins'.static.GetFlashColorList(), PreviewSecondaryColor, SetSecondaryColor, Customization.SkyrangerState.SecondaryColor + 1);
}

simulated function SetSecondaryColor(int idx)
{
	Customization.SkyrangerState.SecondaryColor = idx - 1;
	UpdateData();
}

simulated function PreviewSecondaryColor(int idx)
{
	Customization.SkyrangerState.SecondaryColor = idx - 1;
	Customization.PreviewVisuals();
}


simulated function OnCustomizePattern()
{
	local array<X2BodyPartTemplate> Patterns;
	local array<name> PatternNames;
	local array<string> PatternStrings;
	local int i;
	
	class'X2BodyPartTemplateManager'.static.GetBodyPartTemplateManager().GetUberTemplates("Patterns", Patterns);

	for (i = 0; i < Patterns.Length; i++)
	{
		PatternNames.AddItem(Patterns[i].DataName);
		PatternStrings.AddItem(Patterns[i].DisplayName);
	}

	GetSelector(class'UIListSelector', PatternStrings, PreviewPattern, SetPattern, PatternNames.Find(Customization.SkyrangerState.PatternName), PatternNames);
}

simulated function SetPattern(int idx)
{
	Customization.SkyrangerState.PatternName = UIListSelector(Selector).GetNames()[idx];
	UpdateData();
}

simulated function PreviewPattern(int idx)
{
	Customization.SkyrangerState.PatternName = UIListSelector(Selector).GetNames()[idx];
	Customization.PreviewVisuals();
}

simulated function OnCustomizeDecal()
{
	local array<X2SkyrangerCustomizationTemplate> Decals;
	local array<name> DecalNames;
	local array<string> DecalStrings;
	local int i;
	
	class'X2SkyrangerCustomizationTemplateManager'.static.GetSkyrangerCustomizationTemplateManager().GetFilteredTemplates('Decal', none, Decals);
	
	for (i = 0; i < Decals.Length; i++)
	{
		DecalNames.AddItem(Decals[i].DataName);
		DecalStrings.AddItem(Decals[i].DisplayName);
	}

	GetSelector(class'UIListSelector', DecalStrings, PreviewDecal, SetDecal, DecalNames.Find(Customization.SkyrangerState.DecalName), DecalNames);
}

simulated function SetDecal(int idx)
{
	Customization.SkyrangerState.DecalName = UIListSelector(Selector).GetNames()[idx];
	UpdateData();
}

simulated function PreviewDecal(int idx)
{
	Customization.SkyrangerState.DecalName = UIListSelector(Selector).GetNames()[idx];
	Customization.PreviewVisuals();
}

simulated function OnCustomizeDecalColor()
{
	GetSelector(class'UIColorSelectorWithInterface', class'Helpers_SkyrangerSkins'.static.GetFlashColorList(), PreviewDecalColor, SetDecalColor, Customization.SkyrangerState.DecalColor + 1);
}

simulated function SetDecalColor(int idx)
{
	Customization.SkyrangerState.DecalColor = idx - 1;
	UpdateData();
}

simulated function PreviewDecalColor(int idx)
{
	Customization.SkyrangerState.DecalColor = idx - 1;
	Customization.PreviewVisuals();
}




event OnRemoteEvent(name RemoteEventName)
{
	super.OnRemoteEvent(RemoteEventName);
	if (RemoteEventName == 'CIN_SkyrangerFadedOut')
	{
		`log("Faded out triggered");
		OnFadeOutTriggered();
	}
}

function OnFadeOutTriggered()
{
	if (ScreenState == eSCSS_Starting)
	{
		`GAME.GetGeoscape().m_kBase.SetAvengerCapVisibility(true);
		`GAME.GetGeoscape().m_kBase.SetPostMissionSequenceVisibility(true);
		SetLightsActive(false);
		class'UIUtilities'.static.DisplayUI3D('3DUIBP_SkyrangerCustomization', '3DUIBP_SkyrangerCustomization', 0);
		ScreenState = eSCSS_Running;
		`log("Set State to Running");
	}
	else if (ScreenState == eSCSS_Ending)
	{
		Cleanup();
		super.CloseScreen();
	}
}

// Delay close screen
simulated function CloseScreen()
{
	if (!CloseSelector(true) && ScreenState == eSCSS_Running)
	{
		`XCOMGRI.DoRemoteEvent('CIN_EndSkyrangerCustomization');
		ScreenState = eSCSS_Ending;
		`log("Set State to ending");
	}
}

simulated function OnRemoved()
{
	super.OnRemoved();
	// Failsafe: If we've been removed, but haven't cleaned up, do it now
	if (ScreenState == eSCSS_Running)
	{
		Cleanup();
		ScreenState = eSCSS_Ending;
	}
}

simulated function Cleanup()
{
	SetLightsActive(true);
	`GAME.GetGeoscape().m_kBase.SetAvengerCapVisibility(false);
	`GAME.GetGeoscape().m_kBase.SetPostMissionSequenceVisibility(false);
	if (Customization != none)
	{
		Customization.Close();
		Customization = none;
	}
}





function InitKismet()
{
	WorldInfo.RemoteEventListeners.AddItem(self);
	SetSkyrangerVars();
}

// Make our Kismet aware of the Skyranger
function SetSkyrangerVars()
{
	local WorldInfo WI;
	local SkeletalMeshActor S;
	WI = class'WorldInfo'.static.GetWorldInfo();
	WI.MyKismetVariableMgr.RebuildVariableMap();
	foreach WI.DynamicActors(class'SkeletalMeshActor', S)
	{
		if (InStr(PathName(S), "CIN_PostMission1", false, true) != INDEX_NONE)
		{
			if (S.Name == 'SkeletalMeshActor_0')
			{
				SetObjectVar('SkinSkyrangerInt', S);
			}
			else if (S.Name == 'SkeletalMeshActor_8')
			{
				SetObjectVar('SkinSkyrangerExt', S);
			}
		}
	}
}

function SetObjectVar(name N, Object O)
{
	local WorldInfo WI;
	local array<SequenceVariable> OutVariables;
	local SequenceVariable SeqVar;
	local SeqVar_Object SeqVarObj;

	WI = class'WorldInfo'.static.GetWorldInfo();

	WI.MyKismetVariableMgr.GetVariable(N, OutVariables);
	foreach OutVariables(SeqVar)
	{
		SeqVarObj = SeqVar_Object(SeqVar);
		if(SeqVarObj != none)
		{
			SeqVarObj.SetObjectValue(O);
		}
	}
}

// Turn off annoying lights
function SetLightsActive(bool ShouldEnable)
{
	local WorldInfo WI;
	local Light L;
	WI = class'WorldInfo'.static.GetWorldInfo();

	foreach WI.AllActors(class'Light', L)
	{
		if ((PointLightMovable(L) != none || SpotLightMovable(L) != none) && InStr(PathName(L), "CIN_PostMission1", false, true) != INDEX_NONE)
		{
			L.LightComponent.SetEnabled(ShouldEnable);
		}
	}
}