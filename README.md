# Reddit Gif Recipes

[Demo Website](http://giacom.github.io/reddit-gif-recipes)

### How it works

This codebase uses the Dart Reddit API wrapper to send a request to ```/r/GifRecipe/random/.json``` and injects the media embedded HTML code. It will keep requesting a new random gif until it finds a valid link.

