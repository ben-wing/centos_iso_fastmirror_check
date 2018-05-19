import sys
from bs4 import BeautifulSoup

html_source = open(sys.argv[1], 'r');

soup = BeautifulSoup(html_source, 'html.parser');

for link in soup.find_all('a'):
  href = unicode(link.string)
  if( href.startswith('http') and 'bittorrent' not in href and 'wiki.centos.org' not in href):
    print href.rstrip()

