import tabsdata as td


@td.transformer(
    input_tables=["bronze/products_bronze"],
    output_tables=["products_silver"],
)
def products_silver_trf(products_bronze: td.TableFrame) -> td.TableFrame:
    products_silver = products_bronze.select(
        [
            "ProductId",
            "Id",
            "Name",
            "ShortDescription",
            "LongDescription",
            "CategoryId",
            "SubCategoryId",
            "SecondaryCategoryId",
            "GroupId",
            "Price",
            "OnlinePrice",
            "TaxIncluded",
            "TaxRate",
            "SupplierId",
            "SupplierName",
            "ManufacturerId",
            "Color__Id",
            "Color__Name",
            "Size__Id",
            "Size__Name",
        ]
    )

    return products_silver
