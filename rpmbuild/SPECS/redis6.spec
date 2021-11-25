%bcond_with    tests
%global doc_commit e0528232fdd0d2efc91d62b798b924d716f88813
%global short_doc_commit %(c=%{doc_commit}; echo ${c:0:7})
%global macrosdir %(d=%{_rpmconfigdir}/macros.d; [ -d $d ] || d=%{_sysconfdir}/rpm; echo $d)
%global make_flags	DEBUG="" V="echo" LDFLAGS="%{?__global_ldflags}" CFLAGS+="%{optflags} -fPIC" INSTALL="install -p" PREFIX=%{buildroot}%{_prefix} BUILD_WITH_SYSTEMD=yes BUILD_TLS=yes
%global Pname redis
Name:                redis6
Version:             6.2.6
Release:             4
Summary:             A persistent key-value database
License:             BSD and MIT
URL:                 https://redis.io
Source0:             https://download.redis.io/releases/%{Pname}-%{version}.tar.gz
Source1:             %{Pname}.logrotate
Source2:             %{Pname}-sentinel.service
Source3:             %{Pname}.service
Source6:             %{Pname}-shutdown
Source7:             %{Pname}-limit-systemd
Source9:             macros.%{Pname}
Source10:            https://github.com/%{Pname}/%{Pname}-doc/archive/%{doc_commit}/%{Pname}-doc-%{short_doc_commit}.tar.gz

Patch0001:           Modify-aarch64-architecture-jemalloc-page-size-from-from-4k-to-64k.patch

BuildRequires:       make gcc
%if %{with tests}
BuildRequires:       procps-ng tcl
%endif
BuildRequires:       pkgconfig(libsystemd) systemd-devel openssl-devel libatomic
Obsoletes:           redis-trib < 5
Requires:            /bin/awk logrotate
Provides:            bundled(hiredis) = 0.14.0
Provides:            bundled(jemalloc) = 5.1.0
Provides:            bundled(lua-libs) = 5.1.5
Provides:            bundled(linenoise) = 1.0
Provides:            bundled(lzf)
Requires(pre):     shadow-utils
Requires(post):    systemd
Requires(preun):   systemd
Requires(postun):  systemd
Provides:            redis(modules_abi)%{?_isa} = 1
%description
Redis is an advanced key-value store. It is often referred to as a data
structure server since keys can contain strings, hashes, lists, sets and
sorted sets.
You can run atomic operations on these types, like appending to a string;
incrementing the value in a hash; pushing to a list; computing set
intersection, union and difference; or getting the member with highest
ranking in a sorted set.
In order to achieve its outstanding performance, Redis works with an
in-memory dataset. Depending on your use case, you can persist it either
by dumping the dataset to disk every once in a while, or by appending
each command to a log.
Redis also supports trivial-to-setup master-slave replication, with very
fast non-blocking first synchronization, auto-reconnection on net split
and so forth.
Other features include Transactions, Pub/Sub, Lua scripting, Keys with a
limited time-to-live, and configuration settings to make Redis behave like
a cache.
You can use Redis from most programming languages also.

%package           devel
Summary:             Development header for Redis module development
Provides:            %{Pname}-static = %{version}-%{release}
%description       devel
Header file required for building loadable Redis modules. Detailed
API documentation is available in the redis-doc package.

%package           doc
Summary:             Documentation for Redis
License:             CC-BY-SA
BuildArch:           noarch
Conflicts:           redis < 4.0
%description       doc
Detailed documentation for many aspects of Redis use,
administration and development.

%prep
tar -xvf  %{SOURCE10}
%setup -n %{Pname}-%{version}
%ifarch aarch64
%patch0001 -p1
%patch0002 -p1
%endif
mv ../%{Pname}-doc-%{doc_commit} doc
mv deps/lua/COPYRIGHT    COPYRIGHT-lua
mv deps/jemalloc/COPYING COPYING-jemalloc
mv deps/hiredis/COPYING  COPYING-hiredis
sed -i -e 's|^logfile .*$|logfile /var/log/redis/redis.log|g' redis.conf
sed -i -e 's|^logfile .*$|logfile /var/log/redis/sentinel.log|g' sentinel.conf
sed -i -e 's|^dir .*$|dir /var/lib/redis|g' redis.conf
api=`sed -n -e 's/#define REDISMODULE_APIVER_[0-9][0-9]* //p' src/redismodule.h`
if test "$api" != "1"; then
   : Error: Upstream API version is now ${api}, expecting %1.
   : Update the redis_modules_abi macro, the rpmmacros file, and rebuild.
   exit 1
fi

%build
make %{?_smp_mflags} %{make_flags} all

%install
make %{make_flags} install
install -d %{buildroot}%{_sharedstatedir}/%{Pname}
install -d %{buildroot}%{_localstatedir}/log/%{Pname}
install -d %{buildroot}%{_localstatedir}/run/%{Pname}
install -d %{buildroot}%{_libdir}/%{Pname}/modules
install -pDm644 %{S:1} %{buildroot}%{_sysconfdir}/logrotate.d/%{Pname}
install -pDm640 %{Pname}.conf  %{buildroot}%{_sysconfdir}/%{Pname}/%{Pname}.conf
install -pDm640 sentinel.conf %{buildroot}%{_sysconfdir}/%{Pname}/sentinel.conf
mkdir -p %{buildroot}%{_unitdir}
install -pm644 %{S:3} %{buildroot}%{_unitdir}
install -pm644 %{S:2} %{buildroot}%{_unitdir}
install -p -D -m 644 %{S:7} %{buildroot}%{_sysconfdir}/systemd/system/%{Pname}.service.d/limit.conf
install -p -D -m 644 %{S:7} %{buildroot}%{_sysconfdir}/systemd/system/%{Pname}-sentinel.service.d/limit.conf
chmod 755 %{buildroot}%{_bindir}/%{Pname}-*
install -pDm755 %{S:6} %{buildroot}%{_libexecdir}/%{Pname}-shutdown
install -pDm644 src/%{Pname}module.h %{buildroot}%{_includedir}/%{Pname}module.h
doc=$(echo %{buildroot}/%{_docdir}/%{Pname})
for page in 00-RELEASENOTES BUGS CONTRIBUTING MANIFESTO; do
    install -Dpm644 $page $doc/$page
done
for page in $(find doc -name \*.md | sed -e 's|.md$||g'); do
    base=$(echo $page | sed -e 's|doc/||g')
    install -Dpm644 $page.md $doc/$base.md
done
mkdir -p %{buildroot}%{macrosdir}
install -pDm644 %{S:9} %{buildroot}%{macrosdir}/macros.%{Pname}

%check
%if %{with tests}
taskset -c 1 make %{make_flags} test
make %{make_flags} test-sentinel
%endif

%pre
getent group %{Pname} &> /dev/null || \
groupadd -r %{Pname} &> /dev/null
getent passwd %{Pname} &> /dev/null || \
useradd -r -g %{Pname} -d %{_sharedstatedir}/%{Pname} -s /sbin/nologin \
-c 'Redis Database Server' %{Pname} &> /dev/null
exit 0

%post
if [ -f %{_sysconfdir}/%{Pname}.conf -a ! -L %{_sysconfdir}/%{Pname}.conf ]; then
  if [ -f %{_sysconfdir}/%{Pname}/%{Pname}.conf.rpmnew ]; then
    rm    %{_sysconfdir}/%{Pname}/%{Pname}.conf.rpmnew
  fi
  if [ -f %{_sysconfdir}/%{Pname}/%{Pname}.conf ]; then
    mv    %{_sysconfdir}/%{Pname}/%{Pname}.conf %{_sysconfdir}/%{Pname}/%{Pname}.conf.rpmnew
  fi
  mv %{_sysconfdir}/%{Pname}.conf %{_sysconfdir}/%{Pname}/%{Pname}.conf
  echo -e "\nWarning: %{Pname} configuration is now in %{_sysconfdir}/%{Pname} directory\n"
fi
if [ -f %{_sysconfdir}/%{Pname}-sentinel.conf  -a ! -L %{_sysconfdir}/%{Pname}-sentinel.conf  ]; then
  if [ -f %{_sysconfdir}/%{Pname}/sentinel.conf.rpmnew ]; then
    rm    %{_sysconfdir}/%{Pname}/sentinel.conf.rpmnew
  fi
  if [ -f %{_sysconfdir}/%{Pname}/sentinel.conf ]; then
    mv    %{_sysconfdir}/%{Pname}/sentinel.conf %{_sysconfdir}/%{Pname}/sentinel.conf.rpmnew
  fi
  mv %{_sysconfdir}/%{Pname}-sentinel.conf %{_sysconfdir}/%{Pname}/sentinel.conf
fi
%systemd_post %{Pname}.service
%systemd_post %{Pname}-sentinel.service

%preun
%systemd_preun %{Pname}.service
%systemd_preun %{Pname}-sentinel.service

%postun
%systemd_postun_with_restart %{Pname}.service
%systemd_postun_with_restart %{Pname}-sentinel.service

%files
%{!?_licensedir:%global license %%doc}
%license COPYING
%license COPYRIGHT-lua
%license COPYING-jemalloc
%license COPYING-hiredis
%config(noreplace) %{_sysconfdir}/logrotate.d/%{Pname}
%attr(0750, redis, root) %dir %{_sysconfdir}/%{Pname}
%attr(0640, redis, root) %config(noreplace) %{_sysconfdir}/%{Pname}/%{Pname}.conf
%attr(0640, redis, root) %config(noreplace) %{_sysconfdir}/%{Pname}/sentinel.conf
%dir %attr(0750, redis, redis) %{_libdir}/%{Pname}
%dir %attr(0750, redis, redis) %{_libdir}/%{Pname}/modules
%dir %attr(0750, redis, redis) %{_sharedstatedir}/%{Pname}
%dir %attr(0750, redis, redis) %{_localstatedir}/log/%{Pname}
%exclude %{macrosdir}
%exclude %{_includedir}
%exclude %{_docdir}/%{Pname}/*
%{_bindir}/%{Pname}-*
%{_libexecdir}/%{Pname}-*
%{_unitdir}/%{Pname}.service
%{_unitdir}/%{Pname}-sentinel.service
%dir %{_sysconfdir}/systemd/system/%{Pname}.service.d
%config(noreplace) %{_sysconfdir}/systemd/system/%{Pname}.service.d/limit.conf
%dir %{_sysconfdir}/systemd/system/%{Pname}-sentinel.service.d
%config(noreplace) %{_sysconfdir}/systemd/system/%{Pname}-sentinel.service.d/limit.conf
%dir %attr(0755, redis, redis) %ghost %{_localstatedir}/run/%{Pname}

%files devel
%license COPYING
%{_includedir}/%{Pname}module.h
%{macrosdir}/*

%files doc
%license COPYING
%docdir %{_docdir}/%{Pname}
%{_docdir}/%{Pname}

