if [ $1 -eq 0 ]; then
    /usr/sbin/userdel elastalert
fi
%systemd_postun_with_restart %{name}.service
