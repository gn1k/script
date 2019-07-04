#!/bin/bash

_force="0"

# Get native version
_native_phpver=$(/usr/bin/selectorctl --current --show-native-version | awk -F"[()]" '{print $2}' | tr -d '.')

# File .ini for native
_php_native="/usr/share/cagefs-skeleton/usr/local/php${_native_phpver}/lib/php.conf.d/custom-domain.ini"

if [[ "$1" == "--force" ]]; then
	_force="1"
	echo -n > "${_php_native}"
fi

for dl in $(find /usr/local/directadmin/data/users/*/domains.list); do
        [[ "${dl}" == "" ]] && { continue; }
        _usr=$(echo "$dl" | awk -F / '{print $7}')
	# Get current php of user
	_cur_phpver=$(/usr/bin/selectorctl --user-current --user=${_usr} | awk -F" " '{print $1}' | tr -d '.')
	# Get prefix cagefs
	_cagefs_prefix=$(/usr/sbin/cagefsctl --getprefix ${_usr})
	# Loop domain
        for _domain in $(cat $dl); do
                [[ "${_domain}" == "" ]] && { continue; }
                if [[ "$_cur_phpver" != "native" ]]; then
                        # Custom for ALT-php
                        _php_alt="/var/cagefs/${_cagefs_prefix}/${_usr}/etc/cl.php.d/alt-php${_cur_phpver}/${_domain}.ini"
                        if [[ "${_force}" == "1" || ! -f "${_php_alt}" ]]; then
				# non-www
                                echo "[HOST=${_domain}]" > "${_php_alt}"
                                echo "open_basedir=/home/${_usr}/domains/${_domain}/public_html" >> "${_php_alt}"
				# www
				echo "[HOST=www.${_domain}]" >> "${_php_alt}"
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

		# Alias domain
		_pt_file="/usr/local/directadmin/data/users/${_usr}/domains/${_domain}.pointers"
		if [[ -f "${_pt_file}" ]]; then
			for al in $(grep "alias" "${_pt_file}"); do
				[[ "${al}" == "" ]] && { continue; }
				# Get only alias, no pointer
				_al_domain="$(echo "${al}" | awk -F"=" '{print $1}')"
				if [[ "$_cur_phpver" != "native" ]]; then
                        		# Custom for ALT-php
                        		_php_alt="/var/cagefs/${_cagefs_prefix}/${_usr}/etc/cl.php.d/alt-php${_cur_phpver}/${_al_domain}.ini"
                        		if [[ "${_force}" == "1" || ! -f "${_php_alt}" ]]; then
						# non-www
                                		echo "[HOST=${_al_domain}]" > "${_php_alt}"
                                		echo "open_basedir=/home/${_usr}/domains/${_domain}/public_html" >> "${_php_alt}"
						echo >> "${_php_alt}"
						# www
						echo "[HOST=www.${_al_domain}]" >> "${_php_alt}"
						echo "open_basedir=/home/${_usr}/domains/${_domain}/public_html" >> "${_php_alt}"
                        		fi
                		fi
				# Custom for Native-php
                		# check exist
                		if [[ "${_force}" == "1" || "$(grep -Fxc "[HOST=${_al_domain}]" "${_php_native}")" -eq 0 ]]; then
					# non-www
                        		echo "[HOST=${_al_domain}]" >> "${_php_native}"
					echo "open_basedir=/home/${_usr}/domains/${_domain}/public_html" >> "${_php_native}"
					# www
					echo "[HOST=www.${_al_domain}]" >> "${_php_native}"
                        		echo "open_basedir=/home/${_usr}/domains/${_domain}/public_html" >> "${_php_native}"
                        		echo >> "${_php_native}"
                		fi
			done
		fi

		# Sub domain
                _sub_file="/usr/local/directadmin/data/users/${_usr}/domains/${_domain}.subdomains"
                if [[ -f "${_sub_file}" ]]; then
                        for sb in $(cat "${_sub_file}"); do
                                [[ "${sb}" == "" ]] && { continue; }
                                # Get only alias, no pointer
                                _sub_domain="${sb}.${_domain}"
                                if [[ "$_cur_phpver" != "native" ]]; then
                                        # Custom for ALT-php
                                        _php_alt="/var/cagefs/${_cagefs_prefix}/${_usr}/etc/cl.php.d/alt-php${_cur_phpver}/${_sub_domain}.ini"
                                        if [[ "${_force}" == "1" || ! -f "${_php_alt}" ]]; then
                                                # non-www
                                                echo "[HOST=${_sub_domain}]" >> "${_php_alt}"
                                                echo "open_basedir=/home/${_usr}/domains/${_domain}/public_html/${sb}" >> "${_php_alt}"
                                                echo >> "${_php_alt}"
                                                # www
                                                #echo "[HOST=www.${_sub_domain}]" > "${_php_alt}"
                                                #echo "open_basedir=/home/${_usr}/domains/${_domain}/public_html/${sb}" >> "${_php_alt}"
                                        fi
                                fi
                                # Custom for Native-php
                                # check exist
                                if [[ "${_force}" == "1" || "$(grep -Fxc "[HOST=${_sub_domain}]" "${_php_native}")" -eq 0 ]]; then
                                        # non-www
                                        echo "[HOST=${_sub_domain}]" >> "${_php_native}"
                                        echo "open_basedir=/home/${_usr}/domains/${_domain}/public_html/${sb}" >> "${_php_native}"
                                        # www
                                        #echo "[HOST=www.${_sub_domain}]" >> "${_php_native}"
                                        #echo "open_basedir=/home/${_usr}/domains/${_domain}/public_html/${sb}" >> "${_php_native}"
                                        echo >> "${_php_native}"
                                fi
                        done
                fi 
        done
done
