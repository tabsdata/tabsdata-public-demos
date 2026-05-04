import tabsdata as td


@td.transformer(
    input_tables=["bronze/locations_bronze"],
    output_tables=["locations_silver"],
)
def locations_silver_trf(locations_bronze: td.TableFrame) -> td.TableFrame:
    locations_silver = locations_bronze.select(
        [
            "Address",
            "Address2",
            "Amenities",
            "BusinessDescription",
            "City",
            "Id",
            "HasClasses",
            "Name",
            "Phone",
            "PostalCode",
            "StateProvCode",
        ]
    )

    return locations_silver
