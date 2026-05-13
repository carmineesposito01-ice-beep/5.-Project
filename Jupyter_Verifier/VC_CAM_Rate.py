# VC_CAM_Rate
# Simple stub: given a time-stamped sequence of CAM events, measure update rate and jitter.

def measure_cam_rate(timestamps):
    # timestamps: list of float seconds
    if len(timestamps) < 2:
        return 0.0, 0.0
    intervals = [t2 - t1 for t1, t2 in zip(timestamps, timestamps[1:])]
    import statistics
    mean_interval = statistics.mean(intervals)
    jitter = statistics.pstdev(intervals)
    rate = 1.0 / mean_interval if mean_interval > 0 else 0.0
    return rate, jitter

if __name__ == '__main__':
    # Example usage with synthetic timestamps
    ts = [i*0.1 for i in range(100)]  # 10 Hz
    rate, jitter = measure_cam_rate(ts)
    print(f"Measured rate: {rate:.2f} Hz, jitter: {jitter:.6f} s")
