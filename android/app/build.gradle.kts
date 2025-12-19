plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.prahaar"
    compileSdk = 36  // Replace with your desired SDK version

    defaultConfig {
        applicationId = "com.example.prahaar"
        minSdk = flutter.minSdkVersion  // Replace with your minSdk version
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Core library desugaring for Java 8+ features
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
    
    // Firebase BOM for version management
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-messaging-ktx")
}
