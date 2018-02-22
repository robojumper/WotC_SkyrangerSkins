// As much as I dislike Matinee, it's a good way to handle the skyranger here
class UICustomizeSkyranger extends UIScreen;

enum ESkyrangerCustomizationTrait
{
	eSCT_Materials,
};

var UIList ActiveList;

var UIPanel EquippedListContainer;
var UIList EquippedList;

var UIPanel LockerListContainer;
var UIList LockerList;


var SkeletalMeshActor PreviewSkyrangerHull;
var SkeletalMeshActor PreviewSkyrangerInterior;

var XComGameState PendingGameState;
var XComGameState_SkyrangerOptions OptionsState;

// Simple state tracking so we don't end up triggering events multiple times (or skip them)
var enum ESkyrangerCustomizeScreenState
{
	eSCSS_Starting,
	eSCSS_Running,
	eSCSS_Ending,
} ScreenState;

var localized string strTitle;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	local StateObjectReference EmptyRef;
	super.InitScreen(InitController, InitMovie, InitName);
	Spawn(class'UISoldierHeader', self).InitSoldierHeader(EmptyRef, none).Hide();

	InitKismet();
	class'XComGameState_SkyrangerOptions'.static.GetOrCreate();
	CreateCustomizationState();

	MC.FunctionString("setLeftPanelTitle", strTitle);

	EquippedListContainer = Spawn(class'UIPanel', self);
	EquippedListContainer.bAnimateOnInit = false;
	EquippedListContainer.InitPanel('leftPanel');
	EquippedList = class'UIArmory_Loadout'.static.CreateList(EquippedListContainer);
	EquippedList.OnSelectionChanged = OnSelectionChanged;
	EquippedList.OnItemClicked = OnItemClicked;
	EquippedList.OnItemDoubleClicked = OnItemClicked;

	LockerListContainer = Spawn(class'UIPanel', self);
	LockerListContainer.bAnimateOnInit = false;
	LockerListContainer.InitPanel('rightPanel');
	LockerList = class'UIArmory_Loadout'.static.CreateList(LockerListContainer);
	LockerList.OnSelectionChanged = OnSelectionChanged;
	LockerList.OnItemClicked = OnItemClicked;
	LockerList.OnItemDoubleClicked = OnItemClicked;

	UpdateNavHelp();
	PopulateData();

}

simulated function PopulateData()
{
	UpdateEquippedList();
	UpdateLockerList();
	ChangeActiveList(EquippedList, true);
}


simulated function OnInit()
{
	super.OnInit();
	`XCOMGRI.DoRemoteEvent('CIN_StartSkyrangerCustomization');
	ScreenState = eSCSS_Starting;
	`log("Set State to starting");
}


simulated function CreateCustomizationState()
{
	if (PendingGameState == none)
	{
		PendingGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Create Skyranger Customization State");
		OptionsState = class'XComGameState_SkyrangerOptions'.static.GetOrCreate(PendingGameState);
		OptionsState = XComGameState_SkyrangerOptions(PendingGameState.ModifyStateObject(class'XComGameState_SkyrangerOptions', OptionsState.ObjectID));
	}
}

simulated function SubmitCustomizationState()
{
	if (PendingGameState != none)
	{
		`GAMERULES.SubmitGameState(PendingGameState);
		PendingGameState = none;
		OptionsState = none;
		CreateCustomizationState();
	}
}

simulated function DiscardCustomizationState()
{
	if (PendingGameState != none)
	{
		`XCOMHISTORY.CleanupPendingGameState(PendingGameState);
		PendingGameState = none;
		OptionsState = none;
		CreateCustomizationState();
	}
}


simulated function UpdateEquippedList()
{
	local XComGameState_SkyrangerOptions HistoryOptions;
	local UICustomizeSkyrangerItem Item;
	local int prevIndex;
	local X2SkyrangerCustomizationTemplateManager Man;
	local X2SkyrangerCustomizationTemplate Temp;

	Man = class'X2SkyrangerCustomizationTemplateManager'.static.GetSkyrangerCustomizationTemplateManager();

	HistoryOptions = XComGameState_SkyrangerOptions(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_SkyrangerOptions'));
	
	prevIndex = EquippedList.SelectedIndex;
	EquippedList.ClearItems();

	// Materials
	Item = UICustomizeSkyrangerItem(EquippedList.CreateItem(class'UICustomizeSkyrangerItem'));
	Temp = Man.FindSkyrangerCustomizationTemplate(HistoryOptions.MaterialsName);
	Item.InitCustomizeItem(Temp, eSCT_Materials);

	EquippedList.SetSelectedIndex(prevIndex < EquippedList.ItemCount ? prevIndex : 0);
	// Force item into view
	EquippedList.NavigatorSelectionChanged(EquippedList.SelectedIndex);

}

simulated function UpdateLockerList()
{
	local array<X2SkyrangerCustomizationTemplate> Templates;
	local int i;
	local ESkyrangerCustomizationTrait Trait;

	Trait = UICustomizeSkyrangerItem(EquippedList.GetSelectedItem()).Trait;
	Templates = GetTemplatesForCategory(Trait);
	LockerList.ClearItems();

	for (i = 0; i < Templates.Length; i++)
	{
		UICustomizeSkyrangerItem(LockerList.CreateItem(class'UICustomizeSkyrangerItem')).InitCustomizeItem(Templates[i], Trait);
	}

	// If we have an invalid SelectedIndex, just try and select the first thing that we can.
	// Otherwise let's make sure the Navigator is selecting the right thing.
	if(LockerList.SelectedIndex < 0 || LockerList.SelectedIndex >= LockerList.ItemCount)
	{
		LockerList.Navigator.SelectFirstAvailable();
	}
	else
	{
		LockerList.Navigator.SetSelected(LockerList.GetSelectedItem());
	}
	OnSelectionChanged(ActiveList, ActiveList.SelectedIndex);

}


simulated function array<X2SkyrangerCustomizationTemplate> GetTemplatesForCategory(ESkyrangerCustomizationTrait Cat)
{
	switch (Cat)
	{
		case eSCT_Materials:
			return class'X2SkyrangerCustomizationTemplateManager'.static.GetSkyrangerCustomizationTemplateManager().GetAllTemplatesOfClass(class'X2SkyrangerMaterialsTemplate');
	}
}


simulated function OnSelectionChanged(UIList ContainerList, int ItemIndex)
{
	if (ContainerList == LockerList && LockerList == ActiveList)
	{
		Apply(UICustomizeSkyrangerItem(LockerList.GetSelectedItem()));
	}
}


simulated function Apply(UICustomizeSkyrangerItem Item)
{
	local array<MeshComponent> A, B;
	switch (Item.Trait)
	{
		case eSCT_Materials:
			OptionsState.MaterialsName = UICustomizeSkyrangerItem(LockerList.GetSelectedItem()).Template.DataName;
			break;
	}
	A.AddItem(PreviewSkyrangerHull.SkeletalMeshComponent);
	B.AddItem(PreviewSkyrangerInterior.SkeletalMeshComponent);
	OptionsState.ApplyToSkyrangers(A, B);
}


simulated function OnItemClicked(UIList ContainerList, int ItemIndex)
{
	if(ContainerList != ActiveList) return;

	if(ContainerList == EquippedList)
	{
		UpdateLockerList();
		ChangeActiveList(LockerList);
	}
	else
	{
		Apply(UICustomizeSkyrangerItem(LockerList.GetSelectedItem()));
		SubmitCustomizationState();
		ChangeActiveList(EquippedList);
		UpdateEquippedList();
		
		if (EquippedList.SelectedIndex < 0)
		{
			EquippedList.SetSelectedIndex(0);
		}
	}
}


simulated function ChangeActiveList(UIList kActiveList, optional bool bSkipAnimation)
{
	local UICustomizeSkyrangerItem LoadoutItem;

	ActiveList = kActiveList;

	LoadoutItem =  UICustomizeSkyrangerItem(EquippedList.GetSelectedItem());
	
	if(kActiveList == EquippedList)
	{
		if(!bSkipAnimation)
			MC.FunctionVoid("closeList");

		// disable list item selection on LockerList, enable it on EquippedList
		LockerListContainer.DisableMouseHit();
		EquippedListContainer.EnableMouseHit();

		Navigator.RemoveControl(LockerListContainer);
		Navigator.AddControl(EquippedListContainer);
		EquippedList.EnableNavigation();
		LockerList.DisableNavigation();
		Navigator.SetSelected(EquippedListContainer);
		if (EquippedList.SelectedIndex < 0)
		{
			EquippedList.SetSelectedIndex(0);
		}
		else
		{
			EquippedList.GetSelectedItem().OnReceiveFocus();
		}
	}
	else
	{
		if(!bSkipAnimation)
			MC.FunctionVoid("openList");

		// disable list item selection on LockerList, enable it on EquippedList
		LockerListContainer.EnableMouseHit();
		EquippedListContainer.DisableMouseHit();

		LockerList.SetSelectedIndex(0, true);
		Navigator.RemoveControl(EquippedListContainer);
		Navigator.AddControl(LockerListContainer);
		EquippedList.DisableNavigation();
		LockerList.EnableNavigation();
		Navigator.SetSelected(LockerListContainer);
		LockerList.Navigator.SelectFirstAvailable();
	}
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
	if (ScreenState == eSCSS_Running)
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
	if (PendingGameState != none)
	{
		`XCOMHISTORY.CleanupPendingGameState(PendingGameState);
	}
	class'XComGameState_SkyrangerOptions'.static.ApplyToAll();
}

// Input

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	local bool bHandled;

	if( !CheckInputIsReleaseOrDirectionRepeat(cmd, arg) )
		return false;

	bHandled = true;

	switch( cmd )
	{
		case class'UIUtilities_Input'.const.FXS_BUTTON_A:
		case class'UIUtilities_Input'.const.FXS_KEY_ENTER:
		case class'UIUtilities_Input'.const.FXS_KEY_SPACEBAR:
			OnAccept();
			break;
		case class'UIUtilities_Input'.const.FXS_BUTTON_B:
		case class'UIUtilities_Input'.const.FXS_KEY_ESCAPE:
		case class'UIUtilities_Input'.const.FXS_R_MOUSE_DOWN:
			OnCancel();
			break;
		default:
			bHandled = false;
			break;
	}

	return bHandled || super.OnUnrealCommand(cmd, arg);
}

simulated function OnAccept()
{
	if (ActiveList.SelectedIndex == -1)
		return;

	OnItemClicked(ActiveList, ActiveList.SelectedIndex);
}


simulated function OnCancel()
{
	if(ActiveList == EquippedList)
	{
		CloseScreen();
	}	
	else
	{
		DiscardCustomizationState();
		ChangeActiveList(EquippedList);
		OnSelectionChanged(EquippedList, EquippedList.SelectedIndex);
	}
}

simulated function UpdateNavHelp()
{
	local UINavigationHelp NavHelp;

	NavHelp = `HQPRES.m_kAvengerHUD.NavHelp;

	NavHelp.ClearButtonHelp();
	NavHelp.bIsVerticalHelp = `ISCONTROLLERACTIVE;
	NavHelp.AddBackButton(OnCancel);
	NavHelp.AddSelectNavHelp();
	NavHelp.Show();

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
				PreviewSkyrangerInterior = S;
			}
			else if (S.Name == 'SkeletalMeshActor_8')
			{
				SetObjectVar('SkinSkyrangerExt', S);
				PreviewSkyrangerHull = S;
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

defaultproperties
{
	Package="/ package/gfxArmory/Armory"
	LibID="LoadoutScreenMC"
	InputState=eInputState_Evaluate
	bAnimateOnInit=true
	bConsumeMouseEvents=true
	bIsIn3D=true
}