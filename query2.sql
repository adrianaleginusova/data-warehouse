SELECT dd.device_name,
       round(avg(app_duration), 2) AS avg_app_duration
FROM delivery_tracking_fact AS dtf
         LEFT JOIN device_dimension AS dd
                   ON dtf.device_key_fk = dd.device_key
         LEFT JOIN time_dimension AS td
                   ON dtf.time_key_fk = td.time_key AND td.month = 'March'
GROUP BY device_name
ORDER BY avg_app_duration DESC;
