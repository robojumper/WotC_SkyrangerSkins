class X2SkyrangerCustomizationTemplate extends X2DataTemplate config(SkyrangerSkins);

var localized string DisplayName;

var name PartType;

// If PartType == 'Material'
var string Mat_Zero;
var string Mat_Hull;
var string Mat_Glass;
var string Mat_Interior;
var string Mat_Engine;
var string Mat_Landing;
var string Mat_Int_Floor;
var string Mat_Int_Wall;
var string Mat_Int_Three;
var string Mat_Int_Four;
var bool AllowMaterialPrimaryTinting;
var bool AllowMaterialSecondaryTinting;
var bool AllowPattern;
var bool AllowDecal;

// If PartType == 'Decal'
var string TexturePath;
var bool AllowDecalTinting;
var bool ForceAlpha;
var bool ForceTint;
var LinearColor DefaultTint;

// Options that don't need a template: Pattern (XComPatternsContent in X2BodyPart...), Colors