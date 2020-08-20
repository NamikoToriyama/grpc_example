## Railsのコマンドについて
なぜか`rbrnv exec`がないと実行できないので必ずつけるようにする

### install
多分`npm install`的なイメージな気がする
```
rbenv exec bundle install --path vendor/bdundle
rbenv exec bundle install
```

### プロジェクト作成
```
rbenv exec bundle exec rails new .
```

### 実行
``` 
rbenv exec bundle exec rails server
```

### railsコンソール
```
rbenv exec bundle exec rails console
Bakery.bake_pancake(Bakery::Menu::CLASSIC)
```