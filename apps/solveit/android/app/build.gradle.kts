import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val uploadStoreFile = System.getenv("LOOPLOOM_UPLOAD_KEYSTORE")
val uploadStorePassword = System.getenv("LOOPLOOM_UPLOAD_STORE_PASSWORD")
val uploadKeyAlias = System.getenv("LOOPLOOM_UPLOAD_KEY_ALIAS")
val uploadKeyPassword = System.getenv("LOOPLOOM_UPLOAD_KEY_PASSWORD")
val hasPlaySigning = listOf(uploadStoreFile, uploadStorePassword, uploadKeyAlias, uploadKeyPassword)
    .all { !it.isNullOrBlank() }

android {
    namespace = "dev.solveit.solveit"
    compileSdk = flutter.compileSdkVersion
    // Optional local development override for an already installed NDK.
    // Release verification should use the Flutter toolchain default.
    ndkVersion = System.getenv("SOLVEIT_NDK_VERSION") ?: flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "dev.solveit.solveit"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasPlaySigning) {
            create("playUpload") {
                storeFile = file(uploadStoreFile!!)
                storePassword = uploadStorePassword!!
                keyAlias = uploadKeyAlias!!
                keyPassword = uploadKeyPassword!!
            }
        }
    }

    buildTypes {
        release {
            // Local APKs keep their existing signing identity. A Play bundle
            // requires the separate upload key and cannot use the debug key.
            signingConfig = signingConfigs.getByName(if (hasPlaySigning) "playUpload" else "debug")
        }
    }
}

val verifyPlaySigning = tasks.register("verifyPlaySigning") {
    doLast {
        if (!hasPlaySigning || !file(uploadStoreFile!!).isFile) {
            throw GradleException("A Play app bundle requires LOOPLOOM_UPLOAD_KEYSTORE, LOOPLOOM_UPLOAD_STORE_PASSWORD, LOOPLOOM_UPLOAD_KEY_ALIAS, and LOOPLOOM_UPLOAD_KEY_PASSWORD.")
        }
    }
}
tasks.matching { it.name == "bundleRelease" }.configureEach {
    dependsOn(verifyPlaySigning)
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
