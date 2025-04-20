DROP TABLE IF EXISTS device_dimension CASCADE;
DROP TABLE IF EXISTS time_dimension CASCADE;
DROP TABLE IF EXISTS operator_dimension CASCADE;
DROP TABLE IF EXISTS network_dimension CASCADE;
DROP TABLE IF EXISTS tracking_fact CASCADE;
DROP TABLE IF EXISTS delivery_tracking_fact CASCADE;

CREATE TABLE time_dimension
(
    time_key    SERIAL PRIMARY KEY,
    minute      SMALLINT NOT NULL,
    hour        SMALLINT NOT NULL,
    day         SMALLINT NOT NULL,
    month       TEXT     NOT NULL,
    year        SMALLINT NOT NULL,
    day_of_week TEXT     NOT NULL
);

CREATE TABLE device_dimension
(
    device_key  SERIAL PRIMARY KEY,
    device_name TEXT
);

CREATE TABLE network_dimension
(
    network_key SERIAL PRIMARY KEY,
    network_id  VARCHAR(15) NOT NULL,
    country     TEXT,
    network     TEXT
);

CREATE TABLE delivery_tracking_fact
(
    tracking_key    SERIAL PRIMARY KEY,
    time_key_fk     BIGINT,
    device_key_fk   BIGINT,
    network_key_fk  BIGINT,
    sim_imsi        VARCHAR(15),
    app_version     VARCHAR(6),
    app_duration    NUMERIC(6, 2),
    device_duration NUMERIC(6, 2),
    constraint fk_time_key foreign key (time_key_fk) REFERENCES time_dimension (time_key) ON DELETE SET NULL,
    constraint fk_device_key foreign key (device_key_fk) REFERENCES device_dimension (device_key) ON DELETE SET NULL,
    constraint fk_network_key foreign key (network_key_fk) REFERENCES network_dimension (network_key) ON DELETE SET NULL
);

INSERT INTO device_dimension (device_name)
SELECT DISTINCT device_name
FROM delivery_tracking
WHERE device_name IS NOT null;

INSERT INTO device_dimension (device_key, device_name)
VALUES (-1, 'unknown');

INSERT INTO network_dimension (network_id)
SELECT DISTINCT network_id
FROM delivery_tracking
WHERE network_id IS NOT null;

INSERT INTO network_dimension (network_key, network_id, country, network)
VALUES (-1, 'unknown', 'unknown', 'unknown');

INSERT INTO time_dimension (minute, hour, day, month, year, day_of_week)
SELECT DISTINCT EXTRACT('MINUTE' FROM recorded_at),
                EXTRACT('HOUR' FROM recorded_at),
                EXTRACT('Day' FROM recorded_at),
                TRIM(TO_CHAR(recorded_at, 'Month')),
                EXTRACT('Year' FROM recorded_at),
                TRIM(TO_CHAR(recorded_at, 'Day'))
FROM delivery_tracking
WHERE recorded_at IS NOT NULL;

INSERT INTO delivery_tracking_fact (time_key_fk, device_key_fk, network_key_fk, sim_imsi, app_version, app_duration,
                                    device_duration)
SELECT DISTINCT
    ON (data.log_id) t.time_key,
                     d.device_key,
                     n.network_key,
                     data.sim_imsi,
                     data.app_version,
                     data.app_duration,
                     data.device_duration
FROM delivery_tracking data
         LEFT JOIN device_dimension AS d
                   ON data.device_name = d.device_name
         LEFT JOIN time_dimension AS t ON
    (EXTRACT('MINUTE' FROM data.recorded_at) = t.minute and
     EXTRACT('HOUR' FROM data.recorded_at) = t.hour and
     EXTRACT('Day' FROM data.recorded_at) = t.day and
     TRIM(TO_CHAR(recorded_at, 'Month')) = t.month and
     EXTRACT('Year' FROM data.recorded_at) = t.year and
     TRIM(TO_CHAR(recorded_at, 'Day')) = t.day_of_week)
         LEFT JOIN network_dimension AS n ON data.network_id = n.network_id;


UPDATE delivery_tracking_fact
SET device_key_fk = -1
WHERE device_key_fk IS NULL;

UPDATE delivery_tracking_fact
SET network_key_fk = -1
WHERE network_key_fk IS NULL;

UPDATE network_dimension
SET network_id = 'unknown',
    country    = 'unknown',
    network    = 'unknown'
WHERE network_key = -1;
UPDATE network_dimension
SET network_id = '1',
    country    = 'Netherlands',
    network    = 'Vodafone'
WHERE network_key = 66;
UPDATE network_dimension
SET network_id = '10',
    country    = 'Netherlands',
    network    = 'KPN'
WHERE network_key = 17;
UPDATE network_dimension
SET network_id = '11',
    country    = 'Netherlands',
    network    = 'T-Mobile'
WHERE network_key = 12;
UPDATE network_dimension
SET network_id = '12',
    country    = 'Belgium',
    network    = 'Proximus'
WHERE network_key = 25;
UPDATE network_dimension
SET network_id = '13',
    country    = 'Belgium',
    network    = 'Mobistar / Orange'
WHERE network_key = 20;
UPDATE network_dimension
SET network_id = '14',
    country    = 'Belgium',
    network    = 'Base'
WHERE network_key = 72;
UPDATE network_dimension
SET network_id = '15',
    country    = 'France',
    network    = 'Orange'
WHERE network_key = 37;
UPDATE network_dimension
SET network_id = '16',
    country    = 'France',
    network    = 'SFR'
WHERE network_key = 11;
UPDATE network_dimension
SET network_id = '17',
    country    = 'France',
    network    = 'Free Mobile'
WHERE network_key = 67;
UPDATE network_dimension
SET network_id = '18',
    country    = 'France',
    network    = 'Bouygues Telecom'
WHERE network_key = 50;
UPDATE network_dimension
SET network_id = '19',
    country    = 'Spain',
    network    = 'Vodafone'
WHERE network_key = 31;
UPDATE network_dimension
SET network_id = '2',
    country    = 'Spain',
    network    = 'Orange'
WHERE network_key = 30;
UPDATE network_dimension
SET network_id = '20',
    country    = 'Spain',
    network    = 'Yoigo'
WHERE network_key = 45;
UPDATE network_dimension
SET network_id = '21',
    country    = 'Spain',
    network    = 'Movistar'
WHERE network_key = 33;
UPDATE network_dimension
SET network_id = '22',
    country    = 'Hungary',
    network    = 'Telenor'
WHERE network_key = 79;
UPDATE network_dimension
SET network_id = '23',
    country    = 'Hungary',
    network    = 'Telekom'
WHERE network_key = 27;
UPDATE network_dimension
SET network_id = '24',
    country    = 'Hungary',
    network    = 'Vodafone'
WHERE network_key = 44;
UPDATE network_dimension
SET network_id = '25',
    country    = 'Croatia',
    network    = 'Telemach / Tele2'
WHERE network_key = 54;
UPDATE network_dimension
SET network_id = '26',
    country    = 'Croatia',
    network    = 'A1 / VIP'
WHERE network_key = 28;
UPDATE network_dimension
SET network_id = '27',
    country    = 'Serbia',
    network    = 'Telenor'
WHERE network_key = 70;
UPDATE network_dimension
SET network_id = '28',
    country    = 'Serbia',
    network    = 'MTS'
WHERE network_key = 74;
UPDATE network_dimension
SET network_id = '29',
    country    = 'Serbia',
    network    = 'VIP'
WHERE network_key = 42;
UPDATE network_dimension
SET network_id = '3',
    country    = 'Italy',
    network    = 'TIM'
WHERE network_key = 63;
UPDATE network_dimension
SET network_id = '30',
    country    = 'Italy',
    network    = 'Vodafone'
WHERE network_key = 69;
UPDATE network_dimension
SET network_id = '31',
    country    = 'Italy',
    network    = 'WindTre / WIND'
WHERE network_key = 1;
UPDATE network_dimension
SET network_id = '32',
    country    = 'Romania',
    network    = 'Vodafone'
WHERE network_key = 49;
UPDATE network_dimension
SET network_id = '33',
    country    = 'Romania',
    network    = 'Orange'
WHERE network_key = 65;
UPDATE network_dimension
SET network_id = '34',
    country    = 'Switzerland',
    network    = 'Swisscom'
WHERE network_key = 19;
UPDATE network_dimension
SET network_id = '35',
    country    = 'Switzerland',
    network    = 'Sunrise'
WHERE network_key = 15;
UPDATE network_dimension
SET network_id = '36',
    country    = 'Switzerland',
    network    = 'Salt Mobile'
WHERE network_key = 61;
UPDATE network_dimension
SET network_id = '37',
    country    = 'Czech Republic',
    network    = 'T-Mobile'
WHERE network_key = 36;
UPDATE network_dimension
SET network_id = '38',
    country    = 'Czech Republic',
    network    = 'O2'
WHERE network_key = 5;
UPDATE network_dimension
SET network_id = '39',
    country    = 'Czech Republic',
    network    = 'Vodafone'
WHERE network_key = 23;
UPDATE network_dimension
SET network_id = '4',
    country    = 'Slovakia',
    network    = 'Orange'
WHERE network_key = 8;
UPDATE network_dimension
SET network_id = '40',
    country    = 'Slovakia',
    network    = 'Telekom'
WHERE network_key = 13;
UPDATE network_dimension
SET network_id = '41',
    country    = 'Slovakia',
    network    = 'O2'
WHERE network_key = 68;
UPDATE network_dimension
SET network_id = '42',
    country    = 'Austria',
    network    = 'A1 Telekom'
WHERE network_key = 35;
UPDATE network_dimension
SET network_id = '43',
    country    = 'Austria',
    network    = 'T-Mobile / Magenta'
WHERE network_key = 51;
UPDATE network_dimension
SET network_id = '44',
    country    = 'Austria',
    network    = 'Hutchinson Drei'
WHERE network_key = 78;
UPDATE network_dimension
SET network_id = '45',
    country    = 'Austria',
    network    = 'Hutchinson Drei'
WHERE network_key = 56;
UPDATE network_dimension
SET network_id = '46',
    country    = 'United Kingdom',
    network    = 'O2'
WHERE network_key = 52;
UPDATE network_dimension
SET network_id = '48',
    country    = 'United Kingdom',
    network    = 'Vodafone'
WHERE network_key = 71;
UPDATE network_dimension
SET network_id = '49',
    country    = 'United Kingdom',
    network    = '3'
WHERE network_key = 34;
UPDATE network_dimension
SET network_id = '5',
    country    = 'United Kingdom',
    network    = 'T-Mobile'
WHERE network_key = 16;
UPDATE network_dimension
SET network_id = '51',
    country    = 'Denmark',
    network    = 'TDC'
WHERE network_key = 7;
UPDATE network_dimension
SET network_id = '52',
    country    = 'Denmark',
    network    = 'Telenor'
WHERE network_key = 6;
UPDATE network_dimension
SET network_id = '53',
    country    = 'Denmark',
    network    = '3'
WHERE network_key = 47;
UPDATE network_dimension
SET network_id = '54',
    country    = 'Denmark',
    network    = 'Telia'
WHERE network_key = 10;
UPDATE network_dimension
SET network_id = '55',
    country    = 'Sweden',
    network    = 'Telia'
WHERE network_key = 73;
UPDATE network_dimension
SET network_id = '56',
    country    = 'Sweden',
    network    = '3'
WHERE network_key = 40;
UPDATE network_dimension
SET network_id = '57',
    country    = 'Sweden',
    network    = 'Tele2'
WHERE network_key = 58;
UPDATE network_dimension
SET network_id = '58',
    country    = 'Sweden',
    network    = 'Telenor'
WHERE network_key = 62;
UPDATE network_dimension
SET network_id = '59',
    country    = 'Sweden',
    network    = 'Telenor'
WHERE network_key = 77;
UPDATE network_dimension
SET network_id = '6',
    country    = 'Finland',
    network    = 'Elisa'
WHERE network_key = 21;
UPDATE network_dimension
SET network_id = '60',
    country    = 'Finland',
    network    = 'Telia'
WHERE network_key = 4;
UPDATE network_dimension
SET network_id = '61',
    country    = 'Lithuania',
    network    = 'Tele2'
WHERE network_key = 48;
UPDATE network_dimension
SET network_id = '62',
    country    = 'Latvia',
    network    = 'Tele2'
WHERE network_key = 24;
UPDATE network_dimension
SET network_id = '63',
    country    = 'Estonia',
    network    = 'Elisa'
WHERE network_key = 41;
UPDATE network_dimension
SET network_id = '64',
    country    = 'Poland',
    network    = 'Plus'
WHERE network_key = 38;
UPDATE network_dimension
SET network_id = '65',
    country    = 'Poland',
    network    = 'T-Mobile'
WHERE network_key = 3;
UPDATE network_dimension
SET network_id = '66',
    country    = 'Poland',
    network    = 'Orange'
WHERE network_key = 46;
UPDATE network_dimension
SET network_id = '67',
    country    = 'Poland',
    network    = 'Play'
WHERE network_key = 64;
UPDATE network_dimension
SET network_id = '68',
    country    = 'Germany',
    network    = 'Telekom / T-mobile'
WHERE network_key = 53;
UPDATE network_dimension
SET network_id = '69',
    country    = 'Germany',
    network    = 'Vodafone'
WHERE network_key = 75;
UPDATE network_dimension
SET network_id = '7',
    country    = 'Germany',
    network    = 'Telefonica / E-Plus'
WHERE network_key = 29;
UPDATE network_dimension
SET network_id = '70',
    country    = 'Portugal',
    network    = 'Vodafone'
WHERE network_key = 55;
UPDATE network_dimension
SET network_id = '71',
    country    = 'Portugal',
    network    = 'MEO'
WHERE network_key = 59;
UPDATE network_dimension
SET network_id = '72',
    country    = 'Luxembourg',
    network    = 'Post'
WHERE network_key = 76;
UPDATE network_dimension
SET network_id = '73',
    country    = 'Luxembourg',
    network    = 'Tango'
WHERE network_key = 26;
UPDATE network_dimension
SET network_id = '74',
    country    = 'Luxembourg',
    network    = 'Orange'
WHERE network_key = 9;
UPDATE network_dimension
SET network_id = '75',
    country    = 'Ireland',
    network    = 'Vodafone'
WHERE network_key = 57;
UPDATE network_dimension
SET network_id = '8',
    country    = 'Ireland',
    network    = '3'
WHERE network_key = 18;
UPDATE network_dimension
SET network_id = '9',
    country    = 'Slovenia',
    network    = 'A1 / Si.mobil'
WHERE network_key = 22;
UPDATE network_dimension
SET network_id = '26',
    country    = 'Slovakia',
    network    = 'Telekom'
WHERE network_key = 2;
UPDATE network_dimension
SET network_id = '45',
    country    = 'Slovakia',
    network    = 'Telekom'
WHERE network_key = 32;
UPDATE network_dimension
SET network_id = '25',
    country    = 'Slovakia',
    network    = 'Telekom'
WHERE network_key = 14;
UPDATE network_dimension
SET network_id = '11',
    country    = 'Slovakia',
    network    = 'O2'
WHERE network_key = 39;
UPDATE network_dimension
SET network_id = '42',
    country    = 'Slovakia',
    network    = 'O2'
WHERE network_key = 43;
UPDATE network_dimension
SET network_id = '59',
    country    = 'Slovakia',
    network    = 'O2'
WHERE network_key = 60;
