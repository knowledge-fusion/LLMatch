# @cache.memoize(timeout=360)
def complete(prompt, model, run_specs, **kwargs):
    import requests
    import os
    import dateutil

    assert prompt.find("{{") == -1, prompt

    data = {
        "model": model,
        "messages": [
            {
                "content": prompt,
                "role": "user",
            }
        ],
        **kwargs,
    }
    resp = requests.post(
        os.getenv("LLM_API_URL") + "/completion",
        json=data,
    )

    if resp.status_code != 200:
        raise Exception(resp.text)

    data = resp.json()
    from schema_match.data_models.experiment_models import CostAnalysis

    cost_info = {
        "run_specs": run_specs,
        "model": model,
        "text_result": data["choices"][0]["message"]["content"],
        "json_result": data["extra"]["extracted_json"],
        "start": dateutil.parser.parse(data["extra"]["start"]),
        "end": dateutil.parser.parse(data["extra"]["end"]),
        "duration": data["extra"]["duration"],
        **data["usage"],
        "extra_data": data,
    }
    CostAnalysis(**cost_info).save()
    return resp
