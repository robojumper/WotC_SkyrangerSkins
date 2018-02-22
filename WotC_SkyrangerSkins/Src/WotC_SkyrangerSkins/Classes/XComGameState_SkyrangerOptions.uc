class XComGameState_SkyrangerOptions extends XComGameState_BaseObject;

var name MaterialsName;


function ApplyToSkyrangers(array<MeshComponent> Hulls, array<MeshComponent> Interiors)
{
	local X2SkyrangerCustomizationTemplateManager Man;
	local X2SkyrangerMaterialsTemplate Temp;
	local int i;

	Man = class'X2SkyrangerCustomizationTemplateManager'.static.GetSkyrangerCustomizationTemplateManager();
	Temp = X2SkyrangerMaterialsTemplate(Man.FindSkyrangerCustomizationTemplate(MaterialsName));
	`log("Applying" @ MaterialsName);
	if (Temp != none)
	{
		for (i = 0; i < Hulls.Length; i++)
		{
			Hulls[i].SetMaterial(0, MaterialInterface(`CONTENT.RequestGameArchetype(Temp.Mat_Zero)));
			Hulls[i].SetMaterial(1, MaterialInterface(`CONTENT.RequestGameArchetype(Temp.Mat_Hull)));
			Hulls[i].SetMaterial(2, MaterialInterface(`CONTENT.RequestGameArchetype(Temp.Mat_Glass)));
			Hulls[i].SetMaterial(3, MaterialInterface(`CONTENT.RequestGameArchetype(Temp.Mat_Interior)));
			Hulls[i].SetMaterial(4, MaterialInterface(`CONTENT.RequestGameArchetype(Temp.Mat_Engine)));
			Hulls[i].SetMaterial(5, MaterialInterface(`CONTENT.RequestGameArchetype(Temp.Mat_Landing)));
		}

		for (i = 0; i < Interiors.Length; i++)
		{
			Interiors[i].SetMaterial(0, MaterialInterface(`CONTENT.RequestGameArchetype(Temp.Mat_Int_Floor)));
			Interiors[i].SetMaterial(1, MaterialInterface(`CONTENT.RequestGameArchetype(Temp.Mat_Int_Wall)));
			Interiors[i].SetMaterial(2, MaterialInterface(`CONTENT.RequestGameArchetype(Temp.Mat_Int_Three)));
			Interiors[i].SetMaterial(3, MaterialInterface(`CONTENT.RequestGameArchetype(Temp.Mat_Int_Four)));
		}
	}
}

// Ugly and slow, but works
static function ApplyToAll()
{
	local WorldInfo WI;
	local SkeletalMeshActor S;
	local StaticMeshActor A;
	local array<MeshComponent> Exts, Ints;
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


defaultproperties
{
	SkinName="Codex"
}