from pylatex import Document, Tabu, MultiColumn, Section, Subsection

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

experiments = ["imdb-sakila", "omop-cms", "cprd_aurum-omop", "cprd_gold-omop", "mimic_iii-omop"]


def hilight_max(row):
    return row


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


def generate_performance_table():
    from llm_ontology_alignment.evaluations.ontology_matching_evaluation import get_evaluation_result_table

    performance_table = Tabu("|p{2cm}ccccccccccccccc|")
    performance_table.add_hline()
    row = ["Method"]
    for experiment in experiments:
        source, target = experiment.split("-")
        row.append(MultiColumn(3, data=f"{schema_name_mapping[source]}-{schema_name_mapping[target]}"))

    performance_table.add_row(row)
    performance_table.add_hline()
    performance_table.add_row([""] + ["P", "R", "F1"] * len(experiments))
    performance_table.add_hline()
    rows = get_evaluation_result_table(experiments)
    for row in rows:
        performance_table.add_row(row, escape=False, mapper=hilight_max)
    performance_table.add_hline()
    return performance_table


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
    table1 = genenerate_schema_statistics_table()
    table2 = generate_performance_table()
    table2_tex = table2.dumps()
    section = Section("Multirow Test")

    test1 = Subsection("Schema Statistics")
    test2 = Subsection("Performance")
    test1.append(table1)
    # test2.append(HorizontalSpace("-1cm", star=False))
    test2.append(table2)
    section.append(test1)
    section.append(test2)
    doc.append(section)
    import os

    script_dir = os.path.dirname(__file__)
    file_path = os.path.join(
        script_dir,
        "../../..",
        "plots/latex/schema_statistics_table",
    )
    # doc.generate_pdf(file_path, clean_tex=False)
    doc.generate_tex(file_path)
