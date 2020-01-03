not yet complete scripts to attempt to find what the fastest mirror to download the 
notable TODOs:
  - handle any currently supported version (currently both 7 or 8)
  - handle either Stream or traditional
  - improved usage that prompts for currently available iso types, and regions
current CentOS ISO of your choice (passed in as parameter)

major logic executed as
./get_fastest_mirror region iso

region and iso are required
region is specified in full-mirrorlist.csv as downloaded from https://www.centos.org/download/full-mirrorlist.csv
iso is specified by the iso names available in the [mirror download index](https://www.centos.org/download/) (DVD, Everything, Minimal as of 2018-11-06)

the last line printed will provide a URL to be downloaded (TODO: prompt for download)

DEPENDENCIES
  the python scripts depend on the BeautifulSoup4 python library. https://www.crummy.com/software/BeautifulSoup/
  on centos/RHEL/fedora the package is "python-beautifulsoup4"

  script uses both wget (for download) and cURL (for ease of scripting)
