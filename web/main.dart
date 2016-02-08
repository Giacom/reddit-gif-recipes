import 'dart:html';
import 'dart:js';
import 'dart:math';

import 'package:http/browser_client.dart';
import 'package:bootstrap/bootstrap.dart';
import 'package:reddit/reddit.dart';

Reddit reddit = null;
Random random = null;

String recipeSubreddit = "GifRecipes";

void main() {
  reddit = new Reddit(new BrowserClient());
  random = new Random();

  //randomiseContent();
  //randomiseContent();

  ButtonElement button = querySelector("#new_recipe_btn");
  button.onClick.listen((event) => randomiseContent());
}

void randomiseContent() {
  Query query = reddit.sub(recipeSubreddit).random();
  query.params["unique"] = random.nextInt(1000);
  query.fetch().then(setFetchedContent);
}

void setFetchedContent(var result) {
  print(result);
  try {
    String type = result[0].data.children[0].kind;
    String mediaUrl = result[0].data.children[0].data.url;
    String embedded = result[0].data.children[0].data.media_embed.content;

    print(mediaUrl);
    if (isDataOk(mediaUrl, type, embedded)) {
      setContent(embedded);
    } else {
      randomiseContent();
    }
  } catch (Exception) {
    randomiseContent();
  }
}

bool isDataOk(String url, String type, String embedded) {
  if (url == null || url.isEmpty) {
    return false;
  }

  if (type == null || type.isEmpty || type != "t3") {
    return false;
  }

  if (embedded == null || embedded.isEmpty) {
    return false;
  }

  var okFileFormats = [".gifv", ".webm", ".mp4", ".gif"];
  bool validFileFormat = false;
  for (var fileFormat in okFileFormats) {
    if (url.endsWith(fileFormat)) {
      validFileFormat = true;
      break;
    }
  }

  if (!validFileFormat) {
    return false;
  }

  return true;
}

void setContent(String embedded) {
  print("Setting content..");
  Element video = querySelector("#recipe_video");
  print(embedded.length);
  embedded = unescapeHtml(embedded);
  embedded = embedded.replaceAll(new RegExp(r'src="//'), r'src="https://');
  print(embedded.length);
  print(embedded);
  video.setInnerHtml(embedded, treeSanitizer: NodeTreeSanitizer.trusted);
}

String unescapeHtml(String safe) {
  return safe
      .replaceAll(new RegExp(r"&amp;"), "&")
      .replaceAll(new RegExp(r"&lt;"), "<")
      .replaceAll(new RegExp(r"&gt;"), ">")
      .replaceAll(new RegExp(r"&quot;"), "\\")
      .replaceAll(new RegExp(r"&#039;"), "'");
}
