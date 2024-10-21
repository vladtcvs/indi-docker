How to build:

```
sh build.sh
```

Then unpack `rules.tar.bz2` into `/lib/udev/rules.d`
Then copy `indi.service` to `/etc/systemd/system`
Then `systemctl start indi`

For copying to another machine, copy `indi.tar.bz2` and other files to other machine and 
```
bunzip2 indi.tar.bz2
docker image load -i indi.tar
```
Then perform all other steps for `rules.tar.bz2` and `indi.service`
