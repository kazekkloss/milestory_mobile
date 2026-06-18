package com.example.milestory_mobile.tourtracker

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.location.Location
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat

class LocationForegroundService : Service() {

    private lateinit var locationManager: LocationManager

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "onCreate")
        locationManager = LocationManager(this).apply {
            onLocationUpdate = { location -> locationUpdateCallback?.invoke(location) }
            onError = { message ->
                Log.e(TAG, "location error: $message")
                errorCallback?.invoke(message)
            }
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "onStartCommand — starting foreground + location")
        startForeground(NOTIFICATION_ID, buildNotification())
        locationManager.start()
        return START_STICKY
    }

    override fun onDestroy() {
        Log.d(TAG, "onDestroy — stopping location")
        locationManager.stop()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun buildNotification(): Notification {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Tour Tracking",
                NotificationManager.IMPORTANCE_LOW,
            ).apply { description = "Active tour location tracking" }
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Tour in progress")
            .setContentText("Tracking your location")
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .build()
    }

    companion object {
        private const val TAG = "[TourTracker]"
        const val CHANNEL_ID = "milestory_tour_tracker"
        const val NOTIFICATION_ID = 1001

        var locationUpdateCallback: ((Location) -> Unit)? = null
        var errorCallback: ((String) -> Unit)? = null
    }
}
