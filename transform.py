import sys

from lxml import etree as ET

from urllib.request import urlopen
from urllib.parse import urlencode

# Adapted from http://stackoverflow.com/questions/9809469/python-sax-to-lxml-for-80gb-xml/9814580#9814580

# Example program to read a large Solr XML search result, parse out the UMDM, transform to MODS, and write to sys.stdout

# command-line arguments
(baseUrl, query, rows) = sys.argv[1:]

# build Solr select URL
params = urlencode({'q':query, 'rows':rows, 'fl':'umdm','wt':'xml'})
url = "{}?{}".format(baseUrl, params)

# setup the XSLT transformer
transform = ET.XSLT(ET.parse('test.xsl'))

sys.stdout.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
sys.stdout.write("<mods:modsCollection xmlns:mods=\"http://www.loc.gov/mods/v3\">\n")

# user iterparse to stream in each UMDM w/o filling up memory
context = ET.iterparse(urlopen(url), events=('end',))

for action, elem in context:
    if elem.tag=='str' and elem.attrib['name'] == 'umdm':
        # the UMDM is encoded as text so decode and parse to XML
        descMeta = ET.fromstring(elem.text)

        # XSLT transform the single descMeta to mods
        mods = transform(descMeta)

        # write the single mods record to sts.stdout
        modsBytes = ET.tostring(mods)
        if (modsBytes):
            sys.stdout.write(modsBytes.decode("utf-8"))
            sys.stdout.write('\n')

    # cleanup
    # first empty children from current element
        # This is not absolutely necessary if you are also deleting siblings,
        # but it will allow you to free memory earlier.
    elem.clear()
    # second, delete previous siblings (records)
    while elem.getprevious() is not None:
        del elem.getparent()[0]
    # make sure you have no references to Element objects outside the loop

sys.stdout.write("</mods:modsCollection>\n")
