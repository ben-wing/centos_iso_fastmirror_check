import sys
from bs4 import BeautifulSoup

html_source = open(sys.argv[1], 'r');

soup = BeautifulSoup(html_source, 'html.parser');

for link in soup.find_all('a'):
  href = link.get('href')
  if( 'Minimal' in href and 'iso' in href):
    print href

