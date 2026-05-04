import tabsdata as td


@td.transformer(
    input_tables=["bronze/staff_bronze"],
    output_tables=["staff_silver"],
)
def staff_silver_trf(staff_bronze: td.TableFrame) -> td.TableFrame:
    staff_silver = staff_bronze.select(
        [
            "Id",
            "EmpID",
            "FirstName",
            "LastName",
            "DisplayName",
            "Name",
            "Email",
            "HomePhone",
            "MobilePhone",
            "WorkPhone",
            "Address",
            "City",
            "State",
            "PostalCode",
            "Country",
            "IsMale",
            "Bio",
            "IndependentContractor",
            "AppointmentInstructor",
            "ClassTeacher",
            "ClassAssistant",
            "ClassAssistant2",
            "AlwaysAllowDoubleBooking",
            "Rep",
            "Rep2",
            "Rep3",
            "Rep4",
            "Rep5",
            "Rep6",
            "SortOrder",
            "EmploymentStart",
            "EmploymentEnd",
        ]
    )

    return staff_silver
