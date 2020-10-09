CREATE TABLE trips (
    vendor_id               TEXT,
    pickup_datetime         TEXT,
    dropoff_datetime        TEXT,
    passenger_count         INTEGER,
    trip_distance           REAL,
    rate_code_id            INTEGER,
    store_and_fwd_flag      TEXT,
    pu_location_id  INTEGER,
    do_location_id  INTEGER,
    payment_type INTEGER,
    fare_amount real,
    extra real,
    mta_tax real,
    tip_amount real,
    tolls_amount real,
    improvement_surcharge real,
    total_amount real
);