import tabsdata as td


@td.transformer(
    input_tables=["bronze/purchases_bronze"],
    output_tables=["purchases_silver"],
)
def purchases_silver_trf(purchases_bronze: td.TableFrame) -> td.TableFrame:
    purchases_silver = purchases_bronze.select(
        [
            "sale__Id",
            "sale__SaleDate",
            "sale__SaleTime",
            "sale__SaleDateTime",
            "sale__OriginalSaleDateTime",
            "sale__SalesRepId",
            "sale__ClientId",
            "sale__RecipientClientId",
            "sale__LocationId",
            "item__SaleDetailId",
            "item__Id",
            "item__IsService",
            "item__Description",
            "item__ContractId",
            "item__CategoryId",
            "item__SubCategoryId",
            "item__UnitPrice",
            "item__Quantity",
            "item__DiscountPercent",
            "item__DiscountAmount",
            "item__Tax1",
            "item__Tax2",
            "item__Tax3",
            "item__Tax4",
            "item__Tax5",
            "item__TaxAmount",
            "item__TotalAmount",
            "item__Returned",
            "item__PaymentRefId",
            "item__ExpDate",
            "item__ActiveDate",
            "item__RecipientClientId",
        ]
    )

    return purchases_silver
