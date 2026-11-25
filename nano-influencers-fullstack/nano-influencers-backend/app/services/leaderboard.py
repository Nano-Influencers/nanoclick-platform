from dataclasses import dataclass

WEIGHTS = {"ts": 0.20, "cr": 0.30, "ar": 0.10, "tq": 0.20, "td": 0.20}
CATEGORY_COUNT = 7


@dataclass
class WorkerStats:
    worker_id: str
    avg_speed_minutes: float
    avg_client_rating: float
    tasks_approved: int
    tasks_rejected: int
    tasks_completed: int
    cat_counts: list[int]  # length-7, one per CW category


def compute_ts(avg_minutes: float, max_minutes: float) -> float:
    if max_minutes == 0:
        return 100.0
    return max(0.0, 100.0 - (avg_minutes / max_minutes * 100.0))


def compute_cr(avg_rating: float) -> float:
    return (avg_rating / 5.0) * 100.0


def compute_ar(approved: int, rejected: int) -> float:
    total = approved + rejected
    return 100.0 if total == 0 else (approved / total * 100.0)


def compute_tq(worker_count: int, top_count: int) -> float:
    return 0.0 if top_count == 0 else (worker_count / top_count * 100.0)


def compute_td(cat_counts: list[int], available_cats: list[bool] | None = None) -> float:
    if available_cats is None:
        available_cats = [True] * CATEGORY_COUNT

    available_idx = [i for i, av in enumerate(available_cats) if av]
    if not available_idx:
        return 0.0

    performed = [i for i in available_idx if cat_counts[i] > 0]

    # Case 2: missed any available category → TD = 0
    if len(performed) < len(available_idx):
        return 0.0

    # Cases 1 & 3
    max_val = max(cat_counts[i] for i in available_idx)
    if max_val == 0:
        return 0.0
    depth = sum(cat_counts[i] / max_val for i in available_idx) / len(available_idx)
    return round(((1.0 * 0.5) + (depth * 0.5)) * 100.0, 2)


def compute_total(ts: float, cr: float, ar: float, tq: float, td: float) -> float:
    return round(ts * WEIGHTS["ts"] + cr * WEIGHTS["cr"] + ar * WEIGHTS["ar"] +
                 tq * WEIGHTS["tq"] + td * WEIGHTS["td"], 2)


def score_worker_pool(workers: list[WorkerStats], available_cats: list[bool] | None = None) -> list[dict]:
    if not workers:
        return []
    max_speed = max(w.avg_speed_minutes for w in workers) or 1.0
    top_count = max(w.tasks_completed for w in workers) or 1
    results = []
    for w in workers:
        ts = compute_ts(w.avg_speed_minutes, max_speed)
        cr = compute_cr(w.avg_client_rating)
        ar = compute_ar(w.tasks_approved, w.tasks_rejected)
        tq = compute_tq(w.tasks_completed, top_count)
        td = compute_td(w.cat_counts, available_cats)
        total = compute_total(ts, cr, ar, tq, td)
        results.append({"worker_id": w.worker_id, "ts_score": round(ts, 2), "cr_score": round(cr, 2),
                         "ar_score": round(ar, 2), "tq_score": round(tq, 2), "td_score": td, "total_score": total})
    results.sort(key=lambda x: x["total_score"], reverse=True)
    for rank, row in enumerate(results, 1):
        row["rank"] = rank
    return results
