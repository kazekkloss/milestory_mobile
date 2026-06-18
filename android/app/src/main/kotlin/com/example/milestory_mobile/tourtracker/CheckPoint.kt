package com.example.milestory_mobile.tourtracker

import android.util.Log

private data class TrackedArea(
    val id: String,
    val coordinates: List<Pair<Double, Double>>, // (lat, lng)
)

private data class TrackedTourPoint(
    val id: String,
    val areas: List<TrackedArea>,
)

class CheckPoint {

    private var tourPoints: List<TrackedTourPoint> = emptyList()
    private var currentAreaId: String? = null

    fun setTourPoints(raw: List<*>) {
        tourPoints = raw.mapNotNull { rawTp ->
            @Suppress("UNCHECKED_CAST")
            val tp = rawTp as? Map<String, Any> ?: return@mapNotNull null
            val id = tp["id"] as? String ?: return@mapNotNull null
            val areasRaw = tp["areas"] as? List<*> ?: return@mapNotNull null
            val areas = areasRaw.mapNotNull { rawArea ->
                @Suppress("UNCHECKED_CAST")
                val area = rawArea as? Map<String, Any> ?: return@mapNotNull null
                val areaId = area["id"] as? String ?: return@mapNotNull null
                val coordsRaw = area["coordinates"] as? List<*> ?: return@mapNotNull null
                val coords = coordsRaw.mapNotNull { rawCoord ->
                    @Suppress("UNCHECKED_CAST")
                    val coord = rawCoord as? Map<String, Any> ?: return@mapNotNull null
                    val lat = (coord["latitude"] as? Number)?.toDouble() ?: return@mapNotNull null
                    val lng = (coord["longitude"] as? Number)?.toDouble() ?: return@mapNotNull null
                    Pair(lat, lng)
                }
                TrackedArea(areaId, coords)
            }
            TrackedTourPoint(id, areas)
        }
        currentAreaId = null
        val totalAreas = tourPoints.sumOf { it.areas.size }
        Log.d(TAG, "CheckPoint: loaded ${tourPoints.size} tour points, $totalAreas areas total")
    }

    // Returns (tourPointId, areaId) if the user entered a new area, null otherwise.
    fun check(lat: Double, lng: Double): Pair<String, String>? {
        for (tp in tourPoints) {
            for (area in tp.areas) {
                if (pointInPolygon(lat, lng, area.coordinates)) {
                    if (area.id == currentAreaId) return null
                    currentAreaId = area.id
                    Log.d(TAG, "CHECKPOINT HIT — tourPoint: ${tp.id}, area: ${area.id}")
                    return Pair(tp.id, area.id)
                }
            }
        }
        currentAreaId = null
        return null
    }

    companion object {
        private const val TAG = "[TourTracker]"
    }

    // Ray-Casting algorithm: counts edge crossings to determine point-in-polygon.
    private fun pointInPolygon(lat: Double, lng: Double, polygon: List<Pair<Double, Double>>): Boolean {
        val n = polygon.size
        if (n < 3) return false
        var inside = false
        var j = n - 1
        for (i in 0 until n) {
            val xi = polygon[i].second; val yi = polygon[i].first
            val xj = polygon[j].second; val yj = polygon[j].first
            if ((yi > lat) != (yj > lat) && (lng < (xj - xi) * (lat - yi) / (yj - yi) + xi)) {
                inside = !inside
            }
            j = i
        }
        return inside
    }
}
