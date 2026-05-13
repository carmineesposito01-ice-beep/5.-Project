# VC_CAM_ForwardingLatency
# Stub: measure E2E latency by correlating CAM send/receive timestamps.

def measure_e2e_latency(send_times, recv_times):
    # send_times and recv_times are lists of floats (s)
    # naive correlation: assume same ordering and equal counts
    if not send_times or not recv_times:
        return []
    n = min(len(send_times), len(recv_times))
    latencies = [recv_times[i] - send_times[i] for i in range(n)]
    return latencies

if __name__ == '__main__':
    sends = [0.0, 0.1, 0.2, 0.3]
    recvs = [0.015, 0.118, 0.219, 0.322]
    lats = measure_e2e_latency(sends, recvs)
    import statistics
    print(f"Mean latency: {statistics.mean(lats)*1000:.1f} ms")
