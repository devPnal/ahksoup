#include AhkSoup.ahk
#Requires AutoHotkey v2.0

html := "
(
<!DOCTYPE HTML>
<html>
	<head>
		<title>Test title</title>
		<meta charset="utf-8">
	</head>
	<body>
		<main>
			<div id="content">
				<span class="colored" id="article">Test <br>Content 1</span>
				<span class="colored">Test <br>Content 2</span>
				<span class="colored min">Test <br>Content 3</span>
			</div>
		</main>
	</body>
</html>
)"

document := AhkSoup()
document.Open(html)

;All methods return {tag, [id], [class], outerHTML, innerHTML, text} ([] = array)
MsgBox("1: GetElement(s)ByTagName")
MsgBox(document.GetElementsByTagName("title")[1].outerHTML)
MsgBox(document.GetElementByTagName("title").text)

MsgBox("2: GetElement(s)ById")
MsgBox(document.GetElementsById("content")[1].innerHTML)
MsgBox(document.GetElementById("content").text)

MsgBox("3: GetElement(s)ByClassName")
MsgBox(document.GetElementsByClassName("colored")[1].id[1])
MsgBox(document.GetElementsByClassName("colored")[3].class[2]) ;class[1] = colored, class[2] = min
MsgBox(document.GetElementByClassName("colored").tag)

MsgBox("4: QuerySelector(All)")
MsgBox(document.QuerySelectorAll("main #content .colored")[3].text)
MsgBox(document.QuerySelector("main #content .min").text)
