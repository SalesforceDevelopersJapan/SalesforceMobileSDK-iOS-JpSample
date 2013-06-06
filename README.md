# SalesforceMobileSDK-iOS-JpSample

=====================================================================

このアプリケーションはSalesforce Customer Company Tour Tokyo 2013の基調講演内でデモンストレーションしたものです。Salesforce Mobile SDKの利用方法の確認や、実際に動作するアプリケーションを見たいという方向けにオープンソース(修正BSDライセンス)として公開しています。

主に以下のような機能を持っています。

- ホーム画面のカスタマイズ機能(ボタン画像、会社ロゴ、背景等)
- 事前に設定したルート定義からの訪問ルート表示
- 地理位置情報型フィールドを使った取引先の地図マッピング
- 取引先、取引先責任者へのチェックイン
- 商品ファミリ毎に商品の追加情報表示
- 商品在庫の確認及び引き当てて注文(商談の作成、受注)
- 受注時の手書きサイン
- ログインユーザの所有する商談からグラフを作成
- Chatterフィード、グループの表示
  
いくつかの機能はSalesforce組織側にも追加の項目やApexコードを利用しているため、動作には項目を手動で作成するか、下記パッケージのインストールが必要となります。

=====================================================================
## サンプルのID

まずは動作を確認したいという方は、以下のID及びパスワードを利用してみて下さい。  
ID : sample@ios-jpsample.force.com  
Password : mobile12345


=====================================================================
## Salesforce組織のセットアップ

#### 1.パッケージのインストール

まずアプリケーションを動作させる前に、以下のパッケージをログインするユーザの組織にインストールして下さい :

[Salesforceパッケージのインストール(非管理パッケージ)](https://na15.salesforce.com/packaging/installPackage.apexp?p0=04ti00000001wKS)


このパッケージには以下の物が含まれています。

- サンプルアプリケーションの為のカスタムオブジェクト及びフィールド(ルート、ビル情報、地図情報、在庫など)
- 取引先が変更された際に住所から地理位置情報の値を生成するための小さなApexコード及びトリガ


#### 2.データの入力

以下のインストールパッケージで追加された項目を入力、編集します。  
**※2013年6月5日現在、これらの入力が無い場合、エラーとなるケースがありますので、エラーになった場合はデータを入力してみて下さい**


**取引先(Account)関連**

- 経度緯度管理(LatLngObj__c)の位置情報データ
- ビルを定義したい場合は、ビルマスタに名称と位置情報をセットし、取引先と関連付け

**商品(Product2) **

- 順序(Order__c)
- 商品ファミリの設定
- 説明文(Description)
- 商品画像ファイルを商品オブジェクトへ添付。ファイル名は **「main.jpg」**


**在庫(Stock__c)**

- 各商品にダミーの在庫データを入力。数値、日付等はデータ自体があれば任意。


=====================================================================
## 利用しているライブラリ類

このサンプルアプリケーションでは、以下のオープンソースライブラリを使用しています。

#### Salesforce Mobile SDK for iOS
[https://github.com/forcedotcom/SalesforceMobileSDK-iOS](https://github.com/forcedotcom/SalesforceMobileSDK-iOS)

Salesforce.com提供のMobile SDKです。Salesforce組織への認証やREST APIのWrapper、オフラインストア等の機能を提供しています。


#### Google Maps SDK for iOS
[https://developers.google.com/maps/documentation/ios/](https://developers.google.com/maps/documentation/ios/)

Goolge提供の地図ライブラリ。アプリケーション内でGoogle Mapの表示に利用しています。

#### SMCalloutView
[https://github.com/nfarina/calloutview](https://github.com/nfarina/calloutview)

Google Mapsの上のInfoWindow（吹き出し）のカスタマイズに利用しています。

#### iCarousel
[https://github.com/nicklockwood/iCarousel](https://github.com/nicklockwood/iCarousel)

3D回転ライブラリ。商品一覧のCoverFlowや取引先責任者カードのRotateに利用利用しています。

#### MPFoldTransition
[https://github.com/mpospese/MPFoldTransition](https://github.com/mpospese/MPFoldTransition)

ページ(UIView)遷移のライブラリ。商品詳細画面の商品画像のアニメーションなどに利用しています。

#### Reachability
[https://developer.apple.com/library/ios/#samplecode/Reachability/Introduction/Intro.html](https://developer.apple.com/library/ios/#samplecode/Reachability/Introduction/Intro.html)

Apple社の提供するサンプル。ネットワークの接続状況確認などに利用しています。  

=====================================================================
## 今後の予定(Todo)

- エラーハンドリング
- 在庫の引き当てがダミーなので、実際にSalesforceの組織と連動するように
- 画像の表示など、曖昧な仕様の明確化
- 手書きメモ機能
- Chatter画面の改修


=====================================================================
## アプリについてご意見や質問

もし、アプリケーションに対して、何らかの提案や質問、もしくは何か問題等々が発生した場合には、是非私たちに共有頂けると助かります。Developer Forceサイトに [Mobileディスカッションボード](http://boards.developerforce.com/t5/Developer-Boards-JP/ct-p/developers_JP) がありますので、こちらにポストして下さい。