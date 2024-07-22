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
All Table Descriptions:
%s

Source Schema:
%s

Target Schema:
%s
Remember to match the entire input. Make sure to return only the results!
"""

TOP2_PROMPT_TEMPLATE_NO_NA = """
You are an expert in databases. Your task is to create matches from SOURCE columns to TARGET columns.
One source column can be matched to multiple target columns.
Pay attention to column description because column names may have different surface forms.
Context of matched entries should be similar.
Both matched entries should describe the same entity.
Try to suggest as many matches as possible.

Source Columns:
%s

Target Columns:
%s


Make sure to return the results in the following json format.

{
    'source_table1.source_column1': [{
    'mapping':'target_table1.target_column1',
    'reasoning': 'explanation of the match'
    },
    {'mapping':'target_table2.target_column2',
    'reasoning': 'explanation of the match'
    }, ...],
    'source_table2.source_column2': ...',
    ...
    }
}

Only return a json object and no other text.
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
All Table Descriptions:
%s

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
