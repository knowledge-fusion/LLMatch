def get_llm_mapping(sources, targets, run_specs):
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

    from llm_ontology_alignment.alignment_strategies.llm_mapping_templates import (
        TEMPLATES,
    )

    prompt = TEMPLATES[run_specs["template"]] % (sources, targets)

    from llm_ontology_alignment.services.language_models import complete

    response = complete(prompt, run_specs["matching_llm"], run_specs=run_specs)
    return response.json()
