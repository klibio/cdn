#!/bin/bash
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd ) 
export PATH=$PATH:~/.ecdev/tool/apache-maven-3.9.4/bin/

## gradle short dependency
version=1.0.4

# one of [win32.win32.x86_64|linux.gtk.x86_64]
sysprops=win32.win32.x86_64

install_dir=${script_dir}/target/oomph.console
wrk_dir=${script_dir}/wrk

echo -e "#\n# maven provisioning of eclipse-installer console product locally\n#\n"
# https://maven.apache.org/plugins/maven-dependency-plugin/usage.html#dependency:get
mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:unpack \
    -Dartifact=com.github.a-langer:org.eclipse.oomph.console.product:$version:zip:$sysprops \
    -DoutputDirectory=${install_dir} \
    -Dproject.basedir=./

echo -e "#\n# execute eclipse-installer\n#\n"
echo "be patient for installation to execute..."
# see documentation at https://github.com/a-langer/eclipse-oomph-console

project_setup=oomph
project_dir=$wrk_dir/$project_setup
oomph_product=epp.package.committers
oomph_project=oomph
config_oomph=https://raw.githubusercontent.com/eclipse-oomph/oomph/master/setups/configurations/OomphConfiguration.setup
mkdir -p $wrk_dir >>/dev/null 2>&1 
${install_dir}/eclipse-inst -nosplash -application org.eclipse.oomph.console.application \
  -vmargs \
  -D_oomph.configuration.setups="$config_oomph" \
  -Doomph.product.id=$oomph_product \
  -Doomph.project.id=$oomph_project \
  -Doomph.installation.location=$project_dir \
  -Doomph.workspace.location=$project_dir/ws \
  -Doomph.installer.verbose=true \
  -Doomph.installer.layout=text

echo "installation is available inside $project_dir/eclipse"
echo -e "#\n# execution finished\n#\n"
