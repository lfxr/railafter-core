# Notes > コンテナ

## プラグイン管理

### ダウンロード

plugin_id | plugin_id:version

### インストール

plugin_id:version

1. 指定されたプラグインのversionをパッケージファイルから取得
1. `conforming_versions`がversionを含む`dependencies`を取得
1. コンテナが`dependencies`を満たすか確認して, 満たさない場合はエラーを吐く
1. versionから`sha3_512_hash`を取得
1. `temp/plugins/src`内のzipファイルのSHA3-512ハッシュを計算
1. 計算したハッシュと`sha3_512_hash`を比較して一致しない場合はエラーを吐く
1. zipファイルを`temp/plugins/dest`に展開
1. `conforming_versions`がversionを含む`tracked_files_and_dirs`を取得
1. `tracked_files_and_dirs`の`body`を回して, `path`で指定されたファイルもしくはディレクトリが既にコンテナに存在する場合, `is_protected`が偽である`path`を`move_to`で指定されたディレクトリに移動, そうでない場合は, `path`で指定されたファイルもしくはディレクトリを`move_to`で指定されたディレクトリに移動
1. `conforming_versions`がversionを含む`jobs`を取得
1. `jobs`の`body`を回して, `id`が`after_installation`の`tasks`を実行
1. コンテナファイルのplugin_idの`previously_installed_versions`にversionを追加

### アップデート

plugin_id

1. `### インストール`の手順を`plugin_id:latest`を指定して実行

### アンインストール

plugin_id [--delete-config]

1. 指定されたプラグインのversionと`previously_installed_versions`のversionをパッケージファイルから取得
1. `conforming_versions`がversionを含む`tracked_files_and_dirs`を取得
1. `tracked_files_and_dirs`の`body`を回して, `path`で指定されたファイルもしくはディレクトリを削除
1. `conforming_versions`がversionを含む`jobs`を取得
1. `jobs`の`body`を回して, `id`が`after_uninstallation`の`tasks`を実行
1. コンテナファイルのplugin_idの`is_installed`を偽にする
