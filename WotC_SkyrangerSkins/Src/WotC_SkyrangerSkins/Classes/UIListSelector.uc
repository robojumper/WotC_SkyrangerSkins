// A UIList. With a custom interface to make it work like we want to
class UIListSelector extends UIPanel implements(ISkyrangerCustomizeSelector);

var UIList TheList;
var array<string> Options;
var array<name> Names;
var int InitialSelection; 

var delegate<Helpers_SkyrangerSkins.SelectorOnPreviewDelegate> OnPreviewDelegate;
var delegate<Helpers_SkyrangerSkins.SelectorOnSetDelegate> OnSetDelegate;

simulated function ISkyrangerCustomizeSelector InitSelector(optional name InitName, 
															 optional float initX = 500,
															 optional float initY = 500,
															 optional float initWidth = 500,
															 optional float initHeight = 500,
												 			 optional array<string> initOptions,
												 			 optional delegate<Helpers_SkyrangerSkins.SelectorOnPreviewDelegate> initPreviewDelegate,
															 optional delegate<Helpers_SkyrangerSkins.SelectorOnSetDelegate> initSetDelegate,
															 optional int initSelection = 0)
{
	local int i;
	local UIMechaListItem Item;

	InitPanel();

	TheList = Spawn(class'UIList', self);
	TheList.OnItemClicked = OnAccept;
	TheList.OnItemDoubleClicked = OnAccept;
	TheList.OnSelectionChanged = OnPreview;

	OnPreviewDelegate = initPreviewDelegate;
	OnSetDelegate = initSetDelegate;
	Options = initOptions;
	InitialSelection = initSelection;

	TheList.InitList('', initX + 20, initY + 20, initWidth - 60, initHeight - 40, , false);

	for (i = 0; i < Options.Length; i++)
	{
		Item = Spawn(class'UIMechaListItem', TheList.ItemContainer);
		Item.bAnimateOnInit = false;
		Item.InitListItem();
		Item.UpdateDataDescription(Options[i]);
	}

	if (initSelection > -1 && initSelection < TheList.ItemCount)
	{
		TheList.SetSelectedIndex(initSelection);
	}
	else
	{
		TheList.SetSelectedIndex(0);
	}

	return self;
}


simulated function CancelSelection()
{
	OnCancel();
}


simulated function array<string> GetOptions()
{
	return Options;
}

simulated function OnChildMouseEvent( UIPanel control, int cmd )
{
	TheList.OnChildMouseEvent(control, cmd);
}

// Need those to safely resolve back template names
simulated function SetNames(array<name> inNames)
{
	Names = inNames;
}

simulated function array<name> GetNames()
{
	return Names;
}


simulated function OnPreview(UIList L, int iIndex)
{
	if(OnPreviewDelegate != none)
		OnPreviewDelegate( iIndex );
}

simulated function OnAccept(UIList L, int iIndex)
{
	if(OnSetDelegate != none)
		OnSetDelegate( iIndex );
}

simulated function OnCancel()
{
	if(OnSetDelegate != none)
		OnSetDelegate( InitialSelection );
}

defaultproperties
{
	bIsNavigable = true;
	bAnimateOnInit = false;
	bCascadeFocus = false;
}