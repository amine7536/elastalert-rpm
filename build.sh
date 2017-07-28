#! /usr/bin/env bash
set -xe

export BASEDIR=$(dirname "$0")
export NAME="elastalert"
export VERSION="0.1.18"
export REVISION="1.el7"
export BUILDDIR="/tmp/build"
export INSTALLDIR="/usr/share/python"

yum -y install ruby ruby-devel gcc make rpm-build openssl-devel libffi-devel epel-release
yum -y install python-pip  python-virtualenv
pip install virtualenv-tools
pip install --upgrade pip
gem install fpm --no-doc

rm -fr $BUILDDIR
mkdir -p $BUILDDIR$INSTALLDIR

# Configuration files
mkdir -p $BUILDDIR/etc/elastalert/rules
mkdir -p $BUILDDIR/etc/sysconfig/
cp $BASEDIR/conf/config.yml $BUILDDIR/etc/elastalert/.
cp $BASEDIR/conf/elastalert.sysconfig $BUILDDIR/etc/sysconfig/elastalert

# Unit file
mkdir -p $BUILDDIR/usr/lib/systemd/system
cp $BASEDIR/conf/elastalert.service $BUILDDIR/usr/lib/systemd/system

# Virtual Env
virtualenv $BUILDDIR$INSTALLDIR/elastalert
$BUILDDIR$INSTALLDIR/elastalert/bin/pip install --upgrade pip
$BUILDDIR$INSTALLDIR/elastalert/bin/pip install "setuptools>=11.3" "elasticsearch>=5.0.0" "urllib3==1.21.1"
$BUILDDIR$INSTALLDIR/elastalert/bin/pip install "elastalert==$VERSION"

find $BUILDDIR ! -perm -a+r -exec chmod a+r {} \;

cd $BUILDDIR$INSTALLDIR/elastalert
 virtualenv-tools --update-path $INSTALLDIR/elastalert
cd -

# Clean up
find $BUILDDIR -iname *.pyc -exec rm {} \;
find $BUILDDIR -iname *.pyo -exec rm {} \;


fpm -f \
    --iteration $REVISION \
    -t rpm -s dir -C $BUILDDIR -n $NAME -v $VERSION \
    --config-files "/etc/elastalert/config.yml" \
    --config-files "/etc/sysconfig/elastalert" \
    --config-files "/usr/lib/systemd/system/elastalert.service" \
    --before-install $BASEDIR/scripts/preinstall.sh \
    --after-install $BASEDIR/scripts/postinstall.sh \
    --after-remove $BASEDIR/scripts/postuninstall.sh \
    --url http://elastalert.readthedocs.io/en/latest \
    --maintainer 'amine.benseddik@gmail.com' \
    --description 'ElastAlert - Easy & Flexible Alerting With Elasticsearch.' \
    --license 'Apache 2.0' \
    --package $BASEDIR \
    .
