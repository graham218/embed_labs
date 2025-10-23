plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.embedlabs.ble_smart_device_scanner"
    compileSdk = flutter.compileSdkVersion.toInt()

    // Fixed NDK version (optional, but good for consistency)
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.embedlabs.ble_smart_device_scanner"
        // Force Android 5.0+ compatibility
        minSdk = 21
        targetSdk = 33
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName

        // Add multiDex support for older devices
        multiDexEnabled = true

        // Test instrumentation runner
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build if needed
            // signingConfig = signingConfigs.release

            // Enable shrinking for release (with proper configuration)
            isMinifyEnabled = true
            isShrinkResources = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            // Add these for better release builds
            isDebuggable = false
            isJniDebuggable = false
            isRenderscriptDebuggable = false
        }

        debug {
            // Disable shrinking in debug for faster builds
            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = true

            // Add debug suffix to distinguish from release
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-DEBUG"
        }
    }

    // Add build features for better performance
    buildFeatures {
        buildConfig = true
    }

    // Configure packaging options to exclude unnecessary files
    packaging {
        resources {
            excludes += listOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/AL2.0",
                "META-INF/LGPL2.1"
            )
        }
    }
}

flutter {
    source = "../.."

    // Optional: Specify Flutter build mode
    // target = "lib/main.dart"
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.9.0")

    // Add multiDex support for older Android versions
    implementation("androidx.multidex:multidex:2.0.1")

    // Add core Kotlin extensions
    implementation("androidx.core:core-ktx:1.12.0")

    // Optional: Add these if you're using specific Flutter plugins
    implementation("androidx.appcompat:appcompat:1.6.1")
}