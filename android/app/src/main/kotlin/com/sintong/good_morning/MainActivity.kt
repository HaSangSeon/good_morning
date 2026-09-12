package com.sintong.good_morning

import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

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
                                    val targetFileName = if (file.name.endsWith(".jpg", ignoreCase = true) || file.name.endsWith(".jpeg", ignoreCase = true)) {
                                        file.name
                                    } else {
                                        "${file.nameWithoutExtension}.jpg"
                                    }
                                    val targetFile = File(shareCache, targetFileName)

                                    // 초고화질(품질 92%) 시각적 무손실 고속 압축 적용 (용량 80% 감소 & 카톡 로딩 대폭 단축)
                                    val bitmap = BitmapFactory.decodeFile(file.absolutePath)
                                    if (bitmap != null) {
                                        FileOutputStream(targetFile).use { out ->
                                            bitmap.compress(Bitmap.CompressFormat.JPEG, 92, out)
                                            out.flush()
                                        }
                                        bitmap.recycle()
                                    } else {
                                        file.copyTo(targetFile, overwrite = true)
                                    }

                                    val authority = "${applicationContext.packageName}.flutter.share_provider"
                                    val contentUri = FileProvider.getUriForFile(applicationContext, authority, targetFile)

                                    type = "image/jpeg"
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

                        val chooser = Intent.createChooser(intent, "카카오톡으로 공유하기")
                        startActivity(chooser)
                        result.success(true)
                    } catch (e: Throwable) {
                        result.error("SHARE_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
