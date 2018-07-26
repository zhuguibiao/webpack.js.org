wget https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tgz
echo "##############start run install for python2.7 script############"
yum -y install python-devel openssl openssl-devel gcc sqlite sqlite-devel mysql-devel libxml2-devel libxslt-devel
tar -zxf Python-2.7.13.tgz
cd Python-2.7.13/
./configure --prefix=/usr/local/python2.7 --with-threads --enable-shared
make
make altinstall
mv /usr/bin/pip /usr/bin/pip_old
mv /usr/bin/easy_install /usr/bin/easy_install_old
mv /usr/bin/python /usr/bin/python_old
ln -s /usr/local/python2.7/lib/libpython2.7.so /usr/lib
ln -s /usr/local/python2.7/lib/libpython2.7.so.1.0 /usr/lib
ln -s /usr/local/python2.7/bin/python2.7 /usr/bin/python
ln -s /usr/local/python2.7/lib/libpython2.7.so /usr/lib64
ln -s /usr/local/python2.7/lib/libpython2.7.so.1.0 /usr/lib64
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
ln -s /usr/local/python2.7/bin/pip /usr/bin/pip
echo "############更换pip源为国内淘宝源##########"
mkdir /root/.pip/
touch /root/.pip/pip.conf
cat >> /root/.pip/pip.conf << EOF
[global]
index-url=http://mirrors.aliyun.com/pypi/simple/ 

[install]
trusted-host=mirrors.aliyun.com
EOF

pip install Pillow
sed -i 's#\/usr/bin/python#\/usr/bin/python2.6#g' /usr/bin/yum
yum -y install python-devel
echo 'the install script is the end......'