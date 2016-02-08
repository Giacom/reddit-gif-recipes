import 'dart:html';
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

    randomiseContent();

    ButtonElement button = querySelector("#new_recipe_btn");
    button.onClick.listen((event) => randomiseContent());
}

void randomiseContent() {
    setButtonActive(false);
    
    // Need to feed reddit a random number or we keep getting the same thread.
    Query query = reddit.sub(recipeSubreddit).random();
    query.params["unique"] = random.nextInt(1000);
    query.fetch().then(setFetchedContent);
}

void setButtonActive(bool active) {
    ButtonElement button = querySelector("#new_recipe_btn");
    if (active) {
        button.classes.remove("disabled");
    } else {
        button.classes.add("disabled");
    }
}

void setFetchedContent(var result) {
    try {
        String title = result[0].data.children[0].data.title;
        String url = "https://www.reddit.com" + result[0].data.children[0].data.permalink;
        String type = result[0].data.children[0].kind;
        String mediaUrl = result[0].data.children[0].data.url;
        String embedded = result[0].data.children[0].data.media_embed.content;

        print(mediaUrl);
        if (isDataOk(mediaUrl, type, embedded)) {
            setContent(title, url, embedded);
        } else {
            randomiseContent();
        }
    } catch (Exception) {
        randomiseContent();
    }
}

bool isDataOk(String mediaUrl, String type, String embedded) {
    if (mediaUrl == null || mediaUrl.isEmpty) {
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
        if (mediaUrl.endsWith(fileFormat)) {
            validFileFormat = true;
            break;
        }
    }

    if (!validFileFormat) {
        return false;
    }

    return true;
}

void setContent(String title, String url, String embedded) {
    Element video = querySelector("#recipe_video");
    print(embedded.length);
    embedded = unescapeHtml(embedded);
    embedded = embedded.replaceAll(new RegExp(r'src="//'), r'src="https://'); // Used for local debugging, since they change to file://
    print(embedded.length);
    print(embedded);
    video.setInnerHtml(embedded, treeSanitizer: NodeTreeSanitizer.trusted);
    
    querySelector("#recipe_title").text = title;
    querySelector("#recipe_title").href = url;
    
    setButtonActive(true);
}

// Only way I found to unescape reddit's embedded media properly
String unescapeHtml(String safe) {
    return safe
            .replaceAll(new RegExp(r"&amp;"), "&")
            .replaceAll(new RegExp(r"&lt;"), "<")
            .replaceAll(new RegExp(r"&gt;"), ">")
            .replaceAll(new RegExp(r"&quot;"), "\\")
            .replaceAll(new RegExp(r"&#039;"), "'");
}
