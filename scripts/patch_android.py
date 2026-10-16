"""يضيف توقيع الإصدار (release signing) إلى مشروع أندرويد المُولَّد. يُستدعى فقط عند وجود الـ Keystore في Secrets."""
p = 'android/app/build.gradle.kts'
s = open(p, encoding='utf-8').read()
if 'keystoreProperties' not in s:
    s = 'import java.util.Properties\nimport java.io.FileInputStream\n\n' + s
    s = s.replace('android {', 'val keystoreProperties = Properties().apply { load(FileInputStream(rootProject.file("key.properties"))) }\n\nandroid {', 1)
    s = s.replace('buildTypes {', '''signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {''', 1)
    s = s.replace('signingConfigs.getByName("debug")', 'signingConfigs.getByName("release")')
    open(p, 'w', encoding='utf-8').write(s)
print('patched')
