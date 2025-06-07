## Link simulator
リンク機構の運動解析およびアニメーションを行う MATLAB 用シミュレータです．
## 構成
```
link_simulator/
├── MATLAB/
│ ├── data/ # 入出力用のデータファイル
│ ├── scripts/ # 実行用スクリプト（UI，解析など）
│ └── src/ # 関数・ライブラリ群（内部処理）
├── docs/ # ドキュメントなど
└── README.md # このファイル
```

## 使い方
1. 入力用ファイルの作成
   - `\docs\入力データ作成例.xlsx`または`\docs\入力データ作成例.pdf`を参照して作成すること．
2. 解析スクリプトの実行
   - `\MATLAB\scripts\auto_analysis.m`を実行．
3. シミュレーションの実行，結果の確認
   - `\MATLAB\scripts\draw_result.m`を実行．