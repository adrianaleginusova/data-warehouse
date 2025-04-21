SELECT device_name, SPLIT_PART(device_name, '_', 2)::smallint AS device_number
FROM delivery_tracking