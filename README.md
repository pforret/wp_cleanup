![GH stars](https://img.shields.io/github/stars/pforret/wp_cleanup)
![GH tag](https://img.shields.io/github/v/tag/pforret/wp_cleanup)
![Shellcheck CI](https://github.com/pforret/wp_cleanup/workflows/Shellcheck%20CI/badge.svg)
![GH Language](https://img.shields.io/github/languages/top/pforret/wp_cleanup)
![GH License](https://img.shields.io/github/license/pforret/wp_cleanup)
[![basher install](https://img.shields.io/badge/basher-install-white?logo=gnu-bash&style=flat)](https://basher.gitparade.com/package/)

# WP CLEANUP

    Script to clean up infected WordPress installations

![](assets/cleanup.jpg)

## Installation 
* log in to your hacked server (via ssh)
* cd to a folder where you have 'write' permissions

```bash
git clone https://github.com/pforret/wp_cleanup
cd wp_cleanup
./wp_cleanup -W [WP folder] fix
✅  WordPress installation moved to [.../_infected.20230412_1634]
✅  Wordpress 6.2 downloaded!
✅  Wordpress system restored!
✅  Copied from themes: testtheme  
✅  Copied from plugins: testplugin  
✅  Wordpress settings copied!
✅  Wordpress .htaccess set!
✅  --- Wordpress cleanup was done
Do you want to compress the infected files? [y/N] Y 
✅  old WordPress files in _infected.20230412_1634.zip
```

This will
* move your current (infected) WordPress files to a backup folder
* replace your `wp-admin` and `wp-includes` folders with those of a fresh WordPress install
* replace your wp-*.php files with those of a fresh WordPress install
* recover your original `wp-config.php` file
* recover your original `wp-content`: themes,plugins,uploads
* reset your `.htaccess` file


# Valuable articles
* [RESOLVED: cutwin Javascript injection (WordPress)](https://wordpress.org/support/topic/resolved-cutwin-javascript-injection/)
* [FAQ My site was hacked (WordPress)](https://wordpress.org/support/article/faq-my-site-was-hacked/)
* [Removing Malicious Redirects From Your Site (WordFence)](https://www.wordfence.com/learn/removing-malicious-redirects-site/)
* [How To Completely Clean Your Hacked WordPress Installation](https://smackdown.blogsblogsblogs.com/2008/06/24/how-to-completely-clean-your-hacked-wordpress-installation/)

## Test your site

* https://sitecheck.sucuri.net/ (site keeps a cached version of your site, used a random parameter ?test=7763 after the URL to get a new scan)
* http://www.unmaskparasites.com/
* https://www.virustotal.com/gui/home/url

## Check if your site has been flagged as unsafe

* https://transparencyreport.google.com/safe-browsing/search
* https://global.sitesafety.trendmicro.com/
* https://www.trustedsource.org/