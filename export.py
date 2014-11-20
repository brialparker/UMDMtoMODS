import sys

from lxml import etree as ET

from urllib.request import urlopen
from urllib.parse import urlencode

# Adapted from http://stackoverflow.com/questions/9809469/python-sax-to-lxml-for-80gb-xml/9814580#9814580

# Example program to read a large Solr XML search result, parse out the PID and UMDM, and write to sys.stdout

# command-line arguments
(baseUrl, query, rows) = sys.argv[1:]

# build Solr select URL
params = urlencode({'q':query, 'rows':rows, 'fl':'pid,umdm','wt':'xml'})
url = "{}?{}".format(baseUrl, params)

sys.stdout.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
sys.stdout.write("<collection>\n")

# use iterparse to stream in each UMDM w/o filling up memory
context = ET.iterparse(urlopen(url), events=('end',))

for action, elem in context:
	if elem.tag=='doc':
		root = ET.Element('item')
		itemTree = ET.ElementTree(root)
		for child in elem:
			if child.tag=='str' and child.attrib['name'] == 'pid':
				pid = ET.SubElement(root, 'pid')
				pid.text = child.text
			elif child.tag=='str' and child.attrib['name'] == 'umdm':
				descMeta = ET.SubElement(root, 'descMeta')
				# the UMDM is encoded as text so decode and parse to XML and
				# append the parsed XML as a child of the item
				descMeta.append(ET.fromstring(child.text))
				
		# write the item record to sts.stdout
		itemBytes = ET.tostring(itemTree)
		if (itemBytes):
			sys.stdout.write(itemBytes.decode("utf-8"))
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

sys.stdout.write("</collection>\n")
