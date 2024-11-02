/*
MIT License, Copyright (C) 프날(Pnal, contact@pnal.dev)
You should have received a copy of the MIT License along with this library.
*/

/* #############################################################
 * AhkSoup v1.0
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
    document := ""

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
        return this.document := this.dev.SortTags(this.dev.ExtractAllTags(_html), _html)
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
     * [1]{outerHTML, innerHTML, Text}
     * [2]{outerHTML, innerHTML, Text}
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
            result.Push({outerHTML: element.content, innerHTML: this.dev.TrimOuterTag(element.content), Text: this.dev.TrimAllTag(element.content)})
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
     * [1]{outerHTML, innerHTML, Text}
     * [2]{outerHTML, innerHTML, Text}
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
                result.Push({outerHTML: element.content, innerHTML: this.dev.TrimOuterTag(element.content), Text: this.dev.TrimAllTag(element.content)})
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
     * [1]{outerHTML, innerHTML, Text}
     * [2]{outerHTML, innerHTML, Text}
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
                result.Push({outerHTML: element.content, innerHTML: this.dev.TrimOuterTag(element.content), Text: this.dev.TrimAllTag(element.content)})
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
     * {outerHTML, innerHTML, Text}
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
		 * Extract all tags by inner to outer, top to bottom.
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
                    if (tagEnd = 0)  ;If wrong HTML(If there isn't '>')
                        break

                    tag := SubStr(_html, tagStart, tagEnd - tagStart)

                    if (SubStr(tag, 2, 1) != "/") ;Opening tag
                    {
                        tagName := RegExReplace(tag, "^<([^\s>]+).*$", "$1")
                        idPos := RegExMatch(tag, "id=[`"']([^`"']+)[`"']", &idOut)
                        classPos := RegExMatch(tag, "class=[`"']([^`"']+)[`"']", &classOut)

                        tagInfo := {tag: tagName, id: idPos ? idOut[1] : "", class: classPos ? classOut[1] : "", content: ""}

                        ;If this tag is void element, insert it to result.
                        if (this.HasValue(this.voidElements, tagName) || SubStr(tag, -2) = "/>")
                        {
                            tagInfo.content := tag
                            tags.Push(tagInfo)
                        }
                        else ;Else, insert it to stack
                            stack.Push({name: tagName, start: tagStart, info: tagInfo})
                    }
                    else ;Closing Tag. Stack item will pop.
                    {
                        closingTagName := RegExReplace(tag, "^</([^>]+)>$", "$1")
                        while (stack.Length > 0)
                        {
                            lastOpenTag := stack.Pop()
                            if (lastOpenTag.name != closingTagName)
                                continue
                            tagContent := SubStr(_html, lastOpenTag.start, tagEnd - lastOpenTag.start)
                            lastOpenTag.info.content := tagContent
                            tags.Push(lastOpenTag.info)
                            break
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
		 * SortTags(_tags, _html)
		 * Extract all tags by inner to outer, top to bottom.
		 *
		 * @Parameter
         * _tags[String]: The array which has object literal by its elements. (The return value of ExtractAllTags())
		 * _html[String]: The original HTML string to compare
		 *
		 * @Return value
		 * sortedTags: The array which has object literal by its elements. [Sorted]
         * [1]{tag, id, class, content}
         * [2]{tag, id, class, content}
         * ...
		 * ==========================
		 */
        SortTags(_tags, _html)
        {
            sortedTags := []
            tagPositions := Map()

            ;Save each tag's start pos
            for index, tag in _tags
            {
                startPos := InStr(_html, tag.content)
                if (startPos > 0)
                    tagPositions.Set(startPos, tag)
            }

            ;Sorting by start pos, Array to String
            positions := []
            for pos in tagPositions
                positions.Push(pos)

            posStr := ""
            for pos in positions
                posStr .= pos ","
            posStr := SubStr(posStr, 1, -1)
            Sort(posStr, "N D,")

            ;String to Array
            sortedPositions := StrSplit(posStr, ",")
            for pos in sortedPositions
                sortedTags.Push(tagPositions[pos + 0]) ;To convert pos to int

            return sortedTags
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
    }

}

