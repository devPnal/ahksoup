[한국어](/README/ko.md) | [English](/README/en.md)

# AhkSoup
📚 HTML Parsing library for Autohotkey (v2)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)<br>
⭐ → ❤️

## How to use
Include the library file in your script like below .
```
#include ahksoup.ahk
```

After that, create a new instance.

```
document := AhkSoup()
```

Open the HTML String
```
document.Open(htmlstring)
```

Now, you can use the functions in the library in the form of `document.FunctionName`.

Please refer to the example file.

## Supported functions
* GetElementsByTagName()
* GetElementByTagName()
* GetElementsById()
* GetElementById()
* GetElementsByClassName()
* GetElementByClassName()
* *QuerySelectorAll()
* *QuerySelector()

\*: Experiment

## Support and contributions
* If you have any problems during use, please register a GitHub issue or email to contact [at] pnal.dev
* GitHub contributions are always welcome. Please feel free to contribute features you would like to see added and enhanced.
