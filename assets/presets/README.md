# Card Presets 運用ルール

このフォルダは、ゲームで使用するカードプリセットJSONを管理します。

## 1. 追加するJSONの場所

- 追加先: `assets/presets/`
- ファイル名ルール: `cards_<preset_name>.json`
  - 例: `cards_biology.json`, `cards_engineering.json`

## 2. JSONフォーマット

各ファイルは **配列** で、1要素が1枚のカードです。

```json
[
  {
    "id": 1,
    "top": "上段",
    "middle": "中段",
    "bottom": "下段"
  }
]
```

### 必須キー

- `id`: 数値（ファイル内で一意を推奨）
- `top`: 文字列
- `middle`: 文字列（空文字でも可）
- `bottom`: 文字列

## 3. ダミー雛形ファイル

- `cards_template_dummy.json` は新規作成時のコピー元として使用してください。
- このファイルは運用見本です。ゲームで使う場合のみ `assets/card_presets.json` に登録します。

## 4. ゲームで使う手順

1. `assets/presets/` に新しいJSONを追加
2. `assets/card_presets.json` にプリセット情報を1件追加
   - `id`: プリセット識別子（例: `biology`）
   - `name`: 画面表示名
   - `path`: 追加したJSONへのパス（例: `assets/presets/cards_biology.json`）
3. アプリを再起動して設定画面のプリセット選択に表示されることを確認

## 5. 既存ファイル

- `cards.json`: 標準プリセット
- `cards_ai_tech.json`: AI・テクノロジー
- `cards_society.json`: 社会・人文学

