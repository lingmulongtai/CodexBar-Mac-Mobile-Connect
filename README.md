# CodexBar + Mobile Connect for Mac

AIサービスの使用量・リセット時刻・履歴を確認するMac版です。Windows版と共通のアプリケーション・暗号化プロトコルを使い、配布とMac用の設定をこのリポジトリで管理します。

Windows・Mac同士でデータを相互に受信でき、Androidのスマホ・タブレットとも共有できます。LANまたは同じTailscaleネットワークを利用し、exit nodeは不要です。

## ダウンロード

macOS 14以降に対応します。[最新版のリリース](https://github.com/lingmulongtai/CodexBar-Mac-Mobile-Connect/releases/latest)から、お使いのMacに合うDMGを選んでください。

| Mac | v0.72.0 |
| --- | --- |
| Apple Silicon（M1以降） | [arm64 DMG](https://github.com/lingmulongtai/CodexBar-Mac-Mobile-Connect/releases/download/v0.72.0/CodexBar-Mobile-Connect-0.72.0-macOS-arm64.dmg) |
| Intel | [x86_64 DMG](https://github.com/lingmulongtai/CodexBar-Mac-Mobile-Connect/releases/download/v0.72.0/CodexBar-Mobile-Connect-0.72.0-macOS-x86_64.dmg) |

DMG内のアプリをApplicationsへコピーします。更新時はアプリを終了して置き換え、設定フォルダを保持してください。配布物は**ad-hoc署名**で、Apple Developer ID署名・公証済みではありません。ハッシュとビルド元の記録もリリースに添付します。

## 画面

Apple SiliconのmacOS CIで、配布用にビルドした実際のアプリを起動して撮影した接続設定です。検証用の空の設定を使っています。

![Macの共有・受信設定](https://github.com/lingmulongtai/CodexBar-Mac-Mobile-Connect/releases/download/v0.72.0/CodexBar-Mobile-Connect-0.72.0-macOS-arm64-ui.png)

[Intel版の実画面](https://github.com/lingmulongtai/CodexBar-Mac-Mobile-Connect/releases/download/v0.72.0/CodexBar-Mobile-Connect-0.72.0-macOS-x86_64-ui.png)

## 関連プロジェクト

| 対象 | リポジトリ |
| --- | --- |
| Android | [CodexBar-android](https://github.com/lingmulongtai/CodexBar-android) |
| Windows / 共通ソース | [Win-CodexBar-Mobile-Connect](https://github.com/lingmulongtai/Win-CodexBar-Mobile-Connect) |
| Mac / 配布設定 | このリポジトリ |

[共通のGitHub Project](https://github.com/users/lingmulongtai/projects/3)

## 接続

Windows・Mac同士は **Settings → Mobile Connect → Receive from another PC** から接続します。送信と受信は独立しており、スマホ・タブレットも同じ送信元へ接続できます。[接続手順と対応範囲](docs/CONNECTING.md)

## Macでビルド

macOS 14以降、Xcode Command Line Tools、Rust、Node.jsと、共通ソースの`package.json`で指定したpnpmが必要です。

```sh
git clone --recurse-submodules https://github.com/lingmulongtai/CodexBar-Mac-Mobile-Connect.git
cd CodexBar-Mac-Mobile-Connect
./scripts/build-macos.sh
```

Apple Siliconは`aarch64-apple-darwin`、Intelは`x86_64-apple-darwin`を使います。両方のRustターゲットが導入済みなら、`./scripts/build-macos.sh universal-apple-darwin`でもビルドできます。出力は`desktop/target/<target>/release/bundle/`配下の`.app`と`.dmg`です。`CARGO_TARGET_DIR`を設定した場合は、そのディレクトリが出力先になります。

Windows版の`tauri:build`はEXE向けにbundleを作らない設定のため、このMac用スクリプトはTauri CLIへ直接`--bundles app,dmg`を渡します。

## ソースと検証

`desktop`サブモジュールは共通ソースの特定コミットに固定します。通信やUIの修正は共通ソースへ入れ、検証したコミットへピンを更新します。

Apple Silicon／IntelのネイティブmacOS CIでRust・フロントエンドのテスト、実際のKeychainでの保存と同時初期化、暗号化通信、アプリの署名・アーキテクチャ、起動・画面撮影、DMG内の実行ファイルの一致を確認しています。[両CPU版の検証結果](https://github.com/lingmulongtai/CodexBar-Mac-Mobile-Connect/actions/runs/39336522369) · [検証を含むリリース手順](.github/workflows/release.yml)

ユーザーのMac実機での受け入れ確認は未実施です。実機間のTailscale接続、Googleログイン、Finderから起動した際の初回ローカルネットワーク許可は、CIの検証とは区別しています。[対応範囲と接続手順](docs/CONNECTING.md)

共通ソースは[nesszer/Win-CodexBar](https://github.com/nesszer/Win-CodexBar)のフォークで、[steipete/CodexBar](https://github.com/steipete/CodexBar)を基にしています。元のクレジットとライセンスは共通ソース内に保持します。
