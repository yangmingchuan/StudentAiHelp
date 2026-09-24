import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val validateReleaseServices by tasks.registering {
    doLast {
        val properties = Properties()
        rootProject.file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdk = properties.getProperty("flutter.sdk")
        val dart = if (System.getProperty("os.name").startsWith("Windows")) "dart.exe" else "dart"
        providers.exec {
            commandLine("$flutterSdk/bin/cache/dart-sdk/bin/$dart",
                "${rootProject.projectDir}/../tool/validate_release_config.dart",
                "--defines", project.findProperty("dart-defines")?.toString() ?: "")
        }.result.get().assertNormalExitValue()
    }
}
tasks.configureEach {
    if (name == "compileFlutterBuildRelease") dependsOn(validateReleaseServices)
}

android {
    namespace = "com.mingchuanyang.little_hero"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.mingchuanyang.little_hero"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
