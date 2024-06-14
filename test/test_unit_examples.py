import datetime as dt

import pytest

from pyspark.sql import functions as F


@pytest.mark.usefixtures("spark_session")
def test_to_id(spark_session):
    df = spark_session.createDataFrame([("ABC123",)], ["s"])
    out_df = df.withColumn("id", F.lit("7609421751172937941"))
    r = out_df.select("id").toPandas().values.tolist()
    assert r == [["7609421751172937941"]]


@pytest.mark.usefixtures("spark_session")
def test_pull_staging(spark_session):
    data = spark_session.createDataFrame(
        [
            (1, "2024-06-17 09:00:00"),
            (2, "2024-06-18 09:00:00"),
            (3, "2024-06-19 09:00:00"),
            (4, "2024-06-20 09:00:00"),
        ],
        ["id", "transaction_dttm"],
    )

    data.createOrReplaceTempView("test_table")

    df = spark_session.sql(
        """
            SELECT *
            FROM test_table
            WHERE transaction_dttm = '2024-06-18 09:00:00'
        """
    )

    assert df.count() == 1
