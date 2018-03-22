class XComGameState_SkyrangerOptions extends XComGameState_BaseObject;

// Helper macro to create a MIC, set another Material as its parent, and add it to a list of materials
`define MAKE_MIC(VarName, Path, Arrname) `VarName = new class'MaterialInstanceConstant'; `VarName.SetParent(MaterialInterface(`CONTENT.RequestGameArchetype(`Path))); `ArrName.AddItem(`VarName);

var name MaterialsName;
var int PrimaryColor, SecondaryColor; // Index into the Armor color palette. If -1, tinting will be disabled
var name PatternName, DecalName;
var int DecalColor;
var int PatternColor;

event OnCreation( optional X2DataTemplate InitTemplate )
{
	ValidateAppearance();
}

// Hardcoded defaults here
function ValidateAppearance()
{
	if (GetMaterialsTemplate() == none)
	{
		MaterialsName = 'Material_Default';
		PrimaryColor = -1;
		SecondaryColor = -1;
	}

	if (GetPatternTemplate() == none)
	{
		PatternName = 'Pat_Nothing';
		PatternColor = -1;
	}

	if (GetDecalTemplate() == none)
	{
		DecalName = 'Decal_Default';
		DecalColor = -1;
	}
}


function ApplyToSkyrangers(array<MeshComponent> Hulls, array<MeshComponent> Interiors)
{
	local MaterialInstanceConstant Mat_Zero, Mat_Hull, Mat_Glass, Mat_Interior, Mat_Engine, Mat_Landing, Mat_Int_Floor, Mat_Int_Wall, Mat_Int_Three, Mat_Int_Four;
	local array<MaterialInstance> Materials;
	local X2SkyrangerCustomizationTemplate Mat;
	local X2SkyrangerCustomizationTemplate DecalTemplate;
	local X2BodyPartTemplate Pattern;
	local XComPatternsContent PatCont;
	local XComLinearColorPalette Palette;
	local LinearColor DumbColor;
	local int i;
	local bool TempSetting;

	Mat = GetMaterialsTemplate();
	DecalTemplate = Mat.AllowDecal ? GetDecalTemplate() : none;
	Pattern = Mat.AllowPattern ? GetPatternTemplate() : none;
	Palette = `CONTENT.GetColorPalette(ePalette_ArmorTint);
	

	`MAKE_MIC(Mat_Zero, Mat.Mat_Zero, Materials)
	`MAKE_MIC(Mat_Hull, Mat.Mat_Hull, Materials)
	`MAKE_MIC(Mat_Glass, Mat.Mat_Glass, Materials)
	`MAKE_MIC(Mat_Interior, Mat.Mat_Interior, Materials)
	`MAKE_MIC(Mat_Engine, Mat.Mat_Engine, Materials)
	`MAKE_MIC(Mat_Landing, Mat.Mat_Landing, Materials)
	`MAKE_MIC(Mat_Int_Floor, Mat.Mat_Int_Floor, Materials)
	`MAKE_MIC(Mat_Int_Wall, Mat.Mat_Int_Wall, Materials)
	`MAKE_MIC(Mat_Int_Three, Mat.Mat_Int_Three, Materials)
	`MAKE_MIC(Mat_Int_Four, Mat.Mat_Int_Four, Materials)

	for (i = 0; i < Materials.Length; i++)
	{
		TempSetting = Mat.AllowMaterialPrimaryTinting && PrimaryColor > -1;
		Materials[i].SetScalarParameterValue('Use Tint', TempSetting ? 1 : 0);
		if (TempSetting)
		{
			DumbColor = Palette.Entries[PrimaryColor].Primary;
			Materials[i].SetVectorParameterValue('Primary Color', DumbColor);
		}

		TempSetting = Mat.AllowMaterialSecondaryTinting && SecondaryColor > -1;
		Materials[i].SetScalarParameterValue('Use Secondary Tint', TempSetting ? 1 : 0);
		if (TempSetting)
		{
			DumbColor = Palette.Entries[SecondaryColor].Primary;
			Materials[i].SetVectorParameterValue('Secondary Color', DumbColor);
		}
		
		TempSetting = DecalTemplate != none && DecalTemplate.AllowDecalTinting && (DecalColor > -1 || DecalTemplate.ForceTint);
		Materials[i].SetScalarParameterValue('DecalTintable', TempSetting ? 1 : 0);
		if (TempSetting)
		{
			if (DecalColor == -1 && DecalTemplate.ForceTint)
			{
				DumbColor = DecalTemplate.DefaultTint;
			}
			else
			{
				DumbColor = Palette.Entries[DecalColor].Primary;
			}
			Materials[i].SetVectorParameterValue('Decal Color', DumbColor);
		}

		// Important hackery for decals: Since decals can only ever be used for the Hull (and there's no Decal Mask or anything)
		// we need to make sure we only ever enable decals for the Hull. Otherwise it will look very very bad.
		TempSetting = Materials[i] == Mat_Hull && DecalTemplate != none;
		Materials[i].SetScalarParameterValue('DecalUse', (TempSetting && DecalTemplate.TexturePath != "") ? 1 : 0);
		if (TempSetting)
		{
			Materials[i].SetScalarParameterValue('DecalForceAlpha', (DecalTemplate.ForceAlpha) ? 1 : 0);
			if (DecalTemplate.TexturePath != "")
			{
				Materials[i].SetTextureParameterValue('Decal', Texture(`CONTENT.RequestGameArchetype(DecalTemplate.TexturePath)));
			}
		}
		PatCont = (Pattern != none && Pattern.ArchetypeName != "") ? XComPatternsContent(`CONTENT.RequestGameArchetype(Pattern.ArchetypeName)) : none;
		Materials[i].SetScalarParameterValue('PatternUse', (PatCont != none && PatCont.Texture != none) ? 1 : 0);
		Materials[i].SetScalarParameterValue('Use Pattern Color', (PatCont != none && PatCont.Texture != none && PatternColor > -1) ? 1 : 0);
		if (Pattern != none && PatCont.Texture != none)
		{
			Materials[i].SetTextureParameterValue('Pattern', PatCont.Texture);
			if (PatternColor > -1)
			{
				DumbColor = Palette.Entries[PatternColor].Primary;
				Materials[i].SetVectorParameterValue('Pattern Color', DumbColor);
			}
		}
	}

	for (i = 0; i < Hulls.Length; i++)
	{
		Hulls[i].SetMaterial(0, Mat_Zero);
		Hulls[i].SetMaterial(1, Mat_Hull);
		Hulls[i].SetMaterial(2, Mat_Glass);
		Hulls[i].SetMaterial(3, Mat_Interior);
		Hulls[i].SetMaterial(4, Mat_Engine);
		Hulls[i].SetMaterial(5, Mat_Landing);
	}

	for (i = 0; i < Interiors.Length; i++)
	{
		Interiors[i].SetMaterial(0, Mat_Int_Floor);
		Interiors[i].SetMaterial(1, Mat_Int_Wall);
		Interiors[i].SetMaterial(2, Mat_Int_Three);
		Interiors[i].SetMaterial(3, Mat_Int_Four);
	}

}

static function ApplyToAll()
{
	local array<MeshComponent> Exts, Ints;
	class'Helpers_SkyrangerSkins'.static.FindMeshes(Exts, Ints);
	GetOrCreate().ApplyToSkyrangers(Exts, Ints);
}

static function XComGameState_SkyrangerOptions GetOrCreate(optional XComGameState NewGameState = none)
{
	local XComGameState_SkyrangerOptions Options;
	local bool SubmitLocally;
	if (NewGameState != none)
	{
		foreach NewGameState.IterateByClassType(class'XComGameState_SkyrangerOptions', Options)
		{
			break;
		}
	}

	if (Options == none)
	{
		Options = XComGameState_SkyrangerOptions(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_SkyrangerOptions', true));
	}

	if (Options == none)
	{
		if (NewGameState == none)
		{
			NewGameState = `XCOMHISTORY.GetStartState();
			if (NewGameState == none)
			{
				NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Create Skyranger Options");
				SubmitLocally = true;
			}
		}
		Options = XComGameState_SkyrangerOptions(NewGameState.CreateNewStateObject(class'XComGameState_SkyrangerOptions'));
		if (SubmitLocally)
		{
			`XCOMHISTORY.AddGameStateToHistory(NewGameState);
		}
	}
	return Options;
}


///// Customization Code /////
function X2SkyrangerCustomizationTemplate GetMaterialsTemplate()
{
	return GetSpecificTemplate(MaterialsName);
}

function X2BodyPartTemplate GetPatternTemplate()
{
	if (PatternName != '')
	{
		return class'X2BodyPartTemplateManager'.static.GetBodyPartTemplateManager().FindUberTemplate("Patterns", PatternName);
	}
	return none;
}

function X2SkyrangerCustomizationTemplate GetDecalTemplate()
{
	if (DecalName != '')
	{
		return GetSpecificTemplate(DecalName);
	}
	return none;
}

private function X2SkyrangerCustomizationTemplate GetSpecificTemplate(name nm)
{
	return class'X2SkyrangerCustomizationTemplateManager'.static.GetSkyrangerCustomizationTemplateManager().FindSkyrangerCustomizationTemplate(nm);
}