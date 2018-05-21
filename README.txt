not yet complete scripts to attempt to find what the fastest mirror to download the 
current CentOS ISO of your choice (passed in as parameter)

major logic executed as
./get_fastest_mirror region iso

region and iso are required
region is specified in full-mirrorlist.csv as downloaded from centos.org
iso is specified by the iso names available in the mirror download index

the last line printed will provide a URL to be downloaded (TODO: prompt for download)

DEPENDENCIES
  the python scripts depend on the BeautifulSoup4 python library. https://www.crummy.com/software/BeautifulSoup/
  on centos/RHEL/fedora the package is "python-beautifulsoup4"

  script uses both wget (for download) and cURL (for ease of scripting)
