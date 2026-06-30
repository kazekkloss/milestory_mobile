package com.example.milestory_mobile.tourtracker

import android.util.Log
import kotlin.math.abs

private data class TrackedArea(
    val id: String,
    val coordinates: List<Pair<Double, Double>>, // (lat, lng)
    val direction: Double?, // required heading to enter the area to trigger audio, degrees [0, 360)
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
                val direction = (area["direction"] as? Number)?.toDouble()
                val coordsRaw = area["coordinates"] as? List<*> ?: return@mapNotNull null
                val coords = coordsRaw.mapNotNull { rawCoord ->
                    @Suppress("UNCHECKED_CAST")
                    val coord = rawCoord as? Map<String, Any> ?: return@mapNotNull null
                    val lat = (coord["latitude"] as? Number)?.toDouble() ?: return@mapNotNull null
                    val lng = (coord["longitude"] as? Number)?.toDouble() ?: return@mapNotNull null
                    Pair(lat, lng)
                }
                TrackedArea(areaId, coords, direction)
            }
            TrackedTourPoint(id, areas)
        }
        currentAreaId = null
        val totalAreas = tourPoints.sumOf { it.areas.size }
        Log.d(TAG, "CheckPoint: loaded ${tourPoints.size} tour points, $totalAreas areas total")
    }

    // Returns (tourPointId, areaId) if the user entered a new area facing the
    // direction required by that area (if any), null otherwise. If the area
    // requires a direction that hasn't matched yet, the area is not marked as
    // handled so it keeps being re-evaluated on subsequent fixes until the user
    // either matches the direction or leaves the area.
    fun check(lat: Double, lng: Double, bearing: Double?): Pair<String, String>? {
        for (tp in tourPoints) {
            for (area in tp.areas) {
                if (pointInPolygon(lat, lng, area.coordinates)) {
                    if (area.id == currentAreaId) return null
                    if (area.direction != null) {
                        if (bearing == null) return null
                        if (angularDifference(bearing, area.direction) > DIRECTION_TOLERANCE_DEGREES) return null
                    }
                    currentAreaId = area.id
                    Log.d(TAG, "CHECKPOINT HIT — tourPoint: ${tp.id}, area: ${area.id}")
                    return Pair(tp.id, area.id)
                }
            }
        }
        currentAreaId = null
        return null
    }

    // Smallest difference between two compass bearings, in degrees [0, 180].
    private fun angularDifference(a: Double, b: Double): Double {
        val diff = abs(a - b) % 360.0
        return if (diff > 180.0) 360.0 - diff else diff
    }

    companion object {
        private const val TAG = "[TourTracker]"
        private const val DIRECTION_TOLERANCE_DEGREES = 45.0
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
