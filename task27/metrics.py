"""
100 * (1 - (irate(node_cpu_seconds_total{cpu="0", mode="idle", instance="172.31.35.104:9100"}[1m]))) > 80
(100 * ((node_memory_MemTotal_bytes{instance="172.31.47.210:9100"} - node_memory_MemFree_bytes{instance="172.31.47.210:9100"} - node_memory_Buffers_bytes{instance="172.31.47.210:9100"} - node_memory_Cached_bytes{instance="172.31.47.210:9100"} - node_memory_SReclaimable_bytes{instance="172.31.47.210:9100"}) / node_memory_MemTotal_bytes{instance="172.31.47.210:9100"})) > 60
"""
