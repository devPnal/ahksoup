/*
MIT License, Copyright (C) 프날(Pnal, contact@pnal.dev)
You should have received a copy of the MIT License along with this library.
*/

/* #############################################################
 * AhkSoup v1.0.1
 *
 * Author: 프날(Pnal) - https://pnal.dev (contact@pnal.dev)
 * Project URL: - https://github.com/devPnal/ahksoup
 * Description: HTML Parsing library for Autohotkey (v2)
 * License: MIT License (see LICENSE file)
 *
 * If there are any awkward English sentences here, please contribute or contact me.
 * My native language is Korean so English is limited.
 * #############################################################
 */


#Requires AutoHotkey v2.0

class AhkSoup
{
    dev := AhkSoup.Devlopment()
    html := ""
    document := []

    /* =========================
	 * Open(_html)
	 * Open HTML Source and initialize.
	 *
	 * @Parameter
	 * _html[String]: The HTML string to parse.
	 *
	 * @Return value
	 * result: Array for All tags.
	 * ==========================
	 */
    Open(_html)
    {
        this.html := _html
        return this.document := this.dev.ExtractAllTags(_html)
    }

    /* =========================
	 * GetElementsByTagName(_tagName)
	 * Find elements by tag name
	 *
	 * @Parameter
	 * _tagName[String]: The tag name to find elements
	 *
	 * @Return value
	 * result: Array for <_tagname> tags.
     * [1]{tag, id, class, outerHTML, innerHTML, text}
     * [2]{tag, id, class, outerHTML, innerHTML, text}
     * ...
	 * ==========================
	 */
    GetElementsByTagName(_tagName)
    {
        result := []
        for index, element in this.document
        {
            if (element.tag != _tagName)
                continue
            result.Push({
                tag: this.dev.GetTag(element.content),
                id: this.dev.GetId(element.content),
                class: this.dev.GetClass(element.content),
                outerHTML: element.content,
                innerHTML: this.dev.TrimOuterTag(element.content),
                Text: this.dev.TrimAllTag(element.content)
            })
        }
        return result
    }

    /* =========================
	 * GetElementsById(_id)
	 * Find elements by id
	 *
	 * @Parameter
	 * _id[String]: The id to find elements
	 *
	 * @Return value
	 * result: Array for <tagname id='_id'> tags.
     * [1]{tag, id, class, outerHTML, innerHTML, text}
     * [2]{tag, id, class, outerHTML, innerHTML, text}
     * ...
	 * ==========================
	 */
    GetElementsById(_id)
    {
        result := []
        for index, element in this.document
        {
            Loop StrSplit(element.id, " ").Length
            {
                if (StrSplit(element.id, " ")[A_Index] != _id && element.id != _id)
                    continue
                result.Push({
                    tag: this.dev.GetTag(element.content),
                    id: this.dev.GetId(element.content),
                    class: this.dev.GetClass(element.content),
                    outerHTML: element.content,
                    innerHTML: this.dev.TrimOuterTag(element.content),
                    Text: this.dev.TrimAllTag(element.content)
                })
            }
        }
        return result
    }

    /* =========================
	 * GetElementsByClassName(_className)
	 * Find elements by class name
	 *
	 * @Parameter
	 * _className[String]: The class name to find elements
	 *
	 * @Return value
	 * result: Array for <tagname class='_className'> tags.
     * [1]{tag, id, class, outerHTML, innerHTML, text}
     * [2]{tag, id, class, outerHTML, innerHTML, text}
     * ...
	 * ==========================
	 */
    GetElementsByClassName(_className)
    {
        result := []
        for index, element in this.document
        {
            Loop StrSplit(element.class, " ").Length
            {
                if (StrSplit(element.class, " ")[A_Index] != _className && element.class != _className)
                    continue
                result.Push({
                    tag: this.dev.GetTag(element.content),
                    id: this.dev.GetId(element.content),
                    class: this.dev.GetClass(element.content),
                    outerHTML: element.content,
                    innerHTML: this.dev.TrimOuterTag(element.content),
                    Text: this.dev.TrimAllTag(element.content)
                })
            }
        }
        return result
    }

    /* =========================
	 * GetElementByTagName(_name)
	 * GetElementById(_name)
	 * GetElementByClassName(_name)
     * Find the first single element by [tag name | id | class name]
     *
	 * @Parameter
	 * _name[String]: The [tag name | id | class name] to find a first single element
	 *
	 * @Return value
	 * result: A key-value object.
     * {tag, id, class, outerHTML, innerHTML, text}
	 * ==========================
	 */
    GetElementByTagName(_name) => this.GetElementsByTagName(_name)[1]
    GetElementById(_name) => this.GetElementsById(_name)[1]
    GetElementByClassName(_name) => this.GetElementsByClassName(_name)[1]

    /* =========================
	 * [For development]
	 * Functions below this are used for other functions in this library and may be meaningless in actual use.
	 */
    class Devlopment
    {
        voidElements := ["area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr"]

        /* =========================
		 * ExtractAllTags(_html)
		 * Extract all tags by top to bottom.
		 *
		 * @Parameter
		 * _html[String]: The HTML string to extract tags
		 *
		 * @Return value
		 * tags: The array which has object literal by its elements.
         * [1]{tag, id, class, content}
         * [2]{tag, id, class, content}
         * ...
		 * ==========================
		 */
        ExtractAllTags(_html)
        {
            tags := []
            stack := []
            pos := 1

            while (pos <= StrLen(_html))
            {
                if (SubStr(_html, pos, 1) = "<")
                {
                    tagStart := pos
                    tagEnd := InStr(_html, ">", true, pos) + 1
                    if (tagEnd = 0)  ;If wrong HTML (If there isn't '>')
                        break

                    tag := SubStr(_html, tagStart, tagEnd - tagStart)

                    if (SubStr(tag, 2, 1) != "/") ;Opening tag
                    {
                        tagName := RegExReplace(tag, "^<([^\s>]+).*$", "$1")
                        idPos := RegExMatch(tag, "id=[`"']([^`"']+)[`"']", &idOut)
                        classPos := RegExMatch(tag, "class=[`"']([^`"']+)[`"']", &classOut)

                        tagInfo := {tag: tagName, id: idPos ? idOut[1] : "", class: classPos ? classOut[1] : "", content: tag}

                        if (!this.HasValue(this.voidElements, tagName) && SubStr(tag, -2) != "/>")
                            stack.Push({name: tagName, start: tagStart, info: tagInfo})
                        tags.Push(tagInfo)
                    }
                    else ;Closing Tag. Update the corresponding opening tag's content.
                    {
                        closingTagName := RegExReplace(tag, "^</([^>]+)>$", "$1")
                        stackIndex := stack.Length
                        while (stackIndex > 0)
                        {
                            if (stack[stackIndex].name = closingTagName)
                            {
                                fullContent := SubStr(_html, stack[stackIndex].start, tagEnd - stack[stackIndex].start)
                                stack[stackIndex].info.content := fullContent
                                stack.RemoveAt(stackIndex)
                                break
                            }
                            stackIndex--
                        }
                    }

                    pos := tagEnd
                }
                else
                    pos++
            }

            return tags ;{tag, id, class, content}
        }

        /* =========================
		 * TrimOuterTag(_html)
		 * Trim opening and closing tags.
		 *
		 * @Parameter
         * _html[String]: The HTML string to trim outer tags
		 *
		 * @Return value
		 * result: _html without outer tag
		 * ==========================
		 */
        TrimOuterTag(_html)
        {
            RegExMatch(_html, "s)<(.*?) ?.*?>(.*)</\1>", &output)
            return output ? output[2] : ""
        }

        /* =========================
		 * TrimAllTag(_html)
		 * Trim all tags.
		 *
		 * @Parameter
         * _html[String]: The HTML string to trim all tags
		 *
		 * @Return value
		 * result: _html without all tag
		 * ==========================
		 */
        TrimAllTag(_html)
        {
            html := this.TrimOuterTag(_html)
            return RegExReplace(_html, "<.*?>", "")
        }

        /* =========================
		 * HasValue(_arr, _value)
		 * Check if an array has a specific value.
		 *
		 * @Parameter
         * _arr[Array]: Array to check a value in
         * _value[Any]: Values to check if it is in the array
		 *
		 * @Return value
		 * index - If the array has a value
         * false(0) - Else
		 * ==========================
		 */
        HasValue(_arr, _value)
        {
            Loop _arr.Length
            {
                if (_arr[A_Index] = _value)
                    return A_Index
            }
            return false
        }

        /* =========================
		 * GetTag(_outerHTML)
         * GetId(_outerHTML)
         * GetClass(_outerHTML)
         * Find the [tag name | id | class name] of _outerHTML
         *
         * @Parameter
         * _outerHTML[String]: The HTML string to find [Tag | Id | Class]
         *
         * @Return value
         * - string: tag name
         * - array: class, id (for example, <div class="abc def"> returns ['abc', 'def'])
         */
        GetTag(_outerHTML) => RegExReplace(_outerHTML, "s)<(\w*)(?:\s+[^>]*)?>.*", "$1")
        GetId(_outerHTML) => StrSplit(RegExReplace(_outerHTML, "s)<.*?id=['`"](.*?)['`"].*", "$1"), " ")
        GetClass(_outerHTML) => StrSplit(RegExReplace(_outerHTML, "s)<.*?class=['`"](.*?)['`"].*", "$1"), " ")
    }

}

