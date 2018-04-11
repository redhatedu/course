Name:nginx		
Version:1.12.2	
Release:100
Summary:this is a web server.	
License:GPL	
URL:www.douniwan.com	
Source0:nginx-1.12.2.tar.gz
%description
this is a web server tooooooo.

%prep
%setup -q

%build
./configure
make %{?_smp_mflags}

%install
make install DESTDIR=%{buildroot}

%files
%doc
/usr/local/nginx/*


%changelog

