const { defineConfig } = require('@vue/cli-service');
const webpack = require('webpack');
const dotenv = require('dotenv');

// Загружаем переменные из .env
dotenv.config();

module.exports = defineConfig({
  transpileDependencies: true,
  configureWebpack: {
    plugins: [
      new webpack.DefinePlugin({
        'process.env': JSON.stringify(process.env) // Загружаем переменные окружения
      })
    ]
  }
});

