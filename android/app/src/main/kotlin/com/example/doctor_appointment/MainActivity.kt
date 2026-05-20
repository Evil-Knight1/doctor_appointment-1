package com.example.MedLink

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.paymob.sdk.ui.PaymobActivity
import com.paymob.sdk.domain.model.PaymobIntent
import com.paymob.sdk.ui.PaymobSdkListener

class MainActivity: FlutterActivity(), PaymobSdkListener {
    private val CHANNEL = "paymob_sdk_flutter"
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "payWithNativeSdk") {
                val publicKey = call.argument<String>("publicKey")
                val clientSecret = call.argument<String>("clientSecret")
                val appName = call.argument<String>("appName") ?: "Doctor Appointment"
                
                pendingResult = result

                try {
                    val intent = PaymobIntent.Builder()
                        .setPublicKey(publicKey)
                        .setClientSecret(clientSecret)
                        .setAppName(appName)
                        // .setButtonColor(buttonColor) // if supported
                        .build()

                    PaymobActivity.start(this, intent, this)
                } catch (e: Exception) {
                    result.error("PAYMOB_ERROR", e.message, null)
                    pendingResult = null
                }
            } else {
                result.notImplemented()
            }
        }
    }

    override fun transactionAccepted(transactionId: String) {
        pendingResult?.success("Successfull")
        pendingResult = null
    }

    override fun transactionRejected(reason: String) {
        pendingResult?.success("Rejected")
        pendingResult = null
    }

    override fun transactionPending() {
        pendingResult?.success("Pending")
        pendingResult = null
    }
}
