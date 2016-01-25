#!/bin/bash 

MYROOT=$(dirname $(readlink -f ${0}))
MODDIR=${MYROOT}/modules
MODULES=$(ls ${MODDIR})
LINT=/usr/share/gems/gems/puppet-lint-1.1.0/bin/puppet-lint

print_error () {
	case ${1} in
  		1)
    		echo -e "\e[00;33m Usage: ${0} [ --syntax | --lint ] (module) \e[00m" 
		;;
	esac
	exit ${1}
}

ctrl_manif () {
  
	[ ! -z ${1} ] || return 1

	INV=${1}
	if [ ! -z ${2} ]
  	then
		MODULES=${2}
	fi


	for dir in ${MODULES}
	do
		if [ -d ${MODDIR}/${dir}/manifests ]
		then
			MANIFESTS=$(ls ${MODDIR}/${dir}/manifests)
		else
			MANIFESTS=""
		fi

		if [ -d ${MODDIR}/${dir}/templates ]
		then
			TEMPLATES=$(ls ${MODDIR}/${dir}/templates)
		else
			TEMPLATES=""
		fi

		if [[ ! -z ${MANIFESTS} ]]
		then
			echo "MODULE = ${dir}"
			for manif in ${MANIFESTS}
			do
				if [[ ${INV} == "--syntax" ]]
				then
					puppet parser validate ${MODDIR}/${dir}/manifests/${manif} && echo "${manif} = Syntax OK"
				else
					sed -i 's/[ \t]*$//' ${MODDIR}/${dir}/manifests/${manif} 
					sed -i --posix -e 's/\t/  /g' ${MODDIR}/${dir}/manifests/${manif} 			
					${LINT} --no-variable_scope-check --no-inherits_across_namespaces-check --no-80chars-check --log-format '%{filename}" "%{KIND}": "%{message}" on line "%{line}' ${MODDIR}/${dir}/manifests/${manif}	
				fi
			done
		fi

		if [[ ! -z ${TEMPLATES} && ${INV} == "--syntax" ]]
		then
			for temp in ${TEMPLATES}
			do
				echo "${temp} = $(erb -P -x -T '-' ${MODDIR}/${dir}/templates/${temp} | ruby -c)"
			done
		fi
		echo ""
	done
}


case ${1} in

	--syntax | --lint) 
		if [ ${#} -eq 2 ]
		then
			ctrl_manif ${1} ${2}
		else
			ctrl_manif ${1}
		fi
	;;
	*)
		print_error 1
	;;
esac

