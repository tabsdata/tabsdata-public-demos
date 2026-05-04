import tabsdata as td


@td.transformer(
    input_tables=["bronze/classes_bronze"],
    output_tables=["classes_silver"],
)
def classes_silver_trf(classesbronze: td.TableFrame) -> td.TableFrame:
    classes_silver = classesbronze.select(
        [
            "ClassScheduleId",
            "Location__Id",
            "MaxCapacity",
            "WebCapacity",
            "TotalBooked",
            "TotalSignedIn",
            "TotalBookedWaitlist",
            "WebBooked",
            "Active",
            "IsWaitlistAvailable",
            "Id",
            "IsAvailable",
            "StartDateTime",
            "EndDateTime",
            "LastModifiedDateTime",
            "ClassDescription__Description",
            "ClassDescription__Level__Id",
            "ClassDescription__Level__Name",
            "ClassDescription__Name",
            "ClassDescription__Program__Id",
            "ClassDescription__Program__Name",
            "ClassDescription__Program__ScheduleType",
            "BookingStatus",
        ]
    )

    return classes_silver
