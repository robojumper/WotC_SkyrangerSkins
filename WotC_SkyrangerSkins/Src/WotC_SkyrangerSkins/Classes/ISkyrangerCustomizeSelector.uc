// Common interface for Panel logic that implements a "chooser". This can be a color chooser or a list.
interface ISkyrangerCustomizeSelector;

simulated function ISkyrangerCustomizeSelector InitSelector(optional name InitName, 
															 optional float initX = 500,
															 optional float initY = 500,
															 optional float initWidth = 500,
															 optional float initHeight = 500,
												 			 optional array<string> initOptions,
												 			 optional delegate<Helpers_SkyrangerSkins.SelectorOnPreviewDelegate> initPreviewDelegate,
															 optional delegate<Helpers_SkyrangerSkins.SelectorOnSetDelegate> initSetDelegate,
															 optional int initSelection = 0);


simulated function CancelSelection();

simulated function array<string> GetOptions();
simulated function bool OnUnrealCommand(int cmd, int arg);
simulated function OnChildMouseEvent( UIPanel control, int cmd );