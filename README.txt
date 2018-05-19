not yet complete scripts to attempt to find what the fastest mirror to download the 
current (right now hard coded TODO) Minimal CentOS ISO

you can just run get_fastest_mirror.sh

the last line printed will provide a URL to be downloaded (TODO: prompt for download)

NB this is hardcoded to only check the mirrors in my country (US) (TODO)

DEPENDENCIES
  the python scripts depend on the BeautifulSoup4 python library. https://www.crummy.com/software/BeautifulSoup/
  on centos/RHEL/fedora the package is "python-beautifulsoup4"

  script uses both wget (for download) and cURL (for ease of scripting)
