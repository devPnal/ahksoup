[한국어](/README/ko.md) | [English](/README/en.md)

# AhkSoup
📚 HTML 파싱 오토핫키 v2 라이브러리

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)<br>
⭐ → ❤️

## 사용 방법
아래와 같이 라이브러리 파일을 스크립트에 포함시킵니다.
```
#include ahksoup.ahk
```

그 뒤, 새 인스턴스를 만듭니다.

```
document := AhkSoup()
```

HTML 문자열을 엽니다.
```
document.Open(htmlstring)
```

그 후 instance.FunctionName 형태로 라이브러리 내 함수를 자유롭게 이용할 수 있습니다.

예제 파일을 참고해 주세요.

## 지원 함수
* GetElementsByTagName()
* GetElementByTagName()
* GetElementsById()
* GetElementById()
* GetElementsByClassName()
* GetElementByClassName()

## 지원 및 기여
* 사용 중 문제가 있을 경우 GitHub 이슈 등록을 하거나, 이메일 contact@pnal.dev로 연락 주세요.
* GitHub 기여는 언제든지 환영입니다. 추가 및 보완하고 싶은 기능을 자유롭게 기여해주세요.
