# CodexBar + Mobile Connect for Mac

AIサービスの使用量・リセット時刻・履歴を確認するMac版です。Windows版と共通のアプリケーション・暗号化プロトコルを使い、配布とMac用の設定をこのリポジトリで管理します。

開発中です。ネイティブビルドと接続検証が完了するまで、配布済み・動作確認済みとは扱いません。

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

ユーザーのMac実機での確認は未実施です。macOS CIでの結果と、実機での受け入れ結果は区別して記録します。現在のMac設定はad-hoc署名で、Apple Developer ID署名・公証済みではありません。

共通ソースは[nesszer/Win-CodexBar](https://github.com/nesszer/Win-CodexBar)のフォークで、[steipete/CodexBar](https://github.com/steipete/CodexBar)を基にしています。元のクレジットとライセンスは共通ソース内に保持します。
