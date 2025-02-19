import json
from schema_match.services.language_models import complete
from schema_match.utils import get_cache

cache = get_cache()


def review_schema_matching(run_specs, original_mappings, source_data, target_data):
    if not original_mappings:
        return original_mappings
    source_table = list(original_mappings.keys())[0].split(".")[0]
    key = json.dumps(run_specs) + "-review_schema_matching-" + source_table
    cache_result = cache.get(key)
    if cache_result:
        return cache_result

    prompt = f"Review schema matching for {run_specs['source_db']} and {run_specs['target_db']}"
    prompt += "Preliminary schema matching results are as follows:\n"
    prompt += json.dumps(original_mappings, indent=2)
    prompt += "\n\n"
    prompt += "Table descriptions are as follows:\n"
    for source, targets in original_mappings.items():
        prompt += f"Source Table: {source_table} \n Source Table Description {source_data[source_table]}\n"
        target_tables = set()
        for target in targets:
            target_tables.add(target["mapping"].split(".")[0])
        for target_table in target_tables:
            prompt += f"Target Table: {target_table} \n Target Table Description {target_data[target_table]}\n"
    prompt += "\n\n"
    prompt += "Please review the mappings and return adjusted mapping following original json format\n"
    prompt += "Only return the json object and no other text"

    def _prompt():
        response = complete(
            prompt,
            run_specs["column_matching_llm"],
            run_specs=run_specs,
        ).json()
        data = response["extra"]["extracted_json"]
        if isinstance(data, list) or not data:
            response = complete(
                prompt,
                run_specs["column_matching_llm"],
                run_specs=run_specs,
            ).json()
            data = response["extra"]["extracted_json"]
        cleaned_data = {}
        for source, targets in data.items():
            if source.count(".") != 1 or source == "None":
                continue
            source_table, source_column = source.split(".")
            if source not in source_data:
                if source_table not in source_data:
                    continue
                if source_column not in source_data[source_table]["columns"]:
                    continue
                assert source_data[source_table]["columns"][source_column]
            cleaned_mappings = []
            if isinstance(targets, dict):
                targets = [targets]
            for target in targets:
                if isinstance(target, str):
                    continue
                if target["mapping"] == "None" or target["mapping"].count(".") != 1:
                    continue
                if target["mapping"] in target_data:
                    cleaned_mappings.append(target)
                    continue
                target_table, target_column = target["mapping"].split(".")
                if target_table not in target_data:
                    continue
                if target_column not in target_data[target_table]["columns"]:
                    continue
                cleaned_mappings.append(target)
            if cleaned_mappings:
                cleaned_data[source] = cleaned_mappings
        return cleaned_data

    cleaned_data = _prompt()
    cache.set(key, cleaned_data)
    print(len(key))
    return cache.get(key)
