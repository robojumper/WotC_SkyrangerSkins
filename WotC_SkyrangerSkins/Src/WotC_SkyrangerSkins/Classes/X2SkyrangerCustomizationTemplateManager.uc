class X2SkyrangerCustomizationTemplateManager extends X2DataTemplateManager;

static function X2SkyrangerCustomizationTemplateManager GetSkyrangerCustomizationTemplateManager()
{
	return X2SkyrangerCustomizationTemplateManager(class'Engine'.static.GetTemplateManager(class'X2SkyrangerCustomizationTemplateManager'));
}

function bool AddSkyrangerCustomizationTemplate(X2SkyrangerCustomizationTemplate Template, bool ReplaceDuplicate = false)
{
	return AddDataTemplate(Template, ReplaceDuplicate);
}

function X2SkyrangerCustomizationTemplate FindSkyrangerCustomizationTemplate(name DataName)
{
	return X2SkyrangerCustomizationTemplate(FindDataTemplate(DataName));
}


function GetFilteredTemplates(name PartType, delegate<X2SkyrangerCustomizationFilter.FilterCallback> CallbackFn, out array<X2SkyrangerCustomizationTemplate> arrTemplates)
{
	local X2DataTemplate Template;

	foreach IterateTemplates(Template, none)
	{
		if (X2SkyrangerCustomizationTemplate(Template).PartType == PartType && (CallbackFn == none || CallbackFn(X2SkyrangerCustomizationTemplate(Template))))
		{
			arrTemplates.AddItem(X2SkyrangerCustomizationTemplate(Template));
		}
	}
	arrTemplates.Sort(ByDefault);
}

function int ByDefault(X2SkyrangerCustomizationTemplate A, X2SkyrangerCustomizationTemplate B)
{
	return (!A.IsDefault && B.IsDefault) ? -1 : 0;
}

function X2SkyrangerCustomizationTemplate GetDefaultTemplate(name PartType, delegate<X2SkyrangerCustomizationFilter.FilterCallback> CallbackFn)
{
	local X2DataTemplate Template;

	foreach IterateTemplates(Template, none)
	{
		if (X2SkyrangerCustomizationTemplate(Template).IsDefault && X2SkyrangerCustomizationTemplate(Template).PartType == PartType && (CallbackFn == none || CallbackFn(X2SkyrangerCustomizationTemplate(Template))))
		{
			return X2SkyrangerCustomizationTemplate(Template);
		}
	}
	return none;
}

DefaultProperties
{
	TemplateDefinitionClass=class'X2SkyrangerCustomization'
	ManagedTemplateClass=class'X2SkyrangerCustomizationTemplate'
}