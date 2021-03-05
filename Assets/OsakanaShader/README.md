# OsakanaShader
GPU particles of migrating small fish such as in an aquarium.

![Demo](../../Documents~/img02.png)

## Transform
The object's Position reflects the center of the fish migrating area, and the Scale reflects its size. The size of the individual fish is configured in the material.

## Mesh
A special mesh is required. meshes for 10, 20, 30, 40, 50, and 100 fish are included in the package.

## Material Parameters
| カテゴリ | パラメーター | |
|:--|:--|:--|
| | Mask Clip Value | Threshold of alpha clipping. |
| PBR Material | | Basic PBR material parameters. |
| Tiling | | 複数種の魚タイル状に並べるテクスチャを使う設定 |
| | Raws, Cols |  |
| | Tile Count | Number of uset tiles. |
| | Random Seed | |
| | Tile Scale | UV Tiling per tile. |
| | Tile Offset | UV Offset per tile. |
| Fish Position | | Position of indivisual fish. |
| | Position Noise Speed | Migrating speed. |
| | Position Noise Space Mode | Spherical: Migrating around origin point. Linear: Move evenly over the area.  |
| | Position Noise Scale | |
| | Rotation Offset | |
| | dT | |
| Fish Waving | | |
| | Waving Strength | |
| | Waving Length | 幅 |
| | Waving Speed | 速度 |
| Fish Scale | | Scale of indivisual fish |
| | Fish Scale Per Axis | |
| | Fish Randomized Scale Min/Max | |

# Japanese
回遊する小魚のGPUパーティクルです。水槽の中の観賞魚などに。

![Demo](../../Documents~/img02.png)

## Transform
オブジェクトのPositionは回遊する魚の中心、スケールはその範囲に反映されます。個々の魚の大きさはマテリアルで設定します。

## Mesh
専用のメッシュが必要です。10、20、30、40、50、100匹用のメッシュを同梱しています。

## Material Parameters
| カテゴリ | パラメーター | |
|:--|:--|:--|
| | Mask Clip Value | アルファクリッピングのしきい値 |
| PBR Material | | 基本的なマテリアル設定 |
| Tiling | | 複数種の魚タイル状に並べるテクスチャを使う設定 |
| | Raws, Cols | テクスチャ中タイルの行数、列数 |
| | Tile Count | 使用するタイルの数。左下が原点 |
| | Random Seed | |
| | Tile Scale | タイルごとの UV Tiling |
| | Tile Offset | タイルごとの UV Offset |
| Fish Position | | 魚の位置 |
| | Position Noise Speed | 回遊するスピード |
| | Position Noise Space Mode | Spherical: ローカル原点を中心に回遊する。 Linear: スケールの範囲にまんべんなく移動する。 |
| | Position Noise Scale | |
| | Rotation Offset | |
| | dT | |
| Fish Waving | | 身をうねらせる設定 |
| | Waving Strength | 強さ |
| | Waving Length | 幅 |
| | Waving Speed | 速度 |
| Fish Scale | | 個々の魚の大きさ |
| | Fish Scale Per Axis | XYZ各軸の大きさ |
| | Fish Randomized Scale Min/Max | 大きさのばらつき |
