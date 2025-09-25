import tabsdata as td

@td.transformer(
    input_tables=["customers_raw"],
    output_tables=["customers_processed"],
)
def trf(tf: td.TableFrame):
    tf = tf.with_columns((td.col('FIRST_NAME')+ " " + td.col("LAST_NAME")).alias("FULL_NAME"))
    return tf