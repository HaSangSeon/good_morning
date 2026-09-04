package com.sintong.good_morning

import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.sintong.good_morning/kakao_share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isKakaoInstalled" -> {
                    try {
                        packageManager.getPackageInfo("com.kakao.talk", 0)
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "shareToKakao" -> {
                    val filePath = call.argument<String>("filePath")
                    val text = call.argument<String>("text")

                    try {
                        val intent = Intent(Intent.ACTION_SEND).apply {
                            setPackage("com.kakao.talk")
                            if (!filePath.isNullOrEmpty()) {
                                val file = File(filePath)
                                if (file.exists()) {
                                    val shareCache = File(applicationContext.cacheDir, "share_plus")
                                    if (!shareCache.exists()) {
                                        shareCache.mkdirs()
                                    }
                                    val targetFile = File(shareCache, file.name)
                                    file.copyTo(targetFile, overwrite = true)

                                    val authority = "${applicationContext.packageName}.flutter.share_provider"
                                    val contentUri = FileProvider.getUriForFile(applicationContext, authority, targetFile)

                                    type = "image/*"
                                    putExtra(Intent.EXTRA_STREAM, contentUri)
                                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                }
                            } else {
                                type = "text/plain"
                            }
                            if (!text.isNullOrEmpty()) {
                                putExtra(Intent.EXTRA_TEXT, text)
                            }
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SHARE_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
