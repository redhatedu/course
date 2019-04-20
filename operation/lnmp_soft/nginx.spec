Name:nginx		
Version:1.8.0
Release:	1%{?dist}
Summary:test	

License:GPL	
URL:	www.test.com	
Source0:nginx-1.8.0.tar.gz

#BuildRequires:	
#Requires:	

%description
test too

%prep
%setup -q


%build
./configure
make %{?_smp_mflags}


%install
make install DESTDIR=%{buildroot}
mkdir -p %{buildroot}/etc/init.d/
install /root/rpmbuild/SPECS/nginx.txt %{buildroot}/etc/init.d/


%files
%doc
/etc/init.d/nginx.txt
/usr/local/*



%changelog

