#include AhkSoup.ahk

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
				<span class="colored">Test <br>Content 1</span>
				<span class="colored">Test <br>Content 2</span>
				<span class="colored min">Test <br>Content 3</span>
			</div>
		</main>
	</html>
</html>
)"

document := AhkSoup() ;Create Instance
document.Open(html) ;Open HTML String

MsgBox(document.GetElementsByTagName("title")[1].OuterHTML)
MsgBox(document.GetElementByTagName("title").Text)

MsgBox(document.GetElementsById("content")[1].InnerHTML)
MsgBox(document.GetElementById("content").Text)

MsgBox(document.GetElementsByClassName("colored")[2].OuterHTML)
MsgBox(document.GetElementsByClassName("min")[1].InnerHTML)
MsgBox(document.GetElementByClassName("colored").Text)