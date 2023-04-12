# WP CLEANUP
Script to clean up infected WordPress installations

![](assets/cleanup.jpg)

## Installation 
* log in to your hacked server (via ssh)
* cd to a folder where you have 'write' permissions

	git clone https://github.com/pforret/repair_wp_hack.git

	cd repair_wp_hack

* check which line was inserted into your HTML/PHP files 
* default: <script type='text/javascript' src='https://[hacker-site]/same.js'></script>

	./cleanup_html.sh [root of your websites] for fixing .html and .php files

	./cleanup_wp.sh [root of your websites] for fixing Wordpress installation -  this will:

	* replace your wp-admin and wp-includes folders with those of a fresh Wordpress install
	* move your themes and plugins to non-usable folders and replace them by those of a fresh Wordpress install
	* after this, log in through /wp-admin/ and reinstall the necessary themes and plugins


# Valuable articles
* https://wordpress.org/support/topic/resolved-cutwin-javascript-injection/
* https://wordpress.org/support/article/faq-my-site-was-hacked/
* https://www.wordfence.com/learn/removing-malicious-redirects-site/
* https://smackdown.blogsblogsblogs.com/2008/06/24/how-to-completely-clean-your-hacked-wordpress-installation/

## Test your site

* https://sitecheck.sucuri.net/ (site keeps a cached version of your site, used a random parameter ?test=7763 after the URL to get a new scan)
* http://www.unmaskparasites.com/
* https://www.virustotal.com/gui/home/url

## Check if your site has been flagged as unsafe

* https://transparencyreport.google.com/safe-browsing/search
* https://global.sitesafety.trendmicro.com/
* https://www.trustedsource.org/