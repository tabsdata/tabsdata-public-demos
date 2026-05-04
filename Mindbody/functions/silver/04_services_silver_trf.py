import tabsdata as td


@td.transformer(
    input_tables=["bronze/services_bronze"],
    output_tables=["services_silver"],
)
def services_silver_trf(services_bronze: td.TableFrame) -> td.TableFrame:
    services_silver = services_bronze.select(
        [
            "Id",
            "Name",
            "Type",
            "Price",
            "OnlinePrice",
            "TaxIncluded",
            "TaxRate",
            "ProgramId",
            "Program",
            "ProductId",
            "Count",
            "ExpirationLength",
            "ExpirationType",
            "ExpirationUnit",
            "RevenueCategory",
            "MembershipId",
            "Priority",
            "IsIntroOffer",
            "IntroOfferType",
            "SellOnline",
            "SaleInContractOnly",
            "IsThirdPartyDiscountPricing",
            "Discontinued",
        ]
    )

    return services_silver
