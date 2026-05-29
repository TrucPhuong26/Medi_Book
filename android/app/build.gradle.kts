plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") 
}

android {
    namespace = "com.example.medibook_new"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // 1. BẬT DESUGARING TẠI ĐÂY (Cú pháp Kotlin DSL dùng dấu bằng)
        isCoreLibraryDesugaringEnabled = true
        
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // THAY THẾ khối compilerOptions bị lỗi bằng cách viết an toàn này:
    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.medibook_new"
        
        // Cố định minSdk là 21 để Firebase Firestore hoạt động ổn định
//        minSdk = flutter.minSdkVersion
        // 2. LƯU Ý QUAN TRỌNG: Thư viện thông báo yêu cầu minSdk tối thiểu là 21.
        // Nếu flutter.minSdkVersion của bạn đang là 16 or 19, hãy đổi hẳn thành số 21 như dòng dưới:
        minSdk = flutter.minSdkVersion
        
        // Sửa lỗi sai tên biến targetSdkVersion
        targetSdk = flutter.targetSdkVersion 
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // 2. Bật sao lưu multidex nếu ứng dụng vượt giới hạn hàm
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 3. THÊM THƯ VIỆN DESUGAR CHO KOTLIN DSL (Dùng hàm implementation hoặc tương đương)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

    implementation(platform("com.google.firebase:firebase-bom:34.13.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-firestore")
}
