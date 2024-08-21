from pylatex import Document, Tabu, MultiColumn, Section, Subsection

from llm_ontology_alignment.constants import EXPERIMENTS

schema_name_mapping = {
    "cprd_aurum": "CPRD Aurum",
    "cprd_gold": "CPRD Gold",
    "mimic_iii": "MIMIC",
    "omop": "OMOP",
    "cms": "CMS",
    "imdb": "IMDB",
    "sakila": "Sakila",
}

domain_mapping = {
    "cprd_aurum": "Healthcare",
    "cprd_gold": "Healthcare",
    "mimic_iii": "Healthcare",
    "omop": "Healthcare",
    "cms": "Healthcare",
    "imdb": "Entertainment",
    "sakila": "Entertainment",
}


def format_max_value(rows, underline_second_best=False):
    # bold best performance and underline second best performance for each column
    for i in range(1, len(rows[0])):
        col = [row[i] for row in rows]
        best = max(col)
        second_best = sorted(col)[-2]
        for row in rows:
            if row[i] == best:
                row[i] = f"\\textbf{{{f'{row[i]:.3f}'}}}"
            elif row[i] == second_best and underline_second_best:
                row[i] = f"\\underline{{{f'{row[i]:.3f}'}}}"
            else:
                row[i] = f"{f'{row[i]:.3f}'}"

    return rows


def genenerate_schema_statistics_table():
    # Generate data table
    data_table = Tabu("|llcccc|")
    data_table.add_hline()
    data_table.add_row(
        ["Schema", "Domain", "Total Tables", "Total Columns", "Total Foreign Keys", "Total Primary Keys"]
    )
    data_table.add_hline()

    # data_table.add_row((MultiColumn(3, align="r", data="Continued on Next Page"),))

    from llm_ontology_alignment.evaluations.extended_study_evaluation import dataset_statistics_rows

    rows = dataset_statistics_rows()
    for row in rows:
        dataset = row[0]
        data_table.add_row(
            [
                schema_name_mapping[dataset],
                domain_mapping[dataset],
            ]
            + row[1:]
        )
        data_table.add_hline()
    return data_table


def generate_single_table_matching_result_table():
    from llm_ontology_alignment.evaluations.ontology_matching_evaluation import get_single_table_experiment_full_results

    results = get_single_table_experiment_full_results()
    table = Tabu("|ccccc|")
    table.add_hline()
    header = ["Method"]
    experiments = list(results.values())[0].keys()
    # for experiment in experiments:
    # source, target = experiment.split("-")
    # header.append(MultiColumn(3, data=f"{schema_name_mapping[source]}-{schema_name_mapping[target]}"))

    # header.append(f"{schema_name_mapping[source]}-{schema_name_mapping[target]}")
    header += experiments
    table.add_row(header)
    rows = []
    for strategy in results:
        row = [f"{{{strategy.split('Rewrite:')[0].strip().replace('_', ' ').title()}}}"]
        for experiment in experiments:
            row.append(results[strategy][experiment].f1_score)
        rows.append(row)
    table.add_hline()
    rows = format_max_value(rows)
    for row in rows:
        table.add_row(row, escape=False)
        table.add_hline()
    return table


def generate_performance_table():
    from llm_ontology_alignment.evaluations.ontology_matching_evaluation import get_evaluation_result_table

    performance_table = Tabu("|p{4cm}p{0.6cm}p{0.6cm}p{0.6cm}p{0.6cm}p{0.6cm}|")
    performance_table.add_hline()
    row = ["Method"]
    for experiment in EXPERIMENTS:
        source, target = experiment.split("-")
        row.append(MultiColumn(1, data=f"{schema_name_mapping[source]}-{schema_name_mapping[target]}"))

    performance_table.add_row(row)
    performance_table.add_hline()
    performance_table.add_row([""] + ["F1"] * len(EXPERIMENTS))
    performance_table.add_hline()
    rows = get_evaluation_result_table(EXPERIMENTS)
    for row in rows:
        performance_table.add_row(row, escape=False)
    performance_table.add_hline()
    return performance_table


def generate_matching_candidate_selection_table():
    from llm_ontology_alignment.evaluations.extended_study_evaluation import matching_table_candidate_selection_study

    result = matching_table_candidate_selection_study()
    # table = Tabu(
    #     "|p{2cm}ccccc|"
    # )
    table = Tabu(
        "|p{4cm}p{0.6cm}p{0.6cm}p{0.6cm}p{0.6cm}p{0.6cm}p{0.6cm}p{0.6cm}p{0.6cm}p{0.6cm}p{0.6cm}p{0.6cm}p{0.6cm}p{0.6cm}p{0.6cm}p{0.6cm}|"
    )
    table.add_hline()
    header = ["Method"]
    for experiment in EXPERIMENTS:
        source, target = experiment.split("-")
        header.append(MultiColumn(3, data=f"{schema_name_mapping[source]}-{schema_name_mapping[target]}"))

        # header.append(f"{schema_name_mapping[source]}-{schema_name_mapping[target]}")
    table.add_row(header)
    rows = []
    for strategy in ["Vector Similarity (column to table)", "LLM Selection"]:
        row = [strategy]
        for experiment in EXPERIMENTS:
            row += result[strategy][experiment]
        rows.append(row)
    rows = format_max_value(rows)
    for row in rows:
        table.add_row(row, escape=False)
        table.add_hline()
    table.add_hline()
    return table


if __name__ == "__main__":
    from pylatex.package import Package
    from pylatex.base_classes import Environment

    geometry_options = {"margin": "2.54cm", "includeheadfoot": True}

    class AllTT(Environment):
        """A class to wrap LaTeX's alltt environment."""

        packages = [Package("adjustbox")]
        escape = False
        content_separator = "\n"

    doc = Document(AllTT(), page_numbers=True, geometry_options=geometry_options)
    # table1 = genenerate_schema_statistics_table()
    table2 = generate_performance_table()
    table2_tex = table2.dumps()
    section = Section("Multirow Test")

    test1 = Subsection("Schema Statistics")
    section2 = Subsection("Performance")
    test1.append(table2)
    # test2.append(HorizontalSpace("-1cm", star=False))
    # section2.append(table2)
    # candidate_selection_table = generate_matching_candidate_selection_table()
    # single_table_matching_result = generate_single_table_matching_result_table()
    # section2.append(candidate_selection_table)
    section.append(test1)
    section.append(section2)
    doc.append(section)
    import os

    script_dir = os.path.dirname(__file__)
    file_path = os.path.join(
        script_dir,
        # "../../../plots/latex",
        "schema_statistics_table",
    )
    # doc.generate_pdf(file_path, clean_tex=False)
    doc.generate_tex(file_path)
