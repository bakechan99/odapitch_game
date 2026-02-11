Kakenhi Game 設計ドキュメント
1. プロジェクト概要
本プロジェクトは、研究費獲得プロセスを模したパーティーゲームアプリ「カケンヒゲーム」です。
プレイヤーは配られた単語カードを組み合わせて「研究タイトル」を作成し、プレゼンテーションと質疑応答を経て、互いに予算（ポイント）を投票し合います。最も多くの予算を獲得したプレイヤーが勝者となります。

2. ディレクトリ構成
主要なソースコードは lib 配下に配置されています。
~~~
lib/
├── main.dart                  # エントリーポイント。テーマ設定とTitleScreenの呼び出し。
├── constants/
│   └── texts.dart             # アプリ内の定数テキスト管理（ボタン名、メッセージ等）。
├── models/                    # データモデル定義
│   ├── card_data.dart         # カード単体のデータ構造（上・中・下の文言）。
│   ├── game_settings.dart     # ゲーム設定（プレゼン時間、質疑応答時間）。
│   ├── placed_card.dart       # フィールドに配置されたカードの状態（どの段を選択中か）。
│   └── player.dart            # プレイヤー情報（名前、手札、作成したタイトル）。
├── screens/                   # 各画面のUIとロジック
│   ├── title_screen.dart      # タイトル画面。BGM再生、新規ゲーム遷移。
│   ├── setup_screen.dart      # 設定画面。人数、名前、時間設定。
│   ├── game_loop_screen.dart  # メインゲーム画面。カードのドラッグ＆ドロップ操作。
│   └── result_screen.dart     # 結果画面。プレゼン、投票、結果発表のフェーズ管理。
└── widgets/                   # 共通ウィジェット
    ├── custom_confirm_dialog.dart # 汎用確認ダイアログ。
    ├── fancy_button.dart          # 装飾付きボタン。
    └── title_button.dart          # タイトル画面用ボタン。
~~~
4. 画面遷移図
アプリの全体的なフローは以下の通りです。

~~~
graph TD
    Title[TitleScreen<br>タイトル画面] -->|新規ゲーム| Setup[SetupScreen<br>設定画面]
    Setup -->|ゲーム開始| GameLoop[GameLoopScreen<br>メインゲーム画面]
    
    subgraph GameLoopLogic [ゲームループ]
        Pass[端末受け渡し画面] <-->|本人確認| Play[プレイ画面<br>カード配置]
    end
    
    GameLoop -->|全員終了| Result[ResultScreen<br>結果画面]
    
    subgraph ResultLogic [結果・投票フェーズ]
        Pres[プレゼン & 質疑応答] --> Vote[予算投票]
        Vote --> Ranking[結果発表]
    end
    
    Result -->|タイトルへ戻る| Title
~~~
4. データモデル詳細

~~~
Player (player.dart)
ゲームに参加するユーザーを表します。

name (String): プレイヤー名。
hand (List<CardData>): 現在の手札。
selectedCards (List<PlacedCard>): フィールドに配置し、タイトルとして採用したカードのリスト。
researchTitle (String): selectedCards を連結して生成される研究タイトル文字列。
CardData (card_data.dart)
cards.json から読み込まれるカードデータです。

id (int): 一意のID。
top (String): 上段のテキスト。
middle (String): 中段のテキスト。
bottom (String): 下段のテキスト。
PlacedCard (placed_card.dart)
フィールドに置かれたカードの状態を管理します。

card (CardData): 元のカードデータ。
selectedSection (int): 0=上段, 1=中段, 2=下段。ユーザーのタップにより変更可能。
GameSettings (game_settings.dart)
presentationTimeSec (int): プレゼンテーションの持ち時間。
qaTimeSec (int): 質疑応答の持ち時間。

~~~
5. 現状の課題とTODO
コード解析に基づく、今後の改善点や注意点です。
~~~
アセットの依存関係:
title_screen.dart や result_screen.dart で audio (mp3) や images (png) を参照していますが、
ファイルが存在しない場合に例外キャッチでログ出力する実装になっています。
本番ビルド前にリソースの配置確認が必要です。

プレイヤー数の上限と色:
result_screen.dart 内の _getPlayerColor メソッドで定義されている色は8色です。
設定画面で8人まで制限されていますが、拡張する場合はカラーパレットの追加が必要です。

ドラッグ＆ドロップの操作性:
game_loop_screen.dart にて、カードの隙間（Gap）に対する判定エリア（_buildGapTarget）を透明なContainerで確保していますが、
判定エリアの微調整（ちらつき防止）に関するコメントが残っています。
実機での操作感を確認し、必要に応じて調整が必要です。

ハードコーディングされた文字列:
多くのテキストは AppTexts クラスに集約されていますが、一部の画面（ResultScreenのボタンラベルなど）に直接文字列が記述されている箇所があります。
多言語対応や保守性のために AppTexts への移行が推奨されます。
~~~
