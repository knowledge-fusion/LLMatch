def get_llm_mapping(all_table_descriptions, sources, targets, llm, template):
    """
    Get the mapping between the sources and targets using the LLM model.

    Args:
        sources (List[str]): The list of source strings.
        targets (List[str]): The list of target strings.
        llm (str): The LLM model to use.
        template (str): The template to use for the mapping.

    Returns:
        List[str]: The list of mappings.
    """
    from litellm import completion

    from llm_ontology_alignment.alignment_models.llm_mapping_templates import TEMPLATES

    messages = [
        {
            "content": TEMPLATES[template] % (all_table_descriptions, sources, targets),
            "role": "user",
        }
    ]
    response = completion(
        model=llm,
        seed=42,
        temperature=0.5,
        top_p=0.9,
        max_tokens=4096,
        frequency_penalty=0,
        presence_penalty=0,
        messages=messages,
        response_format={"type": "json_object"},
    )

    return response
