TMAGImage
====

for Delphi.  
".mag" image load/save unit.  
".mag" image file format in the PC communication of Japan.  

滅び行く MAG の過去の栄光を顧みて.  


## Usage

 TJPEGImage といっしょ。  

## Install

適当なディレクトリに MAGImage.pas をおいてください。  
メニューの「コンポーネント」－「コンポーネントのインストール」を選んでユニットファイルに MAGImage.pas を選択して適当なパッケージに入れてください。  

アンインストールはインストールしたパッケージから MAGImage.pas を削除。


## Licence

The MIT License (MIT)

Copyright (c) 1997,1999,2012,2015  YOSHIDA, Masahiro

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

[MIT](http://opensource.org/licenses/mit-license.php)


## History

1997/01/13	Ver 0.80  
	とりあえず Delphi 2.0 用に作成。  
	ただし、展開のみ。  

1999/06/26	Ver 0.81  
	 Delphi 4.0J への対応ついでに、展開速度の向上を図る。  
	 ScanLine のおかげで展開時間が約半分に。  

1999/06/30	Ver 0.90  
	ついでに圧縮も追加。  

1999/07/01	Ver 0.99(1.00β)  
	位置情報の追加と圧縮部の整理。  

1999/08/26	Ver 1.00  
	ソースをちょいと整理。  

1999/10/20	Ver 1.01  
	デザイン時に TImage 等の TPicture で使えるようにした。  
	 DIBNeeded を実行した際、正常なパレットにならないバグ修正。  

2012/07/13	Ver 1.02  
	Mag.pas と MagType.pas を MagImage.pas にまとめた.  

2015/03/27	Ver 1.10  
	Delphi XE2(Win32/Win64) に対応した.  
	4 から 7 までは [Ver 1.01](http://masyos.sakura.ne.jp/software.html#delphi) を利用してください.  
	8 から XE, XE4以降は持ってないのでわからないです.
