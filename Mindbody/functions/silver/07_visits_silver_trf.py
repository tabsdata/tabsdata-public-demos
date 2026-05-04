import tabsdata as td


@td.transformer(
    input_tables=["bronze/visits_bronze"],
    output_tables=["visits_silver"],
)
def visits_silver_trf(visits_bronze: td.TableFrame) -> td.TableFrame:
    visits_silver = visits_bronze.select(
        [
            "Id",
            "AppointmentId",
            "ClassId",
            "ClientId",
            "ClientUniqueId",
            "StaffId",
            "SiteId",
            "LocationId",
            "StartDateTime",
            "EndDateTime",
            "LastModifiedDateTime",
            "AppointmentStatus",
            "AppointmentGenderPreference",
            "SignedIn",
            "LateCancelled",
            "Missed",
            "MakeUp",
            "WebSignup",
            "ServiceId",
            "ServiceName",
            "ProductId",
            "Name",
            "Action",
            "VisitType",
            "TypeGroup",
            "Service__Id",
            "Service__Name",
            "Service__ProductId",
            "Service__Count",
            "Service__Remaining",
            "Service__Current",
            "Service__ActiveDate",
            "Service__ExpirationDate",
            "Service__PaymentDate",
            "Service__SiteId",
            "Service__ClientID",
            "Service__Returned",
            "Service__Action",
            "Service__Program__Id",
            "Service__Program__Name",
            "Service__Program__ScheduleType",
        ]
    )

    return visits_silver
