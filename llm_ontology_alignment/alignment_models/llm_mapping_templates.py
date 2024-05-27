TOP2_PROMPT_TEMPLATE = """
You are an expert in databases, and schema matching at top k specifically. Your task is to create matches between source and target tables and
attributes.
You are excellent at this task.
If none of the columns are relevant, the target entry id should be "NA".
Your job is to match the schemas. You never provide explanations, code or anything else, only results. Below are the two schemas.
Create top k matches between source and target.
Make sure to match the entire input tables.
Make sure to return the results in the following json format.
Each source entry id is a unique identifier for the source entry. The target entry id is a unique identifier for the target entry.
If no match is found, the target entry id should be "NA". Try to mach as much target entry as possible!
Expected output format:
{
    'source entry id': 'matched target entry id',
    'another source entry id': 'NA',
    ...
}


Source Schema:
%s

Target Schema:
%s
Remember to match the entire input. Make sure to return only the results!
"""

TOP2_PROMPT_TEMPLATE_NO_NA = """
You are an expert in databases, and schema matching at top k specifically. Your task is to create matches between source and target tables and
attributes.
You are excellent at this task.
If none of the columns are relevant, list the source column in non-match list.
Your job is to match the schemas. You never provide explanations, code or anything else, only results. Below are the two schemas.
Create top 2 matches between source and target.
Make sure to match the entire input tables.
Make sure to return the results in the following json format.
Each source entry id is a unique identifier for the source entry. The target entry id is a unique identifier for the target entry.
Try to match all of the source entries!


Expected output format:
{
    'source entry id': ['first matched target entry id', 'second matched target entry id']
    'another source entry id': [...]',
    ...
    }
}

Source Candidates:
%s

Target Candidates:
%s
Remember to match the entire input. Make sure to return only the results!
"""


TEMPLATE = """
You are an expert in databases, and schema matching at top k specifically. Your task is to create matches between source and target tables and
attributes. For each attribute from the source you always suggest the top 5 most relevant tables and columns from the target. You are excellent at
this task.
If none of the columns are relevant, the last table and column should be "NA", "NA". This value may appear only once per mapping!
Your job is to match the schemas. You never provide explanations, code or anything else, only results. Below are the two schemas.
Create top k matches between source and target tables and columns.
Make sure to match the entire input. Make sure to return the results in the following json format with top 2 target results foreach input in source.
Expected output format:
{
  '1': {
    'SRC_ENT': 'SOURCE_TABLE_NAME',
    'SRC_ATT': 'SOURCE_COLUMN_NAME',
    'TGT_ENT1': 'TARGET_TABLE_NAME1',
    'TGT_ATT1': 'TARGET_COLUMN_NAME1',
  },
  '2': {
    'SRC_ENT': 'SOURCE_TABLE_NAME',
    'SRC_ATT': 'SOURCE_COLUMN_NAME',
    'TGT_ENT1': 'TARGET_TABLE_NAME1',
    'TGT_ATT1': 'TARGET_COLUMN_NAME1',
  }
}...

Source Schema:
,SRC_ENT, SRC_ATT
%s

Target Schema:
,TGT_ENT,TGT_ATT
%s
Remember to match the entire input. Make sure to return only the results!
"""

TEMPLATES = {
    "top2-with-na": TOP2_PROMPT_TEMPLATE,
    "top2-no-na": TOP2_PROMPT_TEMPLATE_NO_NA,
    "top5": TEMPLATE,
}
