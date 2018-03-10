// Big ol' copy of UICustomize, to make it work with the skyranger
class UICustomizeSkyranger extends UIScreen abstract;

var UIBGBox ListBG;
var UIList List;
var UIX2PanelHeader Header;

var protected ISkyrangerCustomizeSelector Selector;
var protected XComSkyrangerCustomization Customization;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);

	ListBG = Spawn(class'UIBGBox', self);
	ListBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
	ListBG.InitBG('', 100, 100, 585, 800);

	Header = Spawn(class'UIX2PanelHeader', self).InitPanelHeader();
	Header.SetPosition(110, 110);
	Header.SetHeaderWidth(550);
	Header.Hide();

	List = Spawn(class'UIList', self);
	List.InitList('', 123, 170, 538, 740);
	List.ItemPadding = 5;
	List.bStickyHighlight = false;
	List.width = 550;
	ListBG.ProcessMouseEvents(List.OnChildMouseEvent);

	UpdateNavHelp();
	UpdateData();
}

function ResetMechaListItems()
{
	local UIMechaListItem CustomizeItem;
	local int i;

	for (i = 0; i < List.ItemCount; i++)
	{
		// CustomizeItem = GetListItem(i++); // FIRAAAAAAAAXIS
		CustomizeItem = GetListItem(i);
		CustomizeItem.SetDisabled(false);
		CustomizeItem.OnLoseFocus();
		CustomizeItem.Hide();
		CustomizeItem.BG.RemoveTooltip();
		CustomizeItem.DisableNavigation();
	}
	List.SetSelectedIndex(-1);
}

simulated function SetTitle(string str)
{
	if (str == "")
	{
		Header.Hide();
	}
	else
	{
		Header.Show();
	}
	Header.SetText(str);
	// HAX: Force flash to send an update command
	Header.headerWidth = 0;
	Header.SetWidth(550);
}

simulated function UpdateData()
{
	if( Selector != none )
	{
		CloseSelector();
	}

}

simulated function UIMechaListItem GetListItem(int ItemIndex, optional bool bDisableItem, optional string DisabledReason)
{
	local UIMechaListItem CustomizeItem;
	local UIPanel Item;

	if(List.ItemCount <= ItemIndex)
	{
		CustomizeItem = Spawn(class'UIMechaListItem', List.ItemContainer);
		CustomizeItem.bAnimateOnInit = false;
		CustomizeItem.InitListItem();
	}
	else
	{
		Item = List.GetItem(ItemIndex);
		CustomizeItem = UIMechaListItem(Item);
	}

	CustomizeItem.SetDisabled(bDisableItem, DisabledReason);

	return CustomizeItem;
}

simulated function ISkyrangerCustomizeSelector GetSelector(class<Actor> SelectorClass, optional array<string> Options,
													optional delegate<Helpers_SkyrangerSkins.SelectorOnPreviewDelegate> PreviewDelegate,
													optional delegate<Helpers_SkyrangerSkins.SelectorOnSetDelegate> SetDelegate,
													optional int Selection = 0,
													optional array<name> InitNames)
{
	if(Selector == none)
	{
		List.Hide();
		Selector = ISkyrangerCustomizeSelector(Spawn(SelectorClass, self));
		if (UIListSelector(Selector) != none)
		{
			UIListSelector(Selector).SetNames(InitNames);
		}

		Selector.InitSelector(, 100, 150, 584, 760, Options, PreviewDelegate, SetDelegate, Selection);
		UIPanel(Selector).SetSelectedNavigation();
		ListBG.ProcessMouseEvents(Selector.OnChildMouseEvent);
	}
	return Selector;
}

simulated function HideListItems()
{
	local int i;
	for(i = 0; i < List.ItemCount; ++i)
	{
		List.GetItem(i).Hide();
	}
}

simulated function ShowListItems()
{
	local int i;
	for(i = 0; i < List.ItemCount; ++i)
	{
		List.GetItem(i).Show();
	}
}


simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();

	UpdateNavHelp();
	UpdateData();

	ListBG.ProcessMouseEvents(List.OnChildMouseEvent);
}


// Input

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	local bool bHandled;

	if( !CheckInputIsReleaseOrDirectionRepeat(cmd, arg) )
		return false;

	if (Selector != none && Selector.OnUnrealCommand(cmd, arg))
		return true;


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

simulated function OnAccept();
simulated function OnCancel()
{
	CloseScreen();
}

simulated function CloseScreen()
{	
	if (!CloseSelector(true))
	{
		super.CloseScreen();
	}
}

simulated function bool CloseSelector(optional bool bCancelSelection)
{
	if (Selector != none)
	{
		if(bCancelSelection)
		{
			Selector.CancelSelection();
			class'UIUtilities_Sound'.static.PlayCloseSound();
		}

		UIPanel(Selector).Remove();
		Selector = none;

		ListBG.ProcessMouseEvents(List.OnChildMouseEvent);
		List.Show();
		List.SetSelectedNavigation();
		return true;
	}
	return false;
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

defaultproperties
{
	InputState=eInputState_Evaluate
	bAnimateOnInit=true
	bConsumeMouseEvents=true
	bIsIn3D=true
}