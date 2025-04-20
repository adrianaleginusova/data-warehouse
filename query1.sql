SELECT count(tracking_key) AS CNT,
       nd.country,
       nd.network,
       td.month
FROM delivery_tracking_fact AS dtf
         LEFT JOIN network_dimension AS nd
                   ON dtf.network_key_fk = nd.network_key
         LEFT JOIN time_dimension AS td
                   ON dtf.time_key_fk = td.time_key
GROUP BY country, network, month
ORDER BY CNT desc, country, network, month
LIMIT 10;
