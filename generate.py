import json
with open('http-status-code.json') as jf:
    codes = json.load(jf)
    for i in codes:
        code = i["code"]
        template = "templates/" + str(code)[0:1] + "xx.html"
        with open(template) as f:
            content = f.read()
            new_content = content
            error_code = int(code)

            print("checking Error Code: %d" % (error_code))

            if error_code == 418 or error_code < 400 or error_code > 599:
                continue
            new_content = new_content.replace("$ERROR_CODE", str(code))
            new_content = new_content.replace("$ERROR_NAME", i["phrase"])
            new_content = new_content.replace("$ERROR_DESC", i["comment"]["description"])
            with open(str(code) + ".html", "w") as output_file:
                output_file.write(new_content)

    with open("snippets/error_pages_content.conf", "w") as epc:
        for i in codes:
            v = int(i["code"])
            if v < 400 or v > 599:
                continue
            print("error_page %d /%d.html;" % (v, v), file=epc)
print("error pages done")