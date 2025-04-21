SELECT device_number, COUNT(device_number) AS CNT
FROM {{ ref('stg_device_name') }}
WHERE MOD(device_number, 2) = 0
GROUP BY device_number