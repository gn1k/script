#!/bin/bash

_force="1"

# Get native version
_native_phpver=$(/usr/bin/selectorctl --current --show-native-version | awk -F"[()]" '{print $2}' | tr -d '.')

# File .ini for native
_php_native="/usr/share/cagefs-skeleton/usr/local/php${_native_phpver}/lib/php.conf.d/custom-domain.ini"

if [[ "$1" == "--force" ]]; then
	_force="1"
fi

_usr="${username}"
# Get current php of user
_cur_phpver=$(/usr/bin/selectorctl --user-current --user=${_usr} | awk -F" " '{print $1}' | tr -d '.')
# Get prefix cagefs
_cagefs_prefix=$(/usr/sbin/cagefsctl --getprefix ${_usr})
	# Loop domain
_domain="${domain}"
if [[ "$_cur_phpver" != "native" ]]; then
        # Custom for ALT-php
        _php_alt="/var/cagefs/${_cagefs_prefix}/${_usr}/etc/cl.php.d/alt-php${_cur_phpver}/${_domain}.ini"
        if [[ "${_force}" == "1" || ! -f "${_php_alt}" ]]; then
		# non-www
                echo "[HOST=${_domain}]" > "${_php_alt}"
                echo "open_basedir=/home/${_usr}/domains/${_domain}/public_html" >> "${_php_alt}"
		# www
		echo "[HOST=www.${_domain}]" > "${_php_alt}"
		echo "open_basedir=/home/${_usr}/domains/${_domain}/public_html" >> "${_php_alt}"
        fi
fi
# Custom for Native-php
# check exist
if [[ "${_force}" == "1" || "$(grep -Fxc "[HOST=${_domain}]" "${_php_native}")" -eq 0 ]]; then
        # non-www
	echo "[HOST=${_domain}]" >> "${_php_native}"
        echo "open_basedir=/home/${_usr}/domains/${_domain}/public_html" >> "${_php_native}"
	# www
	echo "[HOST=www.${_domain}]" >> "${_php_native}"
	echo "open_basedir=/home/${_usr}/domains/${_domain}/public_html" >> "${_php_native}"
	echo >> "${_php_native}"
fi