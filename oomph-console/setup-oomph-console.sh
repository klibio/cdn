#!/bin/bash

# activate bash checks
# e ~ exit on error, u ~ unset vars, pipe fails
#set -eu

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export PATH=$PATH:~/.ecdev/tool/apache-maven-3.9.4/bin/
if [ -v envCompleted ]; then
    echo "skipping env loading"
else
    . ${script_dir}/set-env.sh
fi

## gradle short dependency
version=1.0.4

# one of [win32.win32.x86_64|linux.gtk.x86_64]
#sys_props=win32.win32.x86_64
sys_props=linux.gtk.x86_64
archive_type=tar.gz

install_dir=${script_dir}/target/oomph.console
wrk_dir=${script_dir}/wrk

headline "maven provisioning of eclipse-installer console product locally"
# https://maven.apache.org/plugins/maven-dependency-plugin/usage.html#dependency:get
mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:unpack \
-Dartifact=com.github.a-langer:org.eclipse.oomph.console.product:$version:$archive_type:$sys_props \
-DoutputDirectory=${install_dir} \
-Dproject.basedir=./

#config_oomph=https://raw.githubusercontent.com/eclipse-oomph/oomph/master/setups/configurations/OomphConfiguration.setup
declare -a configs=(
  "https://cdn.klib.io/oomph/setups-github/BndConfiguration.setup"
  "https://cdn.klib.io/oomph/setups-github/BndConfigurationEmpty.setup"
  "https://cdn.klib.io/oomph/setups-github/BndConfigurationECF.setup"
  "https://cdn.klib.io/oomph/setups-github/CdnConfiguration.setup"
  "https://cdn.klib.io/oomph/setups-github/klibio/klibio-configuration-empty.setup"
  "https://raw.githubusercontent.com/eclipse-oomph/oomph/master/setups/configurations/OomphConfiguration.setup"
)

for cfg in "${configs[@]}"
do
    project_setup=$(echo $cfg | sed 's/.*\/\(.*\)\.setup/\1/g')
    echo -e "#\n# execute eclipse-installer\n#\n"
    echo "be patient for installation of ... $project_setup"
    # see documentation at https://github.com/a-langer/eclipse-oomph-console
    project_dir=$wrk_dir/$project_setup
    oomph_product=epp.package.committers
    oomph_project=oomph
    mkdir -p $wrk_dir >>/dev/null 2>&1
    ${install_dir}/eclipse-inst -nosplash -application org.eclipse.oomph.console.application \
    -vmargs \
    -Doomph.configuration.setups="$cfg" \
    -D_oomph.product.id=$oomph_product \
    -D_oomph.project.id=$oomph_project \
    -Doomph.installation.location=$project_dir \
    -Doomph.workspace.location=$project_dir/ws \
    -Doomph.installer.verbose=true \
    -Doomph.installer.layout=text
    
    retVal=$?
    if [ $retVal -ne 0 ]; then
        paderr "error occured during installation"
    fi
    
    padout "installation is available inside $project_dir/eclipse"
    
    headline "validation of $project_setup - started"
    
    padout "existence test eclipse.ini"
    [[ -f $project_dir/eclipse/eclipse.ini ]]  && succ || err
    padout "workspace"
    [[ -d $project_dir/ws/.metadata ]]  && succ || err

    headline "validation of $project_setup - finished"
done

headline "execution finished"
