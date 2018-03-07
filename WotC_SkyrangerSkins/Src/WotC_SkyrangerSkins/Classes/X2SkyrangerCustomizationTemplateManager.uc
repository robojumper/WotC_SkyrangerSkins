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
}

DefaultProperties
{
	TemplateDefinitionClass=class'X2SkyrangerCustomization'
	ManagedTemplateClass=class'X2SkyrangerCustomizationTemplate'
}