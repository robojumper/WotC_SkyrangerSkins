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

// MechaListItems really can't seem to be able to deal with being re-enabled as a different kind
// of item. Hence, just clear the list. It just doesn't work.
function ResetMechaListItems()
{
	// local UIMechaListItem CustomizeItem;
	// local int i;

	List.ClearItems();
/*
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
*/
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
		CustomizeItem.EnableNavigation();
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

	if (List != none && List.OnUnrealCommand(cmd, arg))
	{
		if ((cmd == class'UIUtilities_Input'.const.FXS_KEY_ENTER ||
		     cmd == class'UIUtilities_Input'.const.FXS_BUTTON_A ||
		     cmd == class'UIUtilities_Input'.const.FXS_KEY_SPACEBAR))
		{
			Movie.Pres.PlayUISound(eSUISound_MenuSelect);
		}
		return true;
	}

	bHandled = true;

	switch( cmd )
	{
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

simulated function OnCancel()
{
	CloseScreen();
}

simulated function CloseScreen()
{	
	if (!CancelSelection())
	{
		super.CloseScreen();
	}
}

simulated function CloseSelector()
{
	if (Selector != none)
	{
		UIPanel(Selector).Remove();
		Selector = none;
		ListBG.ProcessMouseEvents(List.OnChildMouseEvent);
		List.Show();
		//List.SetSelectedNavigation();
	}
}

simulated function bool CancelSelection()
{
	if (Selector != none)
	{
		Selector.CancelSelection();
		class'UIUtilities_Sound'.static.PlayCloseSound();
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