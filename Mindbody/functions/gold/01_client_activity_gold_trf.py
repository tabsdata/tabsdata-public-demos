import tabsdata as td


@td.transformer(
    input_tables=[
        "silver/clients_silver",
        "silver/visits_silver",
        "silver/purchases_silver",
    ],
    output_tables=["client_activity_gold"],
)
def client_activity_gold_trf(
    clients_silver: td.TableFrame,
    visits_silver: td.TableFrame,
    purchases_silver: td.TableFrame,
) -> td.TableFrame:
    if clients_silver is None or clients_silver.is_empty():
        return None

    client_activity = clients_silver.select(["Id", "FirstName", "LastName", "Email"])

    if visits_silver is not None and not visits_silver.is_empty():
        visit_counts = visits_silver.group_by(td.col("ClientId")).agg(
            (td.col("ClassId") > 0).sum().alias("num_classes"),
            (td.col("AppointmentId") > 0).sum().alias("num_visits"),
        )
        client_activity = client_activity.join(
            visit_counts, left_on="Id", right_on="ClientId", how="left"
        )
        client_activity = client_activity.with_columns(
            td.col("num_classes").fill_null(0),
            td.col("num_visits").fill_null(0),
        )
    else:
        client_activity = client_activity.with_columns(
            td.lit(0).alias("num_classes"),
            td.lit(0).alias("num_visits"),
        )

    if purchases_silver is not None and not purchases_silver.is_empty():
        purchase_counts = purchases_silver.group_by(td.col("sale__ClientId")).agg(
            td.col("sale__Id").count().alias("num_purchases"),
            td.col("item__TotalAmount").sum().alias("total_purchase_amount"),
        )
        client_activity = client_activity.join(
            purchase_counts, left_on="Id", right_on="sale__ClientId", how="left"
        )
        client_activity = client_activity.with_columns(
            td.col("num_purchases").fill_null(0),
            td.col("total_purchase_amount").fill_null(0.0),
        )
    else:
        client_activity = client_activity.with_columns(
            td.lit(0).alias("num_purchases"),
            td.lit(0.0).alias("total_purchase_amount"),
        )

    client_activity = client_activity.filter(
        (td.col("num_classes") > 0)
        | (td.col("num_visits") > 0)
        | (td.col("num_purchases") > 0)
    )

    return client_activity
