/*
MIT License, Copyright (C) 프날(Pnal, contact@pnal.dev)
You should have received a copy of the MIT License along with this library.
*/

/* #############################################################
 * AhkSoup v1.1
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
    html := ""
    document := []
    dev := {}

    __New()
    {
        this.dev := AhkSoup.Development()
    }

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
                tag: element.tag,
                id: element.id,
                class: element.class,
                outerHTML: element.outerHTML,
                innerHTML: this.dev.TrimOuterTag(element.outerHTML),
                Text: this.dev.TrimAllTag(element.outerHTML)
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
            Loop element.id.Length
            {
                if (element.id[A_Index] != _id && element.id != _id)
                    continue
                result.Push({
                    tag: element.tag,
                    id: element.id,
                    class: element.class,
                    outerHTML: element.outerHTML,
                    innerHTML: this.dev.TrimOuterTag(element.outerHTML),
                    Text: this.dev.TrimAllTag(element.outerHTML)
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
            Loop element.class.Length
            {
                if (element.class[A_Index] != _className && element.class != _className)
                    continue
                result.Push({
                    tag: element.tag,
                    id: element.id,
                    class: element.class,
                    outerHTML: element.outerHTML,
                    innerHTML: this.dev.TrimOuterTag(element.outerHTML),
                    Text: this.dev.TrimAllTag(element.outerHTML)
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
	 * QuerySelectorAll(_query)
	 * Find elements by query (NOT SUPPORT [+] SELECTOR & :nth-child without nth-child(n))
	 *
	 * @Parameter
	 * _query[String]: qeury to find elements. For example, "main #content .warn"
	 *
	 * @Return value
	 * result: Tags for matching with query.
     * [1]{tag, id, class, outerHTML, innerHTML, text}
     * [2]{tag, id, class, outerHTML, innerHTML, text}
     * ...
	 * ==========================
	 */
    QuerySelectorAll(_query) {
        query := RegExReplace(_query, "\s*>\s*", ">")
        query := RegExReplace(query, "\s+", " ")

        selectors := []
        parts := StrSplit(query, " ")

        for index, part in parts
        {
            if (InStr(part, ">"))
            {
                childParts := StrSplit(part, ">")
                for index, childPart in childParts
                {
                    if (childPart != "")
                    {
                        selectors.Push({
                            selector: childPart,
                            relationship: index < childParts.Length ? "child" : "descendant"
                        })
                    }
                }
            }
            else
            {
                selectors.Push({
                    selector: part,
                    relationship: "descendant"
                })
            }
        }
        result := []
        for element in this.dev.QueryInternal(this.document, selectors)
        {
            result.Push({
                tag: element.tag,
                id: element.id,
                class: element.class,
                outerHTML: element.outerHTML,
                innerHTML: this.dev.TrimOuterTag(element.outerHTML),
                Text: this.dev.TrimAllTag(element.outerHTML)
            })
        }

        return result
    }
    /* =========================
	 * QuerySelectorAll(_query)
	 * Find a first single element by query (NOT SUPPORT [+] SELECTOR & :nth-child without nth-child(n))
	 *
	 * @Parameter
	 * _query[String]: qeury to find a first single element. For example, "main #content .warn"
	 *
	 * @Return value
	 * result: A first single tag for matching with query.
     * {tag, id, class, outerHTML, innerHTML, text}
	 * ==========================
	 */
    QuerySelector(_query) => this.QuerySelectorAll(_query)[1]

    /* =========================
	 * [For development]
	 * Functions below this are used for other functions in this library and may be meaningless in actual use.
	 */
    class Development
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
                    if (tagEnd = 0)  ; If wrong HTML (If there isn't '>')
                        break

                    tag := SubStr(_html, tagStart, tagEnd - tagStart)

                    if (SubStr(tag, 2, 1) != "/") ; Opening tag
                    {
                        tagName := RegExReplace(tag, "^<([^\s>]+).*$", "$1")
                        idPos := RegExMatch(tag, "id=[`"']([^`"']+)[`"']", &idOut)
                        classPos := RegExMatch(tag, "class=[`"']([^`"']+)[`"']", &classOut)

                        tagInfo := {tag: tagName, id: idPos ? StrSplit(idOut[1], " ") : [""], class: classPos ? StrSplit(classOut[1], " ") : [""], content: [], outerHTML: tag}

                        if (!this.HasValue(this.voidElements, tagName) && SubStr(tag, -2) != "/>")
                            stack.Push({name: tagName, start: tagStart, info: tagInfo})

                        if (stack.Length > 0 && stack[stack.Length].info != tagInfo)
                            stack[stack.Length].info.content.Push(tagInfo)
                        else
                            tags.Push(tagInfo)
                    }
                    else ; Closing Tag. Update the corresponding opening tag's content.
                    {
                        closingTagName := RegExReplace(tag, "^</([^>]+)>$", "$1")
                        stackIndex := stack.Length
                        while (stackIndex > 0)
                        {
                            if (stack[stackIndex].name = closingTagName)
                            {
                                fullContent := SubStr(_html, stack[stackIndex].start, tagEnd - stack[stackIndex].start)
                                stack[stackIndex].info.outerHTML := fullContent
                                if (stackIndex > 1)
                                    stack[stackIndex - 1].info.content.Push(stack[stackIndex].info)
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

            return tags ; {tag, id, class, content, outerHTML}
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
            return RegExReplace(_html, "^(<[^>]+>)(.*)(</[^>]+>)$", "$2")
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


        /* =========================
         * QueryInternal(elements, selectors)
         * Process selectors and find matching elements recursively.
         *
         * @Parameter
         * elements[Array]: The array of elements to search in
         * selectors[Array]: Array of selector objects {selector, relationship}
         *
         * @Return value
         * filtered: Array of elements that match all selectors.
         * [1]{tag, id, class, content, outerHTML}
         * [2]{tag, id, class, content, outerHTML}
         * ...
         * ==========================
         */
        QueryInternal(elements, selectors)
        {
            if (selectors.Length = 0)
                return elements

            currentSelector := selectors.RemoveAt(1)
            filtered := []
            seenElements := []

            for index, parent in elements
            {
                if (!IsObject(parent.content))
                    continue

                siblings := parent.content

                if (currentSelector.relationship = "child")
                {
                    processDirectChildren(siblings, currentSelector.selector)
                    continue
                }

                processDescendants(parent, siblings, currentSelector.selector)
            }

            return this.queryInternal(filtered, selectors)

            processDirectChildren(siblings, selector)
            {
                for index, child in siblings
                {
                    if (this.IsMatch(child, selector, siblings, seenElements))
                        filtered.Push(child)
                }
            }

            processDescendants(parent, siblings, selector)
            {
                ; Process parent element
                if (this.IsMatch(parent, selector, siblings, seenElements))
                    filtered.Push(parent)

                ; Process children and their descendants
                for index, child in siblings
                {
                    if (this.IsMatch(child, selector, siblings, seenElements))
                        filtered.Push(child)

                    if (!child.content || !IsObject(child.content))
                        continue

                    childMatches := this.queryInternal([child], [{selector: selector, relationship: "descendant"}])

                    for index, match in childMatches
                    {
                        if (this.hasValue(seenElements, match))
                            continue

                        filtered.Push(match)
                        seenElements.Push(match)
                    }
                }
            }
        }

        /* =========================
         * IsMatch(element, selector, siblings, seenElements)
         * Check if an element matches the given selector with nth-child support.
         *
         * @Parameter
         * element[Object]: The element to check
         * selector[String]: The selector to match against
         * siblings[Array]: Array of sibling elements for nth-child calculation
         * seenElements[Array]: Array of already processed elements to avoid duplicates
         *
         * @Return value
         * true: If the element matches the selector
         * false: If the element doesn't match
         * ==========================
         */
        IsMatch(element, selector, siblings, seenElements)
        {
            if (this.hasValue(seenElements, element))
                return false

            if (InStr(selector, ":nth-child"))
            {
                parts := StrSplit(selector, ":nth-child")
                baseSelector := parts[1]

                if (RegExMatch(parts[2], "^\((\d+)\)$", &match))
                {
                    if (!IsObject(siblings) || siblings.Length = 0)
                        return false

                    n := match[1]
                    childIndex := 0

                    for index, sibling in siblings
                    {
                        childIndex++
                        if (sibling = element)
                        {
                            if (childIndex != n)
                                return false

                            if (this.matchSelector(element, baseSelector))
                            {
                                seenElements.Push(element)
                                return true
                            }
                            return false
                        }
                    }
                    return false
                }
            }

            if (this.matchSelector(element, selector))
            {
                seenElements.Push(element)
                return true
            }
            return false
        }

        /* =========================
         * MatchSelector(element, selector)
         * Check if an element matches a basic selector (tag, class, id).
         *
         * @Parameter
         * element[Object]: The element to check
         * selector[String]: The selector to match against (tag, #id, or .class)
         *
         * @Return value
         * true: If the element matches the selector
         * false: If the element doesn't match
         * ==========================
         */
        MatchSelector(element, selector)
        {
            if (selector = "")
                return true

            if (RegExMatch(selector, "^(\w+)([#.].+)$", &match))
            {
                tagSelector := match[1]
                attributeSelector := match[2]

                if (element.tag != tagSelector)
                    return false

                if (SubStr(attributeSelector, 1, 1) = "#")
                    return this.hasValue(element.id, SubStr(attributeSelector, 2))
                else if (SubStr(attributeSelector, 1, 1) = ".")
                    return this.hasValue(element.class, SubStr(attributeSelector, 2))
            }

            if (SubStr(selector, 1, 1) = "#")
                return this.hasValue(element.id, SubStr(selector, 2))
            else if (SubStr(selector, 1, 1) = ".")
                return this.hasValue(element.class, SubStr(selector, 2))
            else
                return element.tag = selector
        }
    }

}

