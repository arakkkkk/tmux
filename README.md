# tmux 設定

このリポジトリは、`~/.config/tmux/tmux.conf` を中心にした個人用 tmux 設定です。

## 主な機能

- Prefix キーを `C-f` に変更
- `hjkl` でペイン移動、`C-hjkl` でペインサイズ変更
- `Down` / `Right` でカレントディレクトリを維持した分割
- `C-p` でフローティング風ポップアップセッション
- `tmux-resurrect` + `tmux-continuum` によるセッション保存/復元
- `tmux-logging` によるログ保存（`~/tmux-logs`）
- ステータスラインは `statusline.conf` を読み込み
- SSH接続時のウィンドウ名自動更新（`scripts/window_name.sh`）

## 必要環境

- tmux
- Git
- `bash`, `ps`, `awk`（通常のLinux/macOS環境なら標準搭載）

`tmux.conf` は `pbcopy` と `open` を使うため、現状は macOS 向けのキーバインドを含みます。
Linuxで使う場合は、必要に応じて `pbcopy` を `xclip`/`wl-copy` に置き換えてください。

## インストール

```sh
# tmux をインストール
sudo apt install -y tmux

# 設定を配置（submodule含む）
git clone --recurse-submodules https://github.com/arakkkkk/tmux.git ~/.config/tmux
```

既に clone 済みの場合:

```sh
cd ~/.config/tmux
git pull --recurse-submodules
git submodule update --init --recursive
```

## プラグイン導入

この設定では `tpm` を利用しています。tmux起動後に以下を実行してください。

- `Prefix` + `I`: プラグインをインストール
- `Prefix` + `U`: プラグインを更新
- `Prefix` + `Alt-u`: 使っていないプラグインを削除

`tmux.conf` の `@plugin` で指定しているプラグイン:

- `tmux-plugins/tpm`
- `tmux-plugins/tmux-sensible`
- `tmux-plugins/tmux-resurrect`
- `tmux-plugins/tmux-continuum`
- `tmux-plugins/tmux-yank`
- `Morantron/tmux-fingers`
- `arakkkkk/tmux-window-controller`
- `tmux-plugins/tmux-logging`

## キーバインド（抜粋）

- `Prefix`: `C-f`
- `Prefix + r`: 設定再読み込み
- `Prefix + R`: 現在ペインを同じパスで再生成
- `Prefix + S`: ペイン同時入力を有効化
- `Prefix + Down`: 縦分割
- `Prefix + Right`: 横分割
- `M-h` / `M-l`: 前/次ウィンドウへ移動
- `Prefix + h/j/k/l`: ペイン移動
- `Prefix + C-h/j/k/l`: ペインサイズ変更
- `C-S-Left` / `C-S-Right`: ウィンドウ並び替え
- `Prefix + ]`: 現在パス名でウィンドウ名変更
- `Prefix + C-p`: ポップアップセッション起動/接続

## セッション保存・復元

`tmux-continuum` の自動復元が有効化されています（`@continuum-restore 'on'`）。
手動保存/復元の基本操作:

- `Prefix + Ctrl-s`: 保存
- `Prefix + Ctrl-r`: 復元

## 補助スクリプト

- `scripts/window_name.sh`: SSH接続先ホスト名またはカレントディレクトリ名をウィンドウ名に反映
- `ide.sh`: IDE向けのペインレイアウトを素早く作成

## 反映方法

tmux内で:

```sh
tmux source-file ~/.config/tmux/tmux.conf
```

または `Prefix + r` を使用してください。
